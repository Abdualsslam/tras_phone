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
import { PermissionsGuard } from '@guards/permissions.guard';
import { Roles } from '@decorators/roles.decorator';
import { RequirePermissions } from '@decorators/permissions.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { Public } from '@decorators/public.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { PERMISSIONS } from '@modules/admins/constants/permissions.constant';
import { CreateTierDto } from './dto/create-tier.dto';
import { UpdateTierDto } from './dto/update-tier.dto';
import { AdminCreditWalletDto } from './dto/admin-credit-wallet.dto';
import { AdminDebitWalletDto } from './dto/admin-debit-wallet.dto';
import { AdminGrantPointsDto } from './dto/admin-grant-points.dto';

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

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.WALLET.VIEW)
    @Get('balance/:customerId')
    @ApiOperation({
        summary: 'Get customer wallet balance (admin)',
        description: 'Retrieve wallet and loyalty summary for a specific customer. Admin only.',
    })
    @ApiParam({ name: 'customerId', description: 'Customer ID' })
    @ApiResponse({ status: 200, description: 'Wallet balance retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getCustomerBalance(@Param('customerId') customerId: string) {
        const data = await this.walletService.getAdminCustomerBalance(customerId);
        return ResponseBuilder.success(data, 'Balance retrieved', 'تم استرجاع الرصيد');
    }

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.WALLET.VIEW_TRANSACTIONS)
    @Get('transactions/:customerId')
    @ApiOperation({
        summary: 'Get customer wallet transactions (admin)',
        description: 'Retrieve wallet transactions for a specific customer. Admin only.',
    })
    @ApiParam({ name: 'customerId', description: 'Customer ID' })
    @ApiResponse({ status: 200, description: 'Wallet transactions retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getCustomerTransactions(@Param('customerId') customerId: string, @Query() query: any) {
        const data = await this.walletService.getAdminCustomerTransactions(customerId, query);
        return ResponseBuilder.success(data, 'Transactions retrieved', 'تم استرجاع المعاملات');
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

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.LOYALTY.MANAGE_TIERS)
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

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.WALLET.ADD_CREDIT)
    @Post('credit')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Credit customer wallet (admin)',
        description: 'Add funds to a customer wallet. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Wallet credited successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async creditWallet(@Body() data: AdminCreditWalletDto, @CurrentUser() user: any) {
        const createdBy = user.adminUserId || user.id;
        const transaction = await this.walletService.credit({
            customerId: data.customerId,
            amount: data.amount,
            transactionType: 'admin_credit',
            description: data.description,
            descriptionAr: data.description,
            referenceNumber: data.reference,
            createdBy,
        });
        return ResponseBuilder.created(transaction, 'Wallet credited', 'تم إضافة الرصيد');
    }

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.WALLET.DEDUCT)
    @Post('debit')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Debit customer wallet (admin)',
        description: 'Deduct funds from a customer wallet. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Wallet debited successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async debitWallet(@Body() data: AdminDebitWalletDto, @CurrentUser() user: any) {
        const createdBy = user.adminUserId || user.id;
        const transaction = await this.walletService.debit({
            customerId: data.customerId,
            amount: data.amount,
            transactionType: 'admin_debit',
            description: data.description,
            descriptionAr: data.description,
            referenceNumber: data.reference,
            createdBy,
        });
        return ResponseBuilder.created(transaction, 'Wallet debited', 'تم خصم الرصيد');
    }

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.LOYALTY.ADJUST_POINTS)
    @Post('points/grant')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Grant loyalty points (admin)',
        description: 'Manually grant loyalty points to a customer. Admin only.',
    })
    @ApiResponse({ status: 201, description: 'Points granted successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async grantPoints(@Body() data: AdminGrantPointsDto, @CurrentUser() user: any) {
        const createdBy = user.adminUserId || user.id;
        const transaction = await this.walletService.earnPoints({
            customerId: data.customerId,
            points: data.points,
            transactionType: 'admin_grant',
            description: data.reason,
            createdBy,
        });
        return ResponseBuilder.created(transaction, 'Points granted', 'تم إضافة النقاط');
    }

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.WALLET.VIEW_TRANSACTIONS)
    @Get('admin/transactions')
    @ApiOperation({
        summary: 'Get wallet transactions across customers (admin)',
        description: 'Retrieve wallet transactions across all customers with optional filters. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Wallet transactions retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getAdminTransactions(@Query() query: any) {
        const data = await this.walletService.getAdminTransactions(query);
        return ResponseBuilder.success(data, 'Transactions retrieved', 'تم استرجاع المعاملات');
    }

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.WALLET.VIEW)
    @Get('admin/stats')
    @ApiOperation({
        summary: 'Get wallet stats (admin)',
        description: 'Retrieve aggregate wallet statistics. Admin only.',
    })
    @ApiResponse({ status: 200, description: 'Wallet stats retrieved successfully', type: ApiResponseDto })
    @ApiCommonErrorResponses()
    async getAdminStats() {
        const data = await this.walletService.getWalletStats();
        return ResponseBuilder.success(data, 'Stats retrieved', 'تم استرجاع الإحصائيات');
    }

    // ═════════════════════════════════════
    // Admin: Loyalty Tiers Management
    // ═════════════════════════════════════

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.LOYALTY.MANAGE_TIERS)
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

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.LOYALTY.MANAGE_TIERS)
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

    @UseGuards(RolesGuard, PermissionsGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @RequirePermissions(PERMISSIONS.LOYALTY.MANAGE_TIERS)
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
