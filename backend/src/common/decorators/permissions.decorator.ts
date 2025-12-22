import { SetMetadata } from '@nestjs/common';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔑 Permissions Decorator
 * ═══════════════════════════════════════════════════════════════
 * Specify required permissions to access a route
 */
export const PERMISSIONS_KEY = 'permissions';
export const RequirePermissions = (...permissions: string[]) =>
    SetMetadata(PERMISSIONS_KEY, permissions);
