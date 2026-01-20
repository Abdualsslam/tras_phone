export class ResponseBuilder {
    static success<T>(data: T, message?: string, messageAr?: string): ApiResponse<T> {
        return {
            success: true,
            data,
            message: message || 'Success',
            messageAr: messageAr || message || 'نجح',
            timestamp: new Date().toISOString(),
        };
    }

    static error(message: string, statusCode?: number, messageAr?: string | any[]): ApiResponse<null> {
        // Handle backward compatibility: if messageAr is an array, it's actually the errors parameter
        const errors = Array.isArray(messageAr) ? messageAr : undefined;
        const arabicMessage = typeof messageAr === 'string' ? messageAr : undefined;
        
        return {
            success: false,
            data: null,
            message,
            messageAr: arabicMessage,
            statusCode: statusCode || 400,
            errors,
            timestamp: new Date().toISOString(),
        };
    }

    static paginated<T>(
        data: T[],
        total: number,
        page: number,
        limit: number,
        message?: string
    ): PaginatedResponse<T> {
        return {
            success: true,
            data,
            pagination: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
                hasNext: page * limit < total,
                hasPrev: page > 1,
            },
            message: message || 'Success',
            timestamp: new Date().toISOString(),
        };
    }
}

export interface ApiResponse<T> {
    success: boolean;
    data: T;
    message: string;
    messageAr?: string;
    statusCode?: number;
    errors?: any[];
    timestamp: string;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
    pagination: {
        total: number;
        page: number;
        limit: number;
        totalPages: number;
        hasNext: boolean;
        hasPrev: boolean;
    };
}
