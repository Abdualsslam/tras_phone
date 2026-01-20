import { useEffect, useCallback } from 'react';
import { socketService } from '@/services/socket.service';
import { useAuth } from '@/contexts/AuthContext';

/**
 * Hook to use WebSocket in components
 */
export function useSocket() {
    const { user, token } = useAuth();

    useEffect(() => {
        if (token && user) {
            socketService.connect(token);
        }

        return () => {
            // Don't disconnect on unmount, only on logout
        };
    }, [token, user]);

    const joinTicket = useCallback((ticketId: string) => {
        socketService.joinTicket(ticketId);
    }, []);

    const leaveTicket = useCallback((ticketId: string) => {
        socketService.leaveTicket(ticketId);
    }, []);

    const joinChat = useCallback((sessionId: string) => {
        socketService.joinChat(sessionId);
    }, []);

    const leaveChat = useCallback((sessionId: string) => {
        socketService.leaveChat(sessionId);
    }, []);

    const sendTyping = useCallback((sessionId: string, isTyping: boolean) => {
        socketService.sendTyping(sessionId, isTyping);
    }, []);

    const on = useCallback((event: string, callback: Function) => {
        return socketService.on(event, callback);
    }, []);

    return {
        joinTicket,
        leaveTicket,
        joinChat,
        leaveChat,
        sendTyping,
        on,
        isConnected: socketService.isConnected(),
    };
}
