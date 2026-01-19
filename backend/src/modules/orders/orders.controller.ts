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
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiParam,
  ApiResponse,
  ApiQuery,
} from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import {
  ApiCommonErrorResponses,
  ApiAuthErrorResponses,
  ApiPublicErrorResponses,
} from '@common/decorators/api-error-responses.decorator';
import { AddCartItemDto } from './dto/add-cart-item.dto';
import { UpdateCartItemDto } from './dto/update-cart-item.dto';
import { ApplyCouponDto } from './dto/apply-coupon.dto';
import { SyncCartDto } from './dto/sync-cart.dto';
import { CreateOrderDto } from './dto/create-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
import { CreateShipmentDto } from './dto/create-shipment.dto';
import { AddOrderNoteDto } from './dto/add-order-note.dto';
import { OrderFilterQueryDto } from './dto/order-filter-query.dto';
import { UploadReceiptDto } from './dto/upload-receipt.dto';
import { VerifyPaymentDto } from './dto/verify-payment.dto';
import { RateOrderDto } from './dto/rate-order.dto';
import { CartService } from './cart.service';
import { OrdersService } from './orders.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { BadRequestException } from '@nestjs/common';
import { Public } from '@decorators/public.decorator';

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
  constructor(private readonly cartService: CartService) {}

  @Get()
  @ApiOperation({
    summary: 'Get my cart',
    description: "Retrieve the current user's shopping cart",
  })
  @ApiResponse({
    status: 200,
    description: 'Cart retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getCart(@CurrentUser() user: any) {
    const cart = await this.cartService.getCart(user.customerId);
    return ResponseBuilder.success(cart, 'Cart retrieved', 'تم استرجاع السلة');
  }

  @Post('items')
  @ApiOperation({
    summary: 'Add item to cart',
    description:
      'Add a product to the shopping cart. If the item already exists, the quantity will be increased.',
  })
  @ApiResponse({
    status: 200,
    description: 'Item added to cart successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async addItem(
    @CurrentUser() user: any,
    @Body() addCartItemDto: AddCartItemDto,
  ) {
    const cart = await this.cartService.addItem(
      user.customerId,
      addCartItemDto.productId,
      addCartItemDto.quantity,
      addCartItemDto.unitPrice,
    );
    return ResponseBuilder.success(cart, 'Item added', 'تم إضافة العنصر');
  }

  @Put('items/:productId')
  @ApiOperation({
    summary: 'Update item quantity',
    description: 'Update the quantity of an item in the cart',
  })
  @ApiParam({
    name: 'productId',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Item quantity updated successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async updateItem(
    @CurrentUser() user: any,
    @Param('productId') productId: string,
    @Body() updateCartItemDto: UpdateCartItemDto,
  ) {
    const cart = await this.cartService.updateItemQuantity(
      user.customerId,
      productId,
      updateCartItemDto.quantity,
    );
    return ResponseBuilder.success(cart, 'Item updated', 'تم تحديث العنصر');
  }

  @Delete('items/:productId')
  @ApiOperation({
    summary: 'Remove item from cart',
    description: 'Remove a product from the shopping cart',
  })
  @ApiParam({
    name: 'productId',
    description: 'Product ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Item removed from cart successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async removeItem(
    @CurrentUser() user: any,
    @Param('productId') productId: string,
  ) {
    const cart = await this.cartService.removeItem(user.customerId, productId);
    return ResponseBuilder.success(cart, 'Item removed', 'تم إزالة العنصر');
  }

  @Delete()
  @ApiOperation({
    summary: 'Clear cart',
    description: 'Remove all items from the shopping cart',
  })
  @ApiResponse({
    status: 200,
    description: 'Cart cleared successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async clearCart(@CurrentUser() user: any) {
    const cart = await this.cartService.clearCart(user.customerId);
    return ResponseBuilder.success(cart, 'Cart cleared', 'تم تفريغ السلة');
  }

  @Post('coupon')
  @ApiOperation({
    summary: 'Apply coupon to cart',
    description: 'Apply a discount coupon to the shopping cart',
  })
  @ApiResponse({
    status: 200,
    description: 'Coupon applied successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async applyCoupon(
    @CurrentUser() user: any,
    @Body() applyCouponDto: ApplyCouponDto,
  ) {
    const cart = await this.cartService.applyCoupon(
      user.customerId,
      applyCouponDto.couponId,
      applyCouponDto.couponCode,
      applyCouponDto.discountAmount,
    );
    return ResponseBuilder.success(cart, 'Coupon applied', 'تم تطبيق الكوبون');
  }

  @Delete('coupon')
  @ApiOperation({
    summary: 'Remove coupon from cart',
    description: 'Remove the applied coupon from the shopping cart',
  })
  @ApiResponse({
    status: 200,
    description: 'Coupon removed successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async removeCoupon(@CurrentUser() user: any) {
    const cart = await this.cartService.removeCoupon(user.customerId);
    return ResponseBuilder.success(cart, 'Coupon removed', 'تم إزالة الكوبون');
  }

  @Post('sync')
  @ApiOperation({
    summary: 'Sync local cart with server',
    description:
      'Synchronize local cart items with server. Validates stock, prices, and product availability.',
  })
  @ApiResponse({
    status: 200,
    description: 'Cart synced successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async syncCart(
    @CurrentUser() user: any,
    @Body() syncCartDto: SyncCartDto,
  ) {
    const result = await this.cartService.syncCart(
      user.customerId,
      syncCartDto.items,
    );

    return ResponseBuilder.success(
      {
        cart: result.cart,
        removedItems: result.removedItems,
        priceChangedItems: result.priceChangedItems,
        quantityAdjustedItems: result.quantityAdjustedItems,
      },
      'Cart synced successfully',
      'تمت مزامنة السلة بنجاح',
    );
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
  constructor(private readonly ordersService: OrdersService) {}

  // ═════════════════════════════════════
  // Customer Endpoints
  // ═════════════════════════════════════

  @Get('my')
  @ApiOperation({
    summary: 'Get my orders',
    description:
      'Retrieve all orders for the current customer with optional filtering',
  })
  @ApiQuery({ name: 'page', required: false, type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, type: Number, example: 20 })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: [
      'pending',
      'confirmed',
      'processing',
      'ready_for_pickup',
      'shipped',
      'out_for_delivery',
      'delivered',
      'completed',
      'cancelled',
      'refunded',
    ],
  })
  @ApiResponse({
    status: 200,
    description: 'Orders retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getMyOrders(
    @CurrentUser() user: any,
    @Query() query: OrderFilterQueryDto,
  ) {
    const result = await this.ordersService.findAll({
      ...query,
      customerId: user.customerId,
    });
    return ResponseBuilder.success(
      result.data,
      'Orders retrieved',
      'تم استرجاع الطلبات',
      {
        total: result.total,
      },
    );
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create order from cart',
    description: 'Create a new order from the current shopping cart',
  })
  @ApiResponse({
    status: 201,
    description: 'Order created successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async createOrder(
    @CurrentUser() user: any,
    @Body() createOrderDto: CreateOrderDto,
  ) {
    const order = await this.ordersService.createOrder(
      user.customerId,
      createOrderDto,
    );
    return ResponseBuilder.created(order, 'Order created', 'تم إنشاء الطلب');
  }

  @Get('my/stats')
  @ApiOperation({
    summary: 'Get my order statistics',
    description: 'Get order statistics for the current customer',
  })
  @ApiResponse({
    status: 200,
    description: 'Order statistics retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getMyStats(@CurrentUser() user: any) {
    const stats = await this.ordersService.getStats(user.customerId);
    return ResponseBuilder.success(
      stats,
      'Order statistics retrieved',
      'تم استرجاع إحصائيات الطلبات',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get('stats')
  @ApiOperation({
    summary: 'Get order statistics',
    description: 'Get comprehensive order statistics. Admin only.',
  })
  @ApiResponse({
    status: 200,
    description: 'Order statistics retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getStats(@CurrentUser() user: any) {
    const stats = await this.ordersService.getStats();
    return ResponseBuilder.success(
      stats,
      'Order statistics retrieved',
      'تم استرجاع إحصائيات الطلبات',
    );
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get order details',
    description: 'Retrieve detailed information about a specific order',
  })
  @ApiParam({
    name: 'id',
    description: 'Order ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Order retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getOrder(@Param('id') id: string) {
    const result = await this.ordersService.findById(id);
    return ResponseBuilder.success(
      result,
      'Order retrieved',
      'تم استرجاع الطلب',
    );
  }

  // ═════════════════════════════════════
  // Admin Endpoints
  // ═════════════════════════════════════

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get()
  @ApiOperation({
    summary: 'Get all orders (admin)',
    description: 'Retrieve all orders with optional filtering. Admin only.',
  })
  @ApiResponse({
    status: 200,
    description: 'Orders retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getAllOrders(@Query() query: OrderFilterQueryDto) {
    const result = await this.ordersService.findAll(query);
    return ResponseBuilder.success(
      result.data,
      'Orders retrieved',
      'تم استرجاع الطلبات',
      {
        total: result.total,
      },
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put(':id/status')
  @ApiOperation({
    summary: 'Update order status',
    description: 'Update the status of an order. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Order ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Order status updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updateStatus(
    @Param('id') id: string,
    @Body() updateOrderStatusDto: UpdateOrderStatusDto,
    @CurrentUser() user: any,
  ) {
    const order = await this.ordersService.updateStatus(
      id,
      updateOrderStatusDto.status,
      user._id,
      updateOrderStatusDto.notes,
    );
    return ResponseBuilder.success(order, 'Status updated', 'تم تحديث الحالة');
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post(':id/shipments')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create shipment for order',
    description: 'Create a shipment record for an order. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Order ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 201,
    description: 'Shipment created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async createShipment(
    @Param('id') id: string,
    @Body() createShipmentDto: CreateShipmentDto,
  ) {
    const shipment = await this.ordersService.createShipment(
      id,
      createShipmentDto,
    );
    return ResponseBuilder.created(
      shipment,
      'Shipment created',
      'تم إنشاء الشحنة',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put('shipments/:shipmentId/status')
  @ApiOperation({
    summary: 'Update shipment status',
    description:
      'Update the status and tracking information of a shipment. Admin only.',
  })
  @ApiParam({
    name: 'shipmentId',
    description: 'Shipment ID',
    example: '507f1f77bcf86cd799439012',
  })
  @ApiResponse({
    status: 200,
    description: 'Shipment status updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updateShipmentStatus(
    @Param('shipmentId') shipmentId: string,
    @Body() data: { status: string; trackingNumber?: string },
  ) {
    const shipment = await this.ordersService.updateShipmentStatus(
      shipmentId,
      data.status,
      data.trackingNumber,
    );
    return ResponseBuilder.success(
      shipment,
      'Shipment updated',
      'تم تحديث الشحنة',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post(':id/payments')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Record payment for order',
    description: 'Record a payment transaction for an order. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Order ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 201,
    description: 'Payment recorded successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async recordPayment(@Param('id') id: string, @Body() data: any) {
    const payment = await this.ordersService.recordPayment(id, data);
    return ResponseBuilder.created(
      payment,
      'Payment recorded',
      'تم تسجيل الدفعة',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get(':id/notes')
  @ApiOperation({
    summary: 'Get order notes',
    description: 'Retrieve all notes associated with an order. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Order ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Order notes retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getNotes(@Param('id') id: string) {
    const notes = await this.ordersService.getNotes(id);
    return ResponseBuilder.success(
      notes,
      'Notes retrieved',
      'تم استرجاع الملاحظات',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post(':id/notes')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Add note to order',
    description: 'Add a note to an order. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Order ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 201,
    description: 'Note added successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async addNote(
    @Param('id') id: string,
    @Body() addOrderNoteDto: AddOrderNoteDto,
    @CurrentUser() user: any,
  ) {
    const note = await this.ordersService.addNote(
      id,
      addOrderNoteDto.content,
      addOrderNoteDto.type || 'internal',
      user._id,
    );
    return ResponseBuilder.created(note, 'Note added', 'تم إضافة الملاحظة');
  }

  // ═════════════════════════════════════
  // Payment & Rating Endpoints
  // ═════════════════════════════════════

  @Post(':id/upload-receipt')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Upload payment receipt',
    description: 'Upload a receipt image for bank transfer payment',
  })
  @ApiParam({
    name: 'id',
    description: 'Order ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Receipt uploaded successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async uploadReceipt(
    @Param('id') id: string,
    @Body() uploadReceiptDto: UploadReceiptDto,
    @CurrentUser() user: any,
  ) {
    // Verify order belongs to user
    const order = await this.ordersService.findById(id);
    if (order.order.customerId.toString() !== user.customerId) {
      throw new BadRequestException('Order not found');
    }

    const result = await this.ordersService.uploadReceipt(id, uploadReceiptDto);
    return ResponseBuilder.success(
      result,
      'Receipt uploaded successfully',
      'تم رفع الإيصال بنجاح',
    );
  }

  @Post(':id/rate')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Rate order',
    description: 'Rate a delivered or completed order',
  })
  @ApiParam({
    name: 'id',
    description: 'Order ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Order rated successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async rateOrder(
    @Param('id') id: string,
    @Body() rateOrderDto: RateOrderDto,
    @CurrentUser() user: any,
  ) {
    const result = await this.ordersService.rateOrder(
      id,
      user.customerId,
      rateOrderDto.rating,
      rateOrderDto.comment,
    );
    return ResponseBuilder.success(
      result,
      'Order rated successfully',
      'تم تقييم الطلب بنجاح',
    );
  }

  @Get('pending-payment')
  @ApiOperation({
    summary: 'Get pending payment orders',
    description: 'Get all orders with pending bank transfer payments',
  })
  @ApiResponse({
    status: 200,
    description: 'Orders retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getPendingPaymentOrders(@CurrentUser() user: any) {
    const orders = await this.ordersService.getPendingPaymentOrders(
      user.customerId,
    );
    return ResponseBuilder.success(
      orders,
      'Pending payment orders retrieved',
      'تم استرجاع الطلبات بانتظار الدفع',
    );
  }
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏦 Bank Accounts Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Bank Accounts')
@Controller('bank-accounts')
export class BankAccountsController {
  constructor(private readonly ordersService: OrdersService) {}

  @Public()
  @Get()
  @ApiOperation({
    summary: 'Get bank accounts',
    description:
      'Retrieve all active bank accounts for payments. Public endpoint.',
  })
  @ApiResponse({
    status: 200,
    description: 'Bank accounts retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getBankAccounts() {
    const accounts = await this.ordersService.getBankAccounts();
    return ResponseBuilder.success(
      accounts,
      'Bank accounts retrieved',
      'تم استرجاع الحسابات البنكية',
    );
  }
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 Admin Orders Controller (Additional endpoints)
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Admin Orders')
@Controller('admin/orders')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
@ApiBearerAuth('JWT-auth')
export class AdminOrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post(':id/verify-payment')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Verify payment',
    description: 'Verify or reject a bank transfer payment. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Order ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Payment verification updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async verifyPayment(
    @Param('id') id: string,
    @Body() verifyPaymentDto: VerifyPaymentDto,
    @CurrentUser() user: any,
  ) {
    const result = await this.ordersService.verifyPayment(
      id,
      verifyPaymentDto.verified,
      user.id,
      verifyPaymentDto.rejectionReason,
      verifyPaymentDto.notes,
    );
    return ResponseBuilder.success(
      result,
      'Payment verification updated',
      'تم تحديث التحقق من الدفع',
    );
  }
}
