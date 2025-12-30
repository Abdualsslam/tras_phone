import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Cart, CartSchema } from './schemas/cart.schema';
import { Order, OrderSchema } from './schemas/order.schema';
import { OrderItem, OrderItemSchema } from './schemas/order-item.schema';
import { OrderStatusHistory, OrderStatusHistorySchema } from './schemas/order-status-history.schema';
import { Invoice, InvoiceSchema } from './schemas/invoice.schema';
import { Shipment, ShipmentSchema } from './schemas/shipment.schema';
import { Payment, PaymentSchema } from './schemas/payment.schema';
import { OrderNote, OrderNoteSchema } from './schemas/order-note.schema';
import { CartService } from './cart.service';
import { OrdersService } from './orders.service';
import { CartController, OrdersController } from './orders.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: Cart.name, schema: CartSchema },
            { name: Order.name, schema: OrderSchema },
            { name: OrderItem.name, schema: OrderItemSchema },
            { name: OrderStatusHistory.name, schema: OrderStatusHistorySchema },
            { name: Invoice.name, schema: InvoiceSchema },
            { name: Shipment.name, schema: ShipmentSchema },
            { name: Payment.name, schema: PaymentSchema },
            { name: OrderNote.name, schema: OrderNoteSchema },
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
    controllers: [CartController, OrdersController],
    providers: [CartService, OrdersService],
    exports: [CartService, OrdersService],
})
export class OrdersModule { }
