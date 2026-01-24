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
import { ProductsService } from '@modules/products/products.service';
import { UsersService } from '@modules/users/users.service';
import { DeleteAccountDto } from './dto/delete-account.dto';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';
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
  constructor(
    private readonly customersService: CustomersService,
    private readonly productsService: ProductsService,
    private readonly usersService: UsersService,
  ) {}

  // ═════════════════════════════════════
  // Profile Management
  // ═════════════════════════════════════

  /**
   * Get customer profile
   */
  @Get('profile')
  @ApiOperation({
    summary: 'Get customer profile',
    description: 'Retrieve the current customer profile information',
  })
  @ApiResponse({
    status: 200,
    description: 'Profile retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getProfile(@CurrentUser() user: any) {
    // Find customer by userId
    let customer = await this.customersService.findByUserId(user.id);

    // إنشاء profile تلقائياً إذا لم يكن موجوداً
    if (!customer) {
      // الحصول على default price level
      const defaultPriceLevel = await this.productsService.getDefaultPriceLevel();

      // إنشاء customer profile أساسي
      await this.customersService.createAutoProfile(
        user.id,
        defaultPriceLevel._id.toString(),
        user.phone || 'Customer',
      );

      // إعادة جلب customer مع populate
      customer = await this.customersService.findByUserId(user.id);
      
      // إذا لم يتم العثور على customer بعد الإنشاء، إرجاع خطأ
      if (!customer) {
        throw new NotFoundException('Customer profile not found');
      }
    }

    // تحويل customer إلى plain object
    const customerObj = customer.toObject ? customer.toObject({ virtuals: true }) : JSON.parse(JSON.stringify(customer));
    
    // تحميل userId يدوياً دائماً لضمان إرجاعه ككائن مع جميع الحقول
    let userIdToLoad: string;
    if (typeof customerObj.userId === 'object' && customerObj.userId?._id) {
      // userId هو كائن populated
      userIdToLoad = customerObj.userId._id.toString();
    } else if (typeof customerObj.userId === 'string') {
      // userId هو string
      userIdToLoad = customerObj.userId;
    } else if (customer.userId) {
      // userId هو ObjectId مباشرة من document
      userIdToLoad = customer.userId.toString();
    } else {
      // استخدام user.id كبديل
      userIdToLoad = user.id;
    }
    
    try {
      const userDoc = await this.usersService.findById(userIdToLoad);
      const userObj = userDoc.toObject ? userDoc.toObject() : JSON.parse(JSON.stringify(userDoc));
      
      // بناء userId object مع جميع الحقول المطلوبة
      const userIdValue = userObj._id 
        ? (typeof userObj._id === 'object' && userObj._id.toString ? userObj._id.toString() : userObj._id)
        : userObj.id;
      
      customerObj.userId = {
        _id: userIdValue,
        phone: userObj.phone,
        email: userObj.email,
        userType: userObj.userType,
        status: userObj.status,
        name: customerObj.responsiblePersonName,
      };
    } catch (error) {
      // إذا فشل تحميل user، نستخدم البيانات المتاحة
      console.error('Failed to load user:', error);
      // إذا كان userId موجود ككائن، نحتفظ به ونضيف name
      if (customerObj.userId && typeof customerObj.userId === 'object') {
        customerObj.userId = {
          ...customerObj.userId,
          name: customerObj.responsiblePersonName,
        };
      }
    }

    return ResponseBuilder.success(
      customerObj,
      'Profile retrieved successfully',
      'تم استرجاع البروفايل بنجاح',
    );
  }

  /**
   * Update customer profile
   */
  @Put('profile')
  @ApiOperation({
    summary: 'Update customer profile',
    description: 'Update the current customer profile. All fields are optional.',
  })
  @ApiResponse({
    status: 200,
    description: 'Profile updated successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async updateProfile(
    @CurrentUser() user: any,
    @Body() updateCustomerDto: UpdateCustomerDto,
  ) {
    // Find customer by userId
    const customer = await this.customersService.findByUserId(user.id);

    if (!customer) {
      throw new NotFoundException('Customer profile not found');
    }

    const updatedCustomer = await this.customersService.update(
      customer._id.toString(),
      updateCustomerDto,
    );

    return ResponseBuilder.success(
      updatedCustomer,
      'Profile updated successfully',
      'تم تحديث البروفايل بنجاح',
    );
  }

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
