import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as nodemailer from 'nodemailer';

export interface EmailOptions {
    to: string | string[];
    subject: string;
    html?: string;
    text?: string;
    attachments?: Array<{
        filename: string;
        path?: string;
        content?: Buffer;
        contentType?: string;
    }>;
    cc?: string | string[];
    bcc?: string | string[];
    replyTo?: string;
}

export interface EmailResult {
    success: boolean;
    messageId?: string;
    provider: string;
    error?: string;
}

@Injectable()
export class EmailService {
    private readonly logger = new Logger(EmailService.name);
    private transporter: nodemailer.Transporter;
    private readonly fromEmail: string;
    private readonly fromName: string;

    constructor(private readonly configService: ConfigService) {
        this.fromEmail = this.configService.get('MAIL_FROM', 'noreply@trasphone.com');
        this.fromName = this.configService.get('MAIL_FROM_NAME', 'Tras Phone');

        this.initializeTransporter();
    }

    private initializeTransporter(): void {
        const provider = this.configService.get('MAIL_PROVIDER', 'smtp');

        if (provider === 'sendgrid') {
            this.transporter = nodemailer.createTransport({
                host: 'smtp.sendgrid.net',
                port: 587,
                auth: {
                    user: 'apikey',
                    pass: this.configService.get('SENDGRID_API_KEY'),
                },
            });
        } else {
            // Default SMTP
            this.transporter = nodemailer.createTransport({
                host: this.configService.get('MAIL_HOST', 'smtp.gmail.com'),
                port: this.configService.get('MAIL_PORT', 587),
                secure: this.configService.get('MAIL_SECURE', false),
                auth: {
                    user: this.configService.get('MAIL_USER'),
                    pass: this.configService.get('MAIL_PASSWORD'),
                },
            });
        }
    }

    async send(options: EmailOptions): Promise<EmailResult> {
        this.logger.log(`Sending email to ${options.to}`);

        try {
            const result = await this.transporter.sendMail({
                from: `"${this.fromName}" <${this.fromEmail}>`,
                to: Array.isArray(options.to) ? options.to.join(', ') : options.to,
                cc: options.cc,
                bcc: options.bcc,
                replyTo: options.replyTo,
                subject: options.subject,
                html: options.html,
                text: options.text,
                attachments: options.attachments,
            });

            return {
                success: true,
                messageId: result.messageId,
                provider: 'smtp',
            };
        } catch (error) {
            this.logger.error(`Email sending failed: ${error.message}`, error.stack);
            return {
                success: false,
                provider: 'smtp',
                error: error.message,
            };
        }
    }

    async sendWelcome(email: string, name: string): Promise<EmailResult> {
        const html = this.getTemplate('welcome', { name });
        return this.send({
            to: email,
            subject: 'مرحباً بك في تراس فون | Welcome to Tras Phone',
            html,
        });
    }

    async sendOtp(email: string, otp: string, name?: string): Promise<EmailResult> {
        const html = this.getTemplate('otp', { otp, name: name || 'العميل' });
        return this.send({
            to: email,
            subject: `رمز التحقق: ${otp} | Verification Code: ${otp}`,
            html,
        });
    }

    async sendPasswordReset(email: string, resetLink: string, name?: string): Promise<EmailResult> {
        const html = this.getTemplate('password-reset', { resetLink, name: name || 'العميل' });
        return this.send({
            to: email,
            subject: 'إعادة تعيين كلمة المرور | Password Reset',
            html,
        });
    }

    async sendOrderConfirmation(email: string, order: any): Promise<EmailResult> {
        const html = this.getTemplate('order-confirmation', order);
        return this.send({
            to: email,
            subject: `تأكيد الطلب رقم ${order.orderNumber} | Order Confirmation ${order.orderNumber}`,
            html,
        });
    }

    async sendShipmentNotification(email: string, shipment: any): Promise<EmailResult> {
        const html = this.getTemplate('shipment-notification', shipment);
        return this.send({
            to: email,
            subject: `تحديث الشحن للطلب ${shipment.orderNumber} | Shipment Update`,
            html,
        });
    }

    async sendInvoice(email: string, invoice: any, pdfBuffer?: Buffer): Promise<EmailResult> {
        const html = this.getTemplate('invoice', invoice);
        const attachments = pdfBuffer ? [{
            filename: `invoice-${invoice.invoiceNumber}.pdf`,
            content: pdfBuffer,
            contentType: 'application/pdf',
        }] : undefined;

        return this.send({
            to: email,
            subject: `الفاتورة رقم ${invoice.invoiceNumber} | Invoice ${invoice.invoiceNumber}`,
            html,
            attachments,
        });
    }

    async sendTicketCreated(email: string, ticket: any): Promise<EmailResult> {
        const html = this.getTemplate('ticket-created', ticket);
        return this.send({
            to: email,
            subject: `تم إنشاء تذكرة الدعم ${ticket.ticketNumber} | Support Ticket Created`,
            html,
        });
    }

