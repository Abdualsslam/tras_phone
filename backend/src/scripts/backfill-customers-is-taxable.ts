import mongoose from 'mongoose';
import * as dotenv from 'dotenv';

dotenv.config();

/**
 * Backfill script for customer tax flag
 * Sets isTaxable=true for customers that do not have this field.
 * Run with: npx ts-node src/scripts/backfill-customers-is-taxable.ts
 */

const CustomerSchema = new mongoose.Schema(
  {
    isTaxable: { type: Boolean, default: true },
  },
  {
    timestamps: true,
    collection: 'customers',
    strict: false,
  },
);

const Customer = mongoose.model('Customer', CustomerSchema);

async function bootstrap() {
  const mongoUri =
    process.env.MONGODB_URI || 'mongodb://localhost:27017/tras-phone';

  console.log('Connecting to MongoDB...');
  await mongoose.connect(mongoUri);
  console.log('Connected');

  const result = await Customer.updateMany(
    { isTaxable: { $exists: false } },
    { $set: { isTaxable: true } },
  );

  console.log('Backfill completed');
  console.log(`Matched: ${result.matchedCount}`);
  console.log(`Modified: ${result.modifiedCount}`);

  await mongoose.disconnect();
  console.log('Disconnected');
}

bootstrap().catch((err) => {
  console.error('Backfill failed:', err);
  process.exit(1);
});
