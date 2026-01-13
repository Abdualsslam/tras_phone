import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type PermissionDocument = Permission & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔑 Permission Schema
 * ═══════════════════════════════════════════════════════════════
 * 95 Permissions organized by module
 */
@Schema({
    timestamps: true,
    collection: 'permissions',
})
export class Permission {
    @Prop({ required: true, unique: true })
    name: string; // Format: module.action (e.g., users.create)

    @Prop({ required: true })
    displayName: string;

    @Prop()
    displayNameAr?: string;

    @Prop()
    description?: string;

    @Prop()
    descriptionAr?: string;

    @Prop({ required: true })
    module: string; // users, customers, products, orders, etc.

    @Prop({ required: true })
    action: string; // view, create, update, delete, approve, etc.

    @Prop({ default: true })
    isActive: boolean;

    createdAt: Date;
    updatedAt: Date;
}

export const PermissionSchema = SchemaFactory.createForClass(Permission);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
// Note: 'name' index is automatically created by unique: true
PermissionSchema.index({ module: 1 });
PermissionSchema.index({ isActive: 1 });
