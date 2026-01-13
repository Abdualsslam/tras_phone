import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type RoleDocument = Role & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎭 Role Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
    timestamps: true,
    collection: 'roles',
})
export class Role {
    @Prop({ required: true, unique: true })
    name: string;

    @Prop()
    nameAr?: string;

    @Prop()
    description?: string;

    @Prop()
    descriptionAr?: string;

    @Prop({ default: true })
    isActive: boolean;

    @Prop({ default: false })
    isSystem: boolean; // System roles cannot be deleted

    createdAt: Date;
    updatedAt: Date;
}

export const RoleSchema = SchemaFactory.createForClass(Role);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
// Note: 'name' index is automatically created by unique: true
RoleSchema.index({ isActive: 1 });
