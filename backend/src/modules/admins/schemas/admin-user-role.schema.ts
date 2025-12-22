import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type AdminUserRoleDocument = AdminUserRole & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔗 Admin-Role Schema (Many-to-Many)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'admin_user_roles',
})
export class AdminUserRole {
    @Prop({ type: Types.ObjectId, ref: 'AdminUser', required: true, index: true })
    adminUserId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Role', required: true, index: true })
    roleId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'AdminUser' })
    assignedBy?: Types.ObjectId;

    createdAt: Date;
    updatedAt: Date;
}

export const AdminUserRoleSchema = SchemaFactory.createForClass(AdminUserRole);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
AdminUserRoleSchema.index({ adminUserId: 1, roleId: 1 }, { unique: true });
