import {
  BadRequestException,
  Controller,
  DefaultValuePipe,
  Get,
  Param,
  ParseFloatPipe,
  ParseIntPipe,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiParam,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Throttle, ThrottlerGuard } from '@nestjs/throttler';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import {
  ApiAuthErrorResponses,
  ApiPublicErrorResponses,
} from '@common/decorators/api-error-responses.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { Public } from '@decorators/public.decorator';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { GoogleMapsService } from './google-maps.service';
import { LocationsService } from './locations.service';
import { ShippingService } from './shipping.service';

@ApiTags('Locations')
@Controller('locations')
export class LocationsController {
  constructor(
    private readonly locationsService: LocationsService,
    private readonly shippingService: ShippingService,
    private readonly googleMapsService: GoogleMapsService,
  ) {}

  @Public()
  @Get('countries')
  @ApiOperation({
    summary: 'Get all countries',
    description: 'Retrieve all countries. Public endpoint.',
  })
  @ApiResponse({
    status: 200,
    description: 'Countries retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getCountries() {
    const countries = await this.locationsService.findAllCountries();

    return ResponseBuilder.success(
      countries,
      'Countries retrieved successfully',
      'تم استرجاع الدول بنجاح',
    );
  }

  @Public()
  @Get('cities')
  @ApiOperation({
    summary: 'Get all cities',
    description:
      'Retrieve all cities with optional country filter. Public endpoint.',
  })
  @ApiQuery({
    name: 'countryId',
    required: false,
    type: String,
    description: 'Filter by country ID',
  })
  @ApiResponse({
    status: 200,
    description: 'Cities retrieved successfully',
    type: ApiResponseDto,
  })
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
  @ApiParam({
    name: 'id',
    description: 'City ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'City retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getCityById(@Param('id') id: string) {
    const city = await this.locationsService.findCityById(id);

    return ResponseBuilder.success(
      city,
      'City retrieved successfully',
      'تم استرجاع المدينة بنجاح',
    );
  }

  @Public()
  @Get('cities/:cityId/markets')
  @ApiOperation({
    summary: 'Get markets by city',
    description: 'Retrieve all markets in a specific city. Public endpoint.',
  })
  @ApiParam({
    name: 'cityId',
    description: 'City ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Markets retrieved successfully',
    type: ApiResponseDto,
  })
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
    description:
      'Retrieve detailed information about a market. Public endpoint.',
  })
  @ApiParam({
    name: 'id',
    description: 'Market ID',
    example: '507f1f77bcf86cd799439011',
  })
  @ApiResponse({
    status: 200,
    description: 'Market retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getMarketById(@Param('id') id: string) {
    const market = await this.locationsService.findMarketById(id);

    return ResponseBuilder.success(
      market,
      'Market retrieved successfully',
      'تم استرجاع السوق بنجاح',
    );
  }

  @Public()
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 30, ttl: 60000 } })
  @Get('geocode/reverse')
  @ApiOperation({
    summary: 'Reverse geocode coordinates',
    description:
      'Resolve a human-readable address from latitude and longitude using the server-side Google Maps integration. Public endpoint.',
  })
  @ApiQuery({
    name: 'lat',
    required: true,
    type: Number,
    description: 'Latitude',
  })
  @ApiQuery({
    name: 'lng',
    required: true,
    type: Number,
    description: 'Longitude',
  })
  @ApiQuery({
    name: 'language',
    required: false,
    type: String,
    description: 'Language code',
    example: 'ar',
  })
  @ApiResponse({
    status: 200,
    description: 'Address resolved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async reverseGeocode(
    @Query('lat', ParseFloatPipe) latitude: number,
    @Query('lng', ParseFloatPipe) longitude: number,
    @Query('language') language = 'ar',
  ) {
    const result = await this.googleMapsService.reverseGeocode({
      latitude,
      longitude,
      language,
    });

    return ResponseBuilder.success(
      result,
      'Address resolved successfully',
      'تم تحديد العنوان بنجاح',
    );
  }

  @Public()
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 20, ttl: 60000 } })
  @Get('geocode/forward')
  @ApiOperation({
    summary: 'Forward geocode an address',
    description:
      'Search for coordinates and address matches using the server-side Google Maps integration. Public endpoint.',
  })
  @ApiQuery({
    name: 'address',
    required: true,
    type: String,
    description: 'Address or search text',
  })
  @ApiQuery({
    name: 'language',
    required: false,
    type: String,
    description: 'Language code',
    example: 'ar',
  })
  @ApiResponse({
    status: 200,
    description: 'Address search completed successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async forwardGeocode(
    @Query('address') address: string,
    @Query('language') language = 'ar',
  ) {
    const results = await this.googleMapsService.forwardGeocode({
      address,
      language,
    });

    return ResponseBuilder.success(
      results,
      'Address search completed successfully',
      'تم البحث عن العنوان بنجاح',
    );
  }

  @Public()
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 20, ttl: 60000 } })
  @Get('places/autocomplete')
  @ApiOperation({
    summary: 'Autocomplete place search',
    description:
      'Search for place suggestions using the server-side Google Maps integration. Public endpoint.',
  })
  @ApiQuery({
    name: 'input',
    required: true,
    type: String,
    description: 'Search text',
  })
  @ApiQuery({
    name: 'language',
    required: false,
    type: String,
    description: 'Language code',
    example: 'ar',
  })
  @ApiQuery({
    name: 'lat',
    required: false,
    type: Number,
    description: 'Latitude for location bias',
  })
  @ApiQuery({
    name: 'lng',
    required: false,
    type: Number,
    description: 'Longitude for location bias',
  })
  @ApiQuery({
    name: 'radius',
    required: false,
    type: Number,
    description: 'Search radius in meters',
    example: 50000,
  })
  @ApiResponse({
    status: 200,
    description: 'Place suggestions retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async autocompletePlaces(
    @Query('input') input: string,
    @Query('language') language = 'ar',
    @Query('lat') latitude?: string,
    @Query('lng') longitude?: string,
    @Query('radius', new DefaultValuePipe(50000), ParseIntPipe) radius = 50000,
  ) {
    const location = this.parseOptionalLocation(latitude, longitude);
    const results = await this.googleMapsService.placesAutocomplete({
      input,
      language,
      radius,
      latitude: location?.latitude,
      longitude: location?.longitude,
    });

    return ResponseBuilder.success(
      results,
      'Place suggestions retrieved successfully',
      'تم استرجاع اقتراحات الأماكن بنجاح',
    );
  }

  @Public()
  @UseGuards(ThrottlerGuard)
  @Throttle({ default: { limit: 20, ttl: 60000 } })
  @Get('places/:placeId')
  @ApiOperation({
    summary: 'Get place details',
    description:
      'Retrieve place details using the server-side Google Maps integration. Public endpoint.',
  })
  @ApiParam({ name: 'placeId', description: 'Google place ID' })
  @ApiQuery({
    name: 'language',
    required: false,
    type: String,
    description: 'Language code',
    example: 'ar',
  })
  @ApiResponse({
    status: 200,
    description: 'Place details retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiPublicErrorResponses()
  async getPlaceDetails(
    @Param('placeId') placeId: string,
    @Query('language') language = 'ar',
  ) {
    const result = await this.googleMapsService.placeDetails({
      placeId,
      language,
    });

    return ResponseBuilder.success(
      result,
      'Place details retrieved successfully',
      'تم استرجاع تفاصيل المكان بنجاح',
    );
  }

  @UseGuards(JwtAuthGuard)
  @Get('shipping-zones')
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get all shipping zones',
    description: 'Retrieve all shipping zones and their rates.',
  })
  @ApiResponse({
    status: 200,
    description: 'Shipping zones retrieved successfully',
    type: ApiResponseDto,
  })
  @ApiAuthErrorResponses()
  async getShippingZones() {
    const zones = await this.locationsService.findAllShippingZones();

    return ResponseBuilder.success(
      zones,
      'Shipping zones retrieved successfully',
      'تم استرجاع مناطق الشحن بنجاح',
    );
  }

  @Public()
  @Get('shipping/calculate')
  @ApiOperation({
    summary: 'Calculate shipping cost',
    description:
      'Calculate shipping cost for an order based on city and order details. Public endpoint.',
  })
  @ApiQuery({
    name: 'cityId',
    required: true,
    type: String,
    description: 'City ID',
  })
  @ApiQuery({
    name: 'orderAmount',
    required: true,
    type: Number,
    description: 'Order amount',
  })
  @ApiQuery({
    name: 'weight',
    required: false,
    type: Number,
    description: 'Order weight in kg',
  })
  @ApiResponse({
    status: 200,
    description: 'Shipping cost calculated successfully',
    type: ApiResponseDto,
  })
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

  private parseOptionalLocation(latitude?: string, longitude?: string) {
    if (
      (latitude == null || latitude === '') &&
      (longitude == null || longitude === '')
    ) {
      return null;
    }

    if (
      latitude == null ||
      latitude === '' ||
      longitude == null ||
      longitude === ''
    ) {
      throw new BadRequestException(
        'Both lat and lng are required when using location bias',
      );
    }

    const parsedLatitude = Number(latitude);
    const parsedLongitude = Number(longitude);

    if (Number.isNaN(parsedLatitude) || Number.isNaN(parsedLongitude)) {
      throw new BadRequestException('lat and lng must be valid numbers');
    }

    return {
      latitude: parsedLatitude,
      longitude: parsedLongitude,
    };
  }
}
