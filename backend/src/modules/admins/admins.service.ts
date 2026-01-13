import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { AdminUser, AdminUserDocument } from './schemas/admin-user.schema';
import { RolesService } from './roles.service';
import { AuthService } from '../auth/auth.service';

export interface CreateAdminUserDto {
  userId: string;
  fullName: string;
  fullNameAr?: string;
  department?: string;
  position?: string;
  directPhone?: string;
  extension?: string;
  isSuperAdmin?: boolean;
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 👔 Admin Users Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class AdminsService {
  constructor(
    @InjectModel(AdminUser.name)
    private adminUserModel: Model<AdminUserDocument>,
    private rolesService: RolesService,
    private authService: AuthService,
  ) {}

  /**
   * Create admin user
   */
  async create(
    createAdminUserDto: CreateAdminUserDto,
  ): Promise<AdminUserDocument> {
    // Check if admin already exists for this user
    const existing = await this.adminUserModel.findOne({
      userId: createAdminUserDto.userId,
    });

    if (existing) {
      throw new ConflictException('Admin user already exists for this user');
    }

    // Generate employee code
    const employeeCode = await this.generateEmployeeCode();

    const adminUser = await this.adminUserModel.create({
      ...createAdminUserDto,
      employeeCode,
      hireDate: new Date(),
    });

    return adminUser;
  }

  /**
   * Get all admin users
   */
  async findAll(
    filters?: any,
  ): Promise<{ data: AdminUserDocument[]; total: number }> {
    const {
      page = 1,
      limit = 20,
      search,
      department,
      employmentStatus,
    } = filters || {};

    const query: any = {};

    if (search) {
      query.$text = { $search: search };
    }

    if (department) {
      query.department = department;
    }

    if (employmentStatus) {
      query.employmentStatus = employmentStatus;
    }

    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      this.adminUserModel
        .find(query)
        .populate('userId', 'phone email')
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 }),
      this.adminUserModel.countDocuments(query),
    ]);

    return { data, total };
  }

  /**
   * Get admin by ID
   */
  async findById(id: string): Promise<AdminUserDocument> {
    const adminUser = await this.adminUserModel
      .findById(id)
      .populate('userId', 'phone email avatar');

    if (!adminUser) {
      throw new NotFoundException('Admin user not found');
    }

    return adminUser;
  }

  /**
   * Get admin by user ID
   */
  async findByUserId(userId: string): Promise<AdminUserDocument | null> {
    return this.adminUserModel.findOne({ userId });
  }

  /**
   * Update admin user
   */
  async update(
    id: string,
    updateData: Partial<CreateAdminUserDto>,
  ): Promise<AdminUserDocument> {
    const adminUser = await this.adminUserModel.findByIdAndUpdate(
      id,
      { $set: updateData },
      { new: true },
    );

    if (!adminUser) {
      throw new NotFoundException('Admin user not found');
    }

    return adminUser;
  }

  /**
   * Delete admin user
   */
  async delete(id: string): Promise<void> {
    const result = await this.adminUserModel.deleteOne({ _id: id });

    if (result.deletedCount === 0) {
      throw new NotFoundException('Admin user not found');
    }
  }

  /**
   * Get admin with roles and permissions
   */
  async getAdminWithPermissions(adminUserId: string) {
    const adminUser = await this.findById(adminUserId);

    // If super admin, return all permissions
    if (adminUser.isSuperAdmin) {
      return {
        adminUser,
        roles: [],
        permissions: ['*'], // All permissions
        isSuperAdmin: true,
      };
    }

    // Get roles
    const roles = await this.rolesService.getRolesForAdmin(adminUserId);

    // Get all permissions from all roles (deduplicated)
    const permissionsSet = new Set<string>();

    for (const role of roles) {
      // This would require PermissionsService - simplified for now
      // const perms = await this.permissionsService.getPermissionsForRole(role.id);
      // perms.forEach(p => permissionsSet.add(p.name));
    }

    return {
      adminUser,
      roles,
      permissions: Array.from(permissionsSet),
      isSuperAdmin: false,
    };
  }

  /**
   * Create admin user with new user account
   */
  async createWithUser(
    createAdminWithUserDto: any,
  ): Promise<AdminUserDocument> {
    // Create user account first
    const result = await this.authService.register({
      phone: createAdminWithUserDto.phone,
      email: createAdminWithUserDto.email,
      password: createAdminWithUserDto.password,
      userType: 'admin',
    });

    // Create admin profile
    const adminData = {
      userId: result.user._id.toString(),
      fullName: createAdminWithUserDto.fullName,
      fullNameAr: createAdminWithUserDto.fullNameAr,
      department: createAdminWithUserDto.department,
      position: createAdminWithUserDto.position,
      directPhone: createAdminWithUserDto.directPhone,
      extension: createAdminWithUserDto.extension,
      isSuperAdmin: createAdminWithUserDto.isSuperAdmin || false,
      canAccessMobile: createAdminWithUserDto.canAccessMobile || false,
      canAccessWeb: createAdminWithUserDto.canAccessWeb !== false, // default true
    };

    return this.create(adminData);
  }

  /**
   * Generate employee code
   */
  private async generateEmployeeCode(): Promise<string> {
    const prefix = 'EMP';
    const date = new Date();
    const year = date.getFullYear().toString().slice(-2);

    const count = await this.adminUserModel.countDocuments();
    const sequence = (count + 1).toString().padStart(4, '0');

    return `${prefix}${year}${sequence}`;
  }
}
