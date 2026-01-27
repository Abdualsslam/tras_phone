import {
    ExceptionFilter,
    Catch,
    ArgumentsHost,
    HttpException,
    HttpStatus,
    Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
    private readonly logger = new Logger(GlobalExceptionFilter.name);

    catch(exception: unknown, host: ArgumentsHost) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse<Response>();
        const request = ctx.getRequest<Request>();

        let status = HttpStatus.INTERNAL_SERVER_ERROR;
        let message = 'Internal server error';
        let errors: any[] = [];

        if (exception instanceof HttpException) {
            status = exception.getStatus();
            const exceptionResponse = exception.getResponse();

            if (typeof exceptionResponse === 'string') {
                message = exceptionResponse;
            } else if (typeof exceptionResponse === 'object') {
                const resp = exceptionResponse as any;
                message = resp.message || resp.error || message;
                errors = Array.isArray(resp.message) ? resp.message : [];
            }
        } else if (exception instanceof Error) {
            message = exception.message;
        }

        // Filter out noisy 404 errors for /api (without /v1)
        // These are typically health checks or incorrect client requests
        const isNoisy404 = 
            status === HttpStatus.NOT_FOUND && 
            (request.url === '/api' || request.url.startsWith('/api/') && !request.url.startsWith('/api/v1'));

        // Log error (skip noisy 404s or log them at debug level)
        if (isNoisy404) {
            this.logger.debug(
                `${request.method} ${request.url} - ${status} - ${message} (filtered)`
            );
        } else {
            this.logger.error(
                `${request.method} ${request.url} - ${status} - ${message}`,
                exception instanceof Error ? exception.stack : undefined
            );
        }

        const errorResponse = {
            success: false,
            statusCode: status,
            message,
            errors: errors.length > 0 ? errors : undefined,
            path: request.url,
            timestamp: new Date().toISOString(),
        };

        response.status(status).json(errorResponse);
    }
}