    async sendTicketReply(email: string, ticket: any, reply: string): Promise<EmailResult> {
        const html = this.getTemplate('ticket-reply', { ...ticket, reply });
        return this.send({
            to: email,
            subject: `رد على تذكرة الدعم ${ticket.ticketNumber} | Ticket Reply`,
            html,
        });
    }

    private getTemplate(templateName: string, data: Record<string, any>): string {
        const templates: Record<string, (d: any) => string> = {
            'welcome': (d) => `
        <!DOCTYPE html>
        <html dir="rtl">
        <head><meta charset="utf-8"></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; direction: rtl;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1 style="color: #333;">مرحباً ${d.name}!</h1>
            <p>نحن سعداء بانضمامك إلى تراس فون.</p>
            <p>يمكنك الآن التسوق والاستمتاع بأفضل المنتجات.</p>
            <hr>
            <h1 style="color: #333;">Welcome ${d.name}!</h1>
            <p>We're happy to have you at Tras Phone.</p>
            <p>You can now shop and enjoy the best products.</p>
          </div>
        </body>
        </html>
      `,
            'otp': (d) => `
        <!DOCTYPE html>
        <html dir="rtl">
        <head><meta charset="utf-8"></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; direction: rtl;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h2>رمز التحقق الخاص بك</h2>
            <p>مرحباً ${d.name}،</p>
            <div style="font-size: 32px; font-weight: bold; color: #007bff; text-align: center; padding: 20px; background: #f5f5f5; border-radius: 8px;">
              ${d.otp}
            </div>
            <p>هذا الرمز صالح لمدة 10 دقائق.</p>
            <hr>
            <h2>Your Verification Code</h2>
            <p>This code is valid for 10 minutes.</p>
          </div>
        </body>
        </html>
      `,
            'password-reset': (d) => `
        <!DOCTYPE html>
        <html dir="rtl">
        <head><meta charset="utf-8"></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; direction: rtl;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h2>إعادة تعيين كلمة المرور</h2>
            <p>مرحباً ${d.name}،</p>
            <p>لقد طلبت إعادة تعيين كلمة المرور. انقر على الرابط التالي:</p>
            <p><a href="${d.resetLink}" style="display: inline-block; padding: 12px 24px; background: #007bff; color: white; text-decoration: none; border-radius: 4px;">إعادة تعيين كلمة المرور</a></p>
            <p>هذا الرابط صالح لمدة ساعة واحدة.</p>
          </div>
        </body>
        </html>
      `,
            'order-confirmation': (d) => `
        <!DOCTYPE html>
        <html dir="rtl">
        <head><meta charset="utf-8"></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; direction: rtl;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1 style="color: #28a745;">✓ تم تأكيد طلبك</h1>
            <p>رقم الطلب: <strong>${d.orderNumber}</strong></p>
            <p>المبلغ الإجمالي: <strong>${d.total} ر.س</strong></p>
            <p>شكراً لتسوقك معنا!</p>
          </div>
        </body>
        </html>
      `,
            'shipment-notification': (d) => `
        <!DOCTYPE html>
        <html dir="rtl">
        <head><meta charset="utf-8"></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; direction: rtl;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1>🚚 تحديث الشحن</h1>
            <p>طلبك رقم <strong>${d.orderNumber}</strong> في طريقه إليك!</p>
            <p>رقم التتبع: <strong>${d.trackingNumber}</strong></p>
          </div>
        </body>
        </html>
      `,
            'invoice': (d) => `
        <!DOCTYPE html>
        <html dir="rtl">
        <head><meta charset="utf-8"></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; direction: rtl;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1>فاتورة رقم ${d.invoiceNumber}</h1>
            <p>المبلغ الإجمالي: <strong>${d.total} ر.س</strong></p>
            <p>مرفق نسخة PDF من الفاتورة.</p>
          </div>
        </body>
        </html>
      `,
            'ticket-created': (d) => `
        <!DOCTYPE html>
        <html dir="rtl">
        <head><meta charset="utf-8"></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; direction: rtl;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1>تم إنشاء تذكرة دعم</h1>
            <p>رقم التذكرة: <strong>${d.ticketNumber}</strong></p>
            <p>الموضوع: ${d.subject}</p>
            <p>سنقوم بالرد عليك في أقرب وقت ممكن.</p>
          </div>
        </body>
        </html>
      `,
            'ticket-reply': (d) => `
        <!DOCTYPE html>
        <html dir="rtl">
        <head><meta charset="utf-8"></head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; direction: rtl;">
          <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
            <h1>رد على تذكرتك ${d.ticketNumber}</h1>
            <div style="background: #f5f5f5; padding: 15px; border-radius: 8px; margin: 15px 0;">
              ${d.reply}
            </div>
          </div>
        </body>
        </html>
      `,
        };

        return templates[templateName]?.(data) || '';
    }
}
