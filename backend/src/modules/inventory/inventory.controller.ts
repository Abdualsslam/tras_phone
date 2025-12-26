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
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
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
    @ApiOperation({ summary: 'Get all warehouses' })
    async getWarehouses() {
        const warehouses = await this.warehousesService.findAll();
        return ResponseBuilder.success(warehouses, 'Warehouses retrieved', 'تم استرجاع المستودعات');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('warehouses/:id')
    @ApiOperation({ summary: 'Get warehouse by ID' })
    async getWarehouse(@Param('id') id: string) {
        const warehouse = await this.warehousesService.findById(id);
        return ResponseBuilder.success(warehouse, 'Warehouse retrieved', 'تم استرجاع المستودع');
    }

    @Roles(UserRole.SUPER_ADMIN)
    @Post('warehouses')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create warehouse' })
    async createWarehouse(@Body() data: any) {
        const warehouse = await this.warehousesService.create(data);
        return ResponseBuilder.created(warehouse, 'Warehouse created', 'تم إنشاء المستودع');
    }

    @Roles(UserRole.SUPER_ADMIN)
    @Put('warehouses/:id')
    @ApiOperation({ summary: 'Update warehouse' })
    async updateWarehouse(@Param('id') id: string, @Body() data: any) {
        const warehouse = await this.warehousesService.update(id, data);
        return ResponseBuilder.success(warehouse, 'Warehouse updated', 'تم تحديث المستودع');
    }

    // ═════════════════════════════════════
    // Stock Locations
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('warehouses/:warehouseId/locations')
    @ApiOperation({ summary: 'Get locations in warehouse' })
    async getLocations(@Param('warehouseId') warehouseId: string) {
        const locations = await this.warehousesService.getLocations(warehouseId);
        return ResponseBuilder.success(locations, 'Locations retrieved', 'تم استرجاع المواقع');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('warehouses/:warehouseId/locations')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create location' })
    async createLocation(@Param('warehouseId') warehouseId: string, @Body() data: any) {
        const location = await this.warehousesService.createLocation(warehouseId, data);
        return ResponseBuilder.created(location, 'Location created', 'تم إنشاء الموقع');
    }

    // ═════════════════════════════════════
    // Stock
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('products/:productId/stock')
    @ApiOperation({ summary: 'Get product stock across warehouses' })
    async getProductStock(@Param('productId') productId: string) {
        const stock = await this.inventoryService.getProductStock(productId);
        return ResponseBuilder.success(stock, 'Stock retrieved', 'تم استرجاع المخزون');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('adjust')
    @ApiOperation({ summary: 'Adjust stock (manual adjustment)' })
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
    @ApiOperation({ summary: 'Get stock movements' })
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
    @ApiOperation({ summary: 'Get low stock alerts' })
    async getAlerts(@Query('status') status?: string) {
        const alerts = await this.inventoryService.getLowStockAlerts(status);
        return ResponseBuilder.success(alerts, 'Alerts retrieved', 'تم استرجاع التنبيهات');
    }

    // ═════════════════════════════════════
    // Reservations
    // ═════════════════════════════════════

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('reserve')
    @ApiOperation({ summary: 'Reserve stock' })
    async reserveStock(@Body() data: any) {
        const reservation = await this.inventoryService.reserveStock(data);
        return ResponseBuilder.success(reservation, 'Stock reserved', 'تم حجز المخزون');
    }

    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('reservations/:id/release')
    @ApiOperation({ summary: 'Release reservation' })
    async releaseReservation(@Param('id') id: string, @Body('reason') reason?: string) {
        await this.inventoryService.releaseReservation(id, reason);
        return ResponseBuilder.success(null, 'Reservation released', 'تم إلغاء الحجز');
    }
}
