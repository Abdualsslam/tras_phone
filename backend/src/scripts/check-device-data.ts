import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { Connection, Types } from 'mongoose';
import { getConnectionToken } from '@nestjs/mongoose';

async function check() {
    const app = await NestFactory.createApplicationContext(AppModule, { logger: ['error'] });
    const connection = app.get<Connection>(getConnectionToken());

    const deviceId = '6967e622e75de1251c263b8c';
    const productId = '695ec6035959a294a35a4b7d';

    console.log('\n═══════════════════════════════════════');
    console.log('🔍 Checking device and product data...\n');

    // Check if device exists
    const device = await connection.collection('devices').findOne({
        _id: new Types.ObjectId(deviceId)
    });
    console.log('📱 Device:', device ? `${device.name} (${device.nameAr})` : '❌ NOT FOUND');

    // Check product
    const product = await connection.collection('products').findOne({
        _id: new Types.ObjectId(productId)
    });

    if (product) {
        console.log('\n📦 Product:', product.name || product.nameAr);
        console.log('   compatibleDevices count:', product.compatibleDevices?.length || 0);
        
        if (product.compatibleDevices?.length > 0) {
            const firstDevice = product.compatibleDevices[0];
            console.log('   First device type:', typeof firstDevice);
            console.log('   First device value:', firstDevice);
            console.log('   First device toString:', firstDevice?.toString?.());
        }
    } else {
        console.log('❌ Product NOT FOUND');
    }

    // Try direct query with ObjectId
    const matchesWithObjectId = await connection.collection('products').countDocuments({
        compatibleDevices: { $in: [new Types.ObjectId(deviceId)] }
    });
    console.log('\n🔎 Query with ObjectId:', matchesWithObjectId, 'matches');

    // Try direct query with string
    const matchesWithString = await connection.collection('products').countDocuments({
        compatibleDevices: { $in: [deviceId] }
    });
    console.log('🔎 Query with string:', matchesWithString, 'matches');

    // Try query with both
    const matchesWithBoth = await connection.collection('products').countDocuments({
        compatibleDevices: { $in: [new Types.ObjectId(deviceId), deviceId as any] }
    });
    console.log('🔎 Query with both:', matchesWithBoth, 'matches');

    console.log('\n═══════════════════════════════════════\n');

    await app.close();
    process.exit(0);
}

check().catch(console.error);
