import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS } from '@modules/admins/constants/permissions.constant';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔒 Support Permissions Guard
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class SupportPermissionsGuard implements CanActivate {
    constructor(private reflector: Reflector) { }

    canActivate(context: ExecutionContext): boolean {
        const requiredPermission = this.reflector.get<string>('permission', context.getHandler());

        if (!requiredPermission) {
            return true; // No specific permission required
        }

        const request = context.switchToHttp().getRequest();
        const user = request.user;

        if (!user) {
            return false;
        }

        // Super admin has all permissions
        if (user.role === 'super_admin') {
            return true;
        }

        // Check if user has the required permission
        return user.permissions?.includes(requiredPermission) || false;
    }
}

/**
 * Decorator to require specific permission
 */
export const RequirePermission = (permission: string) => {
    return (target: any, propertyKey: string, descriptor: PropertyDescriptor) => {
        Reflect.defineMetadata('permission', permission, descriptor.value);
        return descriptor;
    };
};
