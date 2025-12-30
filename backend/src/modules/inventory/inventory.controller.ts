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
import { InventoryService } from './inventory.service';
import { WarehousesService } from './warehouses.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Inventory Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Inventory')
@Controller('inventory')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class InventoryController {
    constructor(
        private readonly inventoryService: InventoryService,
        private readonly warehousesService: WarehousesService,
    ) { }

    // ═════════════════════════════════════
    // Warehouses
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('warehouses')
    @ApiOperation({
        summary: 'Get all warehouses',
        description: 'Retrieve a list of all warehouses. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Warehouses retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getWarehouses() {
        const warehouses = await this.warehousesService.findAll();
        return ResponseBuilder.success(warehouses, 'Warehouses retrieved', 'تم استرجاع المستودعات');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('warehouses/:id')
    @ApiOperation({
        summary: 'Get warehouse by ID',
        description: 'Retrieve detailed information about a specific warehouse. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Warehouse ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Warehouse retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getWarehouse(@Param('id') id: string) {
        const warehouse = await this.warehousesService.findById(id);
        return ResponseBuilder.success(warehouse, 'Warehouse retrieved', 'تم استرجاع المستودع');
    }

    @Roles(UserRole.SUPER_ADMIN)
    @Post('warehouses')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Create warehouse',
        description: 'Create a new warehouse. Super admin only.',
    })
    @ApiResponse({ status: 201, description: 'Warehouse created successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async createWarehouse(@Body() data: any) {
        const warehouse = await this.warehousesService.create(data);
        return ResponseBuilder.created(warehouse, 'Warehouse created', 'تم إنشاء المستودع');
    }

    @Roles(UserRole.SUPER_ADMIN)
    @Put('warehouses/:id')
    @ApiOperation({
        summary: 'Update warehouse',
        description: 'Update warehouse information. Super admin only.',
    })
    @ApiParam({ name: 'id', description: 'Warehouse ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Warehouse updated successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async updateWarehouse(@Param('id') id: string, @Body() data: any) {
        const warehouse = await this.warehousesService.update(id, data);
        return ResponseBuilder.success(warehouse, 'Warehouse updated', 'تم تحديث المستودع');
    }

    // ═════════════════════════════════════
    // Stock Locations
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('warehouses/:warehouseId/locations')
    @ApiOperation({
        summary: 'Get locations in warehouse',
        description: 'Retrieve all stock locations within a warehouse. Admin only.',
    })
    @ApiParam({ name: 'warehouseId', description: 'Warehouse ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Locations retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getLocations(@Param('warehouseId') warehouseId: string) {
        const locations = await this.warehousesService.getLocations(warehouseId);
        return ResponseBuilder.success(locations, 'Locations retrieved', 'تم استرجاع المواقع');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('warehouses/:warehouseId/locations')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Create location',
        description: 'Create a new stock location within a warehouse. Admin only.',
    })
    @ApiParam({ name: 'warehouseId', description: 'Warehouse ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 201, description: 'Location created successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async createLocation(@Param('warehouseId') warehouseId: string, @Body() data: any) {
        const location = await this.warehousesService.createLocation(warehouseId, data);
        return ResponseBuilder.created(location, 'Location created', 'تم إنشاء الموقع');
    }

    // ═════════════════════════════════════
    // Stock
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('products/:productId/stock')
    @ApiOperation({
        summary: 'Get product stock across warehouses',
        description: 'Retrieve stock levels for a product across all warehouses. Admin only.',
    })
    @ApiParam({ name: 'productId', description: 'Product ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Stock information retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getProductStock(@Param('productId') productId: string) {
        const stock = await this.inventoryService.getProductStock(productId);
        return ResponseBuilder.success(stock, 'Stock retrieved', 'تم استرجاع المخزون');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('adjust')
    @ApiOperation({
        summary: 'Adjust stock (manual adjustment)',
        description: 'Manually adjust stock levels. Used for corrections, damages, etc. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Stock adjusted successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async adjustStock(@Body() data: any) {
        const movement = await this.inventoryService.adjustStock({
            ...data,
            movementType: data.quantity > 0 ? 'adjustment_in' : 'adjustment_out',
        });
        return ResponseBuilder.success(movement, 'Stock adjusted', 'تم تعديل المخزون');
    }

    // ═════════════════════════════════════
    // Movements
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('movements')
    @ApiOperation({
        summary: 'Get stock movements',
        description: 'Retrieve stock movement history with optional filtering. Admin only.',
    })
    @ApiQuery({ name: 'page', required: false, type: Number })
    @ApiQuery({ name: 'limit', required: false, type: Number })
    @ApiQuery({ name: 'productId', required: false, type: String })
    @ApiQuery({ name: 'warehouseId', required: false, type: String })
    @ApiResponse({ status: 200, description: 'Stock movements retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getMovements(@Query() query: any) {
        const result = await this.inventoryService.getMovements(query);
        return ResponseBuilder.success(result.data, 'Movements retrieved', 'تم استرجاع الحركات', {
            total: result.total,
        });
    }

    // ═════════════════════════════════════
    // Alerts
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('alerts')
    @ApiOperation({
        summary: 'Get low stock alerts',
        description: 'Retrieve low stock alerts for products. Admin only.',
    })
    @ApiQuery({ name: 'status', required: false, enum: ['pending', 'resolved'], description: 'Alert status filter' })
    @ApiResponse({ status: 200, description: 'Low stock alerts retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getAlerts(@Query('status') status?: string) {
        const alerts = await this.inventoryService.getLowStockAlerts(status);
        return ResponseBuilder.success(alerts, 'Alerts retrieved', 'تم استرجاع التنبيهات');
    }

    // ═════════════════════════════════════
    // Reservations
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('reserve')
    @ApiOperation({
        summary: 'Reserve stock',
        description: 'Reserve stock for an order or other purpose. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Stock reserved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async reserveStock(@Body() data: any) {
        const reservation = await this.inventoryService.reserveStock(data);
        return ResponseBuilder.success(reservation, 'Stock reserved', 'تم حجز المخزون');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('reservations/:id/release')
    @ApiOperation({
        summary: 'Release reservation',
        description: 'Release a stock reservation. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Reservation ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Reservation released successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async releaseReservation(@Param('id') id: string, @Body('reason') reason?: string) {
        await this.inventoryService.releaseReservation(id, reason);
        return ResponseBuilder.success(null, 'Reservation released', 'تم إلغاء الحجز');
    }
}
