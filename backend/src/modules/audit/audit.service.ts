import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { AuditLog, AuditLogDocument, AuditAction, AuditResource } from './schemas/audit-log.schema';
import { AdminActivity, AdminActivityDocument } from './schemas/admin-activity.schema';
import { LoginHistory, LoginHistoryDocument, LoginStatus, LoginMethod } from './schemas/login-history.schema';

@Injectable()
export class AuditService {
    constructor(
        @InjectModel(AuditLog.name) private auditLogModel: Model<AuditLogDocument>,
        @InjectModel(AdminActivity.name) private adminActivityModel: Model<AdminActivityDocument>,
        @InjectModel(LoginHistory.name) private loginHistoryModel: Model<LoginHistoryDocument>,
    ) { }

    // ==================== Audit Logs ====================

    async log(data: {
        action: AuditAction;
        resource: AuditResource;
        resourceId?: string;
        resourceName?: string;
        actorType: 'admin' | 'customer' | 'system' | 'api';
        actorId?: string;
        actorName?: string;
        actorEmail?: string;
        description: string;
        descriptionAr?: string;
        changes?: {
            before?: Record<string, any>;
            after?: Record<string, any>;
            changedFields?: string[];
        };
        context?: {
            ipAddress?: string;
            userAgent?: string;
            requestId?: string;
            endpoint?: string;
            method?: string;
        };
        success?: boolean;
        errorMessage?: string;
        severity?: 'info' | 'warning' | 'critical';
        tags?: string[];
    }): Promise<AuditLog> {
        // Calculate changed fields if not provided
        if (data.changes?.before && data.changes?.after && !data.changes.changedFields) {
            data.changes.changedFields = this.getChangedFields(data.changes.before, data.changes.after);
        }

        return this.auditLogModel.create({
            ...data,
            resourceId: data.resourceId ? new Types.ObjectId(data.resourceId) : undefined,
            actorId: data.actorId ? new Types.ObjectId(data.actorId) : undefined,
            success: data.success ?? true,
            severity: data.severity || 'info',
        });
    }

    async findAuditLogs(filters: {
        action?: AuditAction;
        resource?: AuditResource;
        resourceId?: string;
        actorType?: string;
        actorId?: string;
        severity?: string;
        startDate?: Date;
        endDate?: Date;
        search?: string;
        page?: number;
        limit?: number;
    }): Promise<{ logs: AuditLog[]; total: number }> {
        const query: any = {};

        if (filters.action) query.action = filters.action;
        if (filters.resource) query.resource = filters.resource;
        if (filters.resourceId) query.resourceId = new Types.ObjectId(filters.resourceId);
        if (filters.actorType) query.actorType = filters.actorType;
        if (filters.actorId) query.actorId = new Types.ObjectId(filters.actorId);
        if (filters.severity) query.severity = filters.severity;
        if (filters.search) {
            query.$or = [
                { description: { $regex: filters.search, $options: 'i' } },
                { resourceName: { $regex: filters.search, $options: 'i' } },
                { actorName: { $regex: filters.search, $options: 'i' } },
            ];
        }
        if (filters.startDate || filters.endDate) {
            query.createdAt = {};
            if (filters.startDate) query.createdAt.$gte = filters.startDate;
            if (filters.endDate) query.createdAt.$lte = filters.endDate;
        }

        const page = filters.page || 1;
        const limit = filters.limit || 50;

        const [logs, total] = await Promise.all([
            this.auditLogModel
                .find(query)
                .sort({ createdAt: -1 })
                .skip((page - 1) * limit)
                .limit(limit)
                .exec(),
            this.auditLogModel.countDocuments(query),
        ]);

        return { logs, total };
    }

    async getResourceHistory(resource: AuditResource, resourceId: string): Promise<AuditLog[]> {
        return this.auditLogModel
            .find({ resource, resourceId: new Types.ObjectId(resourceId) })
            .sort({ createdAt: -1 })
            .limit(100)
            .exec();
    }

    async getActorActivity(actorType: string, actorId: string, limit: number = 50): Promise<AuditLog[]> {
        return this.auditLogModel
            .find({ actorType, actorId: new Types.ObjectId(actorId) })
            .sort({ createdAt: -1 })
            .limit(limit)
            .exec();
    }

    async getCriticalLogs(days: number = 7): Promise<AuditLog[]> {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        return this.auditLogModel
            .find({ severity: 'critical', createdAt: { $gte: startDate } })
            .sort({ createdAt: -1 })
            .exec();
    }

    // ==================== Admin Activity ====================

    async logAdminActivity(data: {
        adminId: string;
        adminName: string;
        action: string;
        description: string;
        descriptionAr?: string;
        entityType?: string;
        entityId?: string;
        entityName?: string;
        ipAddress?: string;
        userAgent?: string;
        page?: string;
        route?: string;
        durationMs?: number;
        success?: boolean;
        errorCode?: string;
    }): Promise<AdminActivity> {
        return this.adminActivityModel.create({
            admin: new Types.ObjectId(data.adminId),
            adminName: data.adminName,
            action: data.action,
            description: data.description,
            descriptionAr: data.descriptionAr,
            entityType: data.entityType,
            entityId: data.entityId ? new Types.ObjectId(data.entityId) : undefined,
            entityName: data.entityName,
            ipAddress: data.ipAddress,
            userAgent: data.userAgent,
            page: data.page,
            route: data.route,
            durationMs: data.durationMs,
            success: data.success ?? true,
            errorCode: data.errorCode,
        });
    }

