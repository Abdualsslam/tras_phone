import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AdminUser, AdminUserSchema } from './schemas/admin-user.schema';
import { Role, RoleSchema } from './schemas/role.schema';
import { Permission, PermissionSchema } from './schemas/permission.schema';
import {
    RolePermission,
    RolePermissionSchema,
} from './schemas/role-permission.schema';
import {
    AdminUserRole,
    AdminUserRoleSchema,
} from './schemas/admin-user-role.schema';
import { AdminsService } from './admins.service';
import { RolesService } from './roles.service';
import { PermissionsService } from './permissions.service';
import { AdminsController } from './admins.controller';
import { RolesController } from './roles.controller';
import { PermissionsGuard } from '@guards/permissions.guard';

@Module({
    imports: [
        MongooseModule.forFeature([
            { name: AdminUser.name, schema: AdminUserSchema },
            { name: Role.name, schema: RoleSchema },
            { name: Permission.name, schema: PermissionSchema },
            { name: RolePermission.name, schema: RolePermissionSchema },
            { name: AdminUserRole.name, schema: AdminUserRoleSchema },
        ]),
    ],
    controllers: [AdminsController, RolesController],
    providers: [AdminsService, RolesService, PermissionsService, PermissionsGuard],
    exports: [AdminsService, RolesService, PermissionsService, PermissionsGuard],
})
export class AdminsModule implements OnModuleInit {
    constructor(
        private rolesService: RolesService,
        private permissionsService: PermissionsService,
    ) { }

    /**
     * Seed roles and permissions on module initialization
     */
    async onModuleInit() {
        await this.rolesService.seedRoles();
        await this.permissionsService.seedPermissions();
    }
}
