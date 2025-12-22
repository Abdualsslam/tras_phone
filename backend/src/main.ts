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
        .setTitle('Tras Phone API')
        .setDescription('TRAS Phone E-Commerce Platform API Documentation')
        .setVersion('1.0')
        .addBearerAuth()
        .addTag('Auth', 'Authentication endpoints')
        .addTag('Customers', 'Customer management')
        .addTag('Admin', 'Admin management')
        .addTag('Products', 'Product catalog')
        .addTag('Categories', 'Product categories')
        .addTag('Orders', 'Order management')
        .addTag('Cart', 'Shopping cart')
        .addTag('Inventory', 'Inventory management')
        .addTag('Promotions', 'Promotions & coupons')
        .addTag('Returns', 'Returns & refunds')
        .addTag('Wallet', 'Customer wallet')
        .addTag('Loyalty', 'Loyalty program')
        .addTag('Notifications', 'Notifications')
        .addTag('Support', 'Customer support')
        .addTag('Content', 'CMS content')
        .addTag('Settings', 'System settings')
        .addTag('Analytics', 'Analytics & reports')
        .addTag('Audit', 'Audit logs')
        .build();

    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup('api/docs', app, document, {
        swaggerOptions: {
            persistAuthorization: true,
            docExpansion: 'none',
        },
    });

    // Start server
    const port = configService.get('PORT', 3000);
    await app.listen(port);

    logger.log(`🚀 Application running on: http://localhost:${port}`);
    logger.log(`📚 Swagger docs available at: http://localhost:${port}/api/docs`);
    logger.log(`🌍 Environment: ${configService.get('NODE_ENV', 'development')}`);
}

bootstrap();
