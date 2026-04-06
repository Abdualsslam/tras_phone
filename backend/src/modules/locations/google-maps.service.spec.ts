import { ServiceUnavailableException } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { GoogleMapsService } from './google-maps.service';

describe('GoogleMapsService', () => {
  let service: GoogleMapsService;
  let configService: { get: jest.Mock };
  let fetchMock: jest.Mock;

  beforeEach(async () => {
    fetchMock = jest.fn();
    global.fetch = fetchMock as typeof fetch;

    configService = {
      get: jest.fn((key: string) => {
        if (key === 'GOOGLE_MAPS_SERVER_API_KEY') {
          return 'server-key';
        }

        return undefined;
      }),
    };

    const moduleRef = await Test.createTestingModule({
      providers: [
        GoogleMapsService,
        {
          provide: ConfigService,
          useValue: configService,
        },
      ],
    }).compile();

    service = moduleRef.get(GoogleMapsService);
  });

  afterEach(() => {
    jest.resetAllMocks();
  });

  it('uses the server-side key and returns the first reverse geocode result', async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({
        status: 'OK',
        results: [
          {
            formatted_address: 'Riyadh',
            geometry: { location: { lat: 24.7136, lng: 46.6753 } },
            place_id: 'place-1',
            address_components: [],
          },
        ],
      }),
    });

    const result = await service.reverseGeocode({
      latitude: 24.7136,
      longitude: 46.6753,
      language: 'ar',
    });

    expect(result).toMatchObject({
      formatted_address: 'Riyadh',
      place_id: 'place-1',
    });
    expect(fetchMock).toHaveBeenCalledTimes(1);
    expect(fetchMock.mock.calls[0][0]).toContain('key=server-key');
    expect(fetchMock.mock.calls[0][0]).toContain('latlng=24.7136%2C46.6753');
  });

  it('returns an empty list when autocomplete has zero results', async () => {
    fetchMock.mockResolvedValue({
      ok: true,
      json: async () => ({
        status: 'ZERO_RESULTS',
      }),
    });

    const result = await service.placesAutocomplete({
      input: 'unknown',
      language: 'ar',
    });

    expect(result).toEqual([]);
  });

  it('throws when the server-side key is missing', async () => {
    configService.get.mockReturnValue(undefined);

    await expect(
      service.forwardGeocode({
        address: 'Riyadh',
      }),
    ).rejects.toBeInstanceOf(ServiceUnavailableException);
  });
});
