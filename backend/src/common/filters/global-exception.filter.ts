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

type ExtractedError = {
  status: number;
  message: string;
  messageAr?: string;
  errorCode?: string;
  errors: Array<{ field?: string; message: string }>;
};

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

    const extractedError = this.extractError(exception);
    const { status, message, messageAr, errorCode, errors } = extractedError;

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
    } else if (status >= 500) {
      this.logger.error(
        `${request.method} ${request.url} - ${status} - ${message}${errorCode ? ` - ${errorCode}` : ''}`,
        exception instanceof Error ? exception.stack : undefined,
      );
    } else {
      this.logger.warn(
        `${request.method} ${request.url} - ${status} - ${message}${errorCode ? ` - ${errorCode}` : ''}`,
      );
    }

    const errorResponse: ApiResponse = {
      status: 'error',
      statusCode: status,
      message,
      messageAr: messageAr || this.translateMessage(message, errorCode),
      errorCode,
      errors: errors.length > 0 ? errors : undefined,
      path: request.url,
      timestamp: new Date().toISOString(),
    };

    response.status(status).json(errorResponse);
  }

  /**
   * Translate common error messages to Arabic
   */
  private translateMessage(message: string, errorCode?: string): string {
    if (errorCode) {
      const byCode: Record<string, string> = {
        AUTH_INVALID_CREDENTIALS: 'بيانات الدخول غير صحيحة',
        AUTH_ACCOUNT_REJECTED: 'حسابك مرفوض',
        AUTH_ACCOUNT_SUSPENDED: 'تم تعليق حسابك',
        AUTH_ACCOUNT_DELETED: 'تم حذف حسابك',
        AUTH_ACCOUNT_PENDING: 'حسابك قيد المراجعة. يرجى انتظار التفعيل',
        AUTH_ACCOUNT_NOT_ACTIVE: 'حسابك غير مفعل. يرجى التحقق من حسابك أو التواصل مع الدعم',
        AUTH_ACCOUNT_LOCKED: 'الحساب مقفل',
        AUTH_REFRESH_TOKEN_INVALID: 'رمز التحديث غير صالح',
        AUTH_ACCESS_TOKEN_MISSING: 'رمز الوصول غير موجود',
        AUTH_ACCESS_TOKEN_INVALID: 'رمز الوصول غير صالح أو منتهي',
        AUTH_USER_NOT_FOUND: 'المستخدم غير موجود',
        AUTH_HEADER_MISSING: 'ترويسة التفويض غير موجودة',
        AUTH_AUTHENTICATION_FAILED: 'فشلت المصادقة. يرجى تسجيل الدخول مرة أخرى',
      };

      if (byCode[errorCode]) {
        return byCode[errorCode];
      }
    }

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

  private extractError(exception: unknown): ExtractedError {
    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message = 'Internal server error';
    let messageAr: string | undefined;
    let errorCode: string | undefined;
    let errors: Array<{ field?: string; message: string }> = [];

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const response = exception.getResponse();

      if (typeof response === 'string') {
        message = response;
      } else if (response && typeof response === 'object') {
        const resp = response as {
          message?: string | string[];
          error?: string;
          messageAr?: string;
          errorCode?: string;
          errors?: Array<{ field?: string; message: string } | string>;
        };

        messageAr = resp.messageAr;
        errorCode = resp.errorCode;

        if (Array.isArray(resp.message)) {
          errors = resp.message.map((item) => ({ message: item }));
          message = 'Validation failed';
        } else if (typeof resp.message === 'string') {
          message = resp.message;
        } else if (typeof resp.error === 'string') {
          message = resp.error;
        }

        if (Array.isArray(resp.errors)) {
          errors = resp.errors.map((item) =>
            typeof item === 'string' ? { message: item } : item,
          );
        }
      }
    } else if (exception instanceof Error) {
      message = exception.message;
    }

    return {
      status,
      message,
      messageAr,
      errorCode,
      errors,
    };
  }
}
