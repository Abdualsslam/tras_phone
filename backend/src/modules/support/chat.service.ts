import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ChatSession, ChatSessionDocument, ChatSessionStatus } from './schemas/chat-session.schema';
import { ChatMessage, ChatMessageDocument, ChatSenderType, ChatMessageType } from './schemas/chat-message.schema';

@Injectable()
export class ChatService {
    constructor(
        @InjectModel(ChatSession.name) private sessionModel: Model<ChatSessionDocument>,
        @InjectModel(ChatMessage.name) private messageModel: Model<ChatMessageDocument>,
    ) { }

    // ==================== Sessions ====================

    async createSession(data: {
        visitor: {
            customerId?: string;
            name?: string;
            email?: string;
            phone?: string;
            ipAddress?: string;
            userAgent?: string;
            currentPage?: string;
        };
        department?: string;
        categoryId?: string;
        initialMessage?: string;
    }): Promise<ChatSession> {
        const sessionId = await this.generateSessionId();

        // Calculate queue position
        const waitingCount = await this.sessionModel.countDocuments({
            status: ChatSessionStatus.WAITING,
            department: data.department,
        });

        const session = await this.sessionModel.create({
            sessionId,
            visitor: {
                customerId: data.visitor.customerId ? new Types.ObjectId(data.visitor.customerId) : undefined,
                name: data.visitor.name,
                email: data.visitor.email,
                phone: data.visitor.phone,
                ipAddress: data.visitor.ipAddress,
                userAgent: data.visitor.userAgent,
                currentPage: data.visitor.currentPage,
                visitedPages: data.visitor.currentPage ? [data.visitor.currentPage] : [],
            },
            department: data.department,
            category: data.categoryId ? new Types.ObjectId(data.categoryId) : undefined,
            initialMessage: data.initialMessage,
            queuePosition: waitingCount + 1,
            lastActivityAt: new Date(),
        });

        // Add initial message if provided
        if (data.initialMessage) {
            await this.addMessage(session._id.toString(), {
                senderType: ChatSenderType.VISITOR,
                senderId: data.visitor.customerId,
                senderName: data.visitor.name || 'Visitor',
                content: data.initialMessage,
            });
        }

        // Add welcome message from bot
        await this.addMessage(session._id.toString(), {
            senderType: ChatSenderType.BOT,
            senderName: 'Assistant',
            messageType: ChatMessageType.BOT,
            content: 'مرحباً بك! سيتم توصيلك بأحد ممثلي خدمة العملاء قريباً. / Welcome! You will be connected to a customer service representative shortly.',
        });

        return session;
    }

    async findSessionById(id: string): Promise<ChatSession> {
        const session = await this.sessionModel
            .findById(id)
            .populate('assignedAgent', 'name')
            .populate('category', 'nameAr nameEn')
            .exec();
        if (!session) throw new NotFoundException('Chat session not found');
        return session;
    }

    async findActiveSession(customerId: string): Promise<ChatSession | null> {
        return this.sessionModel.findOne({
            'visitor.customerId': new Types.ObjectId(customerId),
            status: { $in: [ChatSessionStatus.WAITING, ChatSessionStatus.ACTIVE] },
        }).exec();
    }

    async findWaitingSessions(department?: string): Promise<ChatSession[]> {
        const query: any = { status: ChatSessionStatus.WAITING };
        if (department) query.department = department;

        return this.sessionModel
            .find(query)
            .sort({ createdAt: 1 })
            .populate('category', 'nameAr nameEn')
            .exec();
    }

    async findAgentSessions(agentId: string): Promise<ChatSession[]> {
        return this.sessionModel
            .find({
                assignedAgent: new Types.ObjectId(agentId),
                status: { $in: [ChatSessionStatus.ACTIVE, ChatSessionStatus.ON_HOLD] },
            })
            .sort({ lastActivityAt: -1 })
            .exec();
    }

    async acceptSession(sessionId: string, agentId: string): Promise<ChatSession> {
        const session = await this.sessionModel.findById(sessionId);
        if (!session) throw new NotFoundException('Chat session not found');

        if (session.status !== ChatSessionStatus.WAITING) {
            throw new BadRequestException('Session is not waiting to be accepted');
        }

        const now = new Date();
        const waitTime = Math.round((now.getTime() - session.createdAt.getTime()) / 1000);

        const updatedSession = await this.sessionModel.findByIdAndUpdate(
            sessionId,
            {
                status: ChatSessionStatus.ACTIVE,
                assignedAgent: new Types.ObjectId(agentId),
                assignedAt: now,
                startedAt: now,
                lastActivityAt: now,
                queuePosition: 0,
                'metrics.waitTime': waitTime,
            },
            { new: true }
        ).populate('assignedAgent', 'name');

        // Update queue positions for remaining waiting sessions
        await this.updateQueuePositions(session.department);

        // Add system message
        await this.addMessage(sessionId, {
            senderType: ChatSenderType.SYSTEM,
            senderName: 'System',
            messageType: ChatMessageType.SYSTEM,
            content: `انضم ${(updatedSession?.assignedAgent as any)?.name || 'Agent'} إلى المحادثة / ${(updatedSession?.assignedAgent as any)?.name || 'Agent'} joined the chat`,
        });

        return updatedSession!;
    }

