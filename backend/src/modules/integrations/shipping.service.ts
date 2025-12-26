import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface ShipmentRequest {
    orderId: string;
    senderName: string;
    senderPhone: string;
    senderAddress: {
        city: string;
        district?: string;
        street?: string;
        postalCode?: string;
    };
    recipientName: string;
    recipientPhone: string;
    recipientAddress: {
        city: string;
        district?: string;
        street?: string;
        postalCode?: string;
        buildingNumber?: string;
    };
    packageDetails: {
        weight: number; // kg
        pieces: number;
        description?: string;
        codAmount?: number; // Cash on delivery
    };
}

export interface ShipmentResult {
    success: boolean;
    trackingNumber?: string;
    awbNumber?: string;
    labelUrl?: string;
    estimatedDelivery?: Date;
    provider: string;
    error?: string;
    rawResponse?: any;
}

export interface TrackingResult {
    success: boolean;
    status: string;
    statusDescription?: string;
    lastUpdate?: Date;
    location?: string;
    isDelivered: boolean;
    events: Array<{
        date: Date;
        status: string;
        description: string;
        location?: string;
    }>;
    error?: string;
}

@Injectable()
export class ShippingService {
    private readonly logger = new Logger(ShippingService.name);
    private readonly provider: string;

    // SMSA config
    private readonly smsaPassKey: string;
    private readonly smsaAccountNumber: string;

    // Aramex config
    private readonly aramexAccountNumber: string;
    private readonly aramexAccountPin: string;
    private readonly aramexAccountEntity: string;
    private readonly aramexUsername: string;
    private readonly aramexPassword: string;

    constructor(private readonly configService: ConfigService) {
        this.provider = this.configService.get('SHIPPING_PROVIDER', 'smsa');

        // SMSA
        this.smsaPassKey = this.configService.get('SMSA_PASS_KEY', '');
        this.smsaAccountNumber = this.configService.get('SMSA_ACCOUNT_NUMBER', '');

        // Aramex
        this.aramexAccountNumber = this.configService.get('ARAMEX_ACCOUNT_NUMBER', '');
        this.aramexAccountPin = this.configService.get('ARAMEX_ACCOUNT_PIN', '');
        this.aramexAccountEntity = this.configService.get('ARAMEX_ACCOUNT_ENTITY', '');
        this.aramexUsername = this.configService.get('ARAMEX_USERNAME', '');
        this.aramexPassword = this.configService.get('ARAMEX_PASSWORD', '');
    }

    async createShipment(request: ShipmentRequest): Promise<ShipmentResult> {
        this.logger.log(`Creating shipment for order ${request.orderId} via ${this.provider}`);

        try {
            switch (this.provider) {
                case 'smsa':
                    return await this.createSMSAShipment(request);
                case 'aramex':
                    return await this.createAramexShipment(request);
                default:
                    return this.createMockShipment(request);
            }
        } catch (error) {
            this.logger.error(`Shipment creation failed: ${error.message}`, error.stack);
            return {
                success: false,
                provider: this.provider,
                error: error.message,
            };
        }
    }

    async trackShipment(trackingNumber: string): Promise<TrackingResult> {
        this.logger.log(`Tracking shipment ${trackingNumber} via ${this.provider}`);

        try {
            switch (this.provider) {
                case 'smsa':
                    return await this.trackSMSA(trackingNumber);
                case 'aramex':
                    return await this.trackAramex(trackingNumber);
                default:
                    return this.getMockTracking(trackingNumber);
            }
        } catch (error) {
            this.logger.error(`Tracking failed: ${error.message}`, error.stack);
            return {
                success: false,
                status: 'error',
                isDelivered: false,
                events: [],
                error: error.message,
            };
        }
    }

    async cancelShipment(trackingNumber: string): Promise<{ success: boolean; error?: string }> {
        this.logger.log(`Cancelling shipment ${trackingNumber}`);

        try {
            switch (this.provider) {
                case 'smsa':
                    return await this.cancelSMSA(trackingNumber);
                default:
                    return { success: true };
            }
        } catch (error) {
            return { success: false, error: error.message };
        }
    }

    async getShippingRates(fromCity: string, toCity: string, weight: number): Promise<any[]> {
        // Return available shipping options with rates
        return [
            {
                provider: 'smsa',
                service: 'express',
                name: 'SMSA Express',
                nameAr: 'سمسا السريع',
                cost: weight <= 1 ? 25 : 25 + (weight - 1) * 5,
                estimatedDays: 1,
                currency: 'SAR',
            },
            {
                provider: 'smsa',
                service: 'standard',
                name: 'SMSA Standard',
                nameAr: 'سمسا العادي',
                cost: weight <= 1 ? 18 : 18 + (weight - 1) * 3,
                estimatedDays: 3,
                currency: 'SAR',
            },
            {
                provider: 'aramex',
                service: 'express',
                name: 'Aramex Express',
                nameAr: 'أرامكس السريع',
                cost: weight <= 1 ? 28 : 28 + (weight - 1) * 6,
                estimatedDays: 1,
                currency: 'SAR',
            },
        ];
    }

