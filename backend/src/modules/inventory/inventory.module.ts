import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Warehouse, WarehouseSchema } from './schemas/warehouse.schema';
import { StockLocation, StockLocationSchema } from './schemas/stock-location.schema';
import { StockMovement, StockMovementSchema } from './schemas/stock-movement.schema';
import { StockReservation, StockReservationSchema } from './schemas/stock-reservation.schema';
import { StockTransfer, StockTransferSchema } from './schemas/stock-transfer.schema';
import { InventoryCount, InventoryCountSchema } from './schemas/inventory-count.schema';
import { LowStockAlert, LowStockAlertSchema } from './schemas/low-stock-alert.schema';
import { ProductStock, ProductStockSchema } from './schemas/product-stock.schema';
import { InventoryService } from './inventory.service';
import { WarehousesService } from './warehouses.service';
import { InventoryController } from './inventory.controller';
import { AuthModule } from '@modules/auth/auth.module';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Warehouse.name, schema: WarehouseSchema },
            { name: StockLocation.name, schema: StockLocationSchema },
            { name: StockMovement.name, schema: StockMovementSchema },
            { name: StockReservation.name, schema: StockReservationSchema },
            { name: StockTransfer.name, schema: StockTransferSchema },
            { name: InventoryCount.name, schema: InventoryCountSchema },
            { name: LowStockAlert.name, schema: LowStockAlertSchema },
            { name: ProductStock.name, schema: ProductStockSchema },
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
        AuthModule,
    ],
    controllers: [InventoryController],
    providers: [InventoryService, WarehousesService],
    exports: [InventoryService, WarehousesService],
})
export class InventoryModule implements OnModuleInit {
    constructor(private warehousesService: WarehousesService) { }

    async onModuleInit() {
        await this.warehousesService.seedDefaultWarehouse();
    }
}
