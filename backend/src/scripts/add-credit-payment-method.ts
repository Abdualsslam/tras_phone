import mongoose from 'mongoose';
import * as dotenv from 'dotenv';

// Load environment variables
dotenv.config();

/**
 * Script to add Credit payment method to existing database
 * Run with: npx ts-node src/scripts/add-credit-payment-method.ts
 */

// Payment Method Schema
const PaymentMethodSchema = new mongoose.Schema(
  {
    nameAr: { type: String, required: true, trim: true },
    nameEn: { type: String, required: true, trim: true },
    type: {
      type: String,
      enum: [
        'cash_on_delivery',
        'credit_card',
        'credit',
        'mada',
        'apple_pay',
        'stc_pay',
        'bank_transfer',
        'wallet',
        'installment',
      ],
      required: true,
      unique: true,
    },
    icon: String,
    logo: String,
    gateway: {
      type: String,
      enum: ['hyperpay', 'moyasar', 'tap', 'payfort', 'internal', 'none'],
    },
    fixedFee: { type: Number, default: 0 },
    percentageFee: { type: Number, default: 0 },
    minAmount: { type: Number, default: 0 },
    maxAmount: Number,
    isActive: { type: Boolean, default: true },
    platforms: { type: [String], default: ['web', 'mobile'] },
    sortOrder: { type: Number, default: 0 },
  },
  { timestamps: true },
);

const PaymentMethod = mongoose.model('PaymentMethod', PaymentMethodSchema);

async function bootstrap() {
  const mongoUri =
    process.env.MONGODB_URI || 'mongodb://localhost:27017/tras-phone';

  console.log('🔌 Connecting to MongoDB...');
  await mongoose.connect(mongoUri);
  console.log('✅ Connected to MongoDB');

  // Check if credit payment method already exists
  const existingCredit = await PaymentMethod.findOne({ type: 'credit' });

  if (existingCredit) {
    console.log('✅ Credit payment method already exists:');
    console.log(JSON.stringify(existingCredit.toObject(), null, 2));
    await mongoose.disconnect();
    return;
  }

  // Create credit payment method
  const creditMethod = await PaymentMethod.create({
    nameAr: 'الدفع بالآجل',
    nameEn: 'Credit Limit',
    type: 'credit',
    icon: 'credit-limit',
    gateway: 'internal',
    fixedFee: 0,
    percentageFee: 0,
    minAmount: 0,
    isActive: true,
    platforms: ['web', 'mobile'],
    sortOrder: 8,
  });

  console.log('✅ Credit payment method created successfully:');
  console.log(JSON.stringify(creditMethod.toObject(), null, 2));

  await mongoose.disconnect();
  console.log('👋 Disconnected from MongoDB');
}

bootstrap().catch((err) => {
  console.error('❌ Error:', err);
  process.exit(1);
});
