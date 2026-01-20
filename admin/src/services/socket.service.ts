import { io, Socket } from 'socket.io-client';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔌 WebSocket Service for Admin Panel
 * ═══════════════════════════════════════════════════════════════
 */
class SocketService {
    private socket: Socket | null = null;
    private listeners: Map<string, Set<Function>> = new Map();

    /**
     * Connect to WebSocket server
     */
    connect(token: string) {
        if (this.socket?.connected) {
            return;
        }

        const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:3000';
        const wsUrl = baseUrl.replace('/api/v1', '');

        this.socket = io(`${wsUrl}/support`, {
            auth: { token },
            transports: ['websocket', 'polling'],
            reconnection: true,
            reconnectionDelay: 1000,
            reconnectionAttempts: 5,
        });

        this.socket.on('connect', () => {
            console.log('WebSocket connected');
        });

        this.socket.on('disconnect', () => {
            console.log('WebSocket disconnected');
        });

        this.socket.on('error', (error: any) => {
            console.error('WebSocket error:', error);
        });

        // Setup event listeners
        this.setupEventListeners();
    }

    /**
     * Disconnect from WebSocket server
     */
    disconnect() {
        if (this.socket) {
            this.socket.disconnect();
            this.socket = null;
            this.listeners.clear();
        }
    }

    /**
     * Setup event listeners
     */
    private setupEventListeners() {
        if (!this.socket) return;

        // Ticket events
        this.socket.on('ticket:created', (data) => this.emit('ticket:created', data));
        this.socket.on('ticket:created:admin', (data) => this.emit('ticket:created:admin', data));
        this.socket.on('ticket:updated', (data) => this.emit('ticket:updated', data));
        this.socket.on('ticket:message', (data) => this.emit('ticket:message', data));
        this.socket.on('ticket:assigned', (data) => this.emit('ticket:assigned', data));

        // Chat events
        this.socket.on('chat:message', (data) => this.emit('chat:message', data));
        this.socket.on('chat:session:updated', (data) => this.emit('chat:session:updated', data));
        this.socket.on('chat:session:waiting', (data) => this.emit('chat:session:waiting', data));
        this.socket.on('chat:session:accepted', (data) => this.emit('chat:session:accepted', data));
        this.socket.on('typing:start', (data) => this.emit('typing:start', data));
        this.socket.on('typing:stop', (data) => this.emit('typing:stop', data));
    }

    /**
     * Join ticket room
     */
    joinTicket(ticketId: string) {
        this.socket?.emit('ticket:join', { ticketId });
    }

    /**
     * Leave ticket room
     */
    leaveTicket(ticketId: string) {
        this.socket?.emit('ticket:leave', { ticketId });
    }

    /**
     * Join chat room
     */
    joinChat(sessionId: string) {
        this.socket?.emit('chat:join', { sessionId });
    }

    /**
     * Leave chat room
     */
    leaveChat(sessionId: string) {
        this.socket?.emit('chat:leave', { sessionId });
    }

    /**
     * Send typing indicator
     */
    sendTyping(sessionId: string, isTyping: boolean) {
        const event = isTyping ? 'typing:start' : 'typing:stop';
        this.socket?.emit(event, { sessionId });
    }

    /**
     * Subscribe to event
     */
    on(event: string, callback: Function) {
        if (!this.listeners.has(event)) {
            this.listeners.set(event, new Set());
        }
        this.listeners.get(event)!.add(callback);

        // Return unsubscribe function
        return () => {
            const callbacks = this.listeners.get(event);
            if (callbacks) {
                callbacks.delete(callback);
            }
        };
    }

    /**
     * Emit event to listeners
     */
    private emit(event: string, data: any) {
        const callbacks = this.listeners.get(event);
        if (callbacks) {
            callbacks.forEach((callback) => callback(data));
        }
    }

    /**
     * Check if connected
     */
    isConnected(): boolean {
        return this.socket?.connected || false;
    }
}

export const socketService = new SocketService();
