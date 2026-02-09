import {
    Controller,
    Get,
    Post,
    Put,
    Delete,
    Body,
    Param,
    Query,
    UseGuards,
    HttpCode,
    HttpStatus,
    Patch,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery, ApiParam, ApiResponse } from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiCommonErrorResponses } from '@common/decorators/api-error-responses.decorator';
import { CustomersService } from './customers.service';
import { CreateCustomerDto } from './dto/create-customer.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';
import { CreateAddressDto } from './dto/create-address.dto';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { UsersService } from '@modules/users/users.service';
import { CurrentUser } from '@common/decorators/current-user.decorator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👥 Customers Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Customers')
@Controller('customers')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class CustomersController {
    constructor(
        private readonly customersService: CustomersService,
        private readonly usersService: UsersService,
    ) { }

    /**
     * Get available users for customer conversion
     */
    @Get('available-users')
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @ApiOperation({
        summary: 'Get users available for customer conversion',
        description: 'Get users with userType=customer that are not yet linked to a customer profile',
    })
    @ApiResponse({
        status: 200,
        description: 'Available users retrieved successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async getAvailableUsers() {
        const linkedUserIds = await this.customersService.getLinkedUserIds();
        const users = await this.usersService.findUnlinkedCustomerUsers(linkedUserIds);

        return ResponseBuilder.success(
            users,
            'Available users retrieved successfully',
            'تم استرجاع المستخدمين المتاحين بنجاح',
        );
    }

    /**
     * Create customer
     */
    @Post()
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Create new customer',
        description: 'Create a new customer account. The user must already exist with userType=customer.',
    })
    @ApiResponse({
        status: 201,
        description: 'Customer created successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async create(@Body() createCustomerDto: CreateCustomerDto) {
        const customer = await this.customersService.create(createCustomerDto);

        return ResponseBuilder.created(
            customer,
            'Customer created successfully',
            'تم إنشاء العميل بنجاح',
        );
    }

    /**
     * Get all customers
     */
    @Get()
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @ApiOperation({
        summary: 'Get all customers',
        description: 'Retrieve a paginated list of all customers with optional filtering',
    })
    @ApiQuery({ name: 'page', required: false, type: Number, example: 1, description: 'Page number' })
    @ApiQuery({ name: 'limit', required: false, type: Number, example: 20, description: 'Items per page' })
    @ApiQuery({ name: 'search', required: false, type: String, description: 'Search by shop name or customer code' })
    @ApiQuery({ name: 'cityId', required: false, type: String, description: 'Filter by city ID' })
    @ApiQuery({ name: 'priceLevelId', required: false, type: String, description: 'Filter by price level ID' })
    @ApiQuery({ name: 'loyaltyTier', required: false, enum: ['bronze', 'silver', 'gold', 'platinum'], description: 'Filter by loyalty tier' })
    @ApiQuery({ name: 'businessType', required: false, enum: ['shop', 'technician', 'distributor', 'other'], description: 'Filter by business type' })
    @ApiResponse({
        status: 200,
        description: 'Customers retrieved successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async findAll(@Query() query: any) {
        const result = await this.customersService.findAll(query);

        return ResponseBuilder.success(
            result.data,
            'Customers retrieved successfully',
            'تم استرجاع العملاء بنجاح',
            result.pagination,
        );
    }

    /**
     * Get customer by ID
     */
    @Get(':id')
    @ApiOperation({
        summary: 'Get customer by ID',
        description: 'Retrieve detailed information about a specific customer',
    })
    @ApiParam({ name: 'id', description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 200,
        description: 'Customer retrieved successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async findById(@Param('id') id: string) {
        const customer = await this.customersService.findById(id);

        return ResponseBuilder.success(
            customer,
            'Customer retrieved successfully',
            'تم استرجاع العميل بنجاح',
        );
    }

    /**
     * Update customer
     */
    @Put(':id')
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @ApiOperation({
        summary: 'Update customer',
        description: 'Update customer information. All fields are optional.',
    })
    @ApiParam({ name: 'id', description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 200,
        description: 'Customer updated successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async update(
        @Param('id') id: string,
        @Body() updateCustomerDto: UpdateCustomerDto,
    ) {
        const customer = await this.customersService.update(id, updateCustomerDto);

        return ResponseBuilder.success(
            customer,
            'Customer updated successfully',
            'تم تحديث العميل بنجاح',
        );
    }

    /**
     * Approve customer
     */
    @Patch(':id/approve')
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @ApiOperation({
        summary: 'Approve customer registration',
        description: 'Approve a pending customer registration',
    })
    @ApiParam({ name: 'id', description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 200,
        description: 'Customer approved successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async approve(@Param('id') id: string, @CurrentUser() user: any) {
        const customer = await this.customersService.approve(id, user.id);

        return ResponseBuilder.success(
            customer,
            'Customer approved successfully',
            'تمت الموافقة على العميل بنجاح',
        );
    }

    /**
     * Reject customer
     */
    @Patch(':id/reject')
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @ApiOperation({
        summary: 'Reject customer registration',
        description: 'Reject a pending customer registration with a reason',
    })
    @ApiParam({ name: 'id', description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 200,
        description: 'Customer rejected successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async reject(@Param('id') id: string, @Body('reason') reason: string, @CurrentUser() user: any) {
        const customer = await this.customersService.reject(id, reason, user?.adminUserId ?? user?.id);

        return ResponseBuilder.success(
            customer,
            'Customer rejected',
            'تم رفض العميل',
        );
    }

    /**
     * Delete customer
     */
    @Delete(':id')
    @Roles(UserRole.SUPER_ADMIN)
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({
        summary: 'Delete customer',
        description: 'Delete a customer. This action cannot be undone.',
    })
    @ApiParam({ name: 'id', description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 204,
        description: 'Customer deleted successfully',
    })
    @ApiCommonErrorResponses()
    async delete(@Param('id') id: string) {
        await this.customersService.delete(id);

        return ResponseBuilder.success(
            null,
            'Customer deleted successfully',
            'تم حذف العميل بنجاح',
        );
    }

    // ═════════════════════════════════════
    // Addresses
    // ═════════════════════════════════════

    /**
     * Get customer addresses
     */
    @Get(':id/addresses')
    @ApiOperation({
        summary: 'Get customer addresses',
        description: 'Retrieve all addresses for a customer',
    })
    @ApiParam({ name: 'id', description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 200,
        description: 'Addresses retrieved successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async getAddresses(@Param('id') id: string) {
        const addresses = await this.customersService.getAddresses(id);

        return ResponseBuilder.success(
            addresses,
            'Addresses retrieved successfully',
            'تم استرجاع العناوين بنجاح',
        );
    }

    /**
     * Create address
     */
    @Post(':id/addresses')
    @ApiOperation({
        summary: 'Create customer address',
        description: 'Add a new address for a customer',
    })
    @ApiParam({ name: 'id', description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({
        status: 201,
        description: 'Address created successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async createAddress(
        @Param('id') id: string,
        @Body() createAddressDto: CreateAddressDto,
    ) {
        const address = await this.customersService.createAddress(
            id,
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
    @Put(':id/addresses/:addressId')
    @ApiOperation({
        summary: 'Update customer address',
        description: 'Update an existing customer address',
    })
    @ApiParam({ name: 'id', description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @ApiParam({ name: 'addressId', description: 'Address ID', example: '507f1f77bcf86cd799439012' })
    @ApiResponse({
        status: 200,
        description: 'Address updated successfully',
        type: ApiResponseDto,
    })
    @ApiCommonErrorResponses()
    async updateAddress(
        @Param('id') id: string,
        @Param('addressId') addressId: string,
        @Body() updateData: Partial<CreateAddressDto>,
    ) {
        const address = await this.customersService.updateAddress(
            id,
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
    @Delete(':id/addresses/:addressId')
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({
        summary: 'Delete customer address',
        description: 'Delete a customer address',
    })
    @ApiParam({ name: 'id', description: 'Customer ID', example: '507f1f77bcf86cd799439011' })
    @ApiParam({ name: 'addressId', description: 'Address ID', example: '507f1f77bcf86cd799439012' })
    @ApiResponse({
        status: 204,
        description: 'Address deleted successfully',
    })
    @ApiCommonErrorResponses()
    async deleteAddress(
        @Param('id') id: string,
        @Param('addressId') addressId: string,
    ) {
        await this.customersService.deleteAddress(id, addressId);

        return ResponseBuilder.success(
            null,
            'Address deleted successfully',
            'تم حذف العنوان بنجاح',
        );
    }
}
