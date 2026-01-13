import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
  Get,
  Patch,
  Delete,
  Param,
  Req,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
} from '@nestjs/swagger';
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
import { AdminLoginDto } from './dto/admin-login.dto';
import { UpdateFcmTokenDto } from './dto/update-fcm-token.dto';
import { SocialLoginDto } from './dto/social-login.dto';
import { Public } from '@decorators/public.decorator';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import {
  ApiPublicErrorResponses,
  ApiAuthErrorResponses,
} from '@common/decorators/api-error-responses.decorator';
import { ApiParam } from '@nestjs/swagger';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';

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
  ) {}

  // ═════════════════════════════════════
  // 📝 Registration & Login
  // ═════════════════════════════════════

  @Public()
  @Post('register')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Register a new user',
    description:
      'Register a new user account. Requires phone verification via OTP. User can be either customer or admin type.',
  })
  @ApiResponse({
    status: 201,
    description: 'User registered successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
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
  @ApiOperation({
    summary: 'Login user',
    description:
      'Authenticate user with phone number and password. Returns access token and refresh token.',
  })
  @ApiResponse({
    status: 200,
    description: 'Login successful',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async login(@Body() loginDto: LoginDto, @Req() req: Request) {
    const ipAddress =
      req.ip || (req.headers['x-forwarded-for'] as string) || 'unknown';
    const userAgent = req.headers['user-agent'] || 'unknown';
    const result = await this.authService.login(loginDto, ipAddress, userAgent);

    return ResponseBuilder.success(
      result,
      'Login successful',
      'تم تسجيل الدخول بنجاح',
    );
  }

  @Public()
  @Post('admin/login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Login admin user',
    description:
      'Authenticate admin user with email and password. Returns access token and refresh token.',
  })
  @ApiResponse({
    status: 200,
    description: 'Admin login successful',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async adminLogin(@Body() adminLoginDto: AdminLoginDto) {
    const result = await this.authService.adminLogin(
      adminLoginDto.email,
      adminLoginDto.password,
    );

    return ResponseBuilder.success(
      result,
      'Login successful',
      'تم تسجيل الدخول بنجاح',
    );
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Refresh access token',
    description: 'Get a new access token using a valid refresh token.',
  })
  @ApiResponse({
    status: 200,
    description: 'Token refreshed successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
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
  @ApiOperation({
    summary: 'Send OTP to phone number',
    description:
      'Send a one-time password (OTP) to the specified phone number for verification purposes (registration, login, password reset, etc.)',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP sent successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
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
  @ApiOperation({
    summary: 'Verify OTP code',
    description:
      'Verify the OTP code sent to the phone number. Must match the purpose for which OTP was sent.',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP verified successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
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
  @ApiOperation({
    summary: 'Request password reset OTP',
    description:
      "Request a password reset OTP to be sent to the user's phone number",
  })
  @ApiResponse({
    status: 200,
    description: 'Password reset OTP sent',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
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
  @ApiOperation({
    summary: 'Verify password reset OTP and get token',
    description:
      'Verify the OTP code for password reset and receive a reset token to use in the reset-password endpoint',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP verified. Use the reset token to set new password.',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
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
  @ApiOperation({
    summary: 'Reset password using reset token',
    description:
      'Reset user password using the reset token obtained from verify-reset-otp endpoint',
  })
  @ApiResponse({
    status: 200,
    description: 'Password reset successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
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
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Change password for authenticated user',
    description:
      'Change password for the currently authenticated user. Requires current password.',
  })
  @ApiResponse({
    status: 200,
    description: 'Password changed successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
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
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get current user profile',
    description:
      'Retrieve the profile information of the currently authenticated user',
  })
  @ApiResponse({
    status: 200,
    description: 'Profile retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getProfile(@CurrentUser() user: any) {
    // Fetch full user profile from database
    const fullProfile = await this.authService.getFullUserProfile(user.id);
    return ResponseBuilder.success(
      fullProfile,
      'Profile retrieved successfully',
      'تم استرجاع الملف الشخصي بنجاح',
    );
  }

  @Post('logout')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Logout user',
    description:
      'Logout the currently authenticated user. Invalidates the current session.',
  })
  @ApiResponse({
    status: 200,
    description: 'Logout successful',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async logout(@CurrentUser() user: any, @Req() req: Request) {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      throw new UnauthorizedException('Authorization header not found');
    }
    const [, token] = authHeader.split(' ');

    await this.authService.logout(user.id, token);

    return ResponseBuilder.success(
      null,
      'Logout successful',
      'تم تسجيل الخروج بنجاح',
    );
  }

  // ═════════════════════════════════════
  // FCM Token Management
  // ═════════════════════════════════════

  @Post('fcm-token')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update FCM token',
    description: 'Update Firebase Cloud Messaging token for push notifications',
  })
  @ApiResponse({
    status: 200,
    description: 'FCM token updated successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async updateFcmToken(
    @CurrentUser() user: any,
    @Body() updateFcmTokenDto: UpdateFcmTokenDto,
  ) {
    const result = await this.authService.updateFcmToken(
      user.id,
      updateFcmTokenDto,
    );

    return ResponseBuilder.success(
      result,
      'FCM token updated successfully',
      'تم تحديث رمز الإشعارات بنجاح',
    );
  }

  // ═════════════════════════════════════
  // Sessions Management
  // ═════════════════════════════════════

  @Get('sessions')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get user sessions',
    description: 'Retrieve all active sessions for the current user',
  })
  @ApiResponse({
    status: 200,
    description: 'Sessions retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getSessions(@CurrentUser() user: any) {
    const sessions = await this.authService.getUserSessions(user.id);

    return ResponseBuilder.success(
      sessions,
      'Sessions retrieved successfully',
      'تم استرجاع الجلسات بنجاح',
    );
  }

  @Delete('sessions/:id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Delete user session',
    description: 'Delete a specific session for the current user',
  })
  @ApiParam({
    name: 'id',
    description: 'Session ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Session deleted successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async deleteSession(
    @CurrentUser() user: any,
    @Param('id') sessionId: string,
  ) {
    const result = await this.authService.deleteSession(user.id, sessionId);

    return ResponseBuilder.success(
      result,
      'Session deleted successfully',
      'تم حذف الجلسة بنجاح',
    );
  }

  // ═════════════════════════════════════
  // Social Login
  // ═════════════════════════════════════

  @Public()
  @Post('social/:provider')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Social login',
    description: 'Login using Google or Apple social authentication',
  })
  @ApiParam({
    name: 'provider',
    enum: ['google', 'apple'],
    description: 'Social provider',
  })
  @ApiResponse({
    status: 200,
    description: 'Social login successful',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async socialLogin(
    @Param('provider') provider: 'google' | 'apple',
    @Body() socialLoginDto: SocialLoginDto,
    @Req() req: Request,
  ) {
    const ipAddress =
      req.ip || (req.headers['x-forwarded-for'] as string) || 'unknown';
    const userAgent = req.headers['user-agent'] || 'unknown';
    const result = await this.authService.socialLogin(
      socialLoginDto,
      provider,
      ipAddress,
      userAgent,
    );

    return ResponseBuilder.success(
      result,
      'Social login successful',
      'تم تسجيل الدخول بنجاح',
    );
  }
}
