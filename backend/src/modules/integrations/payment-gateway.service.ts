import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';

export interface PaymentRequest {
    amount: number;
    currency: string;
    orderId: string;
    customerEmail: string;
    customerName?: string;
    description?: string;
    paymentMethod: 'VISA' | 'MASTER' | 'MADA' | 'APPLEPAY' | 'STC_PAY';
    returnUrl: string;
    cancelUrl?: string;
    metadata?: Record<string, any>;
}

export interface PaymentResult {
    success: boolean;
    checkoutId?: string;
    redirectUrl?: string;
    transactionId?: string;
    status?: string;
    error?: string;
    rawResponse?: any;
}

export interface PaymentStatus {
    isPaid: boolean;
    status: string;
    transactionId?: string;
    amount?: number;
    currency?: string;
    paymentMethod?: string;
    timestamp?: Date;
    error?: string;
}

@Injectable()
export class PaymentGatewayService {
    private readonly logger = new Logger(PaymentGatewayService.name);
    private readonly provider: string;

    // HyperPay config
    private readonly hyperpayEntityId: string;
    private readonly hyperpayEntityIdMada: string;
    private readonly hyperpayAccessToken: string;
    private readonly hyperpayTestMode: boolean;

    // Moyasar config
    private readonly moyasarApiKey: string;

    constructor(private readonly configService: ConfigService) {
        this.provider = this.configService.get('PAYMENT_PROVIDER', 'hyperpay');

        // HyperPay
        this.hyperpayEntityId = this.configService.get('HYPERPAY_ENTITY_ID', '');
        this.hyperpayEntityIdMada = this.configService.get('HYPERPAY_ENTITY_ID_MADA', '');
        this.hyperpayAccessToken = this.configService.get('HYPERPAY_ACCESS_TOKEN', '');
        this.hyperpayTestMode = this.configService.get('HYPERPAY_TEST_MODE', true);

        // Moyasar
        this.moyasarApiKey = this.configService.get('MOYASAR_API_KEY', '');
    }

    async createPayment(request: PaymentRequest): Promise<PaymentResult> {
        this.logger.log(`Creating payment for order ${request.orderId}, amount: ${request.amount} ${request.currency}`);

        try {
            switch (this.provider) {
                case 'hyperpay':
                    return await this.createHyperpayPayment(request);
                case 'moyasar':
                    return await this.createMoyasarPayment(request);
                default:
                    return this.createMockPayment(request);
            }
        } catch (error) {
            this.logger.error(`Payment creation failed: ${error.message}`, error.stack);
            return {
                success: false,
                error: error.message,
            };
        }
    }

    async getPaymentStatus(checkoutId: string, paymentMethod?: string): Promise<PaymentStatus> {
        try {
            switch (this.provider) {
                case 'hyperpay':
                    return await this.getHyperpayStatus(checkoutId, paymentMethod);
                case 'moyasar':
                    return await this.getMoyasarStatus(checkoutId);
                default:
                    return { isPaid: true, status: 'mock_success' };
            }
        } catch (error) {
            this.logger.error(`Payment status check failed: ${error.message}`, error.stack);
            return {
                isPaid: false,
                status: 'error',
                error: error.message,
            };
        }
    }

    async refund(transactionId: string, amount: number, currency: string = 'SAR'): Promise<PaymentResult> {
        this.logger.log(`Refunding ${amount} ${currency} for transaction ${transactionId}`);

        try {
            switch (this.provider) {
                case 'hyperpay':
                    return await this.refundHyperpay(transactionId, amount, currency);
                case 'moyasar':
                    return await this.refundMoyasar(transactionId, amount);
                default:
                    return { success: true, transactionId: `refund-${Date.now()}` };
            }
        } catch (error) {
            this.logger.error(`Refund failed: ${error.message}`, error.stack);
            return {
                success: false,
                error: error.message,
            };
        }
    }

    // ==================== HyperPay Integration ====================

    private async createHyperpayPayment(request: PaymentRequest): Promise<PaymentResult> {
        const baseUrl = this.hyperpayTestMode
            ? 'https://eu-test.oppwa.com'
            : 'https://eu-prod.oppwa.com';

        const entityId = request.paymentMethod === 'MADA'
            ? this.hyperpayEntityIdMada
            : this.hyperpayEntityId;

        const paymentBrand = this.getHyperpayBrand(request.paymentMethod);

        const body = new URLSearchParams({
            entityId,
            amount: request.amount.toFixed(2),
            currency: request.currency,
            paymentType: 'DB', // Debit
            'merchantTransactionId': request.orderId,
            'customer.email': request.customerEmail,
            'customer.givenName': request.customerName || 'Customer',
        });

        const response = await fetch(`${baseUrl}/v1/checkouts`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${this.hyperpayAccessToken}`,
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body.toString(),
        });

        const data = await response.json();

        if (data.id) {
            const paymentFormUrl = this.hyperpayTestMode
                ? `https://eu-test.oppwa.com/v1/paymentWidgets.js?checkoutId=${data.id}`
                : `https://eu-prod.oppwa.com/v1/paymentWidgets.js?checkoutId=${data.id}`;

            return {
                success: true,
                checkoutId: data.id,
                redirectUrl: paymentFormUrl,
                rawResponse: data,
            };
        }

        return {
            success: false,
            error: data.result?.description || 'Payment creation failed',
            rawResponse: data,
        };
    }

