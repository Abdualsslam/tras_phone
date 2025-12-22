import {
    Injectable,
    NotFoundException,
    ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Role, RoleDocument } from './schemas/role.schema';
import {
    AdminUserRole,
    AdminUserRoleDocument,
} from './schemas/admin-user-role.schema';

export interface CreateRoleDto {
    name: string;
    nameAr?: string;
    description?: string;
    descriptionAr?: string;
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎭 Roles Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class RolesService {
    constructor(
        @InjectModel(Role.name)
        private roleModel: Model<RoleDocument>,
        @InjectModel(AdminUserRole.name)
        private adminUserRoleModel: Model<AdminUserRoleDocument>,
    ) { }

    /**
     * Create role
     */
    async create(createRoleDto: CreateRoleDto): Promise<RoleDocument> {
        // Check if role already exists
        const existing = await this.roleModel.findOne({ name: createRoleDto.name });

        if (existing) {
            throw new ConflictException('Role with this name already exists');
        }

        const role = await this.roleModel.create(createRoleDto);
        return role;
    }

    /**
     * Get all roles
     */
    async findAll(): Promise<RoleDocument[]> {
        return this.roleModel.find({ isActive: true }).sort({ name: 1 });
    }

    /**
     * Get role by ID
     */
    async findById(id: string): Promise<RoleDocument> {
        const role = await this.roleModel.findById(id);

        if (!role) {
            throw new NotFoundException('Role not found');
        }

        return role;
    }

    /**
     * Update role
     */
    async update(
        id: string,
        updateData: Partial<CreateRoleDto>,
    ): Promise<RoleDocument> {
        const role = await this.roleModel.findByIdAndUpdate(
            id,
            { $set: updateData },
            { new: true },
        );

        if (!role) {
            throw new NotFoundException('Role not found');
        }

        return role;
    }

    /**
     * Delete role
     */
    async delete(id: string): Promise<void> {
        const role = await this.roleModel.findById(id);

        if (!role) {
            throw new NotFoundException('Role not found');
        }

        if (role.isSystem) {
            throw new ConflictException('Cannot delete system role');
        }

        // Check if role is assigned to any admin
        const assignedCount = await this.adminUserRoleModel.countDocuments({
            roleId: id,
        });

        if (assignedCount > 0) {
            throw new ConflictException(
                `Cannot delete role. It is assigned to ${assignedCount} admin(s)`,
            );
        }

        await role.deleteOne();
    }

    /**
     * Assign role to admin
     */
    async assignToAdmin(
        adminUserId: string,
        roleId: string,
        assignedBy?: string,
    ): Promise<void> {
        // Check if already assigned
        const existing = await this.adminUserRoleModel.findOne({
            adminUserId,
            roleId,
        });

        if (existing) {
            return; // Already assigned
        }

        await this.adminUserRoleModel.create({
            adminUserId,
            roleId,
            assignedBy,
        });
    }

    /**
     * Remove role from admin
     */
    async removeFromAdmin(adminUserId: string, roleId: string): Promise<void> {
        await this.adminUserRoleModel.deleteOne({
            adminUserId,
            roleId,
        });
    }

    /**
     * Get roles for admin
     */
    async getRolesForAdmin(adminUserId: string): Promise<RoleDocument[]> {
        const adminUserRoles = await this.adminUserRoleModel
            .find({ adminUserId })
            .populate('roleId')
            .exec();

        return adminUserRoles.map((aur) => aur.roleId as any);
    }

    /**
     * Seed default roles
     */
    async seedRoles(): Promise<void> {
        const count = await this.roleModel.countDocuments();

        if (count > 0) {
            return; // Already seeded
        }

        console.log('Seeding default roles...');

        const defaultRoles = [
            {
                name: 'Super Admin',
                nameAr: 'مدير النظام',
                description: 'Full system access',
                descriptionAr: 'صلاحيات كاملة للنظام',
                isSystem: true,
            },
            {
                name: 'Manager',
                nameAr: 'مدير',
                description: 'Management access',
                descriptionAr: 'صلاحيات إدارية',
                isSystem: true,
            },
            {
                name: 'Sales Representative',
                nameAr: 'مندوب مبيعات',
                description: 'Sales and customer management',
                descriptionAr: 'إدارة المبيعات والعملاء',
                isSystem: true,
            },
            {
                name: 'Warehouse Manager',
                nameAr: 'مدير المخازن',
                description: 'Inventory and warehouse management',
                descriptionAr: 'إدارة المخزون والمستودعات',
                isSystem: true,
            },
            {
                name: 'Support Agent',
                nameAr: 'موظف دعم',
                description: 'Customer support access',
                descriptionAr: 'دعم العملاء',
                isSystem: true,
            },
        ];

        await this.roleModel.insertMany(defaultRoles);

        console.log(`✅ ${defaultRoles.length} default roles seeded successfully`);
    }
}
