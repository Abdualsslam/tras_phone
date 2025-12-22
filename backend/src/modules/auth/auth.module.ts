import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { MongooseModule } from '@nestjs/mongoose';

import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { OtpService } from './otp.service';
import { PasswordResetService } from './password-reset.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { User, UserSchema } from '@modules/users/schemas/user.schema';
import {
    OtpVerification,
    OtpVerificationSchema,
} from './schemas/otp-verification.schema';
import {
    PasswordReset,
    PasswordResetSchema,
} from './schemas/password-reset.schema';
import {
    UserSession,
    UserSessionSchema,
} from './schemas/user-session.schema';
import { UsersModule } from '@modules/users/users.module';

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
            { name: OtpVerification.name, schema: OtpVerificationSchema },
            { name: PasswordReset.name, schema: PasswordResetSchema },
            { name: UserSession.name, schema: UserSessionSchema },
        ]),
        UsersModule,
    ],
    controllers: [AuthController],
    providers: [AuthService, OtpService, PasswordResetService, JwtStrategy],
    exports: [AuthService, OtpService, PasswordResetService, JwtStrategy, PassportModule],
})
export class AuthModule { }
