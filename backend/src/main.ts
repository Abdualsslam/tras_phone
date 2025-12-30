import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import compression from 'compression';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';

async function bootstrap() {
    const logger = new Logger('Bootstrap');

    const app = await NestFactory.create(AppModule, {
        logger: ['error', 'warn', 'log', 'debug', 'verbose'],
    });

    const configService = app.get(ConfigService);

    // Global prefix
    app.setGlobalPrefix('api/v1');

    // Security
    app.use(helmet());

    // Compression
    app.use(compression());

    // CORS
    app.enableCors({
        origin: configService.get('CORS_ORIGINS', '*').split(','),
        methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
        credentials: true,
        allowedHeaders: ['Content-Type', 'Authorization', 'Accept-Language'],
    });

    // Validation
    app.useGlobalPipes(
        new ValidationPipe({
            whitelist: true,
            forbidNonWhitelisted: true,
            transform: true,
            transformOptions: {
                enableImplicitConversion: true,
            },
        }),
    );

    // Global filters and interceptors
    app.useGlobalFilters(new GlobalExceptionFilter());
    app.useGlobalInterceptors(
        new LoggingInterceptor(),
        new TransformInterceptor(),
    );

    // Swagger API Documentation
    const swaggerConfig = new DocumentBuilder()
        .setTitle('TRAS Phone API')
        .setDescription(
            `TRAS Phone B2B E-Commerce Platform API Documentation

This API provides comprehensive endpoints for managing:
- Authentication & Authorization
- Customer & Admin Management
- Product Catalog & Inventory
- Orders & Cart Management
- Promotions & Loyalty Programs
- Wallet & Payments
- Support & Notifications
- Analytics & Reporting

All endpoints require JWT Bearer token authentication unless marked as public.`
        )
        .setVersion('1.0.0')
        .setContact(
            'TRAS Phone Team',
            'https://trasphone.com',
            'support@trasphone.com'
        )
        .setLicense('Proprietary', 'https://trasphone.com/license')
        .addServer('http://localhost:3000', 'Development Server')
        .addServer('https://api.trasphone.com', 'Production Server')
        .addBearerAuth(
            {
                type: 'http',
                scheme: 'bearer',
                bearerFormat: 'JWT',
                name: 'JWT',
                description: 'Enter JWT token',
                in: 'header',
            },
            'JWT-auth'
        )
        .addTag('Authentication', 'User authentication and authorization endpoints')
        .addTag('Customers', 'Customer management and operations')
        .addTag('Admin Users', 'Administrative user management')
        .addTag('Products', 'Product catalog and management')
        .addTag('Catalog', 'Product categories and catalog operations')
        .addTag('Orders', 'Order management and tracking')
        .addTag('Cart', 'Shopping cart operations')
        .addTag('Inventory', 'Inventory and warehouse management')
        .addTag('Promotions', 'Promotions, coupons, and discount management')
        .addTag('Returns', 'Product returns and refunds')
        .addTag('Wallet', 'Customer wallet and balance management')
        .addTag('Notifications', 'User notifications management')
        .addTag('Support', 'Customer support tickets and chat')
        .addTag('Content', 'CMS content management')
        .addTag('Settings', 'System settings and configuration')
        .addTag('Analytics', 'Analytics, reports, and insights')
        .addTag('Audit', 'Audit logs and activity tracking')
        .addTag('Locations', 'Cities, markets, and location management')
        .addTag('Suppliers', 'Supplier management')
        .addTag('Users', 'User account management')
        .build();

    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('api/docs', app, document, {
        swaggerOptions: {
            persistAuthorization: true,
            docExpansion: 'list',
            filter: true,
            showRequestDuration: true,
            tryItOutEnabled: true,
        },
        customSiteTitle: 'TRAS Phone API Documentation',
        customCss: '.swagger-ui .topbar { display: none }',
    });

    // Start server
    const port = configService.get('PORT', 3000);
    await app.listen(port);

    logger.log(`🚀 Application running on: http://localhost:${port}`);
    logger.log(`📚 Swagger docs available at: http://localhost:${port}/api/docs`);
    logger.log(`🌍 Environment: ${configService.get('NODE_ENV', 'development')}`);
}

bootstrap();
