import {
    Controller,
    Get,
    Param,
    Query,
    UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { LocationsService } from './locations.service';
import { ShippingService } from './shipping.service';
import { Public } from '@decorators/public.decorator';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🌍 Locations Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Locations')
@Controller('locations')
export class LocationsController {
    constructor(
        private readonly locationsService: LocationsService,
        private readonly shippingService: ShippingService,
    ) { }

    // ═════════════════════════════════════
    // Countries (Public)
    // ═════════════════════════════════════

    @Public()
    @Get('countries')
    @ApiOperation({ summary: 'Get all countries' })
    async getCountries() {
        const countries = await this.locationsService.findAllCountries();

        return ResponseBuilder.success(
            countries,
            'Countries retrieved successfully',
            'تم استرجاع الدول بنجاح',
        );
    }

    // ═════════════════════════════════════
    // Cities (Public)
    // ═════════════════════════════════════

    @Public()
    @Get('cities')
    @ApiOperation({ summary: 'Get all cities' })
    async getCities(@Query('countryId') countryId?: string) {
        const cities = await this.locationsService.findAllCities(countryId);

        return ResponseBuilder.success(
            cities,
            'Cities retrieved successfully',
            'تم استرجاع المدن بنجاح',
        );
    }

    @Public()
    @Get('cities/:id')
    @ApiOperation({ summary: 'Get city by ID' })
    async getCityById(@Param('id') id: string) {
        const city = await this.locationsService.findCityById(id);

        return ResponseBuilder.success(
            city,
            'City retrieved successfully',
            'تم استرجاع المدينة بنجاح',
        );
    }

    // ═════════════════════════════════════
    // Markets (Public)
    // ═════════════════════════════════════

    @Public()
    @Get('cities/:cityId/markets')
    @ApiOperation({ summary: 'Get markets by city' })
    async getMarketsByCity(@Param('cityId') cityId: string) {
        const markets = await this.locationsService.findMarketsByCity(cityId);

        return ResponseBuilder.success(
            markets,
            'Markets retrieved successfully',
            'تم استرجاع الأسواق بنجاح',
        );
    }

    @Public()
    @Get('markets/:id')
    @ApiOperation({ summary: 'Get market by ID' })
    async getMarketById(@Param('id') id: string) {
        const market = await this.locationsService.findMarketById(id);

        return ResponseBuilder.success(
            market,
            'Market retrieved successfully',
            'تم استرجاع السوق بنجاح',
        );
    }

    // ═════════════════════════════════════
    // Shipping Zones (Protected)
    // ═════════════════════════════════════

    @UseGuards(JwtAuthGuard)
    @Get('shipping-zones')
    @ApiBearerAuth('JWT-auth')
    @ApiOperation({ summary: 'Get all shipping zones' })
    async getShippingZones() {
        const zones = await this.locationsService.findAllShippingZones();

        return ResponseBuilder.success(
            zones,
            'Shipping zones retrieved successfully',
            'تم استرجاع مناطق الشحن بنجاح',
        );
    }

    // ═════════════════════════════════════
    // Shipping Cost Calculation
    // ═════════════════════════════════════

    @Public()
    @Get('shipping/calculate')
    @ApiOperation({ summary: 'Calculate shipping cost' })
    async calculateShipping(
        @Query('cityId') cityId: string,
        @Query('orderAmount') orderAmount: number,
        @Query('weight') weight?: number,
    ) {
        const result = await this.shippingService.calculateShippingCost(
            cityId,
            orderAmount,
            weight || 1,
        );

        return ResponseBuilder.success(
            result,
            'Shipping cost calculated successfully',
            'تم حساب تكلفة الشحن بنجاح',
        );
    }
}
