import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiParam,
} from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiAuthErrorResponses } from '@common/decorators/api-error-responses.decorator';
import { CustomersService } from './customers.service';
import { DeleteAccountDto } from './dto/delete-account.dto';
import { CreateAddressDto } from './dto/create-address.dto';
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

  // ═════════════════════════════════════
  // Addresses Management
  // ═════════════════════════════════════

  /**
   * Get customer addresses
   */
  @Get('addresses')
  @ApiOperation({
    summary: 'Get customer addresses',
    description: 'Retrieve all addresses for the current customer',
  })
  @ApiResponse({
    status: 200,
    description: 'Addresses retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getAddresses(@CurrentUser() user: any) {
    // Find customer by userId
    const customer = await this.customersService.findByUserId(user.id);

    if (!customer) {
      throw new NotFoundException('Customer profile not found');
    }

    const addresses = await this.customersService.getAddresses(
      customer._id.toString(),
    );

    return ResponseBuilder.success(
      addresses,
      'Addresses retrieved successfully',
      'تم استرجاع العناوين بنجاح',
    );
  }

  /**
   * Get address by ID
   */
  @Get('addresses/:addressId')
  @ApiOperation({
    summary: 'Get address by ID',
    description: 'Retrieve a specific address by ID',
  })
  @ApiParam({
    name: 'addressId',
    description: 'Address ID',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'Address retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getAddressById(
    @CurrentUser() user: any,
    @Param('addressId') addressId: string,
  ) {
    const customer = await this.customersService.findByUserId(user.id);

    if (!customer) {
      throw new NotFoundException('Customer profile not found');
    }

    const addresses = await this.customersService.getAddresses(
      customer._id.toString(),
    );

    const address = addresses.find(
      (addr) => addr._id.toString() === addressId,
    );

    if (!address) {
      throw new NotFoundException('Address not found');
    }

    return ResponseBuilder.success(
      address,
      'Address retrieved successfully',
      'تم استرجاع العنوان بنجاح',
    );
  }

  /**
   * Create address
   */
  @Post('addresses')
  @ApiOperation({
    summary: 'Create customer address',
    description: 'Add a new address for the current customer',
  })
  @ApiResponse({
    status: 201,
    description: 'Address created successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async createAddress(
    @CurrentUser() user: any,
    @Body() createAddressDto: CreateAddressDto,
  ) {
    const customer = await this.customersService.findByUserId(user.id);

    if (!customer) {
      throw new NotFoundException('Customer profile not found');
    }

    const address = await this.customersService.createAddress(
      customer._id.toString(),
      createAddressDto,
    );

    return ResponseBuilder.created(
      address,
      'Address created successfully',
      'تم إنشاء العنوان بنجاح',
    );
  }

  /**
   * Update address
   */
  @Put('addresses/:addressId')
  @ApiOperation({
    summary: 'Update customer address',
    description: 'Update an existing customer address',
  })
  @ApiParam({
    name: 'addressId',
    description: 'Address ID',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'Address updated successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async updateAddress(
    @CurrentUser() user: any,
    @Param('addressId') addressId: string,
    @Body() updateData: Partial<CreateAddressDto>,
  ) {
    const customer = await this.customersService.findByUserId(user.id);

    if (!customer) {
      throw new NotFoundException('Customer profile not found');
    }

    const address = await this.customersService.updateAddress(
      customer._id.toString(),
      addressId,
      updateData,
    );

    return ResponseBuilder.success(
      address,
      'Address updated successfully',
      'تم تحديث العنوان بنجاح',
    );
  }

  /**
   * Delete address
   */
  @Delete('addresses/:addressId')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete customer address',
    description: 'Delete a customer address',
  })
  @ApiParam({
    name: 'addressId',
    description: 'Address ID',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 204,
    description: 'Address deleted successfully',
  })
  @ApiAuthErrorResponses()
  async deleteAddress(
    @CurrentUser() user: any,
    @Param('addressId') addressId: string,
  ) {
    const customer = await this.customersService.findByUserId(user.id);

    if (!customer) {
      throw new NotFoundException('Customer profile not found');
    }

    await this.customersService.deleteAddress(
      customer._id.toString(),
      addressId,
    );

    return ResponseBuilder.success(
      null,
      'Address deleted successfully',
      'تم حذف العنوان بنجاح',
    );
  }
}
