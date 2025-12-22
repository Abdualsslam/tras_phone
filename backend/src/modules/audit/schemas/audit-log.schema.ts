import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type AuditLogDocument = AuditLog & Document;

export enum AuditAction {
    CREATE = 'create',
    READ = 'read',
    UPDATE = 'update',
    DELETE = 'delete',
    LOGIN = 'login',
    LOGOUT = 'logout',
    EXPORT = 'export',
    IMPORT = 'import',
    APPROVE = 'approve',
    REJECT = 'reject',
    CANCEL = 'cancel',
    REFUND = 'refund',
    ASSIGN = 'assign',
    ESCALATE = 'escalate',
    SETTINGS_CHANGE = 'settings_change',
    PERMISSION_CHANGE = 'permission_change',
    PASSWORD_CHANGE = 'password_change',
    STATUS_CHANGE = 'status_change',
}

export enum AuditResource {
    USER = 'user',
    ADMIN = 'admin',
    CUSTOMER = 'customer',
    PRODUCT = 'product',
    CATEGORY = 'category',
    BRAND = 'brand',
    ORDER = 'order',
    RETURN = 'return',
    REFUND = 'refund',
    PAYMENT = 'payment',
    COUPON = 'coupon',
    PROMOTION = 'promotion',
    TICKET = 'ticket',
    INVENTORY = 'inventory',
    SUPPLIER = 'supplier',
    PURCHASE_ORDER = 'purchase_order',
    SETTINGS = 'settings',
    ROLE = 'role',
    PERMISSION = 'permission',
    REPORT = 'report',
    CONTENT = 'content',
}

@Schema({ _id: false })
export class AuditChanges {
    @Prop({ type: Object })
    before?: Record<string, any>;

    @Prop({ type: Object })
    after?: Record<string, any>;

    @Prop({ type: [String], default: [] })
    changedFields: string[];
}

@Schema({ _id: false })
export class AuditContext {
    @Prop()
    ipAddress?: string;

    @Prop()
    userAgent?: string;

    @Prop()
    browser?: string;

    @Prop()
    os?: string;

    @Prop()
    device?: string;

    @Prop()
    location?: string;

    @Prop()
    requestId?: string;

    @Prop()
    endpoint?: string;

    @Prop()
    method?: string;
}

@Schema({ timestamps: true })
export class AuditLog {
    @Prop({
        type: String,
        enum: Object.values(AuditAction),
        required: true
    })
    action: AuditAction;

    @Prop({
        type: String,
        enum: Object.values(AuditResource),
        required: true
    })
    resource: AuditResource;

    @Prop({ type: Types.ObjectId })
    resourceId?: Types.ObjectId;

    @Prop()
    resourceName?: string;

    // Actor (who performed the action)
    @Prop({
        type: String,
        enum: ['admin', 'customer', 'system', 'api'],
        required: true
    })
    actorType: string;

    @Prop({ type: Types.ObjectId })
    actorId?: Types.ObjectId;

    @Prop()
    actorName?: string;

    @Prop()
    actorEmail?: string;

    // Description
    @Prop({ required: true })
    description: string;

    @Prop()
    descriptionAr?: string;

    // Changes
    @Prop({ type: AuditChanges })
    changes?: AuditChanges;

    // Context
    @Prop({ type: AuditContext })
    context?: AuditContext;

    // Status
    @Prop({ default: true })
    success: boolean;

    @Prop()
    errorMessage?: string;

    // Severity
    @Prop({
        type: String,
        enum: ['info', 'warning', 'critical'],
        default: 'info'
    })
    severity: string;

    // Tags for filtering
    @Prop({ type: [String], default: [] })
    tags: string[];

    // Expiry (for GDPR compliance)
    @Prop()
    expiresAt?: Date;
}

export const AuditLogSchema = SchemaFactory.createForClass(AuditLog);

// Indexes
AuditLogSchema.index({ createdAt: -1 });
AuditLogSchema.index({ action: 1, resource: 1 });
AuditLogSchema.index({ actorId: 1, actorType: 1 });
AuditLogSchema.index({ resourceId: 1, resource: 1 });
AuditLogSchema.index({ severity: 1 });
AuditLogSchema.index({ 'context.ipAddress': 1 });
AuditLogSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });
