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
import {
  PasswordResetRequest,
  PasswordResetRequestDocument,
} from './schemas/password-reset-request.schema';
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
    @InjectModel(PasswordResetRequest.name)
    private passwordResetRequestModel: Model<PasswordResetRequestDocument>,
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

    // Check if user already exists (including deleted users to handle restoration)
    const existingUser = await this.userModel.findOne({
      $or: [{ phone }, ...(email ? [{ email }] : [])],
    });

    let user;
    let isRestoredUser = false;
    if (existingUser) {
      // If user is deleted, we can restore it
      if (existingUser.deletedAt) {
        // Restore the deleted user
        existingUser.deletedAt = undefined;
        existingUser.status = 'pending';
        existingUser.password = await this.hashPassword(password);
        if (email) existingUser.email = email;
        existingUser.userType = userType;
        await existingUser.save();
        user = existingUser;
        isRestoredUser = true;
      } else {
        // User exists and is not deleted
        throw new ConflictException(
          'User with this phone or email already exists',
        );
      }
    } else {
      // Hash password
      const hashedPassword = await this.hashPassword(password);

      // Generate referral code
      const referralCode = this.generateReferralCode();

      // Create new user
      user = await this.userModel.create({
        phone,
        email,
        password: hashedPassword,
        userType,
        referralCode,
        status: 'pending', // Will be activated after admin approval
      });
    }

    // If customer type and customer profile data is provided, create or update customer profile
    if (
      userType === 'customer' &&
      responsiblePersonName &&
      shopName &&
      cityId
    ) {
      // Check if customer already exists
      const existingCustomer = await this.customerModel.findOne({
        userId: user._id,
      });
      
      if (existingCustomer) {
        // Customer already exists - this can happen if:
        // 1. User was restored from deleted state
        // 2. Previous registration attempt partially succeeded
        // Update the customer profile with new data
        existingCustomer.responsiblePersonName = responsiblePersonName;
        existingCustomer.shopName = shopName;
        if (shopNameAr) existingCustomer.shopNameAr = shopNameAr;
        existingCustomer.cityId = new Types.ObjectId(cityId);
        if (businessType) existingCustomer.businessType = businessType;
        await existingCustomer.save();
      } else {
        // Create new customer profile
        try {
          const customerCode = await this.generateCustomerCode();
          const defaultPriceLevel = await this.priceLevelModel.findOne({
            isDefault: true,
            isActive: true,
          });

          if (!defaultPriceLevel) {
            // Rollback: delete the user if price level not found (only if it's a new user, not restored)
            if (!isRestoredUser) {
              await this.userModel.deleteOne({ _id: user._id });
            }
            throw new BadRequestException(
              'Default price level not found. Please contact support.',
            );
          }

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
        } catch (error: any) {
          // Rollback: delete the user if customer creation fails (only if it's a new user, not restored)
          if (!isRestoredUser) {
            await this.userModel.deleteOne({ _id: user._id });
          }
          
          if (error?.code === 11000) {
            // Duplicate key error - customer was created between check and create
            // This is a race condition, but we can handle it by updating instead
            const raceConditionCustomer = await this.customerModel.findOne({
              userId: user._id,
            });
            if (raceConditionCustomer) {
              // Update existing customer
              raceConditionCustomer.responsiblePersonName = responsiblePersonName;
              raceConditionCustomer.shopName = shopName;
              if (shopNameAr) raceConditionCustomer.shopNameAr = shopNameAr;
              raceConditionCustomer.cityId = new Types.ObjectId(cityId);
              if (businessType) raceConditionCustomer.businessType = businessType;
              await raceConditionCustomer.save();
            } else {
              throw new ConflictException(
                'Customer already exists for this user. Please try again.',
              );
            }
          } else {
            // Re-throw other errors (like BadRequestException)
            throw error;
          }
        }
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

    // Check if customer is rejected (for customers only) - must check before other status checks
    if (user.userType === 'customer') {
      const customer = await this.customerModel.findOne({ userId: user._id });
      if (customer && customer.rejectionReason) {
        await this.logLoginAttempt({
          identifier: phone,
          identifierType: 'phone',
          ipAddress: ipAddress || 'unknown',
          userAgent,
          status: 'blocked',
          failureReason: 'Account rejected',
        });
        throw new UnauthorizedException('Your account has been rejected');
      }
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

  // ═════════════════════════════════════
  // Password Reset Requests (New Flow)
  // ═════════════════════════════════════

  /**
   * Request password reset (customer)
   */
  async requestPasswordReset(
    phone: string,
    customerNotes?: string,
  ): Promise<PasswordResetRequestDocument> {
    // Find user by phone
    const user = await this.userModel.findOne({ phone });

    if (!user) {
      throw new BadRequestException('User not found');
    }

    // Check if there's already a pending request for this user
    const existingRequest = await this.passwordResetRequestModel.findOne({
      customerId: user._id,
      status: 'pending',
    });

    if (existingRequest) {
      throw new ConflictException(
        'A password reset request is already pending. Please wait for admin to process it.',
      );
    }

    // Generate request number
    const requestNumber = await this.generatePasswordResetRequestNumber();

    // Create password reset request
    const request = await this.passwordResetRequestModel.create({
      requestNumber,
      customerId: user._id,
      phone: user.phone,
      status: 'pending',
      customerNotes,
    });

    return request;
  }

  /**
   * Get password reset requests (admin)
   */
  async getPasswordResetRequests(filters?: {
    status?: string;
    customerId?: string;
    page?: number;
    limit?: number;
  }): Promise<{ data: PasswordResetRequestDocument[]; total: number }> {
    const {
      page = 1,
      limit = 20,
      status,
      customerId,
    } = filters || {};

    const query: any = {};
    if (status) query.status = status;
    if (customerId) query.customerId = customerId;

    const [data, total] = await Promise.all([
      this.passwordResetRequestModel
        .find(query)
        .populate('customerId', 'phone email')
        .populate('processedBy', 'fullName email')
        .skip((page - 1) * limit)
        .limit(limit)
        .sort({ createdAt: -1 }),
      this.passwordResetRequestModel.countDocuments(query),
    ]);

    return { data, total };
  }

  /**
   * Get password reset request by ID (admin)
   */
  async getPasswordResetRequestById(
    id: string,
  ): Promise<PasswordResetRequestDocument> {
    const request = await this.passwordResetRequestModel
      .findById(id)
      .populate('customerId', 'phone email')
      .populate('processedBy', 'fullName email');

    if (!request) {
      throw new BadRequestException('Password reset request not found');
    }

    return request;
  }

  /**
   * Process password reset request (admin)
   */
  async processPasswordResetRequest(
    requestId: string,
    adminId: string,
    adminNotes?: string,
  ): Promise<{ request: PasswordResetRequestDocument; temporaryPassword: string }> {
    const request = await this.passwordResetRequestModel.findById(requestId);

    if (!request) {
      throw new BadRequestException('Password reset request not found');
    }

    if (request.status !== 'pending') {
      throw new BadRequestException(
        `Request is already ${request.status}. Cannot process it again.`,
      );
    }

    // Find user
    const user = await this.userModel.findById(request.customerId);
    if (!user) {
      throw new BadRequestException('User not found');
    }

    // Generate temporary password
    const temporaryPassword = this.generateTemporaryPassword();

    // Hash temporary password
    const hashedPassword = await this.hashPassword(temporaryPassword);

    // Update user password
    user.password = hashedPassword;
    await user.save();

    // Update request
    request.status = 'completed';
    request.temporaryPassword = hashedPassword;
    request.temporaryPasswordPlain = temporaryPassword; // Store plain text temporarily for admin to copy
    request.processedBy = new Types.ObjectId(adminId);
    request.processedAt = new Date();
    if (adminNotes) {
      request.adminNotes = adminNotes;
    }
    await request.save();

    return { request, temporaryPassword };
  }

  /**
   * Reject password reset request (admin)
   */
  async rejectPasswordResetRequest(
    requestId: string,
    adminId: string,
    rejectionReason: string,
    adminNotes?: string,
  ): Promise<PasswordResetRequestDocument> {
    const request = await this.passwordResetRequestModel.findById(requestId);

    if (!request) {
      throw new BadRequestException('Password reset request not found');
    }

    if (request.status !== 'pending') {
      throw new BadRequestException(
        `Request is already ${request.status}. Cannot reject it.`,
      );
    }

    // Update request
    request.status = 'rejected';
    request.processedBy = new Types.ObjectId(adminId);
    request.processedAt = new Date();
    request.rejectionReason = rejectionReason;
    if (adminNotes) {
      request.adminNotes = adminNotes;
    }
    await request.save();

    return request;
  }

  /**
   * Generate password reset request number
   */
  private async generatePasswordResetRequestNumber(): Promise<string> {
    const date = new Date();
    const prefix = 'PWR';
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');

    const count = await this.passwordResetRequestModel.countDocuments({
      createdAt: {
        $gte: new Date(date.getFullYear(), date.getMonth(), 1),
      },
    });

    return `${prefix}${year}${month}${(count + 1).toString().padStart(4, '0')}`;
  }

  /**
   * Generate temporary password
   */
  private generateTemporaryPassword(): string {
    // Generate a random password: 12 characters with mix of letters and numbers
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '@$!%*?&';
    
    // Ensure at least one of each required character type
    let password = '';
    password += uppercase[Math.floor(Math.random() * uppercase.length)];
    password += lowercase[Math.floor(Math.random() * lowercase.length)];
    password += numbers[Math.floor(Math.random() * numbers.length)];
    password += special[Math.floor(Math.random() * special.length)];
    
    // Fill the rest randomly
    const allChars = uppercase + lowercase + numbers + special;
    for (let i = password.length; i < 12; i++) {
      password += allChars[Math.floor(Math.random() * allChars.length)];
    }
    
    // Shuffle the password
    return password.split('').sort(() => Math.random() - 0.5).join('');
  }
}
