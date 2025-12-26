import {
    Controller,
    Get,
    Post,
    Put,
    Delete,
    Body,
    Param,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PromotionsService } from './promotions.service';
import { CouponsService } from './coupons.service';
import { Public } from '@decorators/public.decorator';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { CurrentUser } from '@decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🎁 Promotions Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Promotions & Coupons')
@Controller('promotions')
export class PromotionsController {
    constructor(
        private readonly promotionsService: PromotionsService,
        private readonly couponsService: CouponsService,
    ) { }

    // ═════════════════════════════════════
    // Promotions - Public
    // ═════════════════════════════════════

    @Public()
    @Get('active')
    @ApiOperation({ summary: 'Get active promotions' })
    async getActivePromotions() {
        const promotions = await this.promotionsService.findActive();
        return ResponseBuilder.success(promotions, 'Promotions retrieved', 'تم استرجاع العروض');
    }

    // ═════════════════════════════════════
    // Promotions - Admin
    // ═════════════════════════════════════

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get()
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Get all promotions (admin)' })
    async getAllPromotions() {
        const promotions = await this.promotionsService.findActive();
        return ResponseBuilder.success(promotions, 'Promotions retrieved', 'تم استرجاع العروض');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get(':id')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Get promotion by ID' })
    async getPromotionById(@Param('id') id: string) {
        const promotion = await this.promotionsService.findById(id);
        return ResponseBuilder.success(promotion, 'Promotion retrieved', 'تم استرجاع العرض');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post()
    @ApiBearerAuth('JWT-auth')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create promotion' })
    async createPromotion(@Body() data: any) {
        const promotion = await this.promotionsService.create(data);
        return ResponseBuilder.created(promotion, 'Promotion created', 'تم إنشاء العرض');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put(':id')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Update promotion' })
    async updatePromotion(@Param('id') id: string, @Body() data: any) {
        const promotion = await this.promotionsService.update(id, data);
        return ResponseBuilder.success(promotion, 'Promotion updated', 'تم تحديث العرض');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.SUPER_ADMIN)
    @Delete(':id')
    @ApiBearerAuth('JWT-auth')
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({ summary: 'Delete promotion' })
    async deletePromotion(@Param('id') id: string) {
        await this.promotionsService.delete(id);
        return ResponseBuilder.success(null, 'Promotion deleted', 'تم حذف العرض');
    }

    // ═════════════════════════════════════
    // Coupons - Public
    // ═════════════════════════════════════

    @Public()
    @Get('coupons/public')
    @ApiOperation({ summary: 'Get public coupons' })
    async getPublicCoupons() {
        const coupons = await this.couponsService.findPublic();
        return ResponseBuilder.success(coupons, 'Coupons retrieved', 'تم استرجاع الكوبونات');
    }

    @UseGuards(JwtAuthGuard)
    @Post('coupons/validate')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Validate coupon code' })
    async validateCoupon(
        @CurrentUser() user: any,
        @Body() data: { code: string; orderAmount: number },
    ) {
        const result = await this.couponsService.validate(
            data.code,
            user.customerId,
            data.orderAmount,
            false, // TODO: Check if first order
        );
        return ResponseBuilder.success(
            { coupon: result.coupon, discountAmount: result.discountAmount },
            'Coupon is valid',
            'الكوبون صحيح',
        );
    }

    // ═════════════════════════════════════
    // Coupons - Admin
    // ═════════════════════════════════════

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('coupons')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Get all coupons (admin)' })
    async getAllCoupons() {
        const coupons = await this.couponsService.findAll();
        return ResponseBuilder.success(coupons, 'Coupons retrieved', 'تم استرجاع الكوبونات');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Post('coupons')
    @ApiBearerAuth('JWT-auth')
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({ summary: 'Create coupon' })
    async createCoupon(@Body() data: any) {
        const coupon = await this.couponsService.create(data);
        return ResponseBuilder.created(coupon, 'Coupon created', 'تم إنشاء الكوبون');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Put('coupons/:id')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Update coupon' })
    async updateCoupon(@Param('id') id: string, @Body() data: any) {
        const coupon = await this.couponsService.update(id, data);
        return ResponseBuilder.success(coupon, 'Coupon updated', 'تم تحديث الكوبون');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.SUPER_ADMIN)
    @Delete('coupons/:id')
    @ApiBearerAuth('JWT-auth')
    @HttpCode(HttpStatus.NO_CONTENT)
    @ApiOperation({ summary: 'Delete coupon' })
    async deleteCoupon(@Param('id') id: string) {
        await this.couponsService.delete(id);
        return ResponseBuilder.success(null, 'Coupon deleted', 'تم حذف الكوبون');
    }

    @UseGuards(JwtAuthGuard, RolesGuard)
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @Get('coupons/:id/statistics')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Get coupon usage statistics' })
    async getCouponStats(@Param('id') id: string) {
        const stats = await this.couponsService.getStatistics(id);
        return ResponseBuilder.success(stats, 'Statistics retrieved', 'تم استرجاع الإحصائيات');
    }
}
