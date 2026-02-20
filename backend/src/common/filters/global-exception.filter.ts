import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { ApiResponse } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛡️ Global Exception Filter
 * ═══════════════════════════════════════════════════════════════
 * Catches all unhandled exceptions and returns a unified ApiResponse
 */
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
    const isNoisy404 =
      status === HttpStatus.NOT_FOUND &&
      (request.url === '/api' ||
        (request.url.startsWith('/api/') &&
          !request.url.startsWith('/api/v1')));

    if (isNoisy404) {
      this.logger.debug(
        `${request.method} ${request.url} - ${status} - ${message} (filtered)`,
      );
    } else {
      this.logger.error(
        `${request.method} ${request.url} - ${status} - ${message}`,
        exception instanceof Error ? exception.stack : undefined,
      );
    }

    const errorResponse: ApiResponse = {
      status: 'error',
      statusCode: status,
      message,
      messageAr: this.translateMessage(message),
      errors:
        errors.length > 0
          ? errors.map((e) => (typeof e === 'string' ? { message: e } : e))
          : undefined,
      path: request.url,
      timestamp: new Date().toISOString(),
    };

    response.status(status).json(errorResponse);
  }

  /**
   * Translate common error messages to Arabic
   */
  private translateMessage(message: string): string {
    const translations: Record<string, string> = {
      'Internal server error': 'خطأ في الخادم الداخلي',
      'Not Found': 'غير موجود',
      'Bad Request': 'طلب غير صالح',
      Unauthorized: 'غير مصرح بالوصول',
      Forbidden: 'الوصول محظور',
      'Validation failed': 'فشل التحقق من صحة البيانات',
      Conflict: 'تعارض في البيانات',
      'Too Many Requests': 'طلبات كثيرة جداً، يرجى المحاولة لاحقاً',
      'Invalid credentials': 'بيانات الدخول غير صحيحة',
      'User not found': 'المستخدم غير موجود',
      'Resource not found': 'المورد غير موجود',
      'Invalid ID format': 'صيغة المعرف غير صالحة',
      'Duplicate entry found': 'يوجد سجل مكرر',
      'Your account has been suspended': 'تم تعليق حسابك',
      'Your account has been rejected': 'حسابك مرفوض',
      'Account is locked': 'الحساب مقفل',
    };

    if (message.startsWith('Account is locked. Try again in')) {
      const minutes = message.match(/\d+/)?.[0] || '';
      return `الحساب مقفل. يرجى المحاولة مرة أخرى بعد ${minutes} دقيقة`;
    }

    return translations[message] || message;
  }
}
