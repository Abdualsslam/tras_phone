import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { Connection, Types } from 'mongoose';
import { getConnectionToken } from '@nestjs/mongoose';

async function migrateProductStockToInventory() {
  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const connection = app.get<Connection>(getConnectionToken());
    const productsCollection = connection.collection('products');
    const warehousesCollection = connection.collection('warehouses');
    const productStocksCollection = connection.collection('product_stocks');

    let defaultWarehouse = await warehousesCollection.findOne({
      isDefault: true,
      isActive: true,
    });

    if (!defaultWarehouse) {
      defaultWarehouse = await warehousesCollection.findOne({ isActive: true });
    }

    if (!defaultWarehouse) {
      const now = new Date();
      const created = await warehousesCollection.insertOne({
        name: 'Main Warehouse',
        nameAr: 'المستودع الرئيسي',
        code: 'WH-MAIN',
        isDefault: true,
        isActive: true,
        allowNegativeStock: true,
        trackSerialNumbers: true,
        totalProducts: 0,
        totalQuantity: 0,
        totalValue: 0,
        createdAt: now,
        updatedAt: now,
      });

      defaultWarehouse = await warehousesCollection.findOne({
        _id: created.insertedId,
      });
    }

    if (!defaultWarehouse?._id) {
      throw new Error('Failed to resolve default warehouse');
    }

    const cursor = productsCollection.find({
      $or: [{ trackInventory: { $exists: false } }, { trackInventory: true }],
    });

    let totalProducts = 0;
    let syncedProducts = 0;
    let createdRecords = 0;
    let updatedRecords = 0;
    let skippedProducts = 0;

    while (await cursor.hasNext()) {
      const product = await cursor.next();
      if (!product?._id) {
        skippedProducts += 1;
        continue;
      }

      totalProducts += 1;

      const quantity = Math.max(0, Number(product.stockQuantity ?? 0));
      const lowStockThreshold = Math.max(
        0,
        Number(product.lowStockThreshold ?? 5),
      );
      const criticalStockThreshold = Math.max(
        0,
        Math.min(2, lowStockThreshold || 2),
      );

      const existing = await productStocksCollection.findOne({
        productId: new Types.ObjectId(product._id),
        warehouseId: new Types.ObjectId(defaultWarehouse._id),
      });

      const now = new Date();
      await productStocksCollection.updateOne(
        {
          productId: new Types.ObjectId(product._id),
          warehouseId: new Types.ObjectId(defaultWarehouse._id),
        },
        {
          $set: {
            quantity,
            lowStockThreshold,
            criticalStockThreshold,
            updatedAt: now,
          },
          $setOnInsert: {
            productId: new Types.ObjectId(product._id),
            warehouseId: new Types.ObjectId(defaultWarehouse._id),
            reservedQuantity: 0,
            damagedQuantity: 0,
            createdAt: now,
          },
        },
        { upsert: true },
      );

      syncedProducts += 1;
      if (existing) {
        updatedRecords += 1;
      } else {
        createdRecords += 1;
      }
    }

    console.log('\n=== Product Stock Migration Completed ===');
    console.log(`Default warehouse: ${defaultWarehouse.name} (${defaultWarehouse.code})`);
    console.log(`Products scanned: ${totalProducts}`);
    console.log(`Products synced: ${syncedProducts}`);
    console.log(`Stock records created: ${createdRecords}`);
    console.log(`Stock records updated: ${updatedRecords}`);
    console.log(`Products skipped: ${skippedProducts}`);
    console.log('=======================================\n');
  } catch (error) {
    console.error('Migration failed:', error);
    process.exitCode = 1;
  } finally {
    await app.close();
    process.exit();
  }
}

migrateProductStockToInventory();
