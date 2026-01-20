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
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse } from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiCommonErrorResponses, ApiAuthErrorResponses, ApiPublicErrorResponses } from '@common/decorators/api-error-responses.decorator';
import { WalletService } from './wallet.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { Public } from '@decorators/public.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { CreateTierDto } from './dto/create-tier.dto';
import { UpdateTierDto } from './dto/update-tier.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 💰 Wallet Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Wallet & Loyalty')
@Controller('wallet')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class WalletController {
    constructor(private readonly walletService: WalletService) { }

    // ═════════════════════════════════════
    // Wallet
    // ═════════════════════════════════════

    @Get('balance')
    @ApiOperation({
        summary: 'Get my wallet balance',
        description: 'Retrieve the current wallet balance for the authenticated customer.',
    })
    @ApiResponse({ status: 200, description: 'Wallet balance retrieved successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
    async getBalance(@CurrentUser() user: any) {
        const balance = await this.walletService.getBalance(user.customerId);
        return ResponseBuilder.success({ balance }, 'Balance retrieved', 'تم استرجاع الرصيد');
    }

    @Get('transactions')
    @ApiOperation({
        summary: 'Get my wallet transactions',
        description: 'Retrieve wallet transaction history for the authenticated customer.',
    })
    @ApiResponse({ status: 200, description: 'Wallet transactions retrieved successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
    async getTransactions(@CurrentUser() user: any, @Query() query: any) {
        const transactions = await this.walletService.getWalletTransactions(user.customerId, query);
        return ResponseBuilder.success(transactions, 'Transactions retrieved', 'تم استرجاع المعاملات');
    }

    // ═════════════════════════════════════
    // Loyalty
    // ═════════════════════════════════════

    @Get('points')
    @ApiOperation({
        summary: 'Get my loyalty points',
        description: 'Retrieve loyalty points balance, tier, and expiring points for the authenticated customer.',
    })
    @ApiResponse({ status: 200, description: 'Loyalty points retrieved successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
    async getPoints(@CurrentUser() user: any) {
        const [points, tier, expiringPoints] = await Promise.all([
            this.walletService.getPointsBalance(user.customerId),
            this.walletService.getCustomerTier(user.customerId),
            this.walletService.getExpiringPoints(user.customerId, 30),
        ]);

        return ResponseBuilder.success({
            points,
            tier,
            expiringPoints,
            expiringTotal: expiringPoints.reduce((sum, p) => sum + p.remainingPoints, 0),
        }, 'Points retrieved', 'تم استرجاع النقاط');
    }

    @Get('points/transactions')
    @ApiOperation({
        summary: 'Get my loyalty transactions',
        description: 'Retrieve loyalty points transaction history for the authenticated customer.',
    })
    @ApiResponse({ status: 200, description: 'Loyalty transactions retrieved successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
    async getLoyaltyTransactions(@CurrentUser() user: any) {
        const transactions = await this.walletService.getLoyaltyTransactions(user.customerId);
        return ResponseBuilder.success(transactions, 'Transactions retrieved', 'تم استرجاع المعاملات');
    }

    @Public()
    @Get('tiers')
    @ApiOperation({
        summary: 'Get loyalty tiers',
        description: 'Retrieve all active loyalty program tiers and their benefits. Public endpoint.',
    })
    @ApiResponse({ status: 200, description: 'Loyalty tiers retrieved successfully', type: ApiResponseDto })
    @ApiPublicErrorResponses()
    async getTiers() {
        const tiers = await this.walletService.getTiers();
        return ResponseBuilder.success(tiers, 'Tiers retrieved', 'تم استرجاع المستويات');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('admin/tiers')
    @ApiOperation({
        summary: 'Get all loyalty tiers (admin)',
        description: 'Retrieve all loyalty tiers including inactive ones. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Tiers retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getAllTiers() {
        const tiers = await this.walletService.getAllTiers();
        return ResponseBuilder.success(tiers, 'Tiers retrieved', 'تم استرجاع المستويات');
    }

    // ═════════════════════════════════════
    // Admin Operations
    // ═════════════════════════════════════

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('credit')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Credit customer wallet (admin)',
        description: 'Add funds to a customer wallet. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Wallet credited successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async creditWallet(@Body() data: any, @CurrentUser() user: any) {
        const transaction = await this.walletService.credit({
            ...data,
            transactionType: 'admin_credit',
            createdBy: user._id,
        });
        return ResponseBuilder.created(transaction, 'Wallet credited', 'تم إضافة الرصيد');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('debit')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Debit customer wallet (admin)',
        description: 'Deduct funds from a customer wallet. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Wallet debited successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async debitWallet(@Body() data: any, @CurrentUser() user: any) {
        const transaction = await this.walletService.debit({
            ...data,
            transactionType: 'admin_debit',
            createdBy: user._id,
        });
        return ResponseBuilder.created(transaction, 'Wallet debited', 'تم خصم الرصيد');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('points/grant')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Grant loyalty points (admin)',
        description: 'Manually grant loyalty points to a customer. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Points granted successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async grantPoints(@Body() data: any, @CurrentUser() user: any) {
        const transaction = await this.walletService.earnPoints({
            ...data,
            transactionType: 'admin_grant',
            createdBy: user._id,
        });
        return ResponseBuilder.created(transaction, 'Points granted', 'تم إضافة النقاط');
    }

    // ═════════════════════════════════════
    // Admin: Loyalty Tiers Management
    // ═════════════════════════════════════

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('admin/tiers')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Create loyalty tier (admin)',
        description: 'Create a new loyalty tier. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Tier created successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async createTier(@Body() data: CreateTierDto) {
        const tier = await this.walletService.createTier(data);
        return ResponseBuilder.created(tier, 'Tier created', 'تم إنشاء المستوى');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put('admin/tiers/:id')
    @ApiOperation({
        summary: 'Update loyalty tier (admin)',
        description: 'Update an existing loyalty tier. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Tier ID' })
    @ApiResponse({ status: 200, description: 'Tier updated successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async updateTier(@Param('id') id: string, @Body() data: UpdateTierDto) {
        const tier = await this.walletService.updateTier(id, data);
        return ResponseBuilder.success(tier, 'Tier updated', 'تم تحديث المستوى');
    }

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Delete('admin/tiers/:id')
    @HttpCode(HttpStatus.OK)
    @ApiOperation({
        summary: 'Delete loyalty tier (admin)',
        description: 'Delete (deactivate) a loyalty tier. Admin only.',
    })
    @ApiParam({ name: 'id', description: 'Tier ID' })
    @ApiResponse({ status: 200, description: 'Tier deleted successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async deleteTier(@Param('id') id: string) {
        await this.walletService.deleteTier(id);
        return ResponseBuilder.success(null, 'Tier deleted', 'تم حذف المستوى');
    }
}
