import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface SmsOptions {
    to: string;
    message: string;
    sender?: string;
}

export interface SmsResult {
    success: boolean;
    messageId?: string;
    provider: string;
    error?: string;
}

@Injectable()
export class SmsService {
    private readonly logger = new Logger(SmsService.name);
    private readonly provider: string;
    private readonly unifonicAppSid: string;
    private readonly unifonicSenderId: string;
    private readonly twilioAccountSid: string;
    private readonly twilioAuthToken: string;
    private readonly twilioPhoneNumber: string;

    constructor(private readonly configService: ConfigService) {
        this.provider = this.configService.get('SMS_PROVIDER', 'unifonic');
        this.unifonicAppSid = this.configService.get('UNIFONIC_APP_SID', '');
        this.unifonicSenderId = this.configService.get('UNIFONIC_SENDER_ID', 'TrasPhone');
        this.twilioAccountSid = this.configService.get('TWILIO_ACCOUNT_SID', '');
        this.twilioAuthToken = this.configService.get('TWILIO_AUTH_TOKEN', '');
        this.twilioPhoneNumber = this.configService.get('TWILIO_PHONE_NUMBER', '');
    }

    async send(options: SmsOptions): Promise<SmsResult> {
        const formattedPhone = this.formatPhoneNumber(options.to);

        this.logger.log(`Sending SMS to ${formattedPhone} via ${this.provider}`);

        try {
            switch (this.provider) {
                case 'unifonic':
                    return await this.sendViaUnifonic(formattedPhone, options.message, options.sender);
                case 'twilio':
                    return await this.sendViaTwilio(formattedPhone, options.message);
                default:
                    return this.sendMock(formattedPhone, options.message);
            }
        } catch (error) {
            this.logger.error(`SMS sending failed: ${error.message}`, error.stack);
            return {
                success: false,
                provider: this.provider,
                error: error.message,
            };
        }
    }

    async sendOtp(phone: string, otp: string): Promise<SmsResult> {
        const message = `رمز التحقق الخاص بك هو: ${otp}\nYour verification code is: ${otp}`;
        return this.send({ to: phone, message });
    }

    async sendOrderConfirmation(phone: string, orderNumber: string): Promise<SmsResult> {
        const message = `تم تأكيد طلبك رقم ${orderNumber} بنجاح. شكراً لتسوقك معنا!\nYour order ${orderNumber} has been confirmed. Thank you for shopping with us!`;
        return this.send({ to: phone, message });
    }

    async sendShipmentUpdate(phone: string, orderNumber: string, status: string): Promise<SmsResult> {
        const statusMessages: Record<string, string> = {
            shipped: `تم شحن طلبك رقم ${orderNumber}.\nYour order ${orderNumber} has been shipped.`,
            out_for_delivery: `طلبك رقم ${orderNumber} في طريقه إليك.\nYour order ${orderNumber} is out for delivery.`,
            delivered: `تم توصيل طلبك رقم ${orderNumber} بنجاح.\nYour order ${orderNumber} has been delivered.`,
        };
        return this.send({ to: phone, message: statusMessages[status] || `Order ${orderNumber}: ${status}` });
    }

    private async sendViaUnifonic(to: string, message: string, sender?: string): Promise<SmsResult> {
        // Unifonic API integration
        const url = 'https://el.cloud.unifonic.com/rest/SMS/messages';

        const body = new URLSearchParams({
            AppSid: this.unifonicAppSid,
            SenderID: sender || this.unifonicSenderId,
            Body: message,
            Recipient: to,
            responseType: 'JSON',
        });

        const response = await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: body.toString(),
        });

        const data = await response.json();

        if (data.success === 'true' || data.Success === 'true') {
            return {
                success: true,
                messageId: data.MessageID || data.data?.MessageID,
                provider: 'unifonic',
            };
        }

        return {
            success: false,
            provider: 'unifonic',
            error: data.message || data.errorCode || 'Unknown error',
        };
    }

    private async sendViaTwilio(to: string, message: string): Promise<SmsResult> {
        // Twilio API integration
        const url = `https://api.twilio.com/2010-04-01/Accounts/${this.twilioAccountSid}/Messages.json`;

        const body = new URLSearchParams({
            To: to,
            From: this.twilioPhoneNumber,
            Body: message,
        });

        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Authorization': 'Basic ' + Buffer.from(`${this.twilioAccountSid}:${this.twilioAuthToken}`).toString('base64'),
                'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: body.toString(),
        });

        const data = await response.json();

        if (data.sid) {
            return {
                success: true,
                messageId: data.sid,
                provider: 'twilio',
            };
        }

        return {
            success: false,
            provider: 'twilio',
            error: data.message || 'Unknown error',
        };
    }

    private sendMock(to: string, message: string): SmsResult {
        this.logger.warn(`[MOCK SMS] To: ${to}, Message: ${message}`);
        return {
            success: true,
            messageId: `mock-${Date.now()}`,
            provider: 'mock',
        };
    }

    private formatPhoneNumber(phone: string): string {
        // Remove any non-digit characters
        let cleaned = phone.replace(/\D/g, '');

        // Add country code if missing (assuming Saudi Arabia)
        if (cleaned.startsWith('0')) {
            cleaned = '966' + cleaned.substring(1);
        } else if (!cleaned.startsWith('966') && !cleaned.startsWith('+')) {
            cleaned = '966' + cleaned;
        }

        return cleaned.startsWith('+') ? cleaned : '+' + cleaned;
    }
}
