import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ResponseBuilder } from '@common/interfaces/response.interface';
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
    const categories = await this.ticketsService.findAllCategories(
      activeOnly === 'true',
    );
    return ResponseBuilder.success(categories);
  }

  @Post('categories')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create ticket category' })
  async createCategory(@Body() data: any) {
    const category = await this.ticketsService.createCategory(data);
    return ResponseBuilder.success(category, 'Category created successfully');
  }

  @Put('categories/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update ticket category' })
  async updateCategory(@Param('id') id: string, @Body() data: any) {
    const category = await this.ticketsService.updateCategory(id, data);
    return ResponseBuilder.success(category, 'Category updated successfully');
  }

  @Delete('categories/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete ticket category' })
  async deleteCategory(@Param('id') id: string) {
    await this.ticketsService.deleteCategory(id);
    return ResponseBuilder.success(null, 'Category deleted successfully');
  }

  @Get('canned-responses')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Get canned responses' })
  async getCannedResponses(
    @CurrentUser() user: any,
    @Query('categoryId') categoryId?: string,
  ) {
    const responses = await this.ticketsService.findCannedResponses(
      user.adminId,
      categoryId,
    );
    return ResponseBuilder.success(responses);
  }

  @Post('canned-responses')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Create canned response' })
  async createCannedResponse(@CurrentUser() user: any, @Body() data: any) {
    const response = await this.ticketsService.createCannedResponse(
      data,
      user.adminId,
    );
    return ResponseBuilder.success(response, 'Canned response created successfully');
  }

  @Put('canned-responses/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Update canned response' })
  async updateCannedResponse(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() data: any,
  ) {
    const response = await this.ticketsService.updateCannedResponse(
      id,
      data,
      user.adminId,
    );
    return ResponseBuilder.success(response, 'Canned response updated successfully');
  }

  @Delete('canned-responses/:id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Delete canned response' })
  async deleteCannedResponse(@CurrentUser() user: any, @Param('id') id: string) {
    await this.ticketsService.deleteCannedResponse(id, user.adminId);
    return ResponseBuilder.success(null, 'Canned response deleted successfully');
  }

  @Post('canned-responses/:id/use')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Mark canned response as used' })
  async useCannedResponse(@Param('id') id: string) {
    const response = await this.ticketsService.useCannedResponse(id);
    return ResponseBuilder.success(response);
  }
}
