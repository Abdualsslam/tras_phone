import { Module, Global } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AuditLog, AuditLogSchema } from './schemas/audit-log.schema';
import { AdminActivity, AdminActivitySchema } from './schemas/admin-activity.schema';
import { LoginHistory, LoginHistorySchema } from './schemas/login-history.schema';
import { AuditService } from './audit.service';
import { AuditController } from './audit.controller';

@Global() // Make available globally for logging from any module
@Module({
    imports: [
        MongooseModule.forFeature([
            { name: AuditLog.name, schema: AuditLogSchema },
            { name: AdminActivity.name, schema: AdminActivitySchema },
            { name: LoginHistory.name, schema: LoginHistorySchema },
        ]),
    ],
    controllers: [AuditController],
    providers: [AuditService],
    exports: [AuditService],
})
export class AuditModule { }
