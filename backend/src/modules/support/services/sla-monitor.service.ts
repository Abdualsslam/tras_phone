import { Injectable, Logger, Inject, forwardRef } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Cron, CronExpression } from '@nestjs/schedule';
import { Ticket, TicketDocument, TicketStatus } from '../schemas/ticket.schema';
import { SupportNotificationsService } from './support-notifications.service';
import { NotificationsService } from '@modules/notifications/notifications.service';

/**
 * ═══════════════════════════════════════════════════════════════
 * ⏰ SLA Monitor Service - مراقبة SLA والتذكيرات
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class SLAMonitorService {
    private readonly logger = new Logger(SLAMonitorService.name);

    constructor(
        @InjectModel(Ticket.name) private ticketModel: Model<TicketDocument>,
        @Inject(forwardRef(() => NotificationsService))
        private notificationsService: NotificationsService,
    ) { }

    /**
     * Check SLA status every 15 minutes
     */
    @Cron(CronExpression.EVERY_10_MINUTES)
    async checkSLAStatus() {
        this.logger.log('Running SLA check...');

        try {
            await Promise.all([
                this.checkFirstResponseSLA(),
                this.checkResolutionSLA(),
                this.checkUrgentTickets(),
                this.checkPendingTickets(),
            ]);

            this.logger.log('SLA check completed');
        } catch (error) {
            this.logger.error('SLA check failed:', error);
        }
    }

    /**
     * Check first response SLA
     */
    private async checkFirstResponseSLA() {
        const now = new Date();

        // Find tickets approaching first response deadline (80% of time elapsed)
        const tickets = await this.ticketModel
            .find({
                status: { $in: [TicketStatus.OPEN, TicketStatus.IN_PROGRESS] },
                'sla.firstResponseDue': { $exists: true },
                'sla.firstRespondedAt': { $exists: false },
                'sla.firstResponseBreached': false,
            })
            .populate('assignedTo', 'name')
            .populate('category', 'nameAr nameEn')
            .exec();

        for (const ticket of tickets) {
            if (!ticket.sla?.firstResponseDue) continue;

            const dueTime = ticket.sla.firstResponseDue.getTime();
            const createdTime = (ticket as any).createdAt.getTime();
            const totalTime = dueTime - createdTime;
            const elapsedTime = now.getTime() - createdTime;
            const percentElapsed = (elapsedTime / totalTime) * 100;

            // Alert at 80% threshold
            if (percentElapsed >= 80 && percentElapsed < 100) {
                await this.sendSLAWarning(ticket, 'first_response', percentElapsed);
            }
            // Alert when breached
            else if (now > ticket.sla.firstResponseDue) {
                await this.markFirstResponseBreached(ticket);
                await this.sendSLABreachAlert(ticket, 'first_response');
            }
        }
    }

    /**
     * Check resolution SLA
     */
    private async checkResolutionSLA() {
        const now = new Date();

        // Find tickets approaching resolution deadline
        const tickets = await this.ticketModel
            .find({
                status: { $nin: [TicketStatus.RESOLVED, TicketStatus.CLOSED] },
                'sla.resolutionDue': { $exists: true },
                'sla.resolvedAt': { $exists: false },
                'sla.resolutionBreached': false,
            })
            .populate('assignedTo', 'name')
            .populate('category', 'nameAr nameEn')
            .exec();

        for (const ticket of tickets) {
            if (!ticket.sla?.resolutionDue) continue;

            const dueTime = ticket.sla.resolutionDue.getTime();
            const createdTime = (ticket as any).createdAt.getTime();
            const totalTime = dueTime - createdTime;
            const elapsedTime = now.getTime() - createdTime;
            const percentElapsed = (elapsedTime / totalTime) * 100;

            // Alert at 80% threshold
            if (percentElapsed >= 80 && percentElapsed < 100) {
                await this.sendSLAWarning(ticket, 'resolution', percentElapsed);
            }
            // Alert when breached
            else if (now > ticket.sla.resolutionDue) {
                await this.markResolutionBreached(ticket);
                await this.sendSLABreachAlert(ticket, 'resolution');
            }
        }
    }

    /**
     * Check urgent tickets without assignment
     */
    private async checkUrgentTickets() {
        const tickets = await this.ticketModel
            .find({
                priority: 'urgent',
                assignedTo: { $exists: false },
                status: TicketStatus.OPEN,
            })
            .populate('category', 'nameAr nameEn')
            .exec();

        for (const ticket of tickets) {
            await this.sendUrgentTicketAlert(ticket);
        }
    }

    /**
     * Check pending tickets (no activity for 24 hours)
     */
    private async checkPendingTickets() {
        const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000); // 24 hours ago

        const tickets = await this.ticketModel
            .find({
                status: { $in: [TicketStatus.OPEN, TicketStatus.IN_PROGRESS] },
                lastAgentReplyAt: { $lt: cutoff },
                assignedTo: { $exists: true },
            })
            .populate('assignedTo', 'name')
            .populate('category', 'nameAr nameEn')
            .exec();

        for (const ticket of tickets) {
            await this.sendPendingTicketReminder(ticket);
        }
    }

    /**
     * Send SLA warning notification
     */
    private async sendSLAWarning(ticket: Ticket, type: 'first_response' | 'resolution', percentElapsed: number) {
        try {
            if (ticket.assignedTo) {
                await this.notificationsService.sendNotification({
                    recipientId: ticket.assignedTo.toString(),
                    recipientType: 'admin',
                    category: 'support',
                    priority: 'high',
                    title: `SLA Warning: ${type === 'first_response' ? 'First Response' : 'Resolution'}`,
                    titleAr: `تحذير SLA: ${type === 'first_response' ? 'الرد الأول' : 'الحل'}`,
                    body: `Ticket #${ticket.ticketNumber} is ${Math.round(percentElapsed)}% towards SLA deadline`,
                    bodyAr: `التذكرة #${ticket.ticketNumber} وصلت إلى ${Math.round(percentElapsed)}% من موعد SLA`,
                    actionType: 'ticket',
                    actionId: (ticket as any)._id.toString(),
                    channels: ['push'],
                });
            }
        } catch (error) {
            this.logger.error('Failed to send SLA warning:', error);
        }
    }

    /**
     * Send SLA breach alert
     */
    private async sendSLABreachAlert(ticket: Ticket, type: 'first_response' | 'resolution') {
        try {
            if (ticket.assignedTo) {
                await this.notificationsService.sendNotification({
                    recipientId: ticket.assignedTo.toString(),
                    recipientType: 'admin',
                    category: 'support',
                    priority: 'urgent',
                    title: `SLA BREACHED: ${type === 'first_response' ? 'First Response' : 'Resolution'}`,
                    titleAr: `تجاوز SLA: ${type === 'first_response' ? 'الرد الأول' : 'الحل'}`,
                    body: `Ticket #${ticket.ticketNumber} has breached SLA deadline!`,
                    bodyAr: `التذكرة #${ticket.ticketNumber} تجاوزت موعد SLA!`,
                    actionType: 'ticket',
                    actionId: (ticket as any)._id.toString(),
                    channels: ['push', 'email'],
                });
            }
        } catch (error) {
            this.logger.error('Failed to send SLA breach alert:', error);
        }
    }

    /**
     * Send urgent ticket alert
     */
    private async sendUrgentTicketAlert(ticket: Ticket) {
        try {
            // Notify all admins or supervisors
            // This is a simplified version - you might want to notify specific roles
            this.logger.warn(`Urgent ticket without assignment: ${ticket.ticketNumber}`);
        } catch (error) {
            this.logger.error('Failed to send urgent ticket alert:', error);
        }
    }

    /**
     * Send pending ticket reminder
     */
    private async sendPendingTicketReminder(ticket: Ticket) {
        try {
            if (ticket.assignedTo) {
                await this.notificationsService.sendNotification({
                    recipientId: ticket.assignedTo.toString(),
                    recipientType: 'admin',
                    category: 'support',
                    title: 'Pending Ticket Reminder',
                    titleAr: 'تذكير بتذكرة معلقة',
                    body: `Ticket #${ticket.ticketNumber} has no activity for 24 hours`,
                    bodyAr: `التذكرة #${ticket.ticketNumber} بدون نشاط منذ 24 ساعة`,
                    actionType: 'ticket',
                    actionId: (ticket as any)._id.toString(),
                    channels: ['push'],
                });
            }
        } catch (error) {
            this.logger.error('Failed to send pending ticket reminder:', error);
        }
    }

    /**
     * Mark first response as breached
     */
    private async markFirstResponseBreached(ticket: Ticket) {
        await this.ticketModel.findByIdAndUpdate((ticket as any)._id, {
            'sla.firstResponseBreached': true,
        });
    }

    /**
     * Mark resolution as breached
     */
    private async markResolutionBreached(ticket: Ticket) {
        await this.ticketModel.findByIdAndUpdate((ticket as any)._id, {
            'sla.resolutionBreached': true,
        });
    }
}