    async getAdminActivities(adminId: string, days: number = 30): Promise<AdminActivity[]> {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        return this.adminActivityModel
            .find({ admin: new Types.ObjectId(adminId), createdAt: { $gte: startDate } })
            .sort({ createdAt: -1 })
            .exec();
    }

    async getRecentActivities(limit: number = 100): Promise<AdminActivity[]> {
        return this.adminActivityModel
            .find()
            .sort({ createdAt: -1 })
            .limit(limit)
            .exec();
    }

    // ==================== Login History ====================

    async logLogin(data: {
        userType: 'admin' | 'customer';
        userId: string;
        email: string;
        phone?: string;
        status: LoginStatus;
        method?: LoginMethod;
        ipAddress: string;
        userAgent?: string;
        device?: {
            browser?: string;
            os?: string;
            device?: string;
            deviceType?: string;
            isMobile?: boolean;
        };
        location?: {
            country?: string;
            countryCode?: string;
            city?: string;
        };
        sessionId?: string;
        tokenId?: string;
        failureReason?: string;
        failedAttempts?: number;
    }): Promise<LoginHistory> {
        // Check for new device/location
        const previousLogins = await this.loginHistoryModel.find({
            userId: new Types.ObjectId(data.userId),
            status: LoginStatus.SUCCESS,
        }).limit(10).exec();

        const isNewDevice = !previousLogins.some(l =>
            l.device?.browser === data.device?.browser &&
            l.device?.os === data.device?.os
        );

        const isNewLocation = !previousLogins.some(l =>
            l.location?.country === data.location?.country &&
            l.location?.city === data.location?.city
        );

        // Check for suspicious activity
        const recentFailures = await this.loginHistoryModel.countDocuments({
            email: data.email,
            status: LoginStatus.FAILED,
            createdAt: { $gte: new Date(Date.now() - 15 * 60 * 1000) }, // Last 15 min
        });

        const isSuspicious = recentFailures >= 5 || (isNewDevice && isNewLocation);

        return this.loginHistoryModel.create({
            ...data,
            userId: new Types.ObjectId(data.userId),
            method: data.method || LoginMethod.PASSWORD,
            isNewDevice,
            isNewLocation,
            isSuspicious,
            suspiciousReason: isSuspicious
                ? (recentFailures >= 5 ? 'Multiple failed attempts' : 'New device and location')
                : undefined,
        });
    }

    async logLogout(userId: string, userType: string, reason: string): Promise<void> {
        await this.loginHistoryModel.findOneAndUpdate(
            {
                userId: new Types.ObjectId(userId),
                userType,
                logoutAt: { $exists: false },
            },
            {
                logoutAt: new Date(),
                logoutReason: reason,
            },
            { sort: { createdAt: -1 } }
        );
    }

    async getLoginHistory(userId: string, userType: string, limit: number = 50): Promise<LoginHistory[]> {
        return this.loginHistoryModel
            .find({ userId: new Types.ObjectId(userId), userType })
            .sort({ createdAt: -1 })
            .limit(limit)
            .exec();
    }

    async getSuspiciousLogins(days: number = 7): Promise<LoginHistory[]> {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        return this.loginHistoryModel
            .find({ isSuspicious: true, createdAt: { $gte: startDate } })
            .sort({ createdAt: -1 })
            .exec();
    }

    async getFailedLogins(email?: string, days: number = 7): Promise<LoginHistory[]> {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        const query: any = {
            status: LoginStatus.FAILED,
            createdAt: { $gte: startDate },
        };
        if (email) query.email = email;

        return this.loginHistoryModel
            .find(query)
            .sort({ createdAt: -1 })
            .exec();
    }

    async getLoginsByIP(ipAddress: string, days: number = 7): Promise<LoginHistory[]> {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        return this.loginHistoryModel
            .find({ ipAddress, createdAt: { $gte: startDate } })
            .sort({ createdAt: -1 })
            .exec();
    }

    // ==================== Statistics ====================

    async getAuditStats(): Promise<any> {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const [todayLogs, criticalCount, suspiciousLogins, failedLogins] = await Promise.all([
            this.auditLogModel.countDocuments({ createdAt: { $gte: today } }),
            this.auditLogModel.countDocuments({ severity: 'critical', createdAt: { $gte: today } }),
            this.loginHistoryModel.countDocuments({ isSuspicious: true, createdAt: { $gte: today } }),
            this.loginHistoryModel.countDocuments({ status: LoginStatus.FAILED, createdAt: { $gte: today } }),
        ]);

        const actionBreakdown = await this.auditLogModel.aggregate([
            { $match: { createdAt: { $gte: today } } },
            { $group: { _id: '$action', count: { $sum: 1 } } },
            { $sort: { count: -1 } },
        ]);

        return {
            todayLogs,
            criticalCount,
            suspiciousLogins,
            failedLogins,
            actionBreakdown: actionBreakdown.reduce((acc, a) => ({ ...acc, [a._id]: a.count }), {}),
        };
    }

    // ==================== Helpers ====================

    private getChangedFields(before: Record<string, any>, after: Record<string, any>): string[] {
        const fields: string[] = [];
        const allKeys = new Set([...Object.keys(before), ...Object.keys(after)]);

        for (const key of allKeys) {
            if (JSON.stringify(before[key]) !== JSON.stringify(after[key])) {
                fields.push(key);
            }
        }

        return fields;
    }
}
