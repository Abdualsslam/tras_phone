import {
    Injectable,
    NestInterceptor,
    ExecutionContext,
    CallHandler,
    Logger as NestLogger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { Logger } from '@common/logger/logger.service';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📊 Logging Interceptor
 * ═══════════════════════════════════════════════════════════════
 * Logs all incoming requests and outgoing responses with timing
 */
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
    private readonly logger: Logger | NestLogger;

    constructor(logger?: Logger) {
        this.logger = logger ?? new NestLogger('LoggingInterceptor');
    }

    intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
        const request = context.switchToHttp().getRequest();
        const { method, url, ip, body } = request;
        const userAgent = request.get('user-agent') || '';
        const startTime = Date.now();

        // Log incoming request
        this.logger.log(
            `→ ${method} ${url} - IP: ${ip} - UserAgent: ${userAgent}`,
            'Request',
        );

        // Log request body for POST/PUT/PATCH (excluding sensitive data)
        if (['POST', 'PUT', 'PATCH'].includes(method)) {
            const sanitizedBody = this.sanitizeBody(body);
            if (Object.keys(sanitizedBody).length > 0) {
                this.logger.debug(
                    `Request Body: ${JSON.stringify(sanitizedBody)}`,
                    'Request',
                );
            }
        }

        return next.handle().pipe(
            tap({
                next: (data) => {
                    const responseTime = Date.now() - startTime;
                    this.logger.log(
                        `← ${method} ${url} - ${responseTime}ms`,
                        'Response',
                    );
                },
                error: (error) => {
                    const responseTime = Date.now() - startTime;
                    const statusCode =
                        typeof error?.status === 'number'
                            ? error.status
                            : typeof error?.statusCode === 'number'
                                ? error.statusCode
                                : 500;
                    const errorMessage =
                        typeof error?.message === 'string'
                            ? error.message
                            : 'Unexpected error';

                    const line = `✗ ${method} ${url} - ${responseTime}ms - ${statusCode} - ${errorMessage}`;

                    if (statusCode >= 500) {
                        this.logger.error(line, error?.stack, 'Response');
                    } else {
                        this.logger.warn(line, 'Response');
                    }
                },
            }),
        );
    }

    /**
     * Sanitize request body to remove sensitive fields
     */
    private sanitizeBody(body: any): any {
        if (!body || typeof body !== 'object') {
            return {};
        }

        const sensitiveFields = [
            'password',
            'confirmPassword',
            'oldPassword',
            'newPassword',
            'token',
            'accessToken',
            'refreshToken',
            'secret',
            'apiKey',
            'creditCard',
            'cvv',
        ];

        const sanitized = { ...body };

        sensitiveFields.forEach((field) => {
            if (sanitized[field]) {
                sanitized[field] = '***REDACTED***';
            }
        });

        return sanitized;
    }
}
