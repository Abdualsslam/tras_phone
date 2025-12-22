import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type AdminActivityDocument = AdminActivity & Document;

@Schema({ timestamps: true })
export class AdminActivity {
    @Prop({ type: Types.ObjectId, ref: 'Admin', required: true })
    admin: Types.ObjectId;

    @Prop({ required: true })
    adminName: string;

    @Prop({ required: true })
    action: string;

    @Prop({ required: true })
    description: string;

    @Prop()
    descriptionAr?: string;

    // Related entity
    @Prop()
    entityType?: string;

    @Prop({ type: Types.ObjectId })
    entityId?: Types.ObjectId;

    @Prop()
    entityName?: string;

    // Session info
    @Prop()
    sessionId?: string;

    @Prop()
    ipAddress?: string;

    @Prop()
    userAgent?: string;

    // Page/Route
    @Prop()
    page?: string;

    @Prop()
    route?: string;

    // Duration (for time-tracking)
    @Prop()
    durationMs?: number;

    // Status
    @Prop({ default: true })
    success: boolean;

    @Prop()
    errorCode?: string;
}

export const AdminActivitySchema = SchemaFactory.createForClass(AdminActivity);

AdminActivitySchema.index({ admin: 1, createdAt: -1 });
AdminActivitySchema.index({ action: 1, createdAt: -1 });
AdminActivitySchema.index({ entityType: 1, entityId: 1 });
AdminActivitySchema.index({ createdAt: -1 });
