import { Injectable, Inject, forwardRef } from '@nestjs/common';
import { NotificationsService } from '@modules/notifications/notifications.service';
import { Ticket } from '../schemas/ticket.schema';
import { ChatSession } from '../schemas/chat-session.schema';
import { TicketMessage } from '../schemas/ticket-message.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔔 Support Notifications Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class SupportNotificationsService {
    constructor(
        @Inject(forwardRef(() => NotificationsService))
        private notificationsService: NotificationsService,
    ) { }

    // ═══════════════════════════════════════════════════════════════
    // Ticket Notifications
    // ═══════════════════════════════════════════════════════════════

    /**
     * Send notification when a new ticket is created
     */
    async notifyTicketCreated(ticket: Ticket) {
        try {
            // Notify assigned agent if exists
            if (ticket.assignedTo) {
                await this.notificationsService.sendNotification({
                    recipientId: ticket.assignedTo.toString(),
                    recipientType: 'admin',
                    category: 'support',
                    title: 'New Support Ticket Assigned',
                    titleAr: 'تذكرة دعم جديدة',
                    body: `Ticket #${ticket.ticketNumber}: ${ticket.subject}`,
                    bodyAr: `تذكرة #${ticket.ticketNumber}: ${ticket.subject}`,
                    actionType: 'ticket',
                    actionId: ticket._id.toString(),
                    channels: ['push', 'email'],
                });
            }
        } catch (error) {
            console.error('Failed to send ticket created notification:', error);
        }
    }

    /**
     * Send notification when ticket status is updated
     */
    async notifyTicketStatusChanged(ticket: Ticket, oldStatus: string, newStatus: string) {
        try {
            // Notify customer
            if (ticket.customer?.customerId) {
                await this.notificationsService.sendNotification({
                    recipientId: ticket.customer.customerId.toString(),
                    recipientType: 'customer',
                    category: 'support',
                    title: 'Ticket Status Updated',
                    titleAr: 'تحديث حالة التذكرة',
                    body: `Your ticket #${ticket.ticketNumber} status changed to ${newStatus}`,
                    bodyAr: `تم تغيير حالة تذكرتك #${ticket.ticketNumber} إلى ${this.getStatusArabic(newStatus)}`,
                    actionType: 'ticket',
                    actionId: ticket._id.toString(),
                    channels: ['push', 'email'],
                });
            }
        } catch (error) {
            console.error('Failed to send ticket status notification:', error);
        }
    }

    /**
     * Send notification when ticket is assigned
     */
    async notifyTicketAssigned(ticket: Ticket) {
        try {
            // Notify new assigned agent
            if (ticket.assignedTo) {
                await this.notificationsService.sendNotification({
                    recipientId: ticket.assignedTo.toString(),
                    recipientType: 'admin',
                    category: 'support',
                    title: 'Ticket Assigned to You',
                    titleAr: 'تم تعيين تذكرة لك',
                    body: `Ticket #${ticket.ticketNumber}: ${ticket.subject}`,
                    bodyAr: `تذكرة #${ticket.ticketNumber}: ${ticket.subject}`,
                    actionType: 'ticket',
                    actionId: ticket._id.toString(),
                    channels: ['push', 'email'],
                });
            }
        } catch (error) {
            console.error('Failed to send ticket assigned notification:', error);
        }
    }

    /**
     * Send notification when a new message is added to ticket
     */
    async notifyTicketMessage(ticket: Ticket, message: TicketMessage, isFromCustomer: boolean) {
        try {
            if (isFromCustomer) {
                // Notify assigned agent
                if (ticket.assignedTo) {
                    await this.notificationsService.sendNotification({
                        recipientId: ticket.assignedTo.toString(),
                        recipientType: 'admin',
                        category: 'support',
                        title: 'New Message on Ticket',
                        titleAr: 'رسالة جديدة على التذكرة',
                        body: `${ticket.customer.name}: ${message.content.substring(0, 100)}`,
                        bodyAr: `${ticket.customer.name}: ${message.content.substring(0, 100)}`,
                        actionType: 'ticket',
                        actionId: ticket._id.toString(),
                        channels: ['push'],
                    });
                }
            } else {
                // Notify customer
                if (ticket.customer?.customerId) {
                    await this.notificationsService.sendNotification({
                        recipientId: ticket.customer.customerId.toString(),
                        recipientType: 'customer',
                        category: 'support',
                        title: 'New Reply on Your Ticket',
                        titleAr: 'رد جديد على تذكرتك',
                        body: `Ticket #${ticket.ticketNumber}: ${message.content.substring(0, 100)}`,
                        bodyAr: `تذكرة #${ticket.ticketNumber}: ${message.content.substring(0, 100)}`,
                        actionType: 'ticket',
                        actionId: ticket._id.toString(),
                        channels: ['push', 'email'],
                    });
                }
            }
        } catch (error) {
            console.error('Failed to send ticket message notification:', error);
        }
    }

    /**
     * Send notification when ticket is resolved
     */
    async notifyTicketResolved(ticket: Ticket) {
        try {
            // Notify customer
            if (ticket.customer?.customerId) {
                await this.notificationsService.sendNotification({
                    recipientId: ticket.customer.customerId.toString(),
                    recipientType: 'customer',
                    category: 'support',
                    title: 'Ticket Resolved',
                    titleAr: 'تم حل التذكرة',
                    body: `Your ticket #${ticket.ticketNumber} has been resolved. Please rate our service.`,
                    bodyAr: `تم حل تذكرتك #${ticket.ticketNumber}. يرجى تقييم خدمتنا.`,
                    actionType: 'ticket',
                    actionId: ticket._id.toString(),
                    channels: ['push', 'email'],
                });
            }
        } catch (error) {
            console.error('Failed to send ticket resolved notification:', error);
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Chat Notifications
    // ═══════════════════════════════════════════════════════════════

    /**
     * Send notification when chat session is accepted
     */
    async notifyChatSessionAccepted(session: ChatSession) {
        try {
            // Notify customer
            if (session.visitor?.customerId) {
                await this.notificationsService.sendNotification({
                    recipientId: session.visitor.customerId.toString(),
                    recipientType: 'customer',
                    category: 'support',
                    title: 'Agent Joined Chat',
                    titleAr: 'انضم وكيل إلى المحادثة',
                    body: 'A support agent has joined your chat session',
                    bodyAr: 'انضم وكيل دعم إلى محادثتك',
                    actionType: 'chat',
                    actionId: session._id.toString(),
                    channels: ['push'],
                });
            }
        } catch (error) {
            console.error('Failed to send chat accepted notification:', error);
        }
    }

    /**
     * Send notification when new chat message is received
     */
    async notifyChatMessage(session: ChatSession, message: any, isFromCustomer: boolean) {
        try {
            if (isFromCustomer) {
                // Notify assigned agent
                if (session.assignedAgent) {
                    await this.notificationsService.sendNotification({
                        recipientId: session.assignedAgent.toString(),
                        recipientType: 'admin',
                        category: 'support',
                        title: 'New Chat Message',
                        titleAr: 'رسالة محادثة جديدة',
                        body: `${session.visitor.name || 'Customer'}: ${message.content.substring(0, 100)}`,
                        bodyAr: `${session.visitor.name || 'عميل'}: ${message.content.substring(0, 100)}`,
                        actionType: 'chat',
                        actionId: session._id.toString(),
                        channels: ['push'],
                    });
                }
            } else {
                // Notify customer
                if (session.visitor?.customerId) {
                    await this.notificationsService.sendNotification({
                        recipientId: session.visitor.customerId.toString(),
                        recipientType: 'customer',
                        category: 'support',
                        title: 'New Message',
                        titleAr: 'رسالة جديدة',
                        body: message.content.substring(0, 100),
                        bodyAr: message.content.substring(0, 100),
                        actionType: 'chat',
                        actionId: session._id.toString(),
                        channels: ['push'],
                    });
                }
            }
        } catch (error) {
            console.error('Failed to send chat message notification:', error);
        }
    }

    /**
     * Send notification when chat session is waiting for agent
     */
    async notifyChatSessionWaiting(session: ChatSession) {
        try {
            // This could notify available agents or supervisors
            // Implementation depends on business logic
            console.log('Chat session waiting for agent:', session.sessionId);
        } catch (error) {
            console.error('Failed to send chat waiting notification:', error);
        }
    }

    // ═══════════════════════════════════════════════════════════════
    // Helper Methods
    // ═══════════════════════════════════════════════════════════════

    private getStatusArabic(status: string): string {
        const statusMap: Record<string, string> = {
            'open': 'مفتوحة',
            'awaiting_response': 'بانتظار الرد',
            'in_progress': 'قيد المعالجة',
            'on_hold': 'معلقة',
            'escalated': 'مُصعّدة',
            'resolved': 'تم الحل',
            'closed': 'مغلقة',
            'reopened': 'أعيد فتحها',
        };
        return statusMap[status] || status;
    }
}
