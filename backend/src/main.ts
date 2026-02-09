import { NestFactory } from '@nestjs/core';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ExpressAdapter } from '@nestjs/platform-express';
import { IoAdapter } from '@nestjs/platform-socket.io';
import helmet from 'helmet';
import compression from 'compression';
import express from 'express';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { AuditAdminActivityInterceptor } from './common/interceptors/audit-admin-activity.interceptor';
import { AuditService } from './modules/audit/audit.service';

async function bootstrap() {
  const logger = new Logger('Bootstrap');

  // Create Express instance with increased body size limit
  const expressApp = express();
  expressApp.use(express.json({ limit: '50mb' }));
  expressApp.use(express.urlencoded({ extended: true, limit: '50mb' }));

  // Handle /api requests (without /v1) to prevent 404 noise
  expressApp.get('/api', (req, res) => {
    res.status(200).json({
      success: true,
      message: 'TRAS Phone API - Please use /api/v1 for API endpoints',
      version: '1.0.0',
      docs: '/api/docs',
      apiBase: '/api/v1',
    });
  });

  const app = await NestFactory.create(
    AppModule,
    new ExpressAdapter(expressApp),
    {
      logger: ['error', 'warn', 'log', 'debug', 'verbose'],
      bodyParser: false, // Disable default body parser since we're using Express middleware
    },
  );

  // Enable WebSocket
  app.useWebSocketAdapter(new IoAdapter(app));

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
  const auditService = app.get(AuditService);
  app.useGlobalInterceptors(
    new LoggingInterceptor(),
    new TransformInterceptor(),
    new AuditAdminActivityInterceptor(auditService),
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

All endpoints require JWT Bearer token authentication unless marked as public.`,
    )
    .setVersion('1.0.0')
    .setContact(
      'TRAS Phone Team',
      'https://trasphone.com',
      'support@trasphone.com',
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
      'JWT-auth',
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
