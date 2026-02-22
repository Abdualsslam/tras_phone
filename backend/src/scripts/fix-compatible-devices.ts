/**
 * ═══════════════════════════════════════════════════════════════
 * 🔧 Fix Compatible Devices - Convert string IDs to ObjectId
 * ═══════════════════════════════════════════════════════════════
 * Usage: npx ts-node -r tsconfig-paths/register --transpile-only src/scripts/fix-compatible-devices.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { Connection, Types } from 'mongoose';
import { getConnectionToken } from '@nestjs/mongoose';

async function fixCompatibleDevices() {
    console.log('\n🔧 Fixing compatibleDevices...\n');

    const app = await NestFactory.createApplicationContext(AppModule, {
        logger: ['error', 'warn'],
    });

    try {
        const connection = app.get<Connection>(getConnectionToken());
        const productsCollection = connection.collection('products');

        // Use aggregation to find and update in bulk
        const result = await productsCollection.updateMany(
            {
                compatibleDevices: { $exists: true, $ne: [] },
                'compatibleDevices.0': { $type: 'string' },
            },
            [
                {
                    $set: {
                        compatibleDevices: {
                            $map: {
                                input: '$compatibleDevices',
                                as: 'deviceId',
                                in: { $toObjectId: '$$deviceId' },
                            },
                        },
                    },
                },
            ],
        );

        console.log(`✅ Matched: ${result.matchedCount}`);
        console.log(`✅ Modified: ${result.modifiedCount}`);

        // Also handle mixed types (some string, some ObjectId)
        const mixedResult = await productsCollection.updateMany(
            {
                compatibleDevices: { $exists: true, $ne: [] },
            },
            [
                {
                    $set: {
                        compatibleDevices: {
                            $map: {
                                input: '$compatibleDevices',
                                as: 'deviceId',
                                in: {
                                    $cond: {
                                        if: { $eq: [{ $type: '$$deviceId' }, 'string'] },
                                        then: { $toObjectId: '$$deviceId' },
                                        else: '$$deviceId',
                                    },
                                },
                            },
                        },
                    },
                },
            ],
        );

        console.log(`\n📊 Final pass:`);
        console.log(`   Matched: ${mixedResult.matchedCount}`);
        console.log(`   Modified: ${mixedResult.modifiedCount}`);

        console.log('\n✨ Done!\n');

    } catch (error) {
        console.error('\n❌ Error:', error);
    } finally {
        await app.close();
        process.exit(0);
    }
}

fixCompatibleDevices();