    // ==================== SMSA Integration ====================

    private async createSMSAShipment(request: ShipmentRequest): Promise<ShipmentResult> {
        const soapBody = `
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
        <soapenv:Body>
          <tem:addShipment>
            <tem:passKey>${this.smsaPassKey}</tem:passKey>
            <tem:refNo>${request.orderId}</tem:refNo>
            <tem:sentDate>${new Date().toISOString()}</tem:sentDate>
            <tem:idNo></tem:idNo>
            <tem:cName>${request.recipientName}</tem:cName>
            <tem:cntry>SA</tem:cntry>
            <tem:cCity>${request.recipientAddress.city}</tem:cCity>
            <tem:cZip>${request.recipientAddress.postalCode || ''}</tem:cZip>
            <tem:cPOBox></tem:cPOBox>
            <tem:cMobile>${request.recipientPhone}</tem:cMobile>
            <tem:cTel1></tem:cTel1>
            <tem:cAddr1>${request.recipientAddress.street || ''}</tem:cAddr1>
            <tem:cAddr2>${request.recipientAddress.district || ''}</tem:cAddr2>
            <tem:shipType>DLV</tem:shipType>
            <tem:PCs>${request.packageDetails.pieces}</tem:PCs>
            <tem:cEmail></tem:cEmail>
            <tem:carrValue>${request.packageDetails.codAmount || 0}</tem:carrValue>
            <tem:carrCurr>SAR</tem:carrCurr>
            <tem:codAmt>${request.packageDetails.codAmount || 0}</tem:codAmt>
            <tem:weight>${request.packageDetails.weight}</tem:weight>
            <tem:custVal>0</tem:custVal>
            <tem:custCurr>SAR</tem:custCurr>
            <tem:insrAmt>0</tem:insrAmt>
            <tem:insrCurr>SAR</tem:insrCurr>
            <tem:itemDesc>${request.packageDetails.description || 'Products'}</tem:itemDesc>
          </tem:addShipment>
        </soapenv:Body>
      </soapenv:Envelope>
    `;

        const response = await fetch('https://track.smsaexpress.com/SEABORNEAPI/Service.asmx', {
            method: 'POST',
            headers: {
                'Content-Type': 'text/xml; charset=utf-8',
                'SOAPAction': 'http://tempuri.org/addShipment',
            },
            body: soapBody,
        });

        const text = await response.text();

        // Parse SOAP response
        const awbMatch = text.match(/<addShipmentResult>(.*?)<\/addShipmentResult>/);
        const awbNumber = awbMatch ? awbMatch[1] : null;

        if (awbNumber && !awbNumber.includes('Failed')) {
            return {
                success: true,
                trackingNumber: awbNumber,
                awbNumber,
                provider: 'smsa',
                rawResponse: text,
            };
        }

        return {
            success: false,
            provider: 'smsa',
            error: awbNumber || 'Shipment creation failed',
            rawResponse: text,
        };
    }

    private async trackSMSA(trackingNumber: string): Promise<TrackingResult> {
        const soapBody = `
      <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">
        <soapenv:Body>
          <tem:getTracking>
            <tem:awbNo>${trackingNumber}</tem:awbNo>
            <tem:passKey>${this.smsaPassKey}</tem:passKey>
          </tem:getTracking>
        </soapenv:Body>
      </soapenv:Envelope>
    `;

        const response = await fetch('https://track.smsaexpress.com/SEABORNEAPI/Service.asmx', {
            method: 'POST',
            headers: {
                'Content-Type': 'text/xml; charset=utf-8',
                'SOAPAction': 'http://tempuri.org/getTracking',
            },
            body: soapBody,
        });

        const text = await response.text();

        // Parse tracking events from SOAP response
        // This is simplified - actual implementation would parse XML properly
        return {
            success: true,
            status: 'in_transit',
            isDelivered: text.includes('Delivered'),
            events: [{
                date: new Date(),
                status: 'in_transit',
                description: 'Shipment in transit',
            }],
        };
    }

    private async cancelSMSA(trackingNumber: string): Promise<{ success: boolean; error?: string }> {
        // SMSA cancel shipment API
        return { success: true };
    }

    // ==================== Aramex Integration ====================

