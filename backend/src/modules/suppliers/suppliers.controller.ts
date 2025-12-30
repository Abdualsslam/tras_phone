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
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiCommonErrorResponses } from '@common/decorators/api-error-responses.decorator';
import { SuppliersService } from './suppliers.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏢 Suppliers Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Suppliers & Purchases')
@Controller('suppliers')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class SuppliersController {
    constructor(private readonly suppliersService: SuppliersService) { }

    // ═════════════════════════════════════
    // Suppliers
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get()
    @ApiOperation({
        summary: 'Get all suppliers',
        description: 'Retrieve all suppliers with optional filtering. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Suppliers retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getSuppliers(@Query() query: any) {
        const suppliers = await this.suppliersService.findAllSuppliers(query);
        return ResponseBuilder.success(suppliers, 'Suppliers retrieved', 'تم استرجاع الموردين');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get(':id')
    @ApiOperation({
        summary: 'Get supplier by ID',
        description: 'Retrieve detailed information about a supplier. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Supplier ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Supplier retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getSupplier(@Param('id') id: string) {
        const supplier = await this.suppliersService.findSupplierById(id);
        return ResponseBuilder.success(supplier, 'Supplier retrieved', 'تم استرجاع المورد');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post()
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Create supplier',
        description: 'Create a new supplier. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Supplier created successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async createSupplier(@Body() data: any) {
        const supplier = await this.suppliersService.createSupplier(data);
        return ResponseBuilder.created(supplier, 'Supplier created', 'تم إنشاء المورد');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put(':id')
    @ApiOperation({
        summary: 'Update supplier',
        description: 'Update supplier information. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Supplier ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Supplier updated successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async updateSupplier(@Param('id') id: string, @Body() data: any) {
        const supplier = await this.suppliersService.updateSupplier(id, data);
        return ResponseBuilder.success(supplier, 'Supplier updated', 'تم تحديث المورد');
    }

    @Roles(UserRole.SUPER_ADMIN)
    @Delete(':id')
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({
        summary: 'Delete supplier',
        description: 'Delete a supplier. Super admin only.',
    })
    @ApiParam({ name: 'id', description: 'Supplier ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 204, description: 'Supplier deleted successfully' })
    @ApiCommonErrorResponses()
    async deleteSupplier(@Param('id') id: string) {
        await this.suppliersService.deleteSupplier(id);
        return ResponseBuilder.success(null, 'Supplier deleted', 'تم حذف المورد');
    }

    // ═════════════════════════════════════
    // Supplier Products
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get(':id/products')
    @ApiOperation({
        summary: 'Get supplier products',
        description: 'Retrieve all products supplied by a specific supplier. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Supplier ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Supplier products retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getSupplierProducts(@Param('id') id: string) {
        const products = await this.suppliersService.getSupplierProducts(id);
        return ResponseBuilder.success(products, 'Products retrieved', 'تم استرجاع المنتجات');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post(':id/products')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Add product to supplier',
        description: 'Associate a product with a supplier. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Supplier ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 201, description: 'Product added to supplier successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async addSupplierProduct(@Param('id') id: string, @Body() data: any) {
        const product = await this.suppliersService.addSupplierProduct({ ...data, supplierId: id });
        return ResponseBuilder.created(product, 'Product added', 'تم إضافة المنتج');
    }

    // ═════════════════════════════════════
    // Supplier Payments
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get(':id/payments')
    @ApiOperation({
        summary: 'Get supplier payments',
        description: 'Retrieve payment history for a supplier. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Supplier ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Supplier payments retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getSupplierPayments(@Param('id') id: string) {
        const payments = await this.suppliersService.getSupplierPayments(id);
        return ResponseBuilder.success(payments, 'Payments retrieved', 'تم استرجاع المدفوعات');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post(':id/payments')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Create payment to supplier',
        description: 'Record a payment made to a supplier. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Supplier ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 201, description: 'Payment created successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async createPayment(@Param('id') id: string, @Body() data: any, @CurrentUser() user: any) {
        const payment = await this.suppliersService.createPayment({
            ...data,
            supplierId: id,
            createdBy: user._id,
        });
        return ResponseBuilder.created(payment, 'Payment created', 'تم إنشاء الدفعة');
    }
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 📋 Purchase Orders Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Suppliers & Purchases')
@Controller('purchase-orders')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class PurchaseOrdersController {
    constructor(private readonly suppliersService: SuppliersService) { }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get()
    @ApiOperation({
        summary: 'Get all purchase orders',
        description: 'Retrieve all purchase orders with optional filtering. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Purchase orders retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getPurchaseOrders(@Query() query: any) {
        const result = await this.suppliersService.findAllPurchaseOrders(query);
        return ResponseBuilder.success(result.data, 'Purchase orders retrieved', 'تم استرجاع أوامر الشراء', {
            total: result.total,
        });
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get(':id')
    @ApiOperation({
        summary: 'Get purchase order by ID',
        description: 'Retrieve detailed information about a purchase order. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Purchase order ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Purchase order retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getPurchaseOrder(@Param('id') id: string) {
        const result = await this.suppliersService.findPurchaseOrderById(id);
        return ResponseBuilder.success(result, 'Purchase order retrieved', 'تم استرجاع أمر الشراء');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post()
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Create purchase order',
        description: 'Create a new purchase order from a supplier. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Purchase order created successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async createPurchaseOrder(@Body() body: { order: any; items: any[] }, @CurrentUser() user: any) {
        const order = await this.suppliersService.createPurchaseOrder(
            { ...body.order, createdBy: user._id },
            body.items,
        );
        return ResponseBuilder.created(order, 'Purchase order created', 'تم إنشاء أمر الشراء');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put(':id/status')
    @ApiOperation({
        summary: 'Update purchase order status',
        description: 'Update the status of a purchase order. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Purchase order ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Purchase order status updated successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async updateStatus(
        @Param('id') id: string,
        @Body('status') status: string,
        @CurrentUser() user: any,
    ) {
        const order = await this.suppliersService.updatePurchaseOrderStatus(id, status, user._id);
        return ResponseBuilder.success(order, 'Status updated', 'تم تحديث الحالة');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post(':id/receive')
    @ApiOperation({
        summary: 'Receive purchase order items',
        description: 'Record the receipt of items from a purchase order. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Purchase order ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Items received successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async receivePurchaseOrder(
        @Param('id') id: string,
        @Body() items: { itemId: string; receivedQuantity: number; damagedQuantity?: number }[],
    ) {
        await this.suppliersService.receivePurchaseOrder(id, items);
        return ResponseBuilder.success(null, 'Items received', 'تم استلام العناصر');
    }
}
