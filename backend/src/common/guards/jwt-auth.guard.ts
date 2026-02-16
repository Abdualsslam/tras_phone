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
import { Model, Types } from 'mongoose';
import { IS_PUBLIC_KEY } from '@decorators/public.decorator';
import { AuthService } from '@modules/auth/auth.service';
import { Customer } from '@modules/customers/schemas/customer.schema';

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
    @InjectModel(Customer.name) private customerModel: Model<Customer>,
  ) {}

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
      const jwtSecret = this.configService.get<string>(
        'JWT_SECRET',
        'your-super-secret-jwt-key',
      );

      const payload = await this.jwtService.verifyAsync(token, {
        secret: jwtSecret,
      });

      // Validate user exists and is active
      const user = await this.authService.validateUser(payload.sub);

      if (!user) {
        console.error(`[JwtAuthGuard] User not found: ${payload.sub}`);
        throw new UnauthorizedException('User not found');
      }

      // Build base user object
      const userObj: any = {
        id: user._id.toString(),
        customerId: user._id.toString(), // default; overwritten below for customers
        phone: user.phone,
        email: user.email,
        userType: user.userType,
        status: user.status,
        isSuperAdmin: false,
        permissions: [],
      };

      if (user.userType === 'admin') {
        const adminAccessProfile = await this.authService.getAdminAccessProfile(
          user._id.toString(),
        );

        if (adminAccessProfile) {
          userObj.isSuperAdmin = adminAccessProfile.isSuperAdmin;
          userObj.adminUserId = adminAccessProfile.adminUserId;
          userObj.adminId = adminAccessProfile.adminUserId;
          userObj.fullName = adminAccessProfile.fullName;
          userObj.canAccessWeb = adminAccessProfile.canAccessWeb;
          userObj.canAccessMobile = adminAccessProfile.canAccessMobile;
          userObj.roles = adminAccessProfile.roles;
          userObj.permissions = adminAccessProfile.permissions;
        }
      } else {
        // Customer (app user): resolve real Customer _id and profile for tickets/support
        const customer = await this.customerModel
          .findOne({ userId: new Types.ObjectId(user._id.toString()) })
          .select('_id responsiblePersonName shopName')
          .lean();
        if (customer) {
          const cust = customer as any;
          userObj.customerId = cust._id.toString();
          // Name for tickets/support (required by Ticket schema)
          userObj.name = cust.responsiblePersonName || cust.shopName || user.phone;
        }
        // Email for tickets: User.email or fallback to phone (contact identifier)
        if (!userObj.email && user.phone) {
          userObj.email = user.phone;
        }
      }

      request.user = userObj;

      return true;
    } catch (error) {
      // Log the actual error for debugging
      console.error('[JwtAuthGuard] Authentication error:', {
        error: error instanceof Error ? error.message : String(error),
        errorName: error instanceof Error ? error.name : typeof error,
        stack: error instanceof Error ? error.stack : undefined,
      });

      // If it's already an UnauthorizedException, re-throw it as is
      if (error instanceof UnauthorizedException) {
        throw error;
      }

      // For JWT verification errors, provide more context
      const errorMessage =
        error instanceof Error ? error.message : String(error);
      throw new UnauthorizedException(
        `Invalid or expired token: ${errorMessage}`,
      );
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