    async transferSession(sessionId: string, fromAgentId: string, toAgentId: string, reason: string): Promise<ChatSession> {
        const session = await this.sessionModel.findById(sessionId);
        if (!session) throw new NotFoundException('Chat session not found');

        if (session.assignedAgent?.toString() !== fromAgentId) {
            throw new BadRequestException('Session is not assigned to this agent');
        }

        const updatedSession = await this.sessionModel.findByIdAndUpdate(
            sessionId,
            {
                assignedAgent: new Types.ObjectId(toAgentId),
                assignedAt: new Date(),
                lastActivityAt: new Date(),
                $push: {
                    transfers: {
                        fromAgent: new Types.ObjectId(fromAgentId),
                        toAgent: new Types.ObjectId(toAgentId),
                        reason,
                        transferredAt: new Date(),
                    },
                },
            },
            { new: true }
        ).populate('assignedAgent', 'name');

        // Add system message
        await this.addMessage(sessionId, {
            senderType: ChatSenderType.SYSTEM,
            senderName: 'System',
            messageType: ChatMessageType.SYSTEM,
            content: `تم تحويل المحادثة: ${reason} / Chat transferred: ${reason}`,
        });

        return updatedSession!;
    }

    async endSession(sessionId: string, endedBy?: string): Promise<ChatSession> {
        const session = await this.sessionModel.findById(sessionId);
        if (!session) throw new NotFoundException('Chat session not found');

        const now = new Date();
        const duration = session.startedAt ? Math.round((now.getTime() - session.startedAt.getTime()) / 1000) : 0;

        const updatedSession = await this.sessionModel.findByIdAndUpdate(
            sessionId,
            {
                status: ChatSessionStatus.ENDED,
                endedAt: now,
                lastActivityAt: now,
                'metrics.chatDuration': duration,
            },
            { new: true }
        );

        // Add system message
        await this.addMessage(sessionId, {
            senderType: ChatSenderType.SYSTEM,
            senderName: 'System',
            messageType: ChatMessageType.SYSTEM,
            content: 'تم إنهاء المحادثة / Chat session ended',
        });

        return updatedSession!;
    }

    async rateSession(sessionId: string, rating: number, feedback?: string): Promise<ChatSession> {
        const session = await this.sessionModel.findById(sessionId);
        if (!session) throw new NotFoundException('Chat session not found');

        if (session.status !== ChatSessionStatus.ENDED) {
            throw new BadRequestException('Can only rate ended sessions');
        }

        const updatedSession = await this.sessionModel.findByIdAndUpdate(
            sessionId,
            {
                rating,
                ratingFeedback: feedback,
            },
            { new: true }
        );
        return updatedSession!;
    }

    async updateVisitorPage(sessionId: string, currentPage: string): Promise<void> {
        await this.sessionModel.findByIdAndUpdate(sessionId, {
            'visitor.currentPage': currentPage,
            $push: { 'visitor.visitedPages': currentPage },
            lastActivityAt: new Date(),
        });
    }

    // ==================== Messages ====================

    async addMessage(sessionId: string, data: {
        senderType: ChatSenderType;
        senderId?: string;
        senderName?: string;
        content: string;
        messageType?: ChatMessageType;
        fileUrl?: string;
        fileName?: string;
        fileSize?: number;
        mimeType?: string;
        quickReplies?: Array<{ label: string; value: string }>;
        isInternal?: boolean;
    }): Promise<ChatMessage> {
        const session = await this.sessionModel.findById(sessionId);
        if (!session) throw new NotFoundException('Chat session not found');

        const message = await this.messageModel.create({
            session: new Types.ObjectId(sessionId),
            senderType: data.senderType,
            senderId: data.senderId ? new Types.ObjectId(data.senderId) : undefined,
            senderModel: data.senderType === ChatSenderType.VISITOR ? 'Customer' : 'Admin',
            senderName: data.senderName,
            messageType: data.messageType || ChatMessageType.TEXT,
            content: data.content,
            fileUrl: data.fileUrl,
            fileName: data.fileName,
            fileSize: data.fileSize,
            mimeType: data.mimeType,
            quickReplies: data.quickReplies,
            isInternal: data.isInternal || false,
        });

        // Update session metrics
        const metricsUpdate: any = {
            $inc: { 'metrics.messageCount': 1 },
            lastActivityAt: new Date(),
        };

        if (data.senderType === ChatSenderType.VISITOR) {
            metricsUpdate.$inc['metrics.visitorMessageCount'] = 1;
        } else if (data.senderType === ChatSenderType.AGENT && !data.isInternal) {
            metricsUpdate.$inc['metrics.agentMessageCount'] = 1;
        }

        await this.sessionModel.findByIdAndUpdate(sessionId, metricsUpdate);

        return message;
    }

