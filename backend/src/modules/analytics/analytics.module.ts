import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { DailyStats, DailyStatsSchema } from './schemas/daily-stats.schema';
import { ProductAnalytics, ProductAnalyticsSchema } from './schemas/product-analytics.schema';
import { SearchAnalytics, SearchAnalyticsSchema } from './schemas/search-analytics.schema';
import { Report, ReportSchema } from './schemas/report.schema';
import { AnalyticsService } from './analytics.service';
import { AnalyticsController } from './analytics.controller';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: DailyStats.name, schema: DailyStatsSchema },
            { name: ProductAnalytics.name, schema: ProductAnalyticsSchema },
            { name: SearchAnalytics.name, schema: SearchAnalyticsSchema },
            { name: Report.name, schema: ReportSchema },
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
    controllers: [AnalyticsController],
    providers: [AnalyticsService],
    exports: [AnalyticsService],
})
export class AnalyticsModule { }
