import {
    Injectable,
    CanActivate,
    ExecutionContext,
    UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { IS_PUBLIC_KEY } from '@decorators/public.decorator';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🔐 JWT Authentication Guard
 * ═══════════════════════════════════════════════════════════════
 * Protects routes by validating JWT tokens
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
    constructor(
        private jwtService: JwtService,
        private configService: ConfigService,
        private reflector: Reflector,
    ) { }

    async canActivate(context: ExecutionContext): Promise<boolean> {
        // Check if route is marked as public
        const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
            context.getHandler(),
            context.getClass(),
        ]);

        if (isPublic) {
            return true;
        }

        const request = context.switchToHttp().getRequest();
        const token = this.extractTokenFromHeader(request);

        if (!token) {
            throw new UnauthorizedException('Access token not found');
        }

        try {
            const payload = await this.jwtService.verifyAsync(token, {
                secret: this.configService.get<string>('JWT_SECRET'),
            });

            // Attach user to request object
            request.user = payload;

            return true;
        } catch (error) {
            throw new UnauthorizedException('Invalid or expired token');
        }
    }

    /**
     * Extract JWT token from Authorization header
     */
    private extractTokenFromHeader(request: any): string | undefined {
        const authHeader = request.headers.authorization;

        if (!authHeader) {
            return undefined;
        }

        const [type, token] = authHeader.split(' ');

        return type === 'Bearer' ? token : undefined;
    }
}
