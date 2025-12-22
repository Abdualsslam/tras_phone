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
import { CartService } from './cart.service';
import { OrdersService } from './orders.service';
import { Public } from '@decorators/public.decorator';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Cart Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Cart')
@Controller('cart')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class CartController {
    constructor(private readonly cartService: CartService) { }

    @Get()
    @ApiOperation({ summary: 'Get my cart' })
    async getCart(@CurrentUser() user: any) {
        const cart = await this.cartService.getCart(user.customerId);
        return ResponseBuilder.success(cart, 'Cart retrieved', 'تم استرجاع السلة');
    }

    @Post('items')
    @ApiOperation({ summary: 'Add item to cart' })
    async addItem(
        @CurrentUser() user: any,
        @Body() data: { productId: string; quantity: number; unitPrice: number },
    ) {
        const cart = await this.cartService.addItem(
            user.customerId,
            data.productId,
            data.quantity,
            data.unitPrice,
        );
        return ResponseBuilder.success(cart, 'Item added', 'تم إضافة العنصر');
    }

    @Put('items/:productId')
    @ApiOperation({ summary: 'Update item quantity' })
    async updateItem(
        @CurrentUser() user: any,
        @Param('productId') productId: string,
        @Body('quantity') quantity: number,
    ) {
        const cart = await this.cartService.updateItemQuantity(user.customerId, productId, quantity);
        return ResponseBuilder.success(cart, 'Item updated', 'تم تحديث العنصر');
    }

    @Delete('items/:productId')
    @ApiOperation({ summary: 'Remove item from cart' })
    async removeItem(@CurrentUser() user: any, @Param('productId') productId: string) {
        const cart = await this.cartService.removeItem(user.customerId, productId);
        return ResponseBuilder.success(cart, 'Item removed', 'تم إزالة العنصر');
    }

    @Delete()
    @ApiOperation({ summary: 'Clear cart' })
    async clearCart(@CurrentUser() user: any) {
        const cart = await this.cartService.clearCart(user.customerId);
        return ResponseBuilder.success(cart, 'Cart cleared', 'تم تفريغ السلة');
    }

    @Post('coupon')
    @ApiOperation({ summary: 'Apply coupon to cart' })
    async applyCoupon(
        @CurrentUser() user: any,
        @Body() data: { couponId: string; couponCode: string; discountAmount: number },
    ) {
        const cart = await this.cartService.applyCoupon(
            user.customerId,
            data.couponId,
            data.couponCode,
            data.discountAmount,
        );
        return ResponseBuilder.success(cart, 'Coupon applied', 'تم تطبيق الكوبون');
    }

    @Delete('coupon')
    @ApiOperation({ summary: 'Remove coupon from cart' })
    async removeCoupon(@CurrentUser() user: any) {
        const cart = await this.cartService.removeCoupon(user.customerId);
        return ResponseBuilder.success(cart, 'Coupon removed', 'تم إزالة الكوبون');
    }
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Orders Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Orders')
@Controller('orders')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class OrdersController {
    constructor(private readonly ordersService: OrdersService) { }

    // ═════════════════════════════════════
    // Customer Endpoints
    // ═════════════════════════════════════

    @Get('my')
    @ApiOperation({ summary: 'Get my orders' })
    async getMyOrders(@CurrentUser() user: any, @Query() query: any) {
        const result = await this.ordersService.findAll({
            ...query,
            customerId: user.customerId,
        });
        return ResponseBuilder.success(result.data, 'Orders retrieved', 'تم استرجاع الطلبات', {
            total: result.total,
        });
    }

    @Post()
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create order from cart' })
    async createOrder(@CurrentUser() user: any, @Body() data: any) {
        const order = await this.ordersService.createOrder(user.customerId, data);
        return ResponseBuilder.created(order, 'Order created', 'تم إنشاء الطلب');
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get order details' })
    async getOrder(@Param('id') id: string) {
        const result = await this.ordersService.findById(id);
        return ResponseBuilder.success(result, 'Order retrieved', 'تم استرجاع الطلب');
    }

    // ═════════════════════════════════════
    // Admin Endpoints
    // ═════════════════════════════════════

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get()
    @ApiOperation({ summary: 'Get all orders (admin)' })
    async getAllOrders(@Query() query: any) {
        const result = await this.ordersService.findAll(query);
        return ResponseBuilder.success(result.data, 'Orders retrieved', 'تم استرجاع الطلبات', {
            total: result.total,
        });
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put(':id/status')
    @ApiOperation({ summary: 'Update order status' })
    async updateStatus(
        @Param('id') id: string,
        @Body() data: { status: string; notes?: string },
        @CurrentUser() user: any,
    ) {
        const order = await this.ordersService.updateStatus(id, data.status, user._id, data.notes);
        return ResponseBuilder.success(order, 'Status updated', 'تم تحديث الحالة');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post(':id/shipments')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create shipment for order' })
    async createShipment(@Param('id') id: string, @Body() data: any) {
        const shipment = await this.ordersService.createShipment(id, data);
        return ResponseBuilder.created(shipment, 'Shipment created', 'تم إنشاء الشحنة');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put('shipments/:shipmentId/status')
    @ApiOperation({ summary: 'Update shipment status' })
    async updateShipmentStatus(
        @Param('shipmentId') shipmentId: string,
        @Body() data: { status: string; trackingNumber?: string },
    ) {
        const shipment = await this.ordersService.updateShipmentStatus(
            shipmentId,
            data.status,
            data.trackingNumber,
        );
        return ResponseBuilder.success(shipment, 'Shipment updated', 'تم تحديث الشحنة');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post(':id/payments')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Record payment for order' })
    async recordPayment(@Param('id') id: string, @Body() data: any) {
        const payment = await this.ordersService.recordPayment(id, data);
        return ResponseBuilder.created(payment, 'Payment recorded', 'تم تسجيل الدفعة');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get(':id/notes')
    @ApiOperation({ summary: 'Get order notes' })
    async getNotes(@Param('id') id: string) {
        const notes = await this.ordersService.getNotes(id);
        return ResponseBuilder.success(notes, 'Notes retrieved', 'تم استرجاع الملاحظات');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post(':id/notes')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Add note to order' })
    async addNote(
        @Param('id') id: string,
        @Body() data: { content: string; type?: string },
        @CurrentUser() user: any,
    ) {
        const note = await this.ordersService.addNote(
            id,
            data.content,
            data.type || 'internal',
            user._id,
        );
        return ResponseBuilder.created(note, 'Note added', 'تم إضافة الملاحظة');
    }
}
