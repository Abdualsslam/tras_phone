import {
    Controller,
    Get,
    Param,
    Query,
    UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiCommonErrorResponses, ApiPublicErrorResponses, ApiAuthErrorResponses } from '@common/decorators/api-error-responses.decorator';
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
    @ApiOperation({
        summary: 'Get all countries',
        description: 'Retrieve all countries. Public endpoint.',
    })
    @ApiResponse({ status: 200, description: 'Countries retrieved successfully', type: ApiResponseDto })
    @ApiPublicErrorResponses()
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
    @ApiOperation({
        summary: 'Get all cities',
        description: 'Retrieve all cities with optional country filter. Public endpoint.',
    })
    @ApiQuery({ name: 'countryId', required: false, type: String, description: 'Filter by country ID' })
    @ApiResponse({ status: 200, description: 'Cities retrieved successfully', type: ApiResponseDto })
    @ApiPublicErrorResponses()
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
    @ApiOperation({
        summary: 'Get city by ID',
        description: 'Retrieve detailed information about a city. Public endpoint.',
    })
    @ApiParam({ name: 'id', description: 'City ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'City retrieved successfully', type: ApiResponseDto })
    @ApiPublicErrorResponses()
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
    @ApiOperation({
        summary: 'Get markets by city',
        description: 'Retrieve all markets in a specific city. Public endpoint.',
    })
    @ApiParam({ name: 'cityId', description: 'City ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Markets retrieved successfully', type: ApiResponseDto })
    @ApiPublicErrorResponses()
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
    @ApiOperation({
        summary: 'Get market by ID',
        description: 'Retrieve detailed information about a market. Public endpoint.',
    })
    @ApiParam({ name: 'id', description: 'Market ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'Market retrieved successfully', type: ApiResponseDto })
    @ApiPublicErrorResponses()
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
    @ApiOperation({
        summary: 'Get all shipping zones',
        description: 'Retrieve all shipping zones and their rates.',
    })
    @ApiResponse({ status: 200, description: 'Shipping zones retrieved successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
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
    @ApiOperation({
        summary: 'Calculate shipping cost',
        description: 'Calculate shipping cost for an order based on city and order details. Public endpoint.',
    })
    @ApiQuery({ name: 'cityId', required: true, type: String, description: 'City ID' })
    @ApiQuery({ name: 'orderAmount', required: true, type: Number, description: 'Order amount' })
    @ApiQuery({ name: 'weight', required: false, type: Number, description: 'Order weight in kg' })
    @ApiResponse({ status: 200, description: 'Shipping cost calculated successfully', type: ApiResponseDto })
    @ApiPublicErrorResponses()
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
