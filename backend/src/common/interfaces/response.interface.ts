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
}

export interface ResponseMeta {
    pagination?: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
        hasNextPage?: boolean;
        hasPreviousPage?: boolean;
    };
    [key: string]: any;
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
    static notFound(message: string = 'Resource not found'): ApiResponse {
        return {
            status: 'error',
            statusCode: 404,
            message,
            messageAr: 'المورد غير موجود',
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build conflict response
     */
    static conflict(message: string = 'Conflict'): ApiResponse {
        return {
            status: 'error',
            statusCode: 409,
            message,
            messageAr: 'تعارض',
            timestamp: new Date().toISOString(),
        };
    }

    /**
     * Build internal server error response
     */
    static internalServerError(
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
            
            // Authentication error messages
            'Invalid credentials': 'بيانات الدخول غير صحيحة. الحالة: غير مفعل أو بيانات خاطئة',
            'Your account is under review. Please wait for activation': 'حسابك قيد المراجعة. الحالة: قيد المراجعة - يرجى انتظار التفعيل',
            'Your account is not active. Please verify your account or contact support': 'حسابك غير مفعل. الحالة: غير مفعل - يرجى التحقق من حسابك أو الاتصال بالدعم',
            'Your account has been suspended': 'تم تعليق حسابك. الحالة: معطل',
            'Your account has been rejected': 'حسابك مرفوض. الحالة: مرفوض',
            'Your account has been deleted': 'تم حذف حسابك. الحالة: محذوف',
            'Your account is not active': 'حسابك غير مفعل. الحالة: غير مفعل',
            'User not found': 'المستخدم غير موجود',
            'Account is locked': 'الحساب مقفل',
        };

        // Handle dynamic messages like "Account is locked. Try again in X minutes"
        if (message.startsWith('Account is locked. Try again in')) {
            const minutes = message.match(/\d+/)?.[0] || '';
            return `الحساب مقفل. يرجى المحاولة مرة أخرى بعد ${minutes} دقيقة`;
        }

        return translations[message] || message;
    }
}
