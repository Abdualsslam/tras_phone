import { Module, Global } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuditLog, AuditLogSchema } from './schemas/audit-log.schema';
import { AdminActivity, AdminActivitySchema } from './schemas/admin-activity.schema';
import { LoginHistory, LoginHistorySchema } from './schemas/login-history.schema';
import { AuditService } from './audit.service';
import { AuditController } from './audit.controller';
import { AuthModule } from '@modules/auth/auth.module';

@Global() // Make available globally for logging from any module
@Module({
    imports: [
        MongooseModule.forFeature([
            { name: AuditLog.name, schema: AuditLogSchema },
            { name: AdminActivity.name, schema: AdminActivitySchema },
            { name: LoginHistory.name, schema: LoginHistorySchema },
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
    controllers: [AuditController],
    providers: [AuditService],
    exports: [AuditService],
})
export class AuditModule { }
