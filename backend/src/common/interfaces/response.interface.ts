/**
 * ═══════════════════════════════════════════════════════════════
 * 🎯 Unified API Response Interface
 * ═══════════════════════════════════════════════════════════════
 * Standard response structure for all API endpoints
 */

export interface ApiResponse<T = any> {
    /**
     * Response status: 'success' | 'error'
     */
    status: 'success' | 'error';

    /**
     * HTTP status code
     */
    statusCode: number;

    /**
     * Human-readable message
     */
    message: string;

    /**
     * Arabic message for localization
     */
    messageAr?: string;

    /**
     * Response payload data
     */
    data?: T;

    /**
     * Error details (only for error responses)
     */
    errors?: ErrorDetail[];

    /**
     * Metadata (pagination, timestamps, etc.)
     */
    meta?: ResponseMeta;

    /**
     * Request timestamp
     */
    timestamp: string;

    /**
     * Request path
     */
    path?: string;
}

export interface ErrorDetail {
    field?: string;
    message: string;
    code?: string;
}

export interface ResponseMeta {
    /**
     * Pagination metadata
     */
    pagination?: PaginationMeta;

    /**
     * Additional metadata
     */
    [key: string]: any;
}

export interface PaginationMeta {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPreviousPage: boolean;
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏗️ Response Builder Class
 * ═══════════════════════════════════════════════════════════════
 */
export class ResponseBuilder {
    /**
     * Build success response
     */
    static success<T>(
        data: T,
        message: string = 'Success',
        messageAr?: string,
        meta?: ResponseMeta,
    ): ApiResponse<T> {
        return {
            status: 'success',
            statusCode: 200,
            message,
            messageAr: messageAr || this.translateMessage(message),
            data,
            meta,
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build created response (201)
     */
    static created<T>(
        data: T,
        message: string = 'Resource created successfully',
        messageAr?: string,
    ): ApiResponse<T> {
        return {
            status: 'success',
            statusCode: 201,
            message,
            messageAr: messageAr || this.translateMessage(message),
            data,
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build no content response (204)
     */
    static noContent(
        message: string = 'No content',
        messageAr?: string,
    ): ApiResponse {
        return {
            status: 'success',
            statusCode: 204,
            message,
            messageAr: messageAr || this.translateMessage(message),
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build error response
     */
    static error(
        message: string,
        statusCode: number = 400,
        errors?: ErrorDetail[],
        messageAr?: string,
    ): ApiResponse {
        return {
            status: 'error',
            statusCode,
            message,
            messageAr: messageAr || this.translateMessage(message),
            errors,
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build validation error response
     */
    static validationError(
        errors: ErrorDetail[],
        message: string = 'Validation failed',
    ): ApiResponse {
        return {
            status: 'error',
            statusCode: 422,
            message,
            messageAr: 'فشل التحقق من صحة البيانات',
            errors,
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build unauthorized response
     */
    static unauthorized(
        message: string = 'Unauthorized access',
    ): ApiResponse {
        return {
            status: 'error',
            statusCode: 401,
            message,
            messageAr: 'غير مصرح بالوصول',
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build forbidden response
     */
    static forbidden(message: string = 'Forbidden access'): ApiResponse {
        return {
            status: 'error',
            statusCode: 403,
            message,
            messageAr: 'الوصول محظور',
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build not found response
     */
    static notFound(
        message: string = 'Resource not found',
        messageAr?: string,
    ): ApiResponse {
        return {
            status: 'error',
            statusCode: 404,
            message,
            messageAr: messageAr || 'المورد غير موجود',
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build server error response
     */
    static serverError(
        message: string = 'Internal server error',
    ): ApiResponse {
        return {
            status: 'error',
            statusCode: 500,
            message,
            messageAr: 'خطأ في الخادم الداخلي',
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build paginated response
     */
    static paginated<T>(
        data: T[],
        pagination: PaginationMeta,
        message: string = 'Data retrieved successfully',
    ): ApiResponse<T[]> {
        return {
            status: 'success',
            statusCode: 200,
            message,
            messageAr: 'تم استرجاع البيانات بنجاح',
            data,
            meta: { pagination },
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Simple Arabic translation helper
     * In production, use a proper i18n library
     */
    private static translateMessage(message: string): string {
        const translations: Record<string, string> = {
            'Success': 'نجح',
            'Resource created successfully': 'تم إنشاء المورد بنجاح',
            'No content': 'لا يوجد محتوى',
            'Validation failed': 'فشل التحقق من صحة البيانات',
            'Unauthorized access': 'غير مصرح بالوصول',
            'Forbidden access': 'الوصول محظور',
            'Resource not found': 'المورد غير موجود',
            'Internal server error': 'خطأ في الخادم الداخلي',
            'Data retrieved successfully': 'تم استرجاع البيانات بنجاح',
        };

        return translations[message] || message;
    }
}
