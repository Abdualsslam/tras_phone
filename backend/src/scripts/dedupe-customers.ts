/**
 * Dedupe customers by userId – keep one per user, remove duplicates.
 * Run before enabling unique index on Customer.userId.
 *
 * Usage:
 *   npx ts-node -r tsconfig-paths/register src/scripts/dedupe-customers.ts           # dry-run
 *   npx ts-node -r tsconfig-paths/register src/scripts/dedupe-customers.ts --execute  # apply
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { getModelToken } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Customer, CustomerDocument } from '../modules/customers/schemas/customer.schema';
import { Types } from 'mongoose';

const EXECUTE = process.argv.includes('--execute');
const VERBOSE = process.argv.includes('--verbose') || process.argv.includes('-v');

async function dedupeCustomers() {
  console.log('Dedupe customers by userId\n');
  if (!EXECUTE) {
    console.log('DRY RUN (use --execute to apply changes)\n');
  }

  const app = await NestFactory.createApplicationContext(AppModule);

  try {
    const customerModel = app.get<Model<CustomerDocument>>(getModelToken(Customer.name));
    const conn = customerModel.db as any;
    const db = conn?.db ?? customerModel.collection?.db;
    const coll = db?.collection('customers') ?? customerModel.collection;

    console.log(`DB: ${db?.databaseName ?? 'unknown'}, collection: customers`);
    console.log('(Use same MONGODB_URI as your API to dedupe the correct database.)\n');
    if (!db || !coll) {
      throw new Error('Could not access customers collection. Check DB connection.');
    }

    const total = await coll.countDocuments();
    console.log(`Total customers: ${total}`);

    const dupes = (await coll
      .aggregate([
        { $addFields: { userIdStr: { $toString: '$userId' } } },
        { $group: { _id: '$userIdStr', userId: { $first: '$userId' }, count: { $sum: 1 }, ids: { $push: '$_id' } } },
        { $match: { count: { $gt: 1 } } },
      ])
      .toArray()) as { _id: string; userId: Types.ObjectId; count: number; ids: Types.ObjectId[] }[];

    if (VERBOSE && dupes.length > 0) {
      console.log('Duplicate groups (userId -> count, ids):');
      dupes.forEach((g) => console.log(`  ${g.userId ?? g._id} -> ${g.count}, ids: ${g.ids.map((id) => id.toString()).join(', ')}`));
      console.log('');
    }

    if (dupes.length === 0) {
      console.log('No duplicate customers found.');
      if (total > 0) {
        const allGroups = (await coll
          .aggregate([
            { $addFields: { userIdStr: { $toString: '$userId' } } },
            { $group: { _id: '$userIdStr', count: { $sum: 1 } } },
            { $sort: { count: -1 } },
            { $limit: 10 },
          ])
          .toArray()) as { _id: string; count: number }[];
        console.log('Sample userId counts (top 10, by normalized userId):');
        allGroups.forEach((g) => console.log(`  ${g._id} -> ${g.count}`));
      }
      await app.close();
      return;
    }

    console.log(`Found ${dupes.length} userId(s) with duplicate customers.\n`);

    let deleted = 0;
    let skipped = 0;

    for (const g of dupes) {
      const userId = g.userId ?? g._id;
      const ids = g.ids;

      const customers = await customerModel
        .find({ _id: { $in: ids } })
        .sort({ approvedAt: -1, createdAt: 1 })
        .lean();

      const [keep, ...toRemove] = customers;
      if (!keep) continue;

      const keepCode = (keep as any).customerCode;
      console.log(`userId ${userId}: keep ${keep._id} (${keepCode}), remove ${toRemove.length}`);

      for (const c of toRemove) {
        const ordersCount = await db!.collection('orders').countDocuments({ customerId: c._id });
        const addressesCount = await db!.collection('customer_addresses').countDocuments({
          customerId: c._id,
        });
        const hasRefs = ordersCount > 0 || addressesCount > 0;

        if (hasRefs) {
          console.log(
            `  skip ${c._id} (orders: ${ordersCount}, addresses: ${addressesCount}) – resolve manually`,
          );
          skipped++;
          continue;
        }

        if (EXECUTE) {
          await customerModel.deleteOne({ _id: c._id });
          deleted++;
          console.log(`  deleted ${c._id}`);
        } else {
          console.log(`  would delete ${c._id}`);
          deleted++;
        }
      }
    }

    console.log(
      '\n' +
        (EXECUTE
          ? `Deleted ${deleted} duplicate(s), skipped ${skipped}.`
          : `Would delete ${deleted}, skip ${skipped}. Run with --execute to apply.`),
    );
  } catch (e: any) {
    console.error('Error:', e.message);
    throw e;
  } finally {
    await app.close();
  }
}

dedupeCustomers();
