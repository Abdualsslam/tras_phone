import {
    Injectable,
    CanActivate,
    ExecutionContext,
    ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY } from '@decorators/permissions.decorator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔒 Permissions Guard
 * ═══════════════════════════════════════════════════════════════
 * Advanced guard that checks granular permissions
 */
@Injectable()
export class PermissionsGuard implements CanActivate {
    constructor(private reflector: Reflector) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        const requiredPermissions = this.reflector.getAllAndOverride<string[]>(
            PERMISSIONS_KEY,
            [context.getHandler(), context.getClass()],
        );

        if (!requiredPermissions || requiredPermissions.length === 0) {
            return true;
        }

        const { user } = context.switchToHttp().getRequest();

        if (!user) {
            throw new ForbiddenException('User not authenticated');
        }

        // Super admins have all permissions
        if (user.isSuperAdmin) {
            return true;
        }

        // Check if user has the required permissions
        // This assumes user.permissions is populated from JWT or database
        const userPermissions = user.permissions || [];

        const hasPermission = requiredPermissions.every((permission) =>
            userPermissions.includes(permission),
        );

        if (!hasPermission) {
            throw new ForbiddenException(
                `You need the following permissions: ${requiredPermissions.join(', ')}`,
            );
        }

        return true;
    }
}
