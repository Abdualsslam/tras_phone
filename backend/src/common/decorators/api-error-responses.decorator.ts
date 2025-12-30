import { applyDecorators } from '@nestjs/common';
import { ApiResponse } from '@nestjs/swagger';
import {
    BadRequestErrorDto,
    UnauthorizedErrorDto,
    ForbiddenErrorDto,
    NotFoundErrorDto,
    ValidationErrorDto,
    InternalServerErrorDto,
} from '../dto/error-response.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎨 Common Error Responses Decorator
 * ═══════════════════════════════════════════════════════════════
 * Adds standard error responses to Swagger documentation
 */
export function ApiCommonErrorResponses() {
    return applyDecorators(
        ApiResponse({
            status: 400,
            description: 'Bad Request - Invalid input or parameters',
            type: BadRequestErrorDto,
        }),
        ApiResponse({
            status: 401,
            description: 'Unauthorized - Missing or invalid authentication token',
            type: UnauthorizedErrorDto,
        }),
        ApiResponse({
            status: 403,
            description: 'Forbidden - Insufficient permissions',
            type: ForbiddenErrorDto,
        }),
        ApiResponse({
            status: 404,
            description: 'Not Found - Resource does not exist',
            type: NotFoundErrorDto,
        }),
        ApiResponse({
            status: 422,
            description: 'Validation Error - Invalid data format',
            type: ValidationErrorDto,
        }),
        ApiResponse({
            status: 500,
            description: 'Internal Server Error - Server-side error occurred',
            type: InternalServerErrorDto,
        }),
    );
}

/**
 * Decorator for authenticated endpoints only
 */
export function ApiAuthErrorResponses() {
    return applyDecorators(
        ApiResponse({
            status: 401,
            description: 'Unauthorized - Missing or invalid authentication token',
            type: UnauthorizedErrorDto,
        }),
        ApiResponse({
            status: 403,
            description: 'Forbidden - Insufficient permissions',
            type: ForbiddenErrorDto,
        }),
        ApiResponse({
            status: 500,
            description: 'Internal Server Error',
            type: InternalServerErrorDto,
        }),
    );
}

/**
 * Decorator for public endpoints
 */
export function ApiPublicErrorResponses() {
    return applyDecorators(
        ApiResponse({
            status: 400,
            description: 'Bad Request',
            type: BadRequestErrorDto,
        }),
        ApiResponse({
            status: 422,
            description: 'Validation Error',
            type: ValidationErrorDto,
        }),
        ApiResponse({
            status: 500,
            description: 'Internal Server Error',
            type: InternalServerErrorDto,
        }),
    );
}
