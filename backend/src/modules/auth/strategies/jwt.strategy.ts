import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { AuthService } from '../auth.service';

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
        @InjectModel('AdminUser') private adminUserModel: Model<any>,
    ) {
        super({
            jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
            ignoreExpiration: false,
            secretOrKey: configService.get<string>('JWT_SECRET'),
        });
    }

    async validate(payload: any) {
        const user = await this.authService.validateUser(payload.sub);

        if (!user) {
            throw new UnauthorizedException();
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

        // If admin user, fetch admin profile for isSuperAdmin flag
        if (user.userType === 'admin') {
            const adminUser = await this.adminUserModel.findOne({ userId: user._id });
            if (adminUser) {
                userObj.isSuperAdmin = adminUser.isSuperAdmin || false;
                userObj.adminUserId = adminUser._id.toString();
                userObj.fullName = adminUser.fullName;
            }
        }

        return userObj;
    }
}
