import {
  Controller,
  Get,
  Put,
  Delete,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
} from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiAuthErrorResponses } from '@common/decorators/api-error-responses.decorator';
import { CustomersService } from './customers.service';
import { DeleteAccountDto } from './dto/delete-account.dto';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { NotFoundException } from '@nestjs/common';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👤 Customer Profile Controller
 * ═══════════════════════════════════════════════════════════════
 * Controller for customer to manage their own profile
 */
@ApiTags('Customer Profile')
@Controller('customer')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class CustomerProfileController {
  constructor(private readonly customersService: CustomersService) {}

  /**
   * Delete customer account (self-delete)
   */
  @Delete('profile')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Delete customer account',
    description:
      'Delete the current customer account. This is a soft delete - data is preserved but account access is blocked.',
  })
  @ApiResponse({
    status: 200,
    description: 'Account deleted successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async deleteAccount(
    @CurrentUser() user: any,
    @Body() dto: DeleteAccountDto,
  ) {
    // Find customer by userId
    const customer = await this.customersService.findByUserId(user.id);

    if (!customer) {
      throw new NotFoundException('Customer profile not found');
    }

    await this.customersService.deleteAccount(
      customer._id.toString(),
      dto.reason,
    );

    return ResponseBuilder.success(
      null,
      'Account deleted successfully',
      'تم حذف الحساب بنجاح',
    );
  }
}
