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
   * Helper method for retry logic with exponential backoff
   */
  private async retryWithBackoff<T>(
    operation: () => Promise<T>,
    maxRetries: number = 3,
    baseDelay: number = 100,
  ): Promise<T> {
    let lastError: any;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error: any) {
        lastError = error;

        // Only retry on duplicate key errors (11000)
        if (error?.code !== 11000) {
          throw error;
        }

        // Don't retry on the last attempt
        if (attempt === maxRetries - 1) {
          throw error;
        }

        // Calculate exponential backoff delay
        const delay = baseDelay * Math.pow(2, attempt);
        console.log(
          `[AuthService] Retry attempt ${attempt + 1}/${maxRetries} after ${delay}ms`,
        );

        // Wait before retrying
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }

    throw lastError;
  }

  /**
   * Normalize phone number for consistent comparison
   * Converts various formats to standard format: +966XXXXXXXXX
   */
  private normalizePhone(phone: string): string {
    if (!phone) return phone;

    // Remove all whitespace and special characters except + and digits
    let normalized = phone.replace(/[\s\-\(\)\.]/g, '');

    // Remove all non-digit characters except +
    normalized = normalized.replace(/[^\d+]/g, '');

    // Handle different formats:
    // 1. If it starts with +966, keep it as is
    // 2. If it starts with 966 (without +), add +
    // 3. If it starts with 0, replace with +966
    // 4. If it's 9 digits, add +966
    if (normalized.startsWith('+966')) {
      // Already in correct format
      return normalized;
    } else if (normalized.startsWith('966')) {
      // Has country code but missing +
      return '+' + normalized;
    } else if (normalized.startsWith('0') && normalized.length === 10) {
      // Local format: 05XXXXXXXX
      return '+966' + normalized.substring(1);
    } else if (normalized.length === 9) {
      // 9 digits without country code
      return '+966' + normalized;
    } else if (normalized.length === 12 && normalized.startsWith('966')) {
      // 12 digits with country code but no +
      return '+' + normalized;
    }

    // Return as is if format is unclear (should not happen with validation)
    return normalized;
  }

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

    // Normalize phone number for consistent comparison
    const normalizedPhone = this.normalizePhone(phone);

    // Check if user already exists (including deleted users to handle restoration)
    // Search with both original and normalized phone to catch any format variations
    const phoneVariations = [
      normalizedPhone,
      phone.trim(),
      phone.replace(/\s+/g, ''), // Remove spaces
      phone.replace(/[^\d+]/g, ''), // Remove all non-digit except +
    ];

    // Remove duplicates
    const uniquePhoneVariations = [...new Set(phoneVariations)];

    console.log('[AuthService] Register attempt:', {
      originalPhone: phone,
      normalizedPhone,
      phoneVariations: uniquePhoneVariations,
      email: email?.trim().toLowerCase(),
    });

    // Debug: Check all users with similar phone numbers (for debugging)
    const allUsersWithPhone = await this.userModel
      .find({
        phone: { $in: uniquePhoneVariations },
      })
      .select('_id phone email status deletedAt')
      .lean();

    console.log(
      '[AuthService] DEBUG - All users found with phone variations:',
      {
        count: allUsersWithPhone.length,
        users: allUsersWithPhone.map((u: any) => ({
          id: u._id.toString(),
          phone: u.phone,
          email: u.email,
          status: u.status,
          deletedAt: u.deletedAt,
        })),
      },
    );

    // First, check for non-deleted users only
    // Find users with matching phone (email is optional, so only check phone)
    const activeUser: UserDocument | null = await this.userModel.findOne({
      $and: [
        {
          phone: { $in: uniquePhoneVariations },
        },
        {
          $or: [{ deletedAt: null }, { deletedAt: { $exists: false } }],
        },
      ],
    });

    if (activeUser) {
      console.log('[AuthService] Found active (non-deleted) user:', {
        userId: activeUser._id,
        phone: activeUser.phone,
        email: activeUser.email,
        status: activeUser.status,
        deletedAt: activeUser.deletedAt,
      });
      throw new ConflictException('User with this phone already exists');
    }

    // Check for soft-deleted users that can be restored
    const deletedUser = await this.userModel.findOne({
      phone: { $in: uniquePhoneVariations },
      deletedAt: { $ne: null, $exists: true },
    });

    console.log('[AuthService] User search results:', {
      activeUser: (activeUser as UserDocument | null)?._id?.toString() ?? null,
      deletedUser: deletedUser?._id?.toString() ?? null,
      deletedUserDeletedAt: deletedUser?.deletedAt,
    });

    let user;
    let isRestoredUser = false;
    if (deletedUser) {
      // Restore the deleted user
      console.log('[AuthService] Restoring deleted user:', deletedUser._id);
      deletedUser.deletedAt = undefined;
      deletedUser.status = 'pending';
      deletedUser.password = await this.hashPassword(password);
      if (email) deletedUser.email = email.trim().toLowerCase();
      deletedUser.userType = userType;
      await deletedUser.save();
      user = deletedUser;
      isRestoredUser = true;
      console.log('[AuthService] User restored successfully');
    } else {
      // Hash password
      const hashedPassword = await this.hashPassword(password);

      // Generate referral code
      const referralCode = this.generateReferralCode();

      // Create new user with normalized phone
      user = await this.userModel.create({
        phone: normalizedPhone,
        email: email?.trim().toLowerCase(),
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
      try {
        // Get default price level
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

        // Use retry with backoff for customer creation
        const customer = await this.retryWithBackoff(async () => {
          // Use findOneAndUpdate with upsert for atomic operation
          const customerDoc = await this.customerModel.findOneAndUpdate(
            { userId: user._id },
            {
              $setOnInsert: {
                userId: user._id,
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
              },
            },
            {
              new: true,
              upsert: true,
              runValidators: true,
              setDefaultsOnInsert: true,
            },
          );

          if (!customerDoc) {
            throw new ConflictException('Failed to create customer profile');
          }

          return customerDoc;
        });

        // Check if this was an insert (new customer) or update (existing)
        const isNewCustomer = customer.get('wasNew', false);

        console.log('[AuthService] Customer operation:', {
          userId: user._id.toString(),
          isNewCustomer,
          customerId: customer._id.toString(),
        });

        if (!isNewCustomer) {
          // Customer already existed - this can happen if:
          // 1. User was restored from deleted state
          // 2. Previous registration attempt partially succeeded
          // Update the customer profile with new data
          customer.responsiblePersonName = responsiblePersonName;
          customer.shopName = shopName;
          if (shopNameAr) customer.shopNameAr = shopNameAr;
          customer.cityId = new Types.ObjectId(cityId);
          if (businessType) customer.businessType = businessType;
          await customer.save();

          console.log(
            '[AuthService] Customer already existed, updated with new data',
          );
        } else {
          console.log(
            `[AuthService] Customer created successfully for user: ${user._id}`,
          );
        }
      } catch (error: any) {
        console.error('[AuthService] Error creating/updating customer:', {
          error: error.message,
          errorCode: error?.code,
          userId: user._id.toString(),
          isRestoredUser,
        });

        // Rollback: delete the user if error occurred (only if it's a new user, not restored)
        if (!isRestoredUser) {
          await this.userModel.deleteOne({ _id: user._id });
        }
        throw error;
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
    const { page = 1, limit = 20, status, customerId } = filters || {};

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
  ): Promise<{
    request: PasswordResetRequestDocument;
    temporaryPassword: string;
  }> {
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
    return password
      .split('')
      .sort(() => Math.random() - 0.5)
      .join('');
  }
}
