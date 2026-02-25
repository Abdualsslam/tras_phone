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
  Query,
  Req,
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
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { AdminLoginDto } from './dto/admin-login.dto';
import { UpdateFcmTokenDto } from './dto/update-fcm-token.dto';
import { RequestPasswordResetDto } from './dto/request-password-reset.dto';
import { ProcessPasswordResetDto } from './dto/process-password-reset.dto';
import { RejectPasswordResetDto } from './dto/reject-password-reset.dto';
import { Public } from '@decorators/public.decorator';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import {
  ApiPublicErrorResponses,
  ApiAuthErrorResponses,
} from '@common/decorators/api-error-responses.decorator';
import { ApiParam, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import {
  AUTH_ERROR_CODES,
  buildAuthUnauthorizedException,
} from './auth-errors';

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
      'Register a new user account. User can be either customer or admin type. Account will be activated after admin approval.',
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
  async adminLogin(@Body() adminLoginDto: AdminLoginDto, @Req() req: Request) {
    const ipAddress =
      req.ip || (req.headers['x-forwarded-for'] as string) || 'unknown';
    const userAgent = req.headers['user-agent'] || 'unknown';
    const result = await this.authService.adminLogin(
      adminLoginDto.email,
      adminLoginDto.password,
      ipAddress,
      userAgent,
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

  // ═══════════════════════════════════
  // 🔑 Password Management
  // ═══════════════════════════════════

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
    await this.authService.changePassword(
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
      throw buildAuthUnauthorizedException({
        code: AUTH_ERROR_CODES.AUTH_HEADER_MISSING,
      });
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
  // 🔐 Password Reset Request (Customer)
  // ═════════════════════════════════════

  @Public()
  @Post('request-password-reset')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Request password reset',
    description:
      'Submit a password reset request. The request will be processed by an admin who will contact you with a new password.',
  })
  @ApiResponse({
    status: 201,
    description: 'Password reset request submitted successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async requestPasswordReset(@Body() dto: RequestPasswordResetDto) {
    const request = await this.authService.requestPasswordReset(
      dto.phone,
      dto.customerNotes,
    );

    return ResponseBuilder.created(
      {
        requestNumber: request.requestNumber,
        status: request.status,
      },
      'Password reset request submitted successfully. An admin will contact you soon.',
      'تم تقديم طلب إعادة تعيين كلمة المرور بنجاح. سيتم التواصل معك قريباً.',
    );
  }

  // ═════════════════════════════════════
  // 🔐 Admin Password Reset
  // ═════════════════════════════════════

  @Post('admin/reset-password')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Reset user password by admin',
    description:
      'Reset password for any user account. This endpoint is only accessible to admin users and allows direct password reset without OTP verification.',
  })
  @ApiResponse({
    status: 200,
    description: 'Password reset successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async resetUserPasswordByAdmin(
    @Body() body: { userId: string; newPassword: string },
  ) {
    await this.authService.resetUserPasswordByAdmin(
      body.userId,
      body.newPassword,
    );

    return ResponseBuilder.success(
      null,
      'Password reset successfully',
      'تم إعادة تعيين كلمة المرور بنجاح',
    );
  }

  // ═════════════════════════════════════
  // 🔐 Admin Password Reset Requests Management
  // ═════════════════════════════════════

  @Get('admin/password-reset-requests')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get password reset requests (admin)',
    description: 'Get list of all password reset requests with filters',
  })
  @ApiQuery({ name: 'status', required: false, enum: ['pending', 'completed', 'rejected'] })
  @ApiQuery({ name: 'customerId', required: false })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  @ApiResponse({
    status: 200,
    description: 'Password reset requests retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getPasswordResetRequests(
    @Query('status') status?: string,
    @Query('customerId') customerId?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
  ) {
    const requests = await this.authService.getPasswordResetRequests({
      status,
      customerId,
      page: page ? parseInt(page) : undefined,
      limit: limit ? parseInt(limit) : undefined,
    });

    return ResponseBuilder.success(
      requests,
      'Password reset requests retrieved successfully',
      'تم استرجاع طلبات إعادة تعيين كلمة المرور بنجاح',
    );
  }

  @Get('admin/password-reset-requests/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get password reset request by ID (admin)',
    description: 'Get details of a specific password reset request',
  })
  @ApiParam({
    name: 'id',
    description: 'Password reset request ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Password reset request retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getPasswordResetRequestById(@Param('id') id: string) {
    const request = await this.authService.getPasswordResetRequestById(id);

    return ResponseBuilder.success(
      request,
      'Password reset request retrieved successfully',
      'تم استرجاع طلب إعادة تعيين كلمة المرور بنجاح',
    );
  }

  @Post('admin/password-reset-requests/:id/process')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Process password reset request (admin)',
    description:
      'Process a pending password reset request. Generates a new password and updates the request status to completed.',
  })
  @ApiParam({
    name: 'id',
    description: 'Password reset request ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Password reset request processed successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async processPasswordResetRequest(
    @CurrentUser() admin: any,
    @Param('id') id: string,
    @Body() dto: ProcessPasswordResetDto,
  ) {
    const result = await this.authService.processPasswordResetRequest(
      id,
      admin.id,
      dto.adminNotes,
    );

    return ResponseBuilder.success(
      {
        request: result.request,
        temporaryPassword: result.temporaryPassword, // Plain password for admin to copy
      },
      'Password reset request processed successfully. Please send the temporary password to the customer.',
      'تم معالجة طلب إعادة تعيين كلمة المرور بنجاح. يرجى إرسال كلمة المرور المؤقتة للعميل.',
    );
  }

  @Post('admin/password-reset-requests/:id/reject')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.OK)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Reject password reset request (admin)',
    description: 'Reject a pending password reset request with a reason',
  })
  @ApiParam({
    name: 'id',
    description: 'Password reset request ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Password reset request rejected successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async rejectPasswordResetRequest(
    @CurrentUser() admin: any,
    @Param('id') id: string,
    @Body() dto: RejectPasswordResetDto,
  ) {
    const request = await this.authService.rejectPasswordResetRequest(
      id,
      admin.id,
      dto.rejectionReason,
      dto.adminNotes,
    );

    return ResponseBuilder.success(
      request,
      'Password reset request rejected successfully',
      'تم رفض طلب إعادة تعيين كلمة المرور بنجاح',
    );
  }
}
