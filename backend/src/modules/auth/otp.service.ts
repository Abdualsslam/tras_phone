import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
    OtpVerification,
    OtpVerificationDocument,
} from './schemas/otp-verification.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📱 OTP Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class OtpService {
    constructor(
        @InjectModel(OtpVerification.name)
        private otpModel: Model<OtpVerificationDocument>,
    ) { }

    /**
     * Generate and send OTP
     */
    async sendOtp(
        phone: string,
        purpose: 'registration' | 'login' | 'password_reset' | 'phone_change',
    ): Promise<{ otpId: string; expiresIn: number }> {
        // Check if there's a recent OTP
        const recentOtp = await this.otpModel.findOne({
            phone,
            purpose,
            expiresAt: { $gt: new Date() },
            verifiedAt: null,
        });

        if (recentOtp) {
            // If OTP was sent less than 60 seconds ago, prevent resend
            const timeSinceCreation =
                Date.now() - new Date(recentOtp.createdAt).getTime();
            if (timeSinceCreation < 60000) {
                const waitTime = Math.ceil((60000 - timeSinceCreation) / 1000);
                throw new BadRequestException(
                    `Please wait ${waitTime} seconds before requesting a new OTP`,
                );
            }
        }

        // Generate 6-digit OTP
        const otp = this.generateOtp();

        // Set expiry time (5 minutes)
        const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

        // Save OTP to database
        const otpDoc = await this.otpModel.create({
            phone,
            otp,
            purpose,
            expiresAt,
            attempts: 0,
            maxAttempts: 3,
        });

        // TODO: Send OTP via SMS (integrate with Unifonic/Twilio)
        // await this.smsService.send(phone, `Your OTP is: ${otp}`);

        // In development, log OTP to console
        if (process.env.NODE_ENV === 'development') {
            console.log(`📱 OTP for ${phone}: ${otp}`);
        }

        return {
            otpId: otpDoc._id.toString(),
            expiresIn: 300, // 5 minutes in seconds
        };
    }

    /**
     * Verify OTP
     */
    async verifyOtp(
        phone: string,
        otp: string,
        purpose: string,
    ): Promise<boolean> {
        const otpDoc = await this.otpModel.findOne({
            phone,
            purpose,
            expiresAt: { $gt: new Date() },
            verifiedAt: null,
        });

        if (!otpDoc) {
            throw new BadRequestException('Invalid or expired OTP');
        }

        // Check max attempts
        if (otpDoc.attempts >= otpDoc.maxAttempts) {
            throw new BadRequestException('Maximum OTP verification attempts exceeded');
        }

        // Verify OTP
        if (otpDoc.otp !== otp) {
            // Increment attempts
            otpDoc.attempts += 1;
            await otpDoc.save();

            throw new BadRequestException(
                `Invalid OTP. ${otpDoc.maxAttempts - otpDoc.attempts} attempts remaining`,
            );
        }

        // Mark as verified
        otpDoc.verifiedAt = new Date();
        await otpDoc.save();

        return true;
    }

    /**
     * Check if phone has verified OTP
     */
    async hasVerifiedOtp(phone: string, purpose: string): Promise<boolean> {
        const otpDoc = await this.otpModel.findOne({
            phone,
            purpose,
            verifiedAt: { $ne: null },
            expiresAt: { $gt: new Date() },
        });

        return !!otpDoc;
    }

    /**
     * Generate random 6-digit OTP
     */
    private generateOtp(): string {
        return Math.floor(100000 + Math.random() * 900000).toString();
    }

    /**
     * Delete all OTPs for a phone and purpose
     */
    async deleteOtps(phone: string, purpose?: string): Promise<void> {
        const query: any = { phone };
        if (purpose) {
            query.purpose = purpose;
        }

        await this.otpModel.deleteMany(query);
    }
}
