import {
    Controller,
    Get,
    Param,
    UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { ResponseBuilder } from '@common/interfaces/response.interface';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👥 Users Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Users')
@Controller('users')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth('JWT-auth')
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @Get(':id')
    @ApiOperation({ summary: 'Get user by ID' })
    async findById(@Param('id') id: string) {
        const user = await this.usersService.findById(id);

        return ResponseBuilder.success(
            user,
            'User retrieved successfully',
            'تم استرجاع المستخدم بنجاح',
        );
    }
}
