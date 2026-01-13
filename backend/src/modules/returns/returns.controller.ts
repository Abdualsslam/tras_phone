import {
  Controller,
  Get,
  Post,
  Put,
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
  ApiPublicErrorResponses,
  ApiAuthErrorResponses,
} from '@common/decorators/api-error-responses.decorator';
import { ReturnsService } from './returns.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { Public } from '@decorators/public.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔄 Returns Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Returns')
@Controller('returns')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class ReturnsController {
  constructor(private readonly returnsService: ReturnsService) {}

  // ═════════════════════════════════════
  // Public
  // ═════════════════════════════════════

  @Public()
  @Get('reasons')
  @ApiOperation({
    summary: 'Get return reasons',
    description: 'Retrieve all available return reasons. Public endpoint.',
  })
  @ApiResponse({
    status: 200,
    description: 'Return reasons retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getReasons() {
    const reasons = await this.returnsService.getReturnReasons();
    return ResponseBuilder.success(
      reasons,
      'Reasons retrieved',
      'تم استرجاع الأسباب',
    );
  }

  // ═════════════════════════════════════
  // Customer Endpoints
  // ═════════════════════════════════════

  @Get('my')
  @ApiOperation({
    summary: 'Get my return requests',
    description: 'Retrieve all return requests for the current customer.',
  })
  @ApiResponse({
    status: 200,
    description: 'Return requests retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getMyReturns(@CurrentUser() user: any, @Query() query: any) {
    const result = await this.returnsService.findAll({
      ...query,
      customerId: user.customerId,
    });
    return ResponseBuilder.success(
      result.data,
      'Returns retrieved',
      'تم استرجاع المرتجعات',
      {
        total: result.total,
      },
    );
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create return request',
    description: 'Create a new return request for an order item.',
  })
  @ApiResponse({
    status: 201,
    description: 'Return request created successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async createReturn(@CurrentUser() user: any, @Body() data: any) {
    const returnRequest = await this.returnsService.createReturnRequest({
      ...data,
      customerId: user.customerId,
    });
    return ResponseBuilder.created(
      returnRequest,
      'Return request created',
      'تم إنشاء طلب الإرجاع',
    );
  }

  @Get(':id')
  @ApiOperation({
    summary: 'Get return request details',
    description: 'Retrieve detailed information about a return request.',
  })
  @ApiParam({
    name: 'id',
    description: 'Return request ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Return request retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getReturn(@Param('id') id: string) {
    const result = await this.returnsService.findById(id);
    return ResponseBuilder.success(
      result,
      'Return retrieved',
      'تم استرجاع طلب الإرجاع',
    );
  }

  // ═════════════════════════════════════
  // Admin Endpoints
  // ═════════════════════════════════════

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get()
  @ApiOperation({
    summary: 'Get all returns (admin)',
    description:
      'Retrieve all return requests with optional filtering. Admin only.',
  })
  @ApiResponse({
    status: 200,
    description: 'Return requests retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getAllReturns(@Query() query: any) {
    const result = await this.returnsService.findAll(query);
    return ResponseBuilder.success(
      result.data,
      'Returns retrieved',
      'تم استرجاع المرتجعات',
      {
        total: result.total,
      },
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put(':id/status')
  @ApiOperation({
    summary: 'Update return status',
    description: 'Update the status of a return request. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Return request ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Return status updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updateStatus(
    @Param('id') id: string,
    @Body() data: { status: string; notes?: string },
    @CurrentUser() user: any,
  ) {
    const returnRequest = await this.returnsService.updateStatus(
      id,
      data.status,
      user._id,
      data.notes,
    );
    return ResponseBuilder.success(
      returnRequest,
      'Status updated',
      'تم تحديث الحالة',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put('items/:itemId/inspect')
  @ApiOperation({
    summary: 'Inspect return item',
    description: 'Record inspection results for a returned item. Admin only.',
  })
  @ApiParam({
    name: 'itemId',
    description: 'Return item ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Item inspection completed successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async inspectItem(
    @Param('itemId') itemId: string,
    @Body() data: any,
    @CurrentUser() user: any,
  ) {
    const item = await this.returnsService.inspectItem(itemId, {
      ...data,
      inspectedBy: user._id,
    });
    return ResponseBuilder.success(item, 'Item inspected', 'تم فحص العنصر');
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post(':id/refund')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Process refund',
    description: 'Process a refund for a return request. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Return request ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 201,
    description: 'Refund processed successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async processRefund(
    @Param('id') id: string,
    @Body() data: any,
    @CurrentUser() user: any,
  ) {
    const refund = await this.returnsService.processRefund(id, {
      ...data,
      processedBy: user._id,
    });
    return ResponseBuilder.created(
      refund,
      'Refund processed',
      'تم معالجة الاسترداد',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put('refunds/:refundId/complete')
  @ApiOperation({
    summary: 'Complete refund',
    description: 'Mark a refund as completed after payment. Admin only.',
  })
  @ApiParam({
    name: 'refundId',
    description: 'Refund ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Refund completed successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async completeRefund(
    @Param('refundId') refundId: string,
    @Body('transactionId') transactionId?: string,
  ) {
    const refund = await this.returnsService.completeRefund(
      refundId,
      transactionId,
    );
    return ResponseBuilder.success(
      refund,
      'Refund completed',
      'تم إكمال الاسترداد',
    );
  }

  // ═════════════════════════════════════
  // Return Reasons Management
  // ═════════════════════════════════════

  @UseGuards(RolesGuard)
  @Roles(UserRole.SUPER_ADMIN)
  @Post('reasons')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create return reason',
    description: 'Create a new return reason. Super admin only.',
  })
  @ApiResponse({
    status: 201,
    description: 'Return reason created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async createReason(@Body() data: any) {
    const reason = await this.returnsService.createReturnReason(data);
    return ResponseBuilder.created(reason, 'Reason created', 'تم إنشاء السبب');
  }

  // ═════════════════════════════════════
  // Supplier Return Batches (Admin)
  // ═════════════════════════════════════

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get('supplier-returns')
  @ApiOperation({
    summary: 'Get supplier return batches',
    description: 'Retrieve all supplier return batches. Admin only.',
  })
  @ApiQuery({ name: 'supplierId', required: false })
  @ApiQuery({ name: 'status', required: false })
  @ApiResponse({
    status: 200,
    description: 'Supplier return batches retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async getSupplierReturnBatches(@Query() query: any) {
    const batches = await this.returnsService.getSupplierReturnBatches(query);
    return ResponseBuilder.success(
      batches,
      'Supplier return batches retrieved',
      'تم استرجاع دفعات إرجاع الموردين',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post('supplier-returns')
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Create supplier return batch',
    description: 'Create a new supplier return batch. Admin only.',
  })
  @ApiResponse({
    status: 201,
    description: 'Supplier return batch created successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async createSupplierReturnBatch(@Body() data: any, @CurrentUser() user: any) {
    const batch = await this.returnsService.createSupplierReturnBatch({
      ...data,
      createdBy: user.id,
    });
    return ResponseBuilder.created(
      batch,
      'Supplier return batch created',
      'تم إنشاء دفعة إرجاع المورد',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Post('items/:itemId/link-supplier')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Link return item to supplier batch',
    description: 'Link a return item to a supplier return batch. Admin only.',
  })
  @ApiParam({
    name: 'itemId',
    description: 'Return Item ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Return item linked successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async linkReturnToSupplier(
    @Param('itemId') itemId: string,
    @Body('batchId') batchId: string,
  ) {
    const result = await this.returnsService.linkReturnToSupplierBatch(
      itemId,
      batchId,
    );
    return ResponseBuilder.success(
      result,
      'Return item linked',
      'تم ربط المرتجع بدفعة المورد',
    );
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Put('supplier-returns/:id/status')
  @ApiOperation({
    summary: 'Update supplier batch status',
    description: 'Update the status of a supplier return batch. Admin only.',
  })
  @ApiParam({
    name: 'id',
    description: 'Supplier Return Batch ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Supplier batch status updated successfully',
    type: ApiResponseDto,
  })
  @ApiCommonErrorResponses()
  async updateSupplierBatchStatus(
    @Param('id') id: string,
    @Body()
    data: {
      status: string;
      acknowledgedDate?: string;
      supplierReference?: string;
      creditNoteNumber?: string;
      actualCreditAmount?: number;
      supplierNotes?: string;
    },
    @CurrentUser() user: any,
  ) {
    const batch = await this.returnsService.updateSupplierBatchStatus(
      id,
      data.status,
      user.id,
      data,
    );
    return ResponseBuilder.success(
      batch,
      'Supplier batch status updated',
      'تم تحديث حالة دفعة المورد',
    );
  }
}
