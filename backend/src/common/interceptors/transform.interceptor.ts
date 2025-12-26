import {
    Injectable,
    NestInterceptor,
    ExecutionContext,
    CallHandler,
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
    implements NestInterceptor<T, ApiResponse<T>> {
    intercept(
        context: ExecutionContext,
        next: CallHandler,
    ): Observable<ApiResponse<T>> {
        const request = context.switchToHttp().getRequest();

        return next.handle().pipe(
            map((data) => {
                // If data is already in ApiResponse format, return as is
                if (data && typeof data === 'object' && 'status' in data && 'statusCode' in data) {
                    return data as ApiResponse<T>;
                }

                // Otherwise, wrap in success response
                const response = ResponseBuilder.success(
                    data,
                    'Operation completed successfully',
                );

                response.path = request.url;

                return response;
            }),
        );
    }
}
