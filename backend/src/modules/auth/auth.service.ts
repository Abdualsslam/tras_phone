import {
    Injectable,
    UnauthorizedException,
    BadRequestException,
    ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { User, UserDocument } from '@modules/users/schemas/user.schema';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 Authentication Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class AuthService {
    constructor(
        @InjectModel(User.name) private userModel: Model<UserDocument>,
        private jwtService: JwtService,
        private configService: ConfigService,
    ) { }

    /**
     * Register new user
     */
    async register(registerDto: RegisterDto) {
        const { phone, email, password, userType } = registerDto;

        // Check if user already exists
        const existingUser = await this.userModel.findOne({
            $or: [{ phone }, ...(email ? [{ email }] : [])],
        });

        if (existingUser) {
            throw new ConflictException('User with this phone or email already exists');
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
            status: 'pending', // Will be activated after OTP verification
        });

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
    async login(loginDto: LoginDto) {
        const { phone, password } = loginDto;

        // Find user with password field
        const user = await this.userModel
            .findOne({ phone })
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
        const isPasswordValid = await this.comparePassword(
            password,
            user.password,
        );

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

            const tokens = await this.generateTokens(user);

            return tokens;
        } catch (error) {
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
                secret: this.configService.get<string>('JWT_SECRET'),
                expiresIn: this.configService.get<string>('JWT_EXPIRATION'),
            }),
            this.jwtService.signAsync(payload, {
                secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
                expiresIn: this.configService.get<string>('JWT_REFRESH_EXPIRATION'),
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
}
