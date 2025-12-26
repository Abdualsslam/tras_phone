import {
    Injectable,
    NotFoundException,
    ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Permission, PermissionDocument } from './schemas/permission.schema';
import { Role, RoleDocument } from './schemas/role.schema';
import {
    RolePermission,
    RolePermissionDocument,
} from './schemas/role-permission.schema';
import { PERMISSION_METADATA } from './constants/permissions.constant';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔑 Permissions Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class PermissionsService {
    constructor(
        @InjectModel(Permission.name)
        private permissionModel: Model<PermissionDocument>,
        @InjectModel(Role.name)
        private roleModel: Model<RoleDocument>,
        @InjectModel(RolePermission.name)
        private rolePermissionModel: Model<RolePermissionDocument>,
    ) { }

    /**
     * Get all permissions
     */
    async findAll(): Promise<PermissionDocument[]> {
        return this.permissionModel.find({ isActive: true }).sort({ module: 1, action: 1 });
    }

    /**
     * Get permissions by module
     */
    async findByModule(module: string): Promise<PermissionDocument[]> {
        return this.permissionModel.find({ module, isActive: true });
    }

    /**
     * Get permissions for a role
     */
    async getPermissionsForRole(roleId: string): Promise<PermissionDocument[]> {
        const rolePermissions = await this.rolePermissionModel
            .find({ roleId })
            .populate('permissionId')
            .exec();

        return rolePermissions.map((rp) => rp.permissionId as any);
    }

    /**
     * Assign permissions to role
     */
    async assignPermissionsToRole(
        roleId: string,
        permissionIds: string[],
    ): Promise<void> {
        // Verify role exists
        const role = await this.roleModel.findById(roleId);
        if (!role) {
            throw new NotFoundException('Role not found');
        }

        // Remove existing permissions
        await this.rolePermissionModel.deleteMany({ roleId });

        // Add new permissions
        const rolePermissions = permissionIds.map((permissionId) => ({
            roleId,
            permissionId,
        }));

        await this.rolePermissionModel.insertMany(rolePermissions);
    }

    /**
     * Seed permissions (run once on app initialization)
     */
    async seedPermissions(): Promise<void> {
        const count = await this.permissionModel.countDocuments();

        if (count > 0) {
            return; // Already seeded
        }

        console.log('Seeding permissions...');

        await this.permissionModel.insertMany(PERMISSION_METADATA);

        console.log(`✅ ${PERMISSION_METADATA.length} permissions seeded successfully`);
    }
}
