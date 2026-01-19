import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { Cart, CartSchema } from './schemas/cart.schema';
import { Order, OrderSchema } from './schemas/order.schema';
import { OrderItem, OrderItemSchema } from './schemas/order-item.schema';
import {
  OrderStatusHistory,
  OrderStatusHistorySchema,
} from './schemas/order-status-history.schema';
import { Invoice, InvoiceSchema } from './schemas/invoice.schema';
import { Shipment, ShipmentSchema } from './schemas/shipment.schema';
import { Payment, PaymentSchema } from './schemas/payment.schema';
import { OrderNote, OrderNoteSchema } from './schemas/order-note.schema';
import { BankAccount, BankAccountSchema } from './schemas/bank-account.schema';
import { CartService } from './cart.service';
import { OrdersService } from './orders.service';
import {
  CartController,
  OrdersController,
  BankAccountsController,
  AdminOrdersController,
} from './orders.controller';
import { AuthModule } from '@modules/auth/auth.module';
import { PromotionsModule } from '@modules/promotions/promotions.module';
import { ProductsModule } from '@modules/products/products.module';
import { InventoryModule } from '@modules/inventory/inventory.module';
import { CustomersModule } from '@modules/customers/customers.module';

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
      { name: BankAccount.name, schema: BankAccountSchema },
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
    PromotionsModule,
    ProductsModule,
    InventoryModule,
    CustomersModule,
  ],
  controllers: [
    CartController,
    OrdersController,
    BankAccountsController,
    AdminOrdersController,
  ],
  providers: [CartService, OrdersService],
  exports: [CartService, OrdersService],
})
export class OrdersModule {}
