import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ResponseBuilder } from '../../common/response.builder';
import { UserRole } from '@common/enums/user-role.enum';
import { TicketsService } from './tickets.service';

/**
 * Support controller: exposes GET /support/stats, /support/categories, /support/canned-responses
 * so the admin panel can use the same paths without /tickets in the path.
 */
@ApiTags('Support')
@Controller('support')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class SupportController {
    constructor(private readonly ticketsService: TicketsService) {}

    @Get('stats')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get support ticket statistics' })
    async getStats() {
        const stats = await this.ticketsService.getTicketStats();
        return ResponseBuilder.success(stats);
    }

    @Get('categories')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get ticket categories' })
    async getCategories(@Query('activeOnly') activeOnly: string = 'true') {
        const categories = await this.ticketsService.findAllCategories(activeOnly === 'true');
        return ResponseBuilder.success(categories);
    }

    @Get('canned-responses')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get canned responses' })
    async getCannedResponses(
        @CurrentUser() user: any,
        @Query('categoryId') categoryId?: string,
    ) {
        const responses = await this.ticketsService.findCannedResponses(user.adminId, categoryId);
        return ResponseBuilder.success(responses);
    }
}
