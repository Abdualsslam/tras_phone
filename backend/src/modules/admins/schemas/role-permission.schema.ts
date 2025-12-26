import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type RolePermissionDocument = RolePermission & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔗 Role-Permission Schema (Many-to-Many)
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'role_permissions',
})
export class RolePermission {
    @Prop({ type: Types.ObjectId, ref: 'Role', required: true, index: true })
    roleId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Permission', required: true, index: true })
    permissionId: Types.ObjectId;

    createdAt: Date;
    updatedAt: Date;
}

export const RolePermissionSchema =
    SchemaFactory.createForClass(RolePermission);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
RolePermissionSchema.index({ roleId: 1, permissionId: 1 }, { unique: true });
