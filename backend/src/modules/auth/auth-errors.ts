import { UnauthorizedException } from '@nestjs/common';

export const AUTH_ERROR_CODES = {
  INVALID_CREDENTIALS: 'AUTH_INVALID_CREDENTIALS',
  ACCOUNT_REJECTED: 'AUTH_ACCOUNT_REJECTED',
  ACCOUNT_SUSPENDED: 'AUTH_ACCOUNT_SUSPENDED',
  ACCOUNT_DELETED: 'AUTH_ACCOUNT_DELETED',
  ACCOUNT_PENDING: 'AUTH_ACCOUNT_PENDING',
  ACCOUNT_NOT_ACTIVE: 'AUTH_ACCOUNT_NOT_ACTIVE',
  ACCOUNT_LOCKED: 'AUTH_ACCOUNT_LOCKED',
  REFRESH_TOKEN_INVALID: 'AUTH_REFRESH_TOKEN_INVALID',
  ACCESS_TOKEN_MISSING: 'AUTH_ACCESS_TOKEN_MISSING',
  ACCESS_TOKEN_INVALID: 'AUTH_ACCESS_TOKEN_INVALID',
  USER_NOT_FOUND: 'AUTH_USER_NOT_FOUND',
  AUTH_HEADER_MISSING: 'AUTH_HEADER_MISSING',
  AUTHENTICATION_FAILED: 'AUTH_AUTHENTICATION_FAILED',
} as const;

export type AuthErrorCode = (typeof AUTH_ERROR_CODES)[keyof typeof AUTH_ERROR_CODES];

type AuthErrorMessage = {
  message: string;
  messageAr: string;
};

const AUTH_ERROR_MESSAGES: Record<AuthErrorCode, AuthErrorMessage> = {
  [AUTH_ERROR_CODES.INVALID_CREDENTIALS]: {
    message: 'Invalid credentials',
    messageAr: 'بيانات الدخول غير صحيحة',
  },
  [AUTH_ERROR_CODES.ACCOUNT_REJECTED]: {
    message: 'Your account has been rejected',
    messageAr: 'حسابك مرفوض',
  },
  [AUTH_ERROR_CODES.ACCOUNT_SUSPENDED]: {
    message: 'Your account has been suspended',
    messageAr: 'تم تعليق حسابك',
  },
  [AUTH_ERROR_CODES.ACCOUNT_DELETED]: {
    message: 'Your account has been deleted',
    messageAr: 'تم حذف حسابك',
  },
  [AUTH_ERROR_CODES.ACCOUNT_PENDING]: {
    message: 'Your account is under review. Please wait for activation',
    messageAr: 'حسابك قيد المراجعة. يرجى انتظار التفعيل',
  },
  [AUTH_ERROR_CODES.ACCOUNT_NOT_ACTIVE]: {
    message: 'Your account is not active. Please verify your account or contact support',
    messageAr: 'حسابك غير مفعل. يرجى التحقق من حسابك أو التواصل مع الدعم',
  },
  [AUTH_ERROR_CODES.ACCOUNT_LOCKED]: {
    message: 'Account is locked',
    messageAr: 'الحساب مقفل',
  },
  [AUTH_ERROR_CODES.REFRESH_TOKEN_INVALID]: {
    message: 'Invalid refresh token',
    messageAr: 'رمز التحديث غير صالح',
  },
  [AUTH_ERROR_CODES.ACCESS_TOKEN_MISSING]: {
    message: 'Access token not found',
    messageAr: 'رمز الوصول غير موجود',
  },
  [AUTH_ERROR_CODES.ACCESS_TOKEN_INVALID]: {
    message: 'Invalid or expired token',
    messageAr: 'رمز الوصول غير صالح أو منتهي',
  },
  [AUTH_ERROR_CODES.USER_NOT_FOUND]: {
    message: 'User not found',
    messageAr: 'المستخدم غير موجود',
  },
  [AUTH_ERROR_CODES.AUTH_HEADER_MISSING]: {
    message: 'Authorization header not found',
    messageAr: 'ترويسة التفويض غير موجودة',
  },
  [AUTH_ERROR_CODES.AUTHENTICATION_FAILED]: {
    message: 'Authentication failed',
    messageAr: 'فشلت المصادقة',
  },
};

type BuildAuthUnauthorizedExceptionParams = {
  code: AuthErrorCode;
  message?: string;
  messageAr?: string;
};

export const buildAuthUnauthorizedException = ({
  code,
  message,
  messageAr,
}: BuildAuthUnauthorizedExceptionParams): UnauthorizedException => {
  const defaults = AUTH_ERROR_MESSAGES[code];

  return new UnauthorizedException({
    errorCode: code,
    message: message || defaults.message,
    messageAr: messageAr || defaults.messageAr,
  });
};
