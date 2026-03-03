import {
    Injectable,
    NestInterceptor,
    ExecutionContext,
    CallHandler,
    StreamableFile,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { ApiResponse, ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔄 Transform Interceptor
 * ═══════════════════════════════════════════════════════════════
 * Automatically wraps all responses in the unified API response format
 */
@Injectable()
export class TransformInterceptor<T>
    implements NestInterceptor<T, ApiResponse<T> | T> {
    intercept(
        context: ExecutionContext,
        next: CallHandler,
    ): Observable<ApiResponse<T> | T> {
        const request = context.switchToHttp().getRequest();
        const httpResponse = context.switchToHttp().getResponse();

        return next.handle().pipe(
            map((data) => {
                if (this.shouldBypassTransform(data, httpResponse)) {
                    return data;
                }

                // If data is already in ApiResponse format, return as is
                if (data && typeof data === 'object' && 'status' in data && 'statusCode' in data) {
                    return data as ApiResponse<T>;
                }

                // Otherwise, wrap in success response
                const apiResponse = ResponseBuilder.success(
                    data,
                    'Operation completed successfully',
                );

                apiResponse.path = request.url;

                return apiResponse;
            }),
        );
    }

    private shouldBypassTransform(data: unknown, response: any): boolean {
        if (data instanceof StreamableFile) {
            return true;
        }

        if (
            Buffer.isBuffer(data) ||
            data instanceof Uint8Array ||
            data instanceof ArrayBuffer
        ) {
            return true;
        }

        const contentType = response?.getHeader?.('Content-Type');
        if (typeof contentType === 'string' && contentType.length > 0) {
            return !contentType.toLowerCase().includes('application/json');
        }

        if (Array.isArray(contentType) && contentType.length > 0) {
            return contentType.some(
                (value) =>
                    typeof value === 'string' &&
                    !value.toLowerCase().includes('application/json'),
            );
        }

        return false;
    }
}
