import {
  Injectable,
  CanActivate,
  ExecutionContext,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { AuthService } from '@modules/auth/auth.service';
import { Customer } from '@modules/customers/schemas/customer.schema';

/**
 * Optional JWT guard - populates request.user when token is valid,
 * but does NOT throw when Token is missing or invalid (for public endpoints with optional auth)
 */
@Injectable()
export class OptionalJwtAuthGuard implements CanActivate {
  constructor(
    private jwtService: JwtService,
    private configService: ConfigService,
    private reflector: Reflector,
    private authService: AuthService,
    @InjectModel('AdminUser') private adminUserModel: Model<any>,
    @InjectModel(Customer.name) private customerModel: Model<Customer>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      return true;
    }

    try {
      const jwtSecret = this.configService.get<string>(
        'JWT_SECRET',
        'your-super-secret-jwt-key',
      );

      const payload = await this.jwtService.verifyAsync(token, {
        secret: jwtSecret,
      });

      const user = await this.authService.validateUser(payload.sub);

      if (!user) {
        return true;
      }

      const userObj: any = {
        id: user._id.toString(),
        customerId: user._id.toString(),
        phone: user.phone,
        email: user.email,
        userType: user.userType,
        status: user.status,
        isSuperAdmin: false,
        permissions: [],
      };

      if (user.userType === 'admin') {
        const adminUser = await this.adminUserModel.findOne({
          userId: user._id,
        });
        if (adminUser) {
          userObj.isSuperAdmin = adminUser.isSuperAdmin || false;
          userObj.adminUserId = adminUser._id.toString();
          userObj.fullName = adminUser.fullName;
        }
      } else {
        const customer = await this.customerModel
          .findOne({ userId: new Types.ObjectId(user._id.toString()) })
          .select('_id')
          .lean();
        if (customer) {
          userObj.customerId = (customer as any)._id.toString();
        }
      }

      request.user = userObj;
    } catch {
      // Ignore - endpoint remains accessible without auth
    }

    return true;
  }

  private extractTokenFromHeader(request: any): string | undefined {
    const authHeader = request.headers.authorization;
    if (!authHeader) return undefined;
    const [type, token] = authHeader.split(' ');
    return type === 'Bearer' ? token : undefined;
  }
}
