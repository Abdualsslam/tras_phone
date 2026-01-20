import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { User, UserSchema } from '@modules/users/schemas/user.schema';
import { UserSession, UserSessionSchema } from './schemas/user-session.schema';
import {
  LoginAttempt,
  LoginAttemptSchema,
} from './schemas/login-attempt.schema';
import { ApiToken, ApiTokenSchema } from './schemas/api-token.schema';
import {
  PasswordResetRequest,
  PasswordResetRequestSchema,
} from './schemas/password-reset-request.schema';
import {
  AdminUser,
  AdminUserSchema,
} from '@modules/admins/schemas/admin-user.schema';
import { Customer, CustomerSchema } from '@modules/customers/schemas/customer.schema';
import { PriceLevel, PriceLevelSchema } from '@modules/products/schemas/price-level.schema';

@Module({
  imports: [
    PassportModule.register({ defaultStrategy: 'jwt' }),
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<string>('JWT_EXPIRATION', '15m'),
        },
      }),
      inject: [ConfigService],
    }),
    MongooseModule.forFeature([
      { name: User.name, schema: UserSchema },
      { name: UserSession.name, schema: UserSessionSchema },
      { name: LoginAttempt.name, schema: LoginAttemptSchema },
      { name: ApiToken.name, schema: ApiTokenSchema },
      { name: AdminUser.name, schema: AdminUserSchema },
      { name: Customer.name, schema: CustomerSchema },
      { name: PriceLevel.name, schema: PriceLevelSchema },
      { name: PasswordResetRequest.name, schema: PasswordResetRequestSchema },
    ]),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, JwtAuthGuard],
  exports: [
    AuthService,
    JwtStrategy,
    JwtAuthGuard,
    PassportModule,
    MongooseModule,
  ],
})
export class AuthModule {}
