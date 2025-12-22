import {
    Controller,
    Get,
    Post,
    Body,
    Query,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { WalletService } from './wallet.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { Public } from '@decorators/public.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';

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
    @ApiOperation({ summary: 'Get my wallet balance' })
    async getBalance(@CurrentUser() user: any) {
        const balance = await this.walletService.getBalance(user.customerId);
        return ResponseBuilder.success({ balance }, 'Balance retrieved', 'تم استرجاع الرصيد');
    }

    @Get('transactions')
    @ApiOperation({ summary: 'Get my wallet transactions' })
    async getTransactions(@CurrentUser() user: any, @Query() query: any) {
        const transactions = await this.walletService.getWalletTransactions(user.customerId, query);
        return ResponseBuilder.success(transactions, 'Transactions retrieved', 'تم استرجاع المعاملات');
    }

    // ═════════════════════════════════════
    // Loyalty
    // ═════════════════════════════════════

    @Get('points')
    @ApiOperation({ summary: 'Get my loyalty points' })
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
    @ApiOperation({ summary: 'Get my loyalty transactions' })
    async getLoyaltyTransactions(@CurrentUser() user: any) {
        const transactions = await this.walletService.getLoyaltyTransactions(user.customerId);
        return ResponseBuilder.success(transactions, 'Transactions retrieved', 'تم استرجاع المعاملات');
    }

    @Public()
    @Get('tiers')
    @ApiOperation({ summary: 'Get loyalty tiers' })
    async getTiers() {
        const tiers = await this.walletService.getTiers();
        return ResponseBuilder.success(tiers, 'Tiers retrieved', 'تم استرجاع المستويات');
    }

    // ═════════════════════════════════════
    // Admin Operations
    // ═════════════════════════════════════

    @UseGuards(RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('credit')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Credit customer wallet (admin)' })
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
    @ApiOperation({ summary: 'Debit customer wallet (admin)' })
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
    @ApiOperation({ summary: 'Grant loyalty points (admin)' })
    async grantPoints(@Body() data: any, @CurrentUser() user: any) {
        const transaction = await this.walletService.earnPoints({
            ...data,
            transactionType: 'admin_grant',
            createdBy: user._id,
        });
        return ResponseBuilder.created(transaction, 'Points granted', 'تم إضافة النقاط');
    }
}
