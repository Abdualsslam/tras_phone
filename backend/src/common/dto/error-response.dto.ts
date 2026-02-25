import { ApiProperty } from '@nestjs/swagger';
import { ErrorDetailDto } from './api-response.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * ❌ Error Response DTOs for Swagger Documentation
 * ═══════════════════════════════════════════════════════════════
 */

export class BadRequestErrorDto {
    @ApiProperty({ example: 'error', description: 'Response status' })
    status: 'error';

    @ApiProperty({ example: 400, description: 'HTTP status code' })
    statusCode: 400;

    @ApiProperty({ example: 'Bad Request', description: 'Error message' })
    message: string;

    @ApiProperty({ example: 'طلب غير صحيح', description: 'Arabic message' })
    messageAr: string;

    @ApiProperty({ type: [ErrorDetailDto], required: false, description: 'Error details' })
    errors?: ErrorDetailDto[];

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Error timestamp' })
    timestamp: string;
}

export class UnauthorizedErrorDto {
    @ApiProperty({ example: 'error', description: 'Response status' })
    status: 'error';

    @ApiProperty({ example: 401, description: 'HTTP status code' })
    statusCode: 401;

    @ApiProperty({ example: 'Unauthorized access', description: 'Error message' })
    message: string;

    @ApiProperty({ example: 'غير مصرح بالوصول', description: 'Arabic message' })
    messageAr: string;

    @ApiProperty({
        example: 'AUTH_INVALID_CREDENTIALS',
        description: 'Machine-readable error code',
        required: false,
    })
    errorCode?: string;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Error timestamp' })
    timestamp: string;
}

export class ForbiddenErrorDto {
    @ApiProperty({ example: 'error', description: 'Response status' })
    status: 'error';

    @ApiProperty({ example: 403, description: 'HTTP status code' })
    statusCode: 403;

    @ApiProperty({ example: 'Forbidden access', description: 'Error message' })
    message: string;

    @ApiProperty({ example: 'الوصول محظور', description: 'Arabic message' })
    messageAr: string;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Error timestamp' })
    timestamp: string;
}

export class NotFoundErrorDto {
    @ApiProperty({ example: 'error', description: 'Response status' })
    status: 'error';

    @ApiProperty({ example: 404, description: 'HTTP status code' })
    statusCode: 404;

    @ApiProperty({ example: 'Resource not found', description: 'Error message' })
    message: string;

    @ApiProperty({ example: 'المورد غير موجود', description: 'Arabic message' })
    messageAr: string;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Error timestamp' })
    timestamp: string;
}

export class ValidationErrorDto {
    @ApiProperty({ example: 'error', description: 'Response status' })
    status: 'error';

    @ApiProperty({ example: 422, description: 'HTTP status code' })
    statusCode: 422;

    @ApiProperty({ example: 'Validation failed', description: 'Error message' })
    message: string;

    @ApiProperty({ example: 'فشل التحقق من صحة البيانات', description: 'Arabic message' })
    messageAr: string;

    @ApiProperty({ type: [ErrorDetailDto], description: 'Validation error details' })
    errors: ErrorDetailDto[];

    @ApiProperty({
        example: 'VALIDATION_ERROR',
        description: 'Machine-readable error code',
        required: false,
    })
    errorCode?: string;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Error timestamp' })
    timestamp: string;
}

export class InternalServerErrorDto {
    @ApiProperty({ example: 'error', description: 'Response status' })
    status: 'error';

    @ApiProperty({ example: 500, description: 'HTTP status code' })
    statusCode: 500;

    @ApiProperty({ example: 'Internal server error', description: 'Error message' })
    message: string;

    @ApiProperty({ example: 'خطأ في الخادم الداخلي', description: 'Arabic message' })
    messageAr: string;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Error timestamp' })
    timestamp: string;
}
