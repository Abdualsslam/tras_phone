import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type AdminUserDocument = AdminUser & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 👔 Admin User Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'admin_users',
    toJSON: { virtuals: true },
})
export class AdminUser {
    @Prop({ type: Types.ObjectId, ref: 'User', required: true, unique: true })
    userId: Types.ObjectId;

    @Prop({ required: true, unique: true })
    employeeCode: string;

    @Prop({ required: true })
    fullName: string;

    @Prop()
    fullNameAr?: string;

    @Prop()
    department?: string;

    @Prop()
    position?: string;

    // ═════════════════════════════════════
    // Permissions
    // ═════════════════════════════════════
    @Prop({ default: false })
    isSuperAdmin: boolean;

    @Prop({ default: false })
    canAccessMobile: boolean;

    @Prop({ default: true })
    canAccessWeb: boolean;

    // ═════════════════════════════════════
    // Contact
    // ═════════════════════════════════════
    @Prop()
    directPhone?: string;

    @Prop()
    extension?: string;

    // ═════════════════════════════════════
    // Emergency Contact
    // ═════════════════════════════════════
    @Prop()
    emergencyContactName?: string;

    @Prop()
    emergencyContactPhone?: string;

    @Prop()
    emergencyContactRelation?: string;

    // ═════════════════════════════════════
    // Employment Info
    // ═════════════════════════════════════
    @Prop({ type: Date })
    hireDate?: Date;

    @Prop({ type: Date })
    terminationDate?: Date;

    @Prop({
        type: String,
        enum: ['active', 'on_leave', 'suspended', 'terminated'],
        default: 'active',
    })
    employmentStatus: string;

    // ═════════════════════════════════════
    // Performance
    // ═════════════════════════════════════
    @Prop({ type: Number, default: 0 })
    totalOrdersProcessed: number;

    @Prop({ type: Number, default: 0 })
    totalCustomersManaged: number;

    @Prop({ type: Date })
    lastActivityAt?: Date;

    createdAt: Date;
    updatedAt: Date;
}

export const AdminUserSchema = SchemaFactory.createForClass(AdminUser);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
AdminUserSchema.index({ userId: 1 });
AdminUserSchema.index({ employeeCode: 1 });
AdminUserSchema.index({ department: 1 });
AdminUserSchema.index({ employmentStatus: 1 });
AdminUserSchema.index({ fullName: 'text', fullNameAr: 'text' });

// ═════════════════════════════════════
// Virtual for ID
// ═════════════════════════════════════
AdminUserSchema.virtual('id').get(function () {
    return this._id.toHexString();
});
