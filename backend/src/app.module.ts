import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';
import { ThrottlerModule } from '@nestjs/throttler';

// Core Modules
import { AuthModule } from './modules/auth/auth.module';
import { CustomersModule } from './modules/customers/customers.module';
import { ProductsModule } from './modules/products/products.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { CatalogModule } from './modules/catalog/catalog.module';

// Business Modules
import { InventoryModule } from './modules/inventory/inventory.module';
import { PromotionsModule } from './modules/promotions/promotions.module';
import { OrdersModule } from './modules/orders/orders.module';
import { ReturnsModule } from './modules/returns/returns.module';
import { WalletModule } from './modules/wallet/wallet.module';
import { SuppliersModule } from './modules/suppliers/suppliers.module';

// Communication Modules
import { NotificationsModule } from './modules/notifications/notifications.module';
import { SupportModule } from './modules/support/support.module';

// Content & Settings Modules
import { ContentModule } from './modules/content/content.module';
import { SettingsModule } from './modules/settings/settings.module';
import { LocationsModule } from './modules/locations/locations.module';

// Analytics & Audit Modules
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { AuditModule } from './modules/audit/audit.module';

// Infrastructure Modules
import { IntegrationsModule } from './modules/integrations/integrations.module';
import { CacheModule } from './modules/cache/cache.module';
import { JobsModule } from './modules/jobs/jobs.module';
import { AdminsModule } from './modules/admins/admins.module';
import { UploadsModule } from './modules/uploads/uploads.module';

@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env.local', '.env'],
    }),

    // Database
    MongooseModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        uri: configService.get<string>(
          'MONGODB_URI',
          'mongodb://localhost:27017/trasphone',
        ),
        retryWrites: true,
        w: 'majority',
      }),
      inject: [ConfigService],
    }),

    // Rate Limiting
    ThrottlerModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => [
        {
          ttl: configService.get<number>('THROTTLE_TTL', 60000),
          limit: configService.get<number>('THROTTLE_LIMIT', 100),
        },
      ],
      inject: [ConfigService],
    }),

    // Global Infrastructure
    CacheModule,
    IntegrationsModule,
    AuditModule,

    // Core Authentication & Users
    AuthModule,
    CustomersModule,
    AdminsModule,

    // Products & Catalog
    ProductsModule,
    CategoriesModule,
    CatalogModule,

    // Inventory & Supply Chain
    InventoryModule,
    SuppliersModule,

    // Commerce
    PromotionsModule,
    OrdersModule,
    ReturnsModule,
    WalletModule,

    // Communication
    NotificationsModule,
    SupportModule,

    // Content & Configuration
    ContentModule,
    SettingsModule,
    LocationsModule,

    // Analytics & Reporting
    AnalyticsModule,

    // Background Jobs
    JobsModule,

    // File Uploads
    UploadsModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
