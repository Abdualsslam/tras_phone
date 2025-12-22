import {
    Controller,
    Post,
    Body,
    HttpCode,
    HttpStatus,
    UseGuards,
    Get,
    Patch,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ThrottlerGuard } from '@nestjs/throttler';

import { AuthService } from './auth.service';
import { OtpService } from './otp.service';
import { PasswordResetService } from './password-reset.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { SendOtpDto } from './dto/send-otp.dto';
import { VerifyOtpDto } from './dto/verify-otp.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { Public } from '@decorators/public.decorator';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 Authentication Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Authentication')
@Controller('auth')
@UseGuards(ThrottlerGuard)
export class AuthController {
    constructor(
        private readonly authService: AuthService,
        private readonly otpService: OtpService,
        private readonly passwordResetService: PasswordResetService,
    ) { }

    // ═════════════════════════════════════
    // 📝 Registration & Login
    // ═════════════════════════════════════

    @Public()
    @Post('register')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Register a new user' })
    async register(@Body() registerDto: RegisterDto) {
        const result = await this.authService.register(registerDto);

        return ResponseBuilder.created(
            result,
            'User registered successfully',
            'تم تسجيل المستخدم بنجاح',
        );
    }

    @Public()
    @Post('login')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Login user' })
    async login(@Body() loginDto: LoginDto) {
        const result = await this.authService.login(loginDto);

        return ResponseBuilder.success(
            result,
            'Login successful',
            'تم تسجيل الدخول بنجاح',
        );
    }

    @Public()
    @Post('refresh')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Refresh access token' })
    async refreshToken(@Body() refreshTokenDto: RefreshTokenDto) {
        const result = await this.authService.refreshToken(
            refreshTokenDto.refreshToken,
        );

        return ResponseBuilder.success(
            result,
            'Token refreshed successfully',
            'تم تحديث الرمز بنجاح',
        );
    }

    // ═════════════════════════════════════
    // 📱 OTP Verification
    // ═════════════════════════════════════

    @Public()
    @Post('send-otp')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Send OTP to phone number' })
    async sendOtp(@Body() sendOtpDto: SendOtpDto) {
        const result = await this.otpService.sendOtp(
            sendOtpDto.phone,
            sendOtpDto.purpose,
        );

        return ResponseBuilder.success(
            result,
            'OTP sent successfully',
            'تم إرسال رمز التحقق بنجاح',
        );
    }

    @Public()
    @Post('verify-otp')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Verify OTP code' })
    async verifyOtp(@Body() verifyOtpDto: VerifyOtpDto) {
        await this.otpService.verifyOtp(
            verifyOtpDto.phone,
            verifyOtpDto.otp,
            verifyOtpDto.purpose,
        );

        return ResponseBuilder.success(
            null,
            'OTP verified successfully',
            'تم التحقق من الرمز بنجاح',
        );
    }

    // ═══════════════════════════════════
    // 🔑 Password Management
    // ═══════════════════════════════════

    @Public()
    @Post('forgot-password')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Request password reset OTP' })
    async forgotPassword(@Body() forgotPasswordDto: ForgotPasswordDto) {
        const result = await this.passwordResetService.requestPasswordReset(
            forgotPasswordDto.phone,
        );

        return ResponseBuilder.success(
            result,
            'Password reset OTP sent',
            'تم إرسال رمز إعادة تعيين كلمة المرور',
        );
    }

    @Public()
    @Post('verify-reset-otp')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Verify password reset OTP and get token' })
    async verifyResetOtp(@Body() verifyOtpDto: VerifyOtpDto) {
        const result = await this.passwordResetService.verifyResetOtp(
            verifyOtpDto.phone,
            verifyOtpDto.otp,
        );

        return ResponseBuilder.success(
            result,
            'OTP verified. Use the reset token to set new password.',
            'تم التحقق. استخدم الرمز لتعيين كلمة مرور جديدة.',
        );
    }

    @Public()
    @Post('reset-password')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({ summary: 'Reset password using reset token' })
    async resetPassword(@Body() resetPasswordDto: ResetPasswordDto) {
        await this.passwordResetService.resetPassword(
            resetPasswordDto.resetToken,
            resetPasswordDto.newPassword,
        );

        return ResponseBuilder.success(
            null,
            'Password reset successfully',
            'تم إعادة تعيين كلمة المرور بنجاح',
        );
    }

    @Patch('change-password')
    @HttpCode(HttpStatus.OK)
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Change password for authenticated user' })
    async changePassword(
        @CurrentUser() user: any,
        @Body() changePasswordDto: ChangePasswordDto,
    ) {
        await this.passwordResetService.changePassword(
            user.id,
            changePasswordDto.oldPassword,
            changePasswordDto.newPassword,
        );

        return ResponseBuilder.success(
            null,
            'Password changed successfully',
            'تم تغيير كلمة المرور بنجاح',
        );
    }

    // ═══════════════════════════════════
    // 👤 Profile & Session
    // ═══════════════════════════════════

    @Get('me')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Get current user profile' })
    async getProfile(@CurrentUser() user: any) {
        return ResponseBuilder.success(
            user,
            'Profile retrieved successfully',
            'تم استرجاع الملف الشخصي بنجاح',
        );
    }

    @Post('logout')
    @HttpCode(HttpStatus.OK)
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Logout user' })
    async logout(@CurrentUser() user: any) {
        return ResponseBuilder.success(
            null,
            'Logout successful',
            'تم تسجيل الخروج بنجاح',
        );
    }
}
