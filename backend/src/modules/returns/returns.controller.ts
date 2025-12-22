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
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
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
    constructor(private readonly returnsService: ReturnsService) { }

    // ═════════════════════════════════════
    // Public
    // ═════════════════════════════════════

    @Public()
    @Get('reasons')
    @ApiOperation({ summary: 'Get return reasons' })
    async getReasons() {
        const reasons = await this.returnsService.getReturnReasons();
        return ResponseBuilder.success(reasons, 'Reasons retrieved', 'تم استرجاع الأسباب');
    }

    // ═════════════════════════════════════
    // Customer Endpoints
    // ═════════════════════════════════════

    @Get('my')
    @ApiOperation({ summary: 'Get my return requests' })
    async getMyReturns(@CurrentUser() user: any, @Query() query: any) {
        const result = await this.returnsService.findAll({
            ...query,
            customerId: user.customerId,
        });
        return ResponseBuilder.success(result.data, 'Returns retrieved', 'تم استرجاع المرتجعات', {
            total: result.total,
        });
    }

    @Post()
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create return request' })
    async createReturn(@CurrentUser() user: any, @Body() data: any) {
        const returnRequest = await this.returnsService.createReturnRequest({
            ...data,
            customerId: user.customerId,
        });
        return ResponseBuilder.created(returnRequest, 'Return request created', 'تم إنشاء طلب الإرجاع');
    }

    @Get(':id')
    @ApiOperation({ summary: 'Get return request details' })
    async getReturn(@Param('id') id: string) {
        const result = await this.returnsService.findById(id);
        return ResponseBuilder.success(result, 'Return retrieved', 'تم استرجاع طلب الإرجاع');
    }

    // ═════════════════════════════════════
    // Admin Endpoints
    // ═════════════════════════════════════

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get()
    @ApiOperation({ summary: 'Get all returns (admin)' })
    async getAllReturns(@Query() query: any) {
        const result = await this.returnsService.findAll(query);
        return ResponseBuilder.success(result.data, 'Returns retrieved', 'تم استرجاع المرتجعات', {
            total: result.total,
        });
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put(':id/status')
    @ApiOperation({ summary: 'Update return status' })
    async updateStatus(
        @Param('id') id: string,
        @Body() data: { status: string; notes?: string },
        @CurrentUser() user: any,
    ) {
        const returnRequest = await this.returnsService.updateStatus(id, data.status, user._id, data.notes);
        return ResponseBuilder.success(returnRequest, 'Status updated', 'تم تحديث الحالة');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put('items/:itemId/inspect')
    @ApiOperation({ summary: 'Inspect return item' })
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
    @ApiOperation({ summary: 'Process refund' })
    async processRefund(
        @Param('id') id: string,
        @Body() data: any,
        @CurrentUser() user: any,
    ) {
        const refund = await this.returnsService.processRefund(id, {
            ...data,
            processedBy: user._id,
        });
        return ResponseBuilder.created(refund, 'Refund processed', 'تم معالجة الاسترداد');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put('refunds/:refundId/complete')
    @ApiOperation({ summary: 'Complete refund' })
    async completeRefund(
        @Param('refundId') refundId: string,
        @Body('transactionId') transactionId?: string,
    ) {
        const refund = await this.returnsService.completeRefund(refundId, transactionId);
        return ResponseBuilder.success(refund, 'Refund completed', 'تم إكمال الاسترداد');
    }

    // ═════════════════════════════════════
    // Return Reasons Management
    // ═════════════════════════════════════

    @UseGuards(RolesGuard)
    @Roles(UserRole.SUPER_ADMIN)
    @Post('reasons')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create return reason' })
    async createReason(@Body() data: any) {
        const reason = await this.returnsService.createReturnReason(data);
        return ResponseBuilder.created(reason, 'Reason created', 'تم إنشاء السبب');
    }
}
