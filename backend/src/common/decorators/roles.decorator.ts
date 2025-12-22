import { SetMetadata } from '@nestjs/common';
import { UserRole } from '@common/enums/user-role.enum';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👮 Roles Decorator
 * ═══════════════════════════════════════════════════════════════
 * Specify required roles to access a route
 */
export const ROLES_KEY = 'roles';
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
