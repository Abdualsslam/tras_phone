import {
    Injectable,
    NotFoundException,
    BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { randomBytes } from 'crypto';
import {
    PasswordReset,
    PasswordResetDocument,
} from './schemas/password-reset.schema';
import { User, UserDocument } from '@modules/users/schemas/user.schema';
import { OtpService } from './otp.service';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔑 Password Reset Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class PasswordResetService {
    constructor(
        @InjectModel(PasswordReset.name)
        private passwordResetModel: Model<PasswordResetDocument>,
        @InjectModel(User.name)
        private userModel: Model<UserDocument>,
        private otpService: OtpService,
        private configService: ConfigService,
    ) { }

    /**
     * Request password reset (send OTP)
     */
    async requestPasswordReset(phone: string): Promise<{
        message: string;
        expiresIn: number;
    }> {
        // Check if user exists
        const user = await this.userModel.findOne({ phone });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        // Generate reset token
        const token = this.generateResetToken();

        // Set expiry (15 minutes)
        const expiresAt = new Date(Date.now() + 15 * 60 * 1000);

        // Save reset request
        await this.passwordResetModel.create({
            userId: user._id,
            token,
            expiresAt,
        });

        // Send OTP
        const { expiresIn } = await this.otpService.sendOtp(
            phone,
            'password_reset',
        );

        // TODO: Also send email if user has email
        // if (user.email) {
        //   await this.emailService.sendPasswordResetEmail(user.email, token);
        // }

        return {
            message: 'Password reset OTP sent successfully',
            expiresIn,
        };
    }

    /**
     * Verify OTP and get reset token
     */
    async verifyResetOtp(
        phone: string,
        otp: string,
    ): Promise<{ resetToken: string }> {
        // Verify OTP
        await this.otpService.verifyOtp(phone, otp, 'password_reset');

        // Find user
        const user = await this.userModel.findOne({ phone });

        if (!user) {
            throw new NotFoundException('User not found');
        }

        // Find valid reset request
        const resetRequest = await this.passwordResetModel.findOne({
            userId: user._id,
            expiresAt: { $gt: new Date() },
            usedAt: null,
        });

        if (!resetRequest) {
            throw new BadRequestException('No valid password reset request found');
        }

        return {
            resetToken: resetRequest.token,
        };
    }

    /**
     * Reset password using token
     */
    async resetPassword(token: string, newPassword: string): Promise<void> {
        // Find reset request
        const resetRequest = await this.passwordResetModel.findOne({
            token,
            expiresAt: { $gt: new Date() },
            usedAt: null,
        });

        if (!resetRequest) {
            throw new BadRequestException('Invalid or expired reset token');
        }

        // Find user
        const user = await this.userModel
            .findById(resetRequest.userId)
            .select('+password');

        if (!user) {
            throw new NotFoundException('User not found');
        }

        // Hash new password
        const hashedPassword = await this.hashPassword(newPassword);

        // Update password
        user.password = hashedPassword;
        user.failedLoginAttempts = 0;
        user.lockedUntil = undefined;
        await user.save();

        // Mark reset request as used
        resetRequest.usedAt = new Date();
        await resetRequest.save();

        // TODO: Send confirmation email/SMS
        // await this.notificationService.sendPasswordChangedNotification(user);
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
            throw new NotFoundException('User not found');
        }

        // Verify old password
        const isPasswordValid = await bcrypt.compare(oldPassword, user.password);

        if (!isPasswordValid) {
            throw new BadRequestException('Current password is incorrect');
        }

        // Check if new password is same as old
        const isSamePassword = await bcrypt.compare(newPassword, user.password);

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

        // TODO: Send confirmation & invalidate other sessions
        // await this.sessionService.invalidateAllExcept(userId, currentSessionId);
    }

    /**
     * Generate reset token
     */
    private generateResetToken(): string {
        return randomBytes(32).toString('hex');
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
     * Clean up expired reset requests
     */
    async cleanupExpired(): Promise<void> {
        await this.passwordResetModel.deleteMany({
            expiresAt: { $lt: new Date() },
        });
    }
}
