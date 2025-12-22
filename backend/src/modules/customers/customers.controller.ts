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
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { CustomersService } from './customers.service';
import { CreateCustomerDto } from './dto/create-customer.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';
import { CreateAddressDto } from './dto/create-address.dto';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { ResponseBuilder } from '@common/interfaces/response.interface';

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
    constructor(private readonly customersService: CustomersService) { }

    /**
     * Create customer
     */
    @Post()
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create new customer' })
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
    @ApiOperation({ summary: 'Get all customers' })
    @ApiQuery({ name: 'page', required: false })
    @ApiQuery({ name: 'limit', required: false })
    @ApiQuery({ name: 'search', required: false })
    @ApiQuery({ name: 'cityId', required: false })
    @ApiQuery({ name: 'priceLevelId', required: false })
    @ApiQuery({ name: 'loyaltyTier', required: false })
    @ApiQuery({ name: 'businessType', required: false })
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
    @ApiOperation({ summary: 'Get customer by ID' })
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
    @ApiOperation({ summary: 'Update customer' })
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
    @ApiOperation({ summary: 'Approve customer registration' })
    async approve(@Param('id') id: string, @Body('adminId') adminId: string) {
        const customer = await this.customersService.approve(id, adminId);

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
    @ApiOperation({ summary: 'Reject customer registration' })
    async reject(@Param('id') id: string, @Body('reason') reason: string) {
        const customer = await this.customersService.reject(id, reason);

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
    @ApiOperation({ summary: 'Delete customer' })
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
    @ApiOperation({ summary: 'Get customer addresses' })
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
    @ApiOperation({ summary: 'Create customer address' })
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
    @ApiOperation({ summary: 'Update customer address' })
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
    @ApiOperation({ summary: 'Delete customer address' })
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
