/**
 * Remove customerCode index from customers collection
 * This script removes the customerCode_1 index that was left in the database
 * after removing the customerCode field from the schema.
 *
 * Usage:
 *   npx ts-node -r tsconfig-paths/register src/scripts/remove-customercode-index.ts           # dry-run
 *   npx ts-node -r tsconfig-paths/register src/scripts/remove-customercode-index.ts --execute  # apply
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { getModelToken } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  Customer,
  CustomerDocument,
} from '../modules/customers/schemas/customer.schema';

const EXECUTE = process.argv.includes('--execute');
const VERBOSE =
  process.argv.includes('--verbose') || process.argv.includes('-v');

async function removeCustomerCodeIndex() {
  console.log('Remove customerCode index from customers collection\n');
  if (!EXECUTE) {
    console.log('DRY RUN (use --execute to apply changes)\n');
  }

  const app = await NestFactory.createApplicationContext(AppModule);

  try {
    const customerModel = app.get<Model<CustomerDocument>>(
      getModelToken(Customer.name),
    );
    const conn = customerModel.db as any;
    const db = conn?.db ?? customerModel.collection?.db;
    const coll = db?.collection('customers') ?? customerModel.collection;

    console.log(`DB: ${db?.databaseName ?? 'unknown'}, collection: customers`);
    console.log(
      '(Use same MONGODB_URI as your API to access the correct database.)\n',
    );
    if (!db || !coll) {
      throw new Error(
        'Could not access customers collection. Check DB connection.',
      );
    }

    // Get all indexes
    const indexes = await coll.indexes();
    console.log('Current indexes:');
    indexes.forEach((idx: any) => {
      console.log(`  - ${idx.name}: ${JSON.stringify(idx.key)}`);
    });
    console.log('');

    // Find customerCode index
    const customerCodeIndex = indexes.find(
      (idx: any) => idx.name === 'customerCode_1' || idx.key?.customerCode,
    );

    if (!customerCodeIndex) {
      console.log('✅ customerCode index not found. Nothing to remove.');
      await app.close();
      return;
    }

    console.log(`Found customerCode index: ${customerCodeIndex.name}`);
    console.log(`Index key: ${JSON.stringify(customerCodeIndex.key)}`);
    console.log('');

    if (EXECUTE) {
      console.log('Removing index...');
      await coll.dropIndex(customerCodeIndex.name);
      console.log(`✅ Successfully removed index: ${customerCodeIndex.name}`);
    } else {
      console.log(`Would remove index: ${customerCodeIndex.name}`);
      console.log('Run with --execute to apply changes.');
    }

    // Show updated indexes
    if (EXECUTE) {
      console.log('\nUpdated indexes:');
      const updatedIndexes = await coll.indexes();
      updatedIndexes.forEach((idx: any) => {
        console.log(`  - ${idx.name}: ${JSON.stringify(idx.key)}`);
      });
    }
  } catch (e: any) {
    console.error('Error:', e.message);
    if (VERBOSE) {
      console.error(e);
    }
    throw e;
  } finally {
    await app.close();
  }
}

removeCustomerCodeIndex();
