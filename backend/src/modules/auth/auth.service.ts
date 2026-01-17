import {
  Injectable,
  UnauthorizedException,
  BadRequestException,
  ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { User, UserDocument } from '@modules/users/schemas/user.schema';
import {
  UserSession,
  UserSessionDocument,
} from './schemas/user-session.schema';
import {
  LoginAttempt,
  LoginAttemptDocument,
} from './schemas/login-attempt.schema';
import {
  AdminUser,
  AdminUserDocument,
} from '@modules/admins/schemas/admin-user.schema';
import {
  Customer,
  CustomerDocument,
} from '@modules/customers/schemas/customer.schema';
import {
  PriceLevel,
  PriceLevelDocument,
} from '@modules/products/schemas/price-level.schema';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { UpdateFcmTokenDto } from './dto/update-fcm-token.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 Authentication Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class AuthService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    @InjectModel(UserSession.name)
    private sessionModel: Model<UserSessionDocument>,
    @InjectModel(LoginAttempt.name)
    private loginAttemptModel: Model<LoginAttemptDocument>,
    @InjectModel(AdminUser.name)
    private adminUserModel: Model<AdminUserDocument>,
    @InjectModel(Customer.name)
    private customerModel: Model<CustomerDocument>,
    @InjectModel(PriceLevel.name)
    private priceLevelModel: Model<PriceLevelDocument>,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  /**
   * Register new user
   */
  async register(registerDto: RegisterDto) {
    const {
      phone,
      email,
      password,
      userType,
      responsiblePersonName,
      shopName,
      shopNameAr,
      cityId,
      businessType,
    } = registerDto;

    // Check if user already exists
    const existingUser = await this.userModel.findOne({
      $or: [{ phone }, ...(email ? [{ email }] : [])],
    });

    if (existingUser) {
      throw new ConflictException(
        'User with this phone or email already exists',
      );
    }

    // Hash password
    const hashedPassword = await this.hashPassword(password);

    // Generate referral code
    const referralCode = this.generateReferralCode();

    // Create user
    const user = await this.userModel.create({
      phone,
      email,
      password: hashedPassword,
      userType,
      referralCode,
      status: 'pending', // Will be activated after admin approval
    });

    // If customer type and customer profile data is provided, create customer profile
    if (
      userType === 'customer' &&
      responsiblePersonName &&
      shopName &&
      cityId
    ) {
      try {
        // Generate customer code
        const customerCode = await this.generateCustomerCode();

        // Get default price level
        const defaultPriceLevel = await this.priceLevelModel.findOne({
          isDefault: true,
          isActive: true,
        });

        if (!defaultPriceLevel) {
          throw new BadRequestException(
            'Default price level not found. Please contact support.',
          );
        }

        // Create customer profile
        await this.customerModel.create({
          userId: user._id,
          customerCode,
          responsiblePersonName,
          shopName,
          shopNameAr,
          cityId: new Types.ObjectId(cityId),
          businessType: businessType || 'shop',
          priceLevelId: defaultPriceLevel._id,
          creditLimit: 0,
          walletBalance: 0,
          loyaltyPoints: 0,
          loyaltyTier: 'bronze',
          preferredContactMethod: 'whatsapp',
        });
      } catch (error) {
        // Log error but don't fail registration if customer creation fails
        console.error('Failed to create customer profile:', error);
        // Optionally, you could delete the user here if customer creation is critical
      }
    }

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      user: user.toJSON(),
      ...tokens,
    };
  }

  /**
   * Login user
   */
  async login(loginDto: LoginDto, ipAddress?: string, userAgent?: string) {
    const { phone, password } = loginDto;

    // Find user with password field
    const user = await this.userModel
      .findOne({ phone })
      .select('+password')
      .exec();

    if (!user) {
      // Log failed attempt
      await this.logLoginAttempt({
        identifier: phone,
        identifierType: 'phone',
        ipAddress: ipAddress || 'unknown',
        userAgent,
        status: 'failed',
        failureReason: 'User not found',
      });
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check if account is suspended or deleted
    if (user.status === 'suspended') {
      await this.logLoginAttempt({
        identifier: phone,
        identifierType: 'phone',
        ipAddress: ipAddress || 'unknown',
        userAgent,
        status: 'blocked',
        failureReason: 'Account suspended',
      });
      throw new UnauthorizedException('Your account has been suspended');
    }

    if (user.status === 'deleted') {
      await this.logLoginAttempt({
        identifier: phone,
        identifierType: 'phone',
        ipAddress: ipAddress || 'unknown',
        userAgent,
        status: 'blocked',
        failureReason: 'Account deleted',
      });
      throw new UnauthorizedException('Your account has been deleted');
    }

    // Check if account is pending (under review)
    if (user.status === 'pending') {
      await this.logLoginAttempt({
        identifier: phone,
        identifierType: 'phone',
        ipAddress: ipAddress || 'unknown',
        userAgent,
        status: 'blocked',
        failureReason: 'Account pending review',
      });
      throw new UnauthorizedException(
        'Your account is under review. Please wait for activation',
      );
    }

    // Check if account is active (must be active to login)
    if (user.status !== 'active') {
      await this.logLoginAttempt({
        identifier: phone,
        identifierType: 'phone',
        ipAddress: ipAddress || 'unknown',
        userAgent,
        status: 'blocked',
        failureReason: `Account status is ${user.status}`,
      });
      throw new UnauthorizedException(
        'Your account is not active. Please verify your account or contact support',
      );
    }

    // Check if account is locked
    if (user.lockedUntil && user.lockedUntil > new Date()) {
      const minutesLeft = Math.ceil(
        (user.lockedUntil.getTime() - Date.now()) / 60000,
      );
      await this.logLoginAttempt({
        identifier: phone,
        identifierType: 'phone',
        ipAddress: ipAddress || 'unknown',
        userAgent,
        status: 'blocked',
        failureReason: 'Account locked',
      });
      throw new UnauthorizedException(
        `Account is locked. Try again in ${minutesLeft} minutes`,
      );
    }

    // Verify password
    const isPasswordValid = await this.comparePassword(password, user.password);

    if (!isPasswordValid) {
      // Increment failed login attempts
      await this.handleFailedLogin(user);
      // Log failed attempt
      await this.logLoginAttempt({
        identifier: phone,
        identifierType: 'phone',
        ipAddress: ipAddress || 'unknown',
        userAgent,
        status: 'failed',
        failureReason: 'Invalid password',
      });
      throw new UnauthorizedException('Invalid credentials');
    }

    // Reset failed login attempts
    if (user.failedLoginAttempts > 0) {
      user.failedLoginAttempts = 0;
      user.lockedUntil = undefined;
      await user.save();
    }

    // Update last login
    user.lastLoginAt = new Date();
    user.lastLoginIp = ipAddress;
    await user.save();

    // Log successful attempt
    await this.logLoginAttempt({
      identifier: phone,
      identifierType: 'phone',
      ipAddress: ipAddress || 'unknown',
      userAgent,
      status: 'success',
    });

    // Generate tokens
    const tokens = await this.generateTokens(user);

    // Create session
    const session = await this.createSession(
      user._id,
      tokens.accessToken,
      ipAddress,
      userAgent,
    );

    return {
      user: user.toJSON(),
      ...tokens,
      sessionId: session._id.toString(),
    };
  }

  /**
   * Login admin by email
   */
  async adminLogin(email: string, password: string) {
    // Find admin user by email
    const user = await this.userModel
      .findOne({ email, userType: 'admin' })
      .select('+password')
      .exec();

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Check if account is suspended or deleted
    if (user.status === 'suspended') {
      throw new UnauthorizedException('Your account has been suspended');
    }

    if (user.status === 'deleted') {
      throw new UnauthorizedException('Your account has been deleted');
    }

    // Check if account is pending (under review)
    if (user.status === 'pending') {
      throw new UnauthorizedException(
        'Your account is under review. Please wait for activation',
      );
    }

    // Check if account is active (must be active to login)
    if (user.status !== 'active') {
      throw new UnauthorizedException(
        'Your account is not active. Please verify your account or contact support',
      );
    }

    // Check if account is locked
    if (user.lockedUntil && user.lockedUntil > new Date()) {
      const minutesLeft = Math.ceil(
        (user.lockedUntil.getTime() - Date.now()) / 60000,
      );
      throw new UnauthorizedException(
        `Account is locked. Try again in ${minutesLeft} minutes`,
      );
    }

    // Verify password
    const isPasswordValid = await this.comparePassword(password, user.password);

    if (!isPasswordValid) {
      // Increment failed login attempts
      await this.handleFailedLogin(user);
      throw new UnauthorizedException('Invalid credentials');
    }

    // Reset failed login attempts
    if (user.failedLoginAttempts > 0) {
      user.failedLoginAttempts = 0;
      user.lockedUntil = undefined;
      await user.save();
    }

    // Update last login
    user.lastLoginAt = new Date();
    await user.save();

    // Generate tokens
    const tokens = await this.generateTokens(user);

    return {
      user: user.toJSON(),
      ...tokens,
    };
  }

  /**
   * Refresh access token
   */
  async refreshToken(refreshToken: string) {
    try {
      const payload = await this.jwtService.verifyAsync(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      const user = await this.userModel.findById(payload.sub);

      if (!user) {
        throw new UnauthorizedException('User not found');
      }

      // Check if account is active before refreshing token
      if (user.status !== 'active') {
        throw new UnauthorizedException('Your account is not active');
      }

      const tokens = await this.generateTokens(user);

      return tokens;
    } catch (error) {
      // If it's already an UnauthorizedException, rethrow it as-is
      if (error instanceof UnauthorizedException) {
        throw error;
      }
      // Otherwise, it's an invalid token format/verification error
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  /**
   * Validate user by ID (used by JWT strategy)
   */
  async validateUser(userId: string): Promise<UserDocument> {
    const user = await this.userModel.findById(userId);

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    if (user.status !== 'active') {
      throw new UnauthorizedException('User  account is not active');
    }

    return user;
  }

  /**
   * Get full user profile with admin details if applicable
   */
  async getFullUserProfile(userId: string): Promise<any> {
    const user = await this.userModel.findById(userId);

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    if (user.status !== 'active') {
      throw new UnauthorizedException('User account is not active');
    }

    // Build base user object
    const userObj: any = user.toJSON();

    // If admin user, fetch admin profile for additional details
    if (user.userType === 'admin') {
      const adminUser = await this.adminUserModel.findOne({ userId: user._id });
      if (adminUser) {
        userObj.isSuperAdmin = adminUser.isSuperAdmin || false;
        userObj.adminUserId = adminUser._id.toString();
        userObj.fullName = adminUser.fullName;
        userObj.permissions = []; // Permissions are managed through roles, not directly on AdminUser
      }
    }

    return userObj;
  }

  /**
   * Generate JWT tokens
   */
  private async generateTokens(user: UserDocument) {
    const payload = {
      sub: user._id.toString(),
      phone: user.phone,
      userType: user.userType,
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>(
          'JWT_SECRET',
          'your-super-secret-jwt-key',
        ),
        expiresIn: this.configService.get<string>('JWT_EXPIRATION', '7d'),
      }),
      this.jwtService.signAsync(payload, {
        secret: this.configService.get<string>(
          'JWT_REFRESH_SECRET',
          'your-super-secret-refresh-key',
        ),
        expiresIn: this.configService.get<string>(
          'JWT_REFRESH_EXPIRATION',
          '30d',
        ),
      }),
    ]);

    return {
      accessToken,
      refreshToken,
      expiresIn: this.configService.get<string>('JWT_EXPIRATION'),
    };
  }

  /**
   * Hash password
   */
  private async hashPassword(password: string): Promise<string> {
    const salt = await bcrypt.genSalt(
      this.configService.get<number>('BCRYPT_ROUNDS', 12),
    );
    return bcrypt.hash(password, salt);
  }

  /**
   * Compare password
   */
  private async comparePassword(
    password: string,
    hashedPassword: string,
  ): Promise<boolean> {
    return bcrypt.compare(password, hashedPassword);
  }

  /**
   * Handle failed login attempt
   */
  private async handleFailedLogin(user: UserDocument) {
    user.failedLoginAttempts += 1;

    // Lock account after 5 failed attempts
    if (user.failedLoginAttempts >= 5) {
      user.lockedUntil = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes
    }

    await user.save();
  }

  /**
   * Generate unique referral code
   */
  private generateReferralCode(): string {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    let code = '';

    for (let i = 0; i < 8; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }

    return code;
  }

  /**
   * Generate unique customer code
   */
  private async generateCustomerCode(): Promise<string> {
    const prefix = 'CUS';
    const date = new Date();
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');

    // Get count of customers created this month
    const count = await this.customerModel.countDocuments({
      createdAt: {
        $gte: new Date(date.getFullYear(), date.getMonth(), 1),
      },
    });

    const sequence = (count + 1).toString().padStart(4, '0');

    return `${prefix}${year}${month}${sequence}`;
  }

  /**
   * Update FCM token
   */
  async updateFcmToken(userId: string, updateFcmTokenDto: UpdateFcmTokenDto) {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    user.fcmToken = updateFcmTokenDto.fcmToken;
    if (updateFcmTokenDto.deviceInfo) {
      user.deviceInfo = updateFcmTokenDto.deviceInfo;
    }
    await user.save();

    return { message: 'FCM token updated successfully' };
  }

  /**
   * Get user sessions
   */
  async getUserSessions(userId: string) {
    const sessions = await this.sessionModel
      .find({ userId: new Types.ObjectId(userId) })
      .sort({ lastActivityAt: -1 })
      .lean();

    return sessions;
  }

  /**
   * Logout user (delete current session by token)
   */
  async logout(userId: string, token: string) {
    // Extract token ID (first 32 characters, same as in createSession)
    const tokenId = token.substring(0, 32);

    // Delete session by tokenId and userId
    await this.sessionModel.deleteOne({
      userId: new Types.ObjectId(userId),
      tokenId,
    });

    return { message: 'Logout successful' };
  }

  /**
   * Delete user session
   */
  async deleteSession(userId: string, sessionId: string) {
    const session = await this.sessionModel.findOne({
      _id: sessionId,
      userId: new Types.ObjectId(userId),
    });

    if (!session) {
      throw new BadRequestException('Session not found');
    }

    await this.sessionModel.deleteOne({ _id: sessionId });
    return { message: 'Session deleted successfully' };
  }

  /**
   * Create user session
   */
  private async createSession(
    userId: Types.ObjectId,
    token: string,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<UserSessionDocument> {
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 30); // 30 days

    // Generate unique token ID using timestamp + random string
    const tokenId = `${Date.now()}-${Math.random().toString(36).substring(2, 15)}`;

    // Use findOneAndUpdate with upsert to avoid duplicate key errors
    const session = await this.sessionModel.findOneAndUpdate(
      { tokenId },
      {
        userId,
        tokenId,
        ipAddress,
        userAgent,
        expiresAt,
        lastActivityAt: new Date(),
      },
      { upsert: true, new: true },
    );

    return session;
  }

  /**
   * Log login attempt
   */
  private async logLoginAttempt(data: {
    identifier: string;
    identifierType: 'phone' | 'email' | 'ip';
    ipAddress: string;
    userAgent?: string;
    status: 'success' | 'failed' | 'blocked';
    failureReason?: string;
  }) {
    await this.loginAttemptModel.create(data);
  }

  /**
   * Change password (for authenticated users)
   */
  async changePassword(
    userId: string,
    oldPassword: string,
    newPassword: string,
  ): Promise<void> {
    // Find user with password
    const user = await this.userModel.findById(userId).select('+password');

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    // Verify old password
    const isPasswordValid = await this.comparePassword(
      oldPassword,
      user.password,
    );

    if (!isPasswordValid) {
      throw new BadRequestException('Current password is incorrect');
    }

    // Check if new password is same as old
    const isSamePassword = await this.comparePassword(
      newPassword,
      user.password,
    );

    if (isSamePassword) {
      throw new BadRequestException(
        'New password must be different from current password',
      );
    }

    // Hash new password
    const hashedPassword = await this.hashPassword(newPassword);

    // Update password
    user.password = hashedPassword;
    await user.save();
  }

  /**
   * Reset user password by admin (for admin panel)
   */
  async resetUserPasswordByAdmin(
    userId: string,
    newPassword: string,
  ): Promise<void> {
    // Find user
    const user = await this.userModel.findById(userId);

    if (!user) {
      throw new UnauthorizedException('User not found');
    }

    // Hash new password
    const hashedPassword = await this.hashPassword(newPassword);

    // Update password
    user.password = hashedPassword;
    await user.save();
  }
}
