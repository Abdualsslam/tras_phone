import { SetMetadata } from '@nestjs/common';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🌐 Public Decorator
 * ═══════════════════════════════════════════════════════════════
 * Mark routes as public (bypass JWT authentication)
 */
export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
