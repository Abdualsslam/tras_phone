import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    OnGatewayInit,
    ConnectedSocket,
    MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, Inject, forwardRef } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Customer } from '@modules/customers/schemas/customer.schema';
import { TicketsService } from '../tickets.service';
import { MessageSenderType } from '../schemas/ticket-message.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔌 Support Gateway - WebSocket للتذاكر والمحادثات
 * ═══════════════════════════════════════════════════════════════
 */
@WebSocketGateway({
    namespace: 'support',
    cors: {
        origin: '*',
        credentials: true,
    },
})
export class SupportGateway implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private readonly logger = new Logger(SupportGateway.name);
    private connectedUsers = new Map<string, Socket>();

    constructor(
        private jwtService: JwtService,
        private configService: ConfigService,
        @InjectModel(Customer.name) private customerModel: Model<Customer>,
        @Inject(forwardRef(() => TicketsService)) private ticketsService: TicketsService,
    ) { }

    afterInit(server: Server) {
        this.logger.log('Support WebSocket Gateway initialized');
    }

    async handleConnection(client: Socket) {
        try {
            // Extract token from handshake
            const token = client.handshake.auth.token || client.handshake.headers.authorization?.split(' ')[1];

            if (!token) {
                this.logger.warn(`Client ${client.id} connection rejected: No token provided`);
                client.disconnect();
                return;
            }

            // Verify JWT token
            const payload = await this.jwtService.verifyAsync(token, {
                secret: this.configService.get<string>('JWT_SECRET'),
            });

            client.data.user = payload;
            let userId = payload.customerId || payload.adminId;
            let userType = payload.customerId ? 'customer' : 'admin';

            // Resolve customerId for mobile (JWT has sub=User id)
            if (!userId && payload.sub) {
                const customer = await this.customerModel
                    .findOne({ userId: new Types.ObjectId(payload.sub) })
                    .select('_id')
                    .lean();
                if (customer) {
                    userId = (customer as any)._id.toString();
                    userType = 'customer';
                } else {
                    userId = payload.sub;
                }
            }

            client.data.userId = userId;
            client.data.userType = userType;

            this.connectedUsers.set(userId, client);
            client.join(`user:${userId}`);

            this.logger.log(`Client connected: ${client.id} (User: ${userId}, Type: ${userType})`);

            client.emit('connected', { userId, userType });
        } catch (error: any) {
            this.logger.error(`Connection error for client ${client.id}:`, error?.message);
            client.disconnect();
        }
    }

    handleDisconnect(client: Socket) {
        if (client.data.userId) {
            this.connectedUsers.delete(client.data.userId);
            this.logger.log(`Client disconnected: ${client.id} (User: ${client.data.userId})`);
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Ticket Events
    // ═══════════════════════════════════════════════════════════════

    /**
     * Join ticket room
     */
    @SubscribeMessage('ticket:join')
    handleJoinTicket(@ConnectedSocket() client: Socket, @MessageBody() data: { ticketId: string }) {
        client.join(`ticket:${data.ticketId}`);
        this.logger.log(`Client ${client.id} joined ticket room: ${data.ticketId}`);
        return { success: true, ticketId: data.ticketId };
    }

    /**
     * Leave ticket room
     */
    @SubscribeMessage('ticket:leave')
    handleLeaveTicket(@ConnectedSocket() client: Socket, @MessageBody() data: { ticketId: string }) {
        client.leave(`ticket:${data.ticketId}`);
        this.logger.log(`Client ${client.id} left ticket room: ${data.ticketId}`);
        return { success: true, ticketId: data.ticketId };
    }

    /**
     * Send message to ticket (customer) - via WebSocket instead of REST POST
     */
    @SubscribeMessage('ticket:message:send')
    async handleTicketMessageSend(
        @ConnectedSocket() client: Socket,
        @MessageBody() data: { ticketId: string; content: string; attachments?: string[] },
    ) {
        try {
            const userId = client.data.userId;
            const userType = client.data.userType;

            if (userType !== 'customer') {
                return { success: false, error: 'Only customers can send ticket messages via socket' };
            }

            // Verify ticket ownership
            const ticket = await this.ticketsService.findTicketById(data.ticketId);
            if (!ticket || ticket.customer?.customerId?.toString() !== userId) {
                return { success: false, error: 'Ticket not found' };
            }

            // Get customer name
            const customer = await this.customerModel
                .findById(userId)
                .select('name')
                .lean();
            const senderName = (customer as any)?.name || 'Customer';

            const message = await this.ticketsService.addMessage(data.ticketId, {
                senderType: MessageSenderType.CUSTOMER,
                senderId: userId,
                senderName,
                content: data.content,
                attachments: data.attachments,
            });

            this.logger.log(`Ticket message sent via socket: ${data.ticketId}`);
            return { success: true, message: message.toObject ? message.toObject() : message };
        } catch (error: any) {
            this.logger.error(`ticket:message:send error: ${error?.message}`);
            return { success: false, error: error?.message || 'Failed to send message' };
        }
    }

    /**
     * Emit ticket created event
     */
    emitTicketCreated(ticket: any) {
        // Notify assigned agent if exists
        if (ticket.assignedTo) {
            this.server.to(`user:${ticket.assignedTo}`).emit('ticket:created', ticket);
        }

        // Notify all admins
        this.server.emit('ticket:created:admin', ticket);

        this.logger.log(`Ticket created event emitted: ${ticket._id}`);
    }

    /**
     * Emit ticket updated event
     */
    emitTicketUpdated(ticket: any) {
        // Notify ticket room
        this.server.to(`ticket:${ticket._id}`).emit('ticket:updated', ticket);

        // Notify customer
        if (ticket.customer?.customerId) {
            this.server.to(`user:${ticket.customer.customerId}`).emit('ticket:updated', ticket);
        }

        // Notify assigned agent
        if (ticket.assignedTo) {
            this.server.to(`user:${ticket.assignedTo}`).emit('ticket:updated', ticket);
        }

        this.logger.log(`Ticket updated event emitted: ${ticket._id}`);
    }

    /**
     * Emit ticket message event
     */
    emitTicketMessage(ticketId: string, message: any) {
        // Notify ticket room
        this.server.to(`ticket:${ticketId}`).emit('ticket:message', message);

        this.logger.log(`Ticket message event emitted: ${ticketId}`);
    }

    /**
     * Emit ticket assigned event
     */
    emitTicketAssigned(ticket: any) {
        // Notify new assigned agent
        if (ticket.assignedTo) {
            this.server.to(`user:${ticket.assignedTo}`).emit('ticket:assigned', ticket);
        }

        // Notify ticket room
        this.server.to(`ticket:${ticket._id}`).emit('ticket:assigned', ticket);

        this.logger.log(`Ticket assigned event emitted: ${ticket._id}`);
    }

    // ═══════════════════════════════════════════════════════════════
    // Chat Events
    // ═══════════════════════════════════════════════════════════════

    /**
     * Join chat session room
     */
    @SubscribeMessage('chat:join')
    handleJoinChat(@ConnectedSocket() client: Socket, @MessageBody() data: { sessionId: string }) {
        client.join(`chat:${data.sessionId}`);
        this.logger.log(`Client ${client.id} joined chat room: ${data.sessionId}`);
        return { success: true, sessionId: data.sessionId };
    }

    /**
     * Leave chat session room
     */
    @SubscribeMessage('chat:leave')
    handleLeaveChat(@ConnectedSocket() client: Socket, @MessageBody() data: { sessionId: string }) {
        client.leave(`chat:${data.sessionId}`);
        this.logger.log(`Client ${client.id} left chat room: ${data.sessionId}`);
        return { success: true, sessionId: data.sessionId };
    }

    /**
     * Typing indicator - start
     */
    @SubscribeMessage('typing:start')
    handleTypingStart(@ConnectedSocket() client: Socket, @MessageBody() data: { sessionId: string }) {
        client.to(`chat:${data.sessionId}`).emit('typing:start', {
            userId: client.data.userId,
            userType: client.data.userType,
        });
    }

    /**
     * Typing indicator - stop
     */
    @SubscribeMessage('typing:stop')
    handleTypingStop(@ConnectedSocket() client: Socket, @MessageBody() data: { sessionId: string }) {
        client.to(`chat:${data.sessionId}`).emit('typing:stop', {
            userId: client.data.userId,
            userType: client.data.userType,
        });
    }

    /**
     * Emit chat message event
     */
    emitChatMessage(sessionId: string, message: any) {
        // Notify chat room
        this.server.to(`chat:${sessionId}`).emit('chat:message', message);

        this.logger.log(`Chat message event emitted: ${sessionId}`);
    }

    /**
     * Emit chat session updated event
     */
    emitChatSessionUpdated(session: any) {
        // Notify chat room
        this.server.to(`chat:${session._id}`).emit('chat:session:updated', session);

        // Notify customer
        if (session.visitor?.customerId) {
            this.server.to(`user:${session.visitor.customerId}`).emit('chat:session:updated', session);
        }

        // Notify assigned agent
        if (session.assignedAgent) {
            this.server.to(`user:${session.assignedAgent}`).emit('chat:session:updated', session);
        }

        this.logger.log(`Chat session updated event emitted: ${session._id}`);
    }

    /**
     * Emit new chat session waiting event (for admins)
     */
    emitChatSessionWaiting(session: any) {
        // Notify all admins
        this.server.emit('chat:session:waiting', session);

        this.logger.log(`Chat session waiting event emitted: ${session._id}`);
    }

    /**
     * Emit chat session accepted event
     */
    emitChatSessionAccepted(session: any) {
        // Notify customer
        if (session.visitor?.customerId) {
            this.server.to(`user:${session.visitor.customerId}`).emit('chat:session:accepted', session);
        }

        // Notify chat room
        this.server.to(`chat:${session._id}`).emit('chat:session:accepted', session);

        this.logger.log(`Chat session accepted event emitted: ${session._id}`);
    }

    // ═══════════════════════════════════════════════════════════════
    // Utility Methods
    // ═══════════════════════════════════════════════════════════════

    /**
     * Check if user is connected
     */
    isUserConnected(userId: string): boolean {
        return this.connectedUsers.has(userId);
    }

    /**
     * Get connected users count
     */
    getConnectedUsersCount(): number {
        return this.connectedUsers.size;
    }
}
