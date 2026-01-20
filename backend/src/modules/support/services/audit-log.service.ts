import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { SupportAudit, SupportAuditDocument, AuditAction } from '../schemas/support-audit.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📝 Audit Log Service - خدمة السجلات
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class AuditLogService {
    constructor(
        @InjectModel(SupportAudit.name) private auditModel: Model<SupportAuditDocument>,
    ) { }

    /**
     * Log an action
     */
    async log(data: {
        action: AuditAction;
        entityType: string;
        entityId: string;
        entityName?: string;
        actorId?: string;
        actorModel?: 'Customer' | 'Admin' | 'System';
        actorName?: string;
        oldValues?: Record<string, any>;
        newValues?: Record<string, any>;
        metadata?: Record<string, any>;
        ipAddress?: string;
        userAgent?: string;
    }): Promise<SupportAudit> {
        return this.auditModel.create({
            action: data.action,
            entityType: data.entityType,
            entityId: new Types.ObjectId(data.entityId),
            entityName: data.entityName,
            actorId: data.actorId ? new Types.ObjectId(data.actorId) : undefined,
            actorModel: data.actorModel,
            actorName: data.actorName,
            oldValues: data.oldValues,
            newValues: data.newValues,
            metadata: data.metadata,
            ipAddress: data.ipAddress,
            userAgent: data.userAgent,
        });
    }

    /**
     * Get audit logs for an entity
     */
    async getEntityLogs(entityType: string, entityId: string, limit: number = 50): Promise<SupportAudit[]> {
        return this.auditModel
            .find({
                entityType,
                entityId: new Types.ObjectId(entityId),
            })
            .sort({ createdAt: -1 })
            .limit(limit)
            .exec();
    }

    /**
     * Get audit logs for an actor
     */
    async getActorLogs(actorId: string, limit: number = 50): Promise<SupportAudit[]> {
        return this.auditModel
            .find({
                actorId: new Types.ObjectId(actorId),
            })
            .sort({ createdAt: -1 })
            .limit(limit)
            .exec();
    }

    /**
     * Get audit logs by action
     */
    async getLogsByAction(action: AuditAction, limit: number = 50): Promise<SupportAudit[]> {
        return this.auditModel
            .find({ action })
            .sort({ createdAt: -1 })
            .limit(limit)
            .exec();
    }

    /**
     * Get audit logs by date range
     */
    async getLogsByDateRange(startDate: Date, endDate: Date, filters?: {
        entityType?: string;
        action?: AuditAction;
        actorId?: string;
    }): Promise<SupportAudit[]> {
        const query: any = {
            createdAt: { $gte: startDate, $lte: endDate },
        };

        if (filters?.entityType) query.entityType = filters.entityType;
        if (filters?.action) query.action = filters.action;
        if (filters?.actorId) query.actorId = new Types.ObjectId(filters.actorId);

        return this.auditModel
            .find(query)
            .sort({ createdAt: -1 })
            .exec();
    }
}
