import {
  BadGatewayException,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

interface GoogleMapsApiResponse<T> {
  status: string;
  error_message?: string;
  predictions?: T[];
  results?: T[];
  result?: T;
}

interface ReverseGeocodeParams {
  latitude: number;
  longitude: number;
  language?: string;
}

interface ForwardGeocodeParams {
  address: string;
  language?: string;
}

interface PlacesAutocompleteParams {
  input: string;
  language?: string;
  latitude?: number;
  longitude?: number;
  radius?: number;
}

interface PlaceDetailsParams {
  placeId: string;
  language?: string;
}

@Injectable()
export class GoogleMapsService {
  private readonly logger = new Logger(GoogleMapsService.name);
  private readonly baseUrl = 'https://maps.googleapis.com/maps/api';

  constructor(private readonly configService: ConfigService) {}

  async reverseGeocode({
    latitude,
    longitude,
    language = 'ar',
  }: ReverseGeocodeParams): Promise<Record<string, unknown> | null> {
    const payload = await this.requestGoogleMaps<Record<string, unknown>>(
      'geocode/json',
      {
        latlng: `${latitude},${longitude}`,
        language,
      },
    );

    return payload.results?.[0] ?? null;
  }

  async forwardGeocode({
    address,
    language = 'ar',
  }: ForwardGeocodeParams): Promise<Record<string, unknown>[]> {
    const payload = await this.requestGoogleMaps<Record<string, unknown>>(
      'geocode/json',
      {
        address,
        language,
      },
    );

    return payload.results ?? [];
  }

  async placesAutocomplete({
    input,
    language = 'ar',
    latitude,
    longitude,
    radius = 50000,
  }: PlacesAutocompleteParams): Promise<Record<string, unknown>[]> {
    const query: Record<string, string> = {
      input,
      language,
    };

    if (latitude != null && longitude != null) {
      query.location = `${latitude},${longitude}`;
      query.radius = String(radius);
    }

    const payload = await this.requestGoogleMaps<Record<string, unknown>>(
      'place/autocomplete/json',
      query,
    );

    return payload.predictions ?? [];
  }

  async placeDetails({
    placeId,
    language = 'ar',
  }: PlaceDetailsParams): Promise<Record<string, unknown> | null> {
    const payload = await this.requestGoogleMaps<Record<string, unknown>>(
      'place/details/json',
      {
        place_id: placeId,
        language,
      },
    );

    return payload.result ?? null;
  }

  private async requestGoogleMaps<T>(
    path: string,
    query: Record<string, string>,
  ): Promise<GoogleMapsApiResponse<T>> {
    const apiKey = this.getApiKey();
    const params = new URLSearchParams({ ...query, key: apiKey });
    const url = `${this.baseUrl}/${path}?${params.toString()}`;

    let response: Response;

    try {
      response = await fetch(url, {
        method: 'GET',
        headers: {
          Accept: 'application/json',
        },
      });
    } catch (error) {
      this.logger.error(
        `Google Maps network request failed for ${path}`,
        error,
      );
      throw new BadGatewayException('Google Maps request failed');
    }

    let payload: GoogleMapsApiResponse<T>;

    try {
      payload = (await response.json()) as GoogleMapsApiResponse<T>;
    } catch (error) {
      this.logger.error(`Google Maps returned invalid JSON for ${path}`, error);
      throw new BadGatewayException('Invalid response from Google Maps');
    }

    if (!response.ok) {
      this.logger.warn(
        `Google Maps HTTP error for ${path}: ${response.status} ${payload.status}`,
      );
      throw new BadGatewayException('Google Maps request failed');
    }

    if (payload.status === 'OK' || payload.status === 'ZERO_RESULTS') {
      return payload;
    }

    this.logger.warn(
      `Google Maps API error for ${path}: ${payload.status} ${payload.error_message ?? ''}`.trim(),
    );
    throw new BadGatewayException(
      `Google Maps request failed with status ${payload.status}`,
    );
  }

  private getApiKey(): string {
    const apiKey =
      this.configService.get<string>('GOOGLE_MAPS_SERVER_API_KEY') ||
      this.configService.get<string>('GOOGLE_MAPS_API_KEY');

    if (!apiKey) {
      throw new ServiceUnavailableException(
        'Google Maps server integration is not configured',
      );
    }

    return apiKey;
  }
}