    async getSessionMessages(sessionId: string, includeInternal: boolean = false): Promise<ChatMessage[]> {
        const query: any = { session: new Types.ObjectId(sessionId) };
        if (!includeInternal) {
            query.isInternal = { $ne: true };
        }
        return this.messageModel.find(query).sort({ createdAt: 1 }).exec();
    }

    async markMessagesAsRead(sessionId: string, readerType: 'visitor' | 'agent'): Promise<void> {
        const senderTypesToMark = readerType === 'visitor'
            ? [ChatSenderType.AGENT, ChatSenderType.BOT, ChatSenderType.SYSTEM]
            : [ChatSenderType.VISITOR];

        await this.messageModel.updateMany(
            {
                session: new Types.ObjectId(sessionId),
                senderType: { $in: senderTypesToMark },
                isRead: false,
            },
            {
                isRead: true,
                readAt: new Date(),
            }
        );
    }

    // ==================== Statistics ====================

    async getChatStats(): Promise<any> {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const [
            activeChats,
            waitingChats,
            todayChats,
            avgWaitTime,
            avgDuration,
            avgRating,
        ] = await Promise.all([
            this.sessionModel.countDocuments({ status: ChatSessionStatus.ACTIVE }),
            this.sessionModel.countDocuments({ status: ChatSessionStatus.WAITING }),
            this.sessionModel.countDocuments({ createdAt: { $gte: today } }),
            this.sessionModel.aggregate([
                { $match: { 'metrics.waitTime': { $exists: true, $gt: 0 } } },
                { $group: { _id: null, avg: { $avg: '$metrics.waitTime' } } },
            ]),
            this.sessionModel.aggregate([
                { $match: { 'metrics.chatDuration': { $exists: true, $gt: 0 } } },
                { $group: { _id: null, avg: { $avg: '$metrics.chatDuration' } } },
            ]),
            this.sessionModel.aggregate([
                { $match: { rating: { $exists: true } } },
                { $group: { _id: null, avg: { $avg: '$rating' } } },
            ]),
        ]);

        return {
            activeChats,
            waitingChats,
            todayChats,
            avgWaitTimeSeconds: Math.round(avgWaitTime[0]?.avg || 0),
            avgDurationSeconds: Math.round(avgDuration[0]?.avg || 0),
            avgRating: avgRating[0]?.avg ? parseFloat(avgRating[0].avg.toFixed(1)) : null,
        };
    }

    async getAgentChatStats(agentId: string): Promise<any> {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const [activeChats, todayChats, avgRating] = await Promise.all([
            this.sessionModel.countDocuments({
                assignedAgent: new Types.ObjectId(agentId),
                status: ChatSessionStatus.ACTIVE,
            }),
            this.sessionModel.countDocuments({
                assignedAgent: new Types.ObjectId(agentId),
                createdAt: { $gte: today },
            }),
            this.sessionModel.aggregate([
                {
                    $match: {
                        assignedAgent: new Types.ObjectId(agentId),
                        rating: { $exists: true }
                    }
                },
                { $group: { _id: null, avg: { $avg: '$rating' } } },
            ]),
        ]);

        return {
            activeChats,
            todayChats,
            avgRating: avgRating[0]?.avg ? parseFloat(avgRating[0].avg.toFixed(1)) : null,
        };
    }

    // ==================== Helpers ====================

    private async generateSessionId(): Promise<string> {
        const year = new Date().getFullYear();
        const count = await this.sessionModel.countDocuments({
            createdAt: { $gte: new Date(`${year}-01-01`) },
        });
        return `CHAT-${year}-${String(count + 1).padStart(6, '0')}`;
    }

    private async updateQueuePositions(department?: string): Promise<void> {
        const waitingSessions = await this.sessionModel
            .find({ status: ChatSessionStatus.WAITING, department })
            .sort({ createdAt: 1 });

        for (let i = 0; i < waitingSessions.length; i++) {
            await this.sessionModel.findByIdAndUpdate(waitingSessions[i]._id, {
                queuePosition: i + 1,
            });
        }
    }

    // ==================== Cleanup ====================

    async markAbandonedSessions(timeoutMinutes: number = 30): Promise<number> {
        const cutoff = new Date(Date.now() - timeoutMinutes * 60 * 1000);

        const result = await this.sessionModel.updateMany(
            {
                status: { $in: [ChatSessionStatus.WAITING, ChatSessionStatus.ACTIVE] },
                lastActivityAt: { $lt: cutoff },
            },
            {
                status: ChatSessionStatus.ABANDONED,
                endedAt: new Date(),
            }
        );

        return result.modifiedCount;
    }
}
