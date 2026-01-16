import {
    Injectable,
    CanActivate,
    ExecutionContext,
    UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { IS_PUBLIC_KEY } from '@decorators/public.decorator';
import { AuthService } from '@modules/auth/auth.service';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 JWT Authentication Guard
 * ═══════════════════════════════════════════════════════════════
 * Protects routes by validating JWT tokens
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
    constructor(
        private jwtService: JwtService,
        private configService: ConfigService,
        private reflector: Reflector,
        private authService: AuthService,
        @InjectModel('AdminUser') private adminUserModel: Model<any>,
    ) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        // Check if route is marked as public
        const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
            context.getHandler(),
            context.getClass(),
        ]);

        if (isPublic) {
            return true;
        }

        const request = context.switchToHttp().getRequest();
        const token = this.extractTokenFromHeader(request);

        if (!token) {
            throw new UnauthorizedException('Access token not found');
        }

        try {
            const payload = await this.jwtService.verifyAsync(token, {
                secret: this.configService.get<string>('JWT_SECRET', 'your-super-secret-jwt-key'),
            });

            // Validate user exists and is active
            const user = await this.authService.validateUser(payload.sub);

            if (!user) {
                throw new UnauthorizedException('User not found');
            }

            // Build base user object
            const userObj: any = {
                id: user._id.toString(),
                customerId: user._id.toString(), // For customer type, customerId is the same as id
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

            request.user = userObj;

            return true;
        } catch (error) {
            throw new UnauthorizedException('Invalid or expired token');
        }
    }

    /**
     * Extract JWT token from Authorization header
     */
    private extractTokenFromHeader(request: any): string | undefined {
        const authHeader = request.headers.authorization;

        if (!authHeader) {
            return undefined;
        }

        const [type, token] = authHeader.split(' ');

        return type === 'Bearer' ? token : undefined;
    }
}
