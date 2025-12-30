import {
    Controller,
    Get,
    Param,
    UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse } from '@nestjs/swagger';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiAuthErrorResponses } from '@common/decorators/api-error-responses.decorator';
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
    @ApiOperation({
        summary: 'Get user by ID',
        description: 'Retrieve detailed information about a user account.',
    })
    @ApiParam({ name: 'id', description: 'User ID', example: '507f1f77bcf86cd799439011' })
    @ApiResponse({ status: 200, description: 'User retrieved successfully', type: ApiResponseDto })
    @ApiAuthErrorResponses()
    async findById(@Param('id') id: string) {
        const user = await this.usersService.findById(id);

        return ResponseBuilder.success(
            user,
            'User retrieved successfully',
            'تم استرجاع المستخدم بنجاح',
        );
    }
}
