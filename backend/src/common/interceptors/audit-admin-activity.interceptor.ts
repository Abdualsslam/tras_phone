import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { AuditService } from '../../modules/audit/audit.service';

@Injectable()
export class AuditAdminActivityInterceptor implements NestInterceptor {
  constructor(private readonly auditService: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    if (context.getType() !== 'http') {
      return next.handle();
    }

    const request = context.switchToHttp().getRequest();
    const { method, originalUrl } = request;
    const user = request.user;

    // Only track admin users
    if (!user || user.userType !== 'admin') {
      return next.handle();
    }

    // Only track state-changing methods
    const trackedMethods = ['POST', 'PUT', 'PATCH', 'DELETE'];
    if (!trackedMethods.includes(method)) {
      return next.handle();
    }

    // Avoid logging audit endpoints themselves
    if (originalUrl && originalUrl.startsWith('/api/v1/audit')) {
      return next.handle();
    }

    const ipAddress =
      request.ip ||
      (request.headers['x-forwarded-for'] as string) ||
      'unknown';
    const userAgent = request.headers['user-agent'] || 'unknown';

    const adminId: string | undefined = user.adminUserId || user.id;
    const adminName: string =
      user.fullName || user.email || user.phone || 'Unknown Admin';

    return next.handle().pipe(
      tap({
        next: () => {
          if (!adminId) {
            return;
          }

          this.auditService
            .logAdminActivity({
              adminId,
              adminName,
              action: `${method} ${originalUrl}`,
              description: `Admin performed ${method} ${originalUrl}`,
              entityType: undefined,
              entityId: undefined,
              entityName: undefined,
              ipAddress,
              userAgent,
              page: undefined,
              route: originalUrl,
              durationMs: undefined,
              success: true,
              errorCode: undefined,
            })
            .catch(() => undefined);
        },
        error: (err: any) => {
          if (!adminId) {
            return;
          }

          this.auditService
            .logAdminActivity({
              adminId,
              adminName,
              action: `${method} ${originalUrl}`,
              description: `Admin request failed for ${method} ${originalUrl}`,
              descriptionAr: err?.message,
              entityType: undefined,
              entityId: undefined,
              entityName: undefined,
              ipAddress,
              userAgent,
              page: undefined,
              route: originalUrl,
              durationMs: undefined,
              success: false,
              errorCode: err?.code || err?.name,
            })
            .catch(() => undefined);
        },
      }),
    );
  }
}

