import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { DailyStats, DailyStatsSchema } from './schemas/daily-stats.schema';
import { ProductAnalytics, ProductAnalyticsSchema } from './schemas/product-analytics.schema';
import { SearchAnalytics, SearchAnalyticsSchema } from './schemas/search-analytics.schema';
import { Report, ReportSchema } from './schemas/report.schema';
import { SearchLog, SearchLogSchema } from './schemas/search-log.schema';
import { RecentlyViewed, RecentlyViewedSchema } from './schemas/recently-viewed.schema';
import { AnalyticsService } from './analytics.service';
import { DashboardService } from './dashboard.service';
import { SearchService } from './search.service';
import { AnalyticsController } from './analytics.controller';
import { Order, OrderSchema } from '../orders/schemas/order.schema';
import { Customer, CustomerSchema } from '../customers/schemas/customer.schema';
import { Product, ProductSchema } from '../products/schemas/product.schema';
import { ReturnRequest, ReturnRequestSchema } from '../returns/schemas/return-request.schema';
import { AuthModule } from '@modules/auth/auth.module';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: DailyStats.name, schema: DailyStatsSchema },
            { name: ProductAnalytics.name, schema: ProductAnalyticsSchema },
            { name: SearchAnalytics.name, schema: SearchAnalyticsSchema },
            { name: Report.name, schema: ReportSchema },
            { name: SearchLog.name, schema: SearchLogSchema },
            { name: RecentlyViewed.name, schema: RecentlyViewedSchema },
            { name: Order.name, schema: OrderSchema },
            { name: Customer.name, schema: CustomerSchema },
            { name: Product.name, schema: ProductSchema },
            { name: ReturnRequest.name, schema: ReturnRequestSchema },
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
    controllers: [AnalyticsController],
    providers: [AnalyticsService, DashboardService, SearchService],
    exports: [AnalyticsService, DashboardService, SearchService],
})
export class AnalyticsModule { }
