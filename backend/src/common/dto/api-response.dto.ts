import { ApiProperty } from '@nestjs/swagger';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎯 API Response DTOs for Swagger Documentation
 * ═══════════════════════════════════════════════════════════════
 */

export class PaginationMetaDto {
    @ApiProperty({ example: 1, description: 'Current page number' })
    page: number;

    @ApiProperty({ example: 20, description: 'Number of items per page' })
    limit: number;

    @ApiProperty({ example: 100, description: 'Total number of items' })
    total: number;

    @ApiProperty({ example: 5, description: 'Total number of pages' })
    totalPages: number;

    @ApiProperty({ example: true, description: 'Whether there is a next page' })
    hasNextPage: boolean;

    @ApiProperty({ example: false, description: 'Whether there is a previous page' })
    hasPreviousPage: boolean;
}

export class ResponseMetaDto {
    @ApiProperty({ type: PaginationMetaDto, required: false, description: 'Pagination metadata' })
    pagination?: PaginationMetaDto;

    [key: string]: any;
}

export class ErrorDetailDto {
    @ApiProperty({ example: 'email', required: false, description: 'Field name with error' })
    field?: string;

    @ApiProperty({ example: 'Email is invalid', description: 'Error message' })
    message: string;

    @ApiProperty({ example: 'VALIDATION_ERROR', required: false, description: 'Error code' })
    code?: string;
}

export class ApiResponseDto<T = any> {
    @ApiProperty({ example: 'success', enum: ['success', 'error'], description: 'Response status' })
    status: 'success' | 'error';

    @ApiProperty({ example: 200, description: 'HTTP status code' })
    statusCode: number;

    @ApiProperty({ example: 'Operation completed successfully', description: 'Response message' })
    message: string;

    @ApiProperty({ example: 'تمت العملية بنجاح', required: false, description: 'Arabic message' })
    messageAr?: string;

    @ApiProperty({ description: 'Response data', required: false })
    data?: T;

    @ApiProperty({ type: [ErrorDetailDto], required: false, description: 'Error details (only for error responses)' })
    errors?: ErrorDetailDto[];

    @ApiProperty({
        example: 'AUTH_INVALID_CREDENTIALS',
        required: false,
        description: 'Machine-readable error code',
    })
    errorCode?: string;

    @ApiProperty({ type: ResponseMetaDto, required: false, description: 'Response metadata' })
    meta?: ResponseMetaDto;

    @ApiProperty({ example: '2024-01-01T00:00:00.000Z', description: 'Response timestamp' })
    timestamp: string;

    @ApiProperty({ example: '/api/v1/products', required: false, description: 'Request path' })
    path?: string;
}
