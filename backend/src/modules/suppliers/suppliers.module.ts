import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Supplier, SupplierSchema } from './schemas/supplier.schema';
import { PurchaseOrder, PurchaseOrderSchema } from './schemas/purchase-order.schema';
import { PurchaseOrderItem, PurchaseOrderItemSchema } from './schemas/purchase-order-item.schema';
import { SupplierPayment, SupplierPaymentSchema } from './schemas/supplier-payment.schema';
import { SupplierProduct, SupplierProductSchema } from './schemas/supplier-product.schema';
import { SuppliersService } from './suppliers.service';
import { SuppliersController, PurchaseOrdersController } from './suppliers.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Supplier.name, schema: SupplierSchema },
            { name: PurchaseOrder.name, schema: PurchaseOrderSchema },
            { name: PurchaseOrderItem.name, schema: PurchaseOrderItemSchema },
            { name: SupplierPayment.name, schema: SupplierPaymentSchema },
            { name: SupplierProduct.name, schema: SupplierProductSchema },
        ]),
        JwtModule.registerAsync({
            imports: [ConfigModule],
            useFactory: async (configService: ConfigService) => ({
                secret: configService.get<string>('JWT_SECRET'),
                signOptions: {
                    expiresIn: configService.get<string>('JWT_EXPIRATION', '15m'),
                },
            }),
            inject: [ConfigService],
        }),
    ],
    controllers: [SuppliersController, PurchaseOrdersController],
    providers: [SuppliersService],
    exports: [SuppliersService],
})
export class SuppliersModule { }
