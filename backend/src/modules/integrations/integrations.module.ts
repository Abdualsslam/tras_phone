import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { SmsService } from './sms.service';
import { EmailService } from './email.service';
import { PaymentGatewayService } from './payment-gateway.service';
import { ShippingService } from './shipping.service';
import { StorageService } from './storage.service';

@Global()
@Module({
    imports: [ConfigModule],
    providers: [
        SmsService,
        EmailService,
        PaymentGatewayService,
        ShippingService,
        StorageService,
    ],
    exports: [
        SmsService,
        EmailService,
        PaymentGatewayService,
        ShippingService,
        StorageService,
    ],
})
export class IntegrationsModule { }
