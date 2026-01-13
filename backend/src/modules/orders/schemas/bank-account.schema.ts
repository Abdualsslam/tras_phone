import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type BankAccountDocument = BankAccount & Document;

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏦 Bank Account Schema
 * ═══════════════════════════════════════════════════════════════
 */
@Schema({
  timestamps: true,
  collection: 'bank_accounts',
})
export class BankAccount {
  // Bank Info
  @Prop({ required: true })
  bankName: string;

  @Prop()
  bankNameAr?: string;

  @Prop()
  bankCode?: string;

  // Account Info
  @Prop({ required: true })
  accountName: string;

  @Prop()
  accountNameAr?: string;

  @Prop({ required: true })
  accountNumber: string;

  @Prop()
  iban?: string;

  // Display
  @Prop({ required: true })
  displayName: string;

  @Prop()
  displayNameAr?: string;

  @Prop()
  logo?: string;

  // Instructions
  @Prop()
  instructions?: string;

  @Prop()
  instructionsAr?: string;

  // Settings
  @Prop({ default: 'SAR' })
  currencyCode: string;

  @Prop({ default: true })
  isActive: boolean;

  @Prop({ default: false })
  isDefault: boolean;

  @Prop({ default: 0 })
  sortOrder: number;

  // Stats
  @Prop({ type: Number, default: 0 })
  totalReceived: number;

  createdAt: Date;
  updatedAt: Date;
}

export const BankAccountSchema = SchemaFactory.createForClass(BankAccount);

// ═════════════════════════════════════
// Indexes
// ═════════════════════════════════════
BankAccountSchema.index({ isActive: 1 });
BankAccountSchema.index({ isDefault: 1 });
BankAccountSchema.index({ sortOrder: 1 });
