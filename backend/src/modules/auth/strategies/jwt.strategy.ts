import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { AuthService } from '../auth.service';
import {
  AUTH_ERROR_CODES,
  buildAuthUnauthorizedException,
} from '../auth-errors';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 JWT Strategy
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private configService: ConfigService,
    private authService: AuthService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>(
        'JWT_SECRET',
        'your-super-secret-jwt-key-change-in-production',
      ),
    });
  }

  async validate(payload: any) {
    const user = await this.authService.validateUser(payload.sub);

    if (!user) {
      throw buildAuthUnauthorizedException({
        code: AUTH_ERROR_CODES.USER_NOT_FOUND,
      });
    }

    // Build base user object
    const userObj: any = {
      id: user._id.toString(),
      phone: user.phone,
      email: user.email,
      userType: user.userType,
      status: user.status,
      isSuperAdmin: false,
      permissions: [],
    };

    // If admin user, fetch admin access profile (roles + permissions)
    if (user.userType === 'admin') {
      const adminAccess = await this.authService.getAdminAccessProfile(
        user._id.toString(),
      );

      if (adminAccess) {
        userObj.isSuperAdmin = adminAccess.isSuperAdmin;
        userObj.adminUserId = adminAccess.adminUserId;
        userObj.fullName = adminAccess.fullName;
        userObj.department = adminAccess.department;
        userObj.canAccessWeb = adminAccess.canAccessWeb;
        userObj.canAccessMobile = adminAccess.canAccessMobile;
        userObj.roles = adminAccess.roles;
        userObj.permissions = adminAccess.permissions;
      }
    }

    return userObj;
  }
}
