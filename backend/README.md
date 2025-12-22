# ═══════════════════════════════════════════════════════════════
# 🚀 TRAS Phone Backend - Professional NestJS API
# ═══════════════════════════════════════════════════════════════

<div align="center">

![NestJS](https://img.shields.io/badge/NestJS-E0234E?style=for-the-badge&logo=nestjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)

**Professional B2B E-commerce API for Mobile Phone Spare Parts**

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Architecture](#architecture)
- [Security](#security)
- [Testing](#testing)
- [Deployment](#deployment)

---

## 🎯 Overview

TRAS Phone Backend is a **professional enterprise-grade API** built with **NestJS** and **MongoDB**, designed specifically for B2B e-commerce operations in the mobile phone spare parts industry.

### Key Highlights

✅ **Clean Architecture** - Modular, scalable, and maintainable code structure  
✅ **Type Safety** - Full TypeScript implementation  
✅ **Security First** - JWT authentication, guards, rate limiting, and input validation  
✅ **Unified Responses** - Consistent API response format with localization  
✅ **Error Handling** - Global exception filters with detailed logging  
✅ **Performance** - Redis caching layer for optimal speed  
✅ **Documentation** - Auto-generated Swagger/OpenAPI docs  
✅ **Production Ready** - Logging, monitoring, and deployment configurations

---

## ✨ Features

### 🔐 Authentication & Authorization
- JWT-based authentication with refresh tokens
- Role-based access control (RBAC)
- Phone & email verification
- Social login support (Google, Apple)
- Failed login attempt tracking & account locking
- Two-factor authentication (2FA)

### 🛡️ Security
- Helmet.js for HTTP headers security
- Rate limiting & throttling
- Input validation with class-validator
- Password hashing with bcrypt
- CORS configuration
- SQL injection prevention
- XSS protection

### 📊 Core Business Logic
- **User Management** - Customers, admins, and permissions
- **Product Catalog** - Products, categories, brands, devices
- **Inventory** - Stock management, warehouses, movements
- **Orders** - Cart, checkout, order processing
- **Pricing** - Multi-level pricing, promotions, coupons
- **Wallet & Loyalty** - Customer wallet, loyalty points, tiers
- **Notifications** - Push, SMS, email notifications
- **Support** - Tickets, live chat, FAQs

### 🚀 Performance & Scalability
- Redis caching layer
- Database indexing & optimization
- Query optimization
- Compression middleware
- Pagination support
- Background job processing

### 📝 Logging & Monitoring
- Winston logger with daily rotation
- Request/response logging
- Error tracking
- Performance metrics
- Structured logging

---

## 🛠 Tech Stack

### Core
- **[NestJS](https://nestjs.com/)** v10.3 - Progressive Node.js framework
- **[TypeScript](https://www.typescriptlang.org/)** v5.3 - Typed JavaScript
- **[Node.js](https://nodejs.org/)** v18+ - Runtime environment

### Database & Caching
- **[MongoDB](https://www.mongodb.com/)** v6+ - Document database
- **[Mongoose](https://mongoosejs.com/)** v8 - MongoDB ODM
- **[Redis](https://redis.io/)** v7 - In-memory caching

### Authentication & Security
- **[Passport.js](http://www.passportjs.org/)** - Authentication middleware
- **[JWT](https://jwt.io/)** - JSON Web Tokens
- **[bcrypt](https://www.npmjs.com/package/bcrypt)** - Password hashing
- **[Helmet](https://helmetjs.github.io/)** - HTTP security headers

### Validation & Documentation
- **[class-validator](https://github.com/typestack/class-validator)** - Validation decorators
- **[class-transformer](https://github.com/typestack/class-transformer)** - Object transformation
- **[Swagger/OpenAPI](https://swagger.io/)** - API documentation

### Utilities
- **[Winston](https://github.com/winstonjs/winston)** - Logging
- **[dayjs](https://day.js.org/)** - Date manipulation
- **[nanoid](https://github.com/ai/nanoid)** - Unique ID generation
- **[AWS SDK](https://aws.amazon.com/sdk-for-javascript/)** - S3 file storage

---

## 📁 Project Structure

```
backend/
├── src/
│   ├── common/                      # Shared utilities
│   │   ├── decorators/             # Custom decorators
│   │   │   ├── current-user.decorator.ts
│   │   │   ├── public.decorator.ts
│   │   │   └── roles.decorator.ts
│   │   ├── filters/                # Exception filters
│   │   │   └── http-exception.filter.ts
│   │   ├── guards/                 # Route guards
│   │   │   ├── jwt-auth.guard.ts
│   │   │   └── roles.guard.ts
│   │   ├── interceptors/           # Request/response interceptors
│   │   │   ├── logging.interceptor.ts
│   │   │   └── transform.interceptor.ts
│   │   ├── interfaces/             # Shared interfaces
│   │   │   └── response.interface.ts
│   │   ├── enums/                  # Enumerations
│   │   │   └── user-role.enum.ts
│   │   ├── logger/                 # Logger service
│   │   │   ├── logger.module.ts
│   │   │   └── logger.service.ts
│   │   └── utils/                  # Utility functions
│   │
│   ├── config/                     # Configuration files
│   │   ├── database.config.ts
│   │   ├── jwt.config.ts
│   │   └── cache.config.ts
│   │
│   ├── modules/                    # Feature modules
│   │   ├── auth/                   # Authentication module
│   │   │   ├── dto/
│   │   │   ├── strategies/
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   └── auth.module.ts
│   │   ├── users/                  # Users module
│   │   ├── customers/              # Customers module
│   │   ├── admins/                 # Admins module
│   │   ├── products/               # Products module
│   │   ├── categories/             # Categories module
│   │   ├── brands/                 # Brands module
│   │   ├── orders/                 # Orders module
│   │   ├── inventory/              # Inventory module
│   │   ├── notifications/          # Notifications module
│   │   └── files/                  # File upload module
│   │
│   ├── app.module.ts               # Root module
│   └── main.ts                     # Application entry point
│
├── logs/                           # Application logs
├── uploads/                        # Uploaded files
├── .env.example                    # Environment variables template
├── .gitignore                      # Git ignore rules
├── nest-cli.json                   # NestJS CLI configuration
├── package.json                    # Dependencies
├── tsconfig.json                   # TypeScript configuration
└── README.md                       # This file
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed:

- **Node.js** v18 or higher ([Download](https://nodejs.org/))
- **MongoDB** v6 or higher ([Download](https://www.mongodb.com/try/download/community))
- **Redis** v7 or higher ([Download](https://redis.io/download))
- **npm** or **yarn** package manager

### Installation

1. **Clone the repository**

```bash
git clone <repository-url>
cd backend
```

2. **Install dependencies**

```bash
npm install
# or
yarn install
```

### Configuration

1. **Create environment file**

```bash
cp .env.example .env
```

2. **Configure environment variables**

Edit `.env` file with your settings:

```env
# Application
APP_PORT=3000
APP_URL=http://localhost:3000
NODE_ENV=development

# MongoDB
MONGODB_URI=mongodb://localhost:27017/tras_phone

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_REFRESH_SECRET=your-super-secret-refresh-key

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
```

---

## 🏃 Running the Application

### Development Mode

```bash
npm run start:dev
```

The API will be available at `http://localhost:3000`

### Production Mode

```bash
# Build the application
npm run build

# Start production server
npm run start:prod
```

### Watch Mode (with hot reload)

```bash
npm run start:debug
```

---

## 📚 API Documentation

### Swagger Documentation

Once the application is running, visit:

```
http://localhost:3000/api/docs
```

Interactive Swagger UI provides:
- Complete API endpoint documentation
- Request/response schemas
- Try-it-out functionality
- Authentication testing

### API Endpoints

#### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/refresh` - Refresh access token
- `GET /api/v1/auth/me` - Get current user profile
- `POST /api/v1/auth/logout` - Logout

#### Users
- `GET /api/v1/users/:id` - Get user by ID

*(More endpoints will be documented as modules are implemented)*

---

## 🏗 Architecture

### Clean Architecture Principles

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│    (Controllers, DTOs, Guards)          │
├─────────────────────────────────────────┤
│         Application Layer               │
│    (Services, Use Cases)                │
├─────────────────────────────────────────┤
│         Domain Layer                    │
│    (Entities, Schemas)                  │
├─────────────────────────────────────────┤
│         Infrastructure Layer            │
│    (Database, Cache, External APIs)     │
└─────────────────────────────────────────┘
```

### Unified Response Format

All API responses follow this structure:

```typescript
{
  "status": "success" | "error",
  "statusCode": 200,
  "message": "Operation successful",
  "messageAr": "تمت العملية بنجاح",
  "data": { ... },
  "meta": {
    "pagination": { ... }
  },
  "timestamp": "2024-12-20T18:30:00.000Z",
  "path": "/api/v1/users/123"
}
```

---

## 🔒 Security

### Implemented Security Measures

1. **Authentication** - JWT with refresh tokens
2. **Authorization** - Role-based access control
3. **Password Security** - Bcrypt hashing (12 rounds)
4. **Rate Limiting** - 100 requests per minute
5. **Input Validation** - class-validator decorators
6. **SQL Injection Prevention** - Mongoose parameterized queries
7. **XSS Protection** - Helmet.js middleware
8. **CORS** - Configurable allowed origins
9. **Account Locking** - After 5 failed login attempts

---

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

---

## 🚢 Deployment

### Docker Deployment

```bash
# Build Docker image
docker build -t tras-phone-api .

# Run container
docker run -p 3000:3000 tras-phone-api
```

### Environment Variables for Production

Ensure these critical variables are set:

- `NODE_ENV=production`
- `JWT_SECRET` - Strong secret key
- `MONGODB_URI` - Production database URL
- `REDIS_HOST` - Redis server host

---

## 📝 License

This project is proprietary and confidential.

---

## 👥 Team

Developed by **TRAS Phone Development Team**

---

## 📞 Support

For support or questions, contact:
- Email: support@trasphone.com
- Website: https://trasphone.com

---

<div align="center">

**Built with ❤️ using NestJS & TypeScript**

</div>
