import {
    ExceptionFilter,
    Catch,
    ArgumentsHost,
    HttpException,
    HttpStatus,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { Logger } from '@common/logger/logger.service';
import { ApiResponse, ErrorDetail, ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛡️ Global HTTP Exception Filter
 * ═══════════════════════════════════════════════════════════════
 * Catches all HTTP exceptions and transforms them into unified responses
 */
@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
    constructor(private readonly logger: Logger) { }

    catch(exception: unknown, host: ArgumentsHost) {
        const ctx = host.switchToHttp();
        const response = ctx.getResponse<Response>();
        const request = ctx.getRequest<Request>();

        let status = HttpStatus.INTERNAL_SERVER_ERROR;
        let message = 'Internal server error';
        let errors: ErrorDetail[] | undefined = undefined;

        // ═════════════════════════════════════
        // 📝 Handle different exception types
        // ═════════════════════════════════════
        if (exception instanceof HttpException) {
            status = exception.getStatus();
            const exceptionResponse = exception.getResponse();

            if (typeof exceptionResponse === 'string') {
                message = exceptionResponse;
            } else if (typeof exceptionResponse === 'object') {
                const responseObj = exceptionResponse as any;
                message = responseObj.message || responseObj.error || message;

                // Handle validation errors
                if (Array.isArray(responseObj.message)) {
                    errors = responseObj.message.map((msg: string) => ({
                        message: msg,
                    }));
                    message = 'Validation failed';
                }
            }
        } else if (exception instanceof Error) {
            message = exception.message;

            // Handle Mongoose errors
            if (exception.name === 'ValidationError') {
                status = HttpStatus.UNPROCESSABLE_ENTITY;
                message = 'Validation failed';
                errors = this.handleMongooseValidationError(exception);
            } else if (exception.name === 'CastError') {
                status = HttpStatus.BAD_REQUEST;
                message = 'Invalid ID format';
            } else if (exception.name === 'MongoServerError' && (exception as any).code === 11000) {
                status = HttpStatus.CONFLICT;
                message = 'Duplicate entry found';
                errors = this.handleMongoDuplicateError(exception);
            }
        }

        // ═════════════════════════════════════
        // 📊 Log the error
        // ═════════════════════════════════════
        const errorLog = {
            statusCode: status,
            message,
            path: request.url,
            method: request.method,
            ip: request.ip,
            userAgent: request.headers['user-agent'],
            timestamp: new Date().toISOString(),
        };

        if (status >= 500) {
            this.logger.error(`Error occurred: ${message}`, exception instanceof Error ? exception.stack : '', 'HttpExceptionFilter');
        } else {
            this.logger.warn(`Client error: ${message}`, 'HttpExceptionFilter');
        }

        // ═════════════════════════════════════
        // 📤 Send unified error response
        // ═════════════════════════════════════
        const apiResponse: ApiResponse = ResponseBuilder.error(
            message,
            status,
            errors,
        );

        apiResponse.path = request.url;

        response.status(status).json(apiResponse);
    }

    /**
     * Handle Mongoose validation errors
     */
    private handleMongooseValidationError(error: any) {
        const errors: ErrorDetail[] = [];

        if (error.errors) {
            for (const field in error.errors) {
                errors.push({
                    field,
                    message: error.errors[field].message,
                });
            }
        }

        return errors;
    }

    /**
     * Handle MongoDB duplicate key errors
     */
    private handleMongoDuplicateError(error: any) {
        const field = Object.keys(error.keyPattern)[0];
        return [
            {
                field,
                message: `${field} already exists`,
            },
        ];
    }
}
