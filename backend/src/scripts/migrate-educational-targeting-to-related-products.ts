import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { Connection, Types } from 'mongoose';
import { getConnectionToken } from '@nestjs/mongoose';

async function migrateEducationalTargetingToRelatedProducts() {
  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const connection = app.get<Connection>(getConnectionToken());
    const collection = connection.collection('educational_content');

    const cursor = collection.find({
      $or: [
        { 'targeting.products.0': { $exists: true } },
        { 'targeting.categories.0': { $exists: true } },
        { 'targeting.brands.0': { $exists: true } },
        { 'targeting.devices.0': { $exists: true } },
        { 'targeting.intentTags.0': { $exists: true } },
      ],
    });

    let scanned = 0;
    let updated = 0;

    while (await cursor.hasNext()) {
      const doc = await cursor.next();
      if (!doc?._id) continue;
      scanned += 1;

      const relatedProducts = Array.isArray(doc.relatedProducts)
        ? doc.relatedProducts
        : [];
      const targetingProducts = Array.isArray(doc.targeting?.products)
        ? doc.targeting.products
        : [];

      const mergedIds = Array.from(
        new Set(
          [...relatedProducts, ...targetingProducts]
            .map((id: any) => id?.toString?.() || '')
            .filter((id: string) => Types.ObjectId.isValid(id)),
        ),
      ).map((id) => new Types.ObjectId(id));

      await collection.updateOne(
        { _id: doc._id },
        {
          $set: {
            relatedProducts: mergedIds,
            targeting: {
              products: [],
              categories: [],
              brands: [],
              devices: [],
              intentTags: [],
            },
            updatedAt: new Date(),
          },
        },
      );
      updated += 1;
    }

    console.log('\n=== Educational Targeting Migration Completed ===');
    console.log(`Documents scanned: ${scanned}`);
    console.log(`Documents updated: ${updated}`);
    console.log('===============================================\n');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exitCode = 1;
  } finally {
    await app.close();
    process.exit();
  }
}

migrateEducationalTargetingToRelatedProducts();