    private async createAramexShipment(request: ShipmentRequest): Promise<ShipmentResult> {
        const body = {
            ClientInfo: {
                UserName: this.aramexUsername,
                Password: this.aramexPassword,
                Version: 'v1',
                AccountNumber: this.aramexAccountNumber,
                AccountPin: this.aramexAccountPin,
                AccountEntity: this.aramexAccountEntity,
                AccountCountryCode: 'SA',
            },
            Shipments: [{
                Shipper: {
                    Reference1: request.orderId,
                    AccountNumber: this.aramexAccountNumber,
                    PartyAddress: {
                        Line1: request.senderAddress.street || 'Main Office',
                        City: request.senderAddress.city,
                        CountryCode: 'SA',
                    },
                    Contact: {
                        PersonName: request.senderName,
                        PhoneNumber1: request.senderPhone,
                    },
                },
                Consignee: {
                    Reference1: request.orderId,
                    PartyAddress: {
                        Line1: request.recipientAddress.street || '',
                        Line2: request.recipientAddress.district || '',
                        City: request.recipientAddress.city,
                        CountryCode: 'SA',
                        PostCode: request.recipientAddress.postalCode || '',
                    },
                    Contact: {
                        PersonName: request.recipientName,
                        PhoneNumber1: request.recipientPhone,
                    },
                },
                Details: {
                    Dimensions: { Length: 10, Width: 10, Height: 10, Unit: 'CM' },
                    ActualWeight: { Unit: 'KG', Value: request.packageDetails.weight },
                    NumberOfPieces: request.packageDetails.pieces,
                    ProductGroup: 'DOM',
                    ProductType: 'ONP',
                    PaymentType: request.packageDetails.codAmount ? 'C' : 'P',
                    CashOnDeliveryAmount: request.packageDetails.codAmount
                        ? { CurrencyCode: 'SAR', Value: request.packageDetails.codAmount }
                        : undefined,
                },
            }],
        };

        const response = await fetch('https://ws.aramex.net/ShippingAPI.V2/Shipping/Service_1_0.svc/json/CreateShipments', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body),
        });

        const data = await response.json();

        if (data.Shipments?.[0]?.ID) {
            return {
                success: true,
                trackingNumber: data.Shipments[0].ID,
                awbNumber: data.Shipments[0].ID,
                labelUrl: data.Shipments[0].ShipmentLabel?.LabelURL,
                provider: 'aramex',
                rawResponse: data,
            };
        }

        return {
            success: false,
            provider: 'aramex',
            error: data.Notifications?.[0]?.Message || 'Shipment creation failed',
            rawResponse: data,
        };
    }

    private async trackAramex(trackingNumber: string): Promise<TrackingResult> {
        const body = {
            ClientInfo: {
                UserName: this.aramexUsername,
                Password: this.aramexPassword,
                Version: 'v1',
                AccountNumber: this.aramexAccountNumber,
                AccountPin: this.aramexAccountPin,
                AccountEntity: this.aramexAccountEntity,
                AccountCountryCode: 'SA',
            },
            Shipments: [trackingNumber],
        };

        const response = await fetch('https://ws.aramex.net/ShippingAPI.V2/Tracking/Service_1_0.svc/json/TrackShipments', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body),
        });

        const data = await response.json();
        const tracking = data.TrackingResults?.[0];

        if (tracking) {
            return {
                success: true,
                status: tracking.UpdateDescription || 'unknown',
                isDelivered: tracking.UpdateCode === 'SH005',
                events: (tracking.Events || []).map((e: any) => ({
                    date: new Date(e.UpdateDateTime),
                    status: e.UpdateCode,
                    description: e.UpdateDescription,
                    location: e.UpdateLocation,
                })),
            };
        }

        return {
            success: false,
            status: 'not_found',
            isDelivered: false,
            events: [],
            error: 'Tracking not found',
        };
    }

    // ==================== Mock for Testing ====================

    private createMockShipment(request: ShipmentRequest): ShipmentResult {
        const trackingNumber = `MOCK${Date.now()}`;
        this.logger.warn(`[MOCK SHIPMENT] Order: ${request.orderId}, Tracking: ${trackingNumber}`);

        return {
            success: true,
            trackingNumber,
            awbNumber: trackingNumber,
            provider: 'mock',
            estimatedDelivery: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000),
        };
    }

    private getMockTracking(trackingNumber: string): TrackingResult {
        return {
            success: true,
            status: 'in_transit',
            statusDescription: 'Package is on its way',
            isDelivered: false,
            events: [
                {
                    date: new Date(),
                    status: 'in_transit',
                    description: 'Package departed facility',
                    location: 'Riyadh Hub',
                },
                {
                    date: new Date(Date.now() - 24 * 60 * 60 * 1000),
                    status: 'picked_up',
                    description: 'Package picked up',
                    location: 'Seller Location',
                },
            ],
        };
    }
}