    private async getHyperpayStatus(checkoutId: string, paymentMethod?: string): Promise<PaymentStatus> {
        const baseUrl = this.hyperpayTestMode
            ? 'https://eu-test.oppwa.com'
            : 'https://eu-prod.oppwa.com';

        const entityId = paymentMethod === 'MADA'
            ? this.hyperpayEntityIdMada
            : this.hyperpayEntityId;

        const response = await fetch(
            `${baseUrl}/v1/checkouts/${checkoutId}/payment?entityId=${entityId}`,
            {
                headers: {
                    'Authorization': `Bearer ${this.hyperpayAccessToken}`,
                },
            }
        );

        const data = await response.json();
        const resultCode = data.result?.code;

        // Success codes: 000.000.000, 000.100.1xx
        const isSuccess = resultCode && (
            resultCode.startsWith('000.000.') ||
            resultCode.startsWith('000.100.1') ||
            resultCode === '000.100.110'
        );

        return {
            isPaid: isSuccess,
            status: data.result?.description || 'unknown',
            transactionId: data.id,
            amount: parseFloat(data.amount),
            currency: data.currency,
            paymentMethod: data.paymentBrand,
            timestamp: data.timestamp ? new Date(data.timestamp) : undefined,
        };
    }

    private async refundHyperpay(transactionId: string, amount: number, currency: string): Promise<PaymentResult> {
        const baseUrl = this.hyperpayTestMode
            ? 'https://eu-test.oppwa.com'
            : 'https://eu-prod.oppwa.com';

        const body = new URLSearchParams({
            entityId: this.hyperpayEntityId,
            amount: amount.toFixed(2),
            currency,
            paymentType: 'RF', // Refund
        });

        const response = await fetch(`${baseUrl}/v1/payments/${transactionId}`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${this.hyperpayAccessToken}`,
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body.toString(),
        });

        const data = await response.json();
        const isSuccess = data.result?.code?.startsWith('000.');

        return {
            success: isSuccess,
            transactionId: data.id,
            error: isSuccess ? undefined : data.result?.description,
            rawResponse: data,
        };
    }

    private getHyperpayBrand(method: string): string {
        const brands: Record<string, string> = {
            'VISA': 'VISA',
            'MASTER': 'MASTER',
            'MADA': 'MADA',
            'APPLEPAY': 'APPLEPAY',
            'STC_PAY': 'STC_PAY',
        };
        return brands[method] || 'VISA';
    }

    // ==================== Moyasar Integration ====================

    private async createMoyasarPayment(request: PaymentRequest): Promise<PaymentResult> {
        const response = await fetch('https://api.moyasar.com/v1/payments', {
            method: 'POST',
            headers: {
                'Authorization': 'Basic ' + Buffer.from(`${this.moyasarApiKey}:`).toString('base64'),
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                amount: Math.round(request.amount * 100), // Moyasar uses cents
                currency: request.currency,
                description: request.description || `Order ${request.orderId}`,
                callback_url: request.returnUrl,
                source: {
                    type: 'creditcard',
                },
                metadata: {
                    order_id: request.orderId,
                    ...request.metadata,
                },
            }),
        });

        const data = await response.json();

        if (data.id) {
            return {
                success: true,
                checkoutId: data.id,
                redirectUrl: data.source?.transaction_url,
                rawResponse: data,
            };
        }

        return {
            success: false,
            error: data.message || 'Payment creation failed',
            rawResponse: data,
        };
    }

    private async getMoyasarStatus(paymentId: string): Promise<PaymentStatus> {
        const response = await fetch(`https://api.moyasar.com/v1/payments/${paymentId}`, {
            headers: {
                'Authorization': 'Basic ' + Buffer.from(`${this.moyasarApiKey}:`).toString('base64'),
            },
        });

        const data = await response.json();

        return {
            isPaid: data.status === 'paid',
            status: data.status,
            transactionId: data.id,
            amount: data.amount / 100,
            currency: data.currency,
        };
    }

    // ==================== Mock for Testing ====================

    private async refundMoyasar(paymentId: string, amount: number): Promise<PaymentResult> {
        const response = await fetch(`https://api.moyasar.com/v1/payments/${paymentId}/refund`, {
            method: 'POST',
            headers: {
                'Authorization': 'Basic ' + Buffer.from(`${this.moyasarApiKey}:`).toString('base64'),
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                amount: Math.round(amount * 100), // Moyasar uses cents
            }),
        });

        const data = await response.json();

        if (data.status === 'refunded') {
            return {
                success: true,
                transactionId: data.id,
                rawResponse: data,
            };
        }

        return {
            success: false,
            error: data.message || 'Refund failed',
            rawResponse: data,
        };
    }

    // ==================== Mock for Testing ====================

    private createMockPayment(request: PaymentRequest): PaymentResult {
        this.logger.warn(`[MOCK PAYMENT] Order: ${request.orderId}, Amount: ${request.amount}`);

        // Simulate failure for amounts ending in .99 (for testing error flows)
        if (request.amount.toString().endsWith('.99')) {
            this.logger.warn(`[MOCK PAYMENT] Simulating failure for amount ${request.amount}`);
            return {
                success: false,
                error: 'Mock: Payment declined — amount ends in .99',
            };
        }

        return {
            success: true,
            checkoutId: `mock-${Date.now()}`,
            redirectUrl: `${request.returnUrl}?checkout_id=mock-${Date.now()}&status=success`,
        };
    }

    // ==================== Webhook Verification ====================

    verifyHyperpayWebhook(payload: string, signature: string, secret: string): boolean {
        const computedSignature = crypto
            .createHmac('sha256', secret)
            .update(payload)
            .digest('hex');
        return crypto.timingSafeEqual(
            Buffer.from(signature),
            Buffer.from(computedSignature)
        );
    }
}
