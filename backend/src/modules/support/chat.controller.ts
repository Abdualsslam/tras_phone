import {
    Controller,
    Get,
    Post,
    Put,
    Body,
    Param,
    Query,
    UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { ChatSenderType, ChatMessageType } from './schemas/chat-message.schema';
import { ResponseBuilder } from '../../common/response.builder';
import { UserRole } from '@/common/enums/user-role.enum';

@ApiTags('Chat')
@Controller('chat')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class ChatController {
    constructor(private readonly chatService: ChatService) { }

    // ==================== Customer Chat ====================

    @Post('start')
    @ApiOperation({ summary: 'Start a new chat session' })
    async startChat(@CurrentUser() user: any, @Body() data: any) {
        // Check for existing active session
        const existing = await this.chatService.findActiveSession(user.customerId);
        if (existing) {
            return ResponseBuilder.success(existing, 'Existing session found');
        }

        const session = await this.chatService.createSession({
            visitor: {
                customerId: user.customerId,
                name: user.name,
                email: user.email,
                phone: user.phone,
                currentPage: data.currentPage,
            },
            department: data.department,
            categoryId: data.categoryId,
            initialMessage: data.message,
        });
        return ResponseBuilder.success(session, 'Chat session started');
    }

    @Get('my-session')
    @ApiOperation({ summary: 'Get my active chat session' })
    async getMySession(@CurrentUser() user: any) {
        const session = await this.chatService.findActiveSession(user.customerId);
        if (!session) {
            return ResponseBuilder.success(null, 'No active session');
        }
        const messages = await this.chatService.getSessionMessages(session._id.toString(), false);
        return ResponseBuilder.success({ session, messages });
    }

    @Post('my-session/messages')
    @ApiOperation({ summary: 'Send message in my chat session' })
    async sendMessage(@CurrentUser() user: any, @Body() data: any) {
        const session = await this.chatService.findActiveSession(user.customerId);
        if (!session) {
            return ResponseBuilder.error('No active session', 404);
        }

        const message = await this.chatService.addMessage(session._id.toString(), {
            senderType: ChatSenderType.VISITOR,
            senderId: user.customerId,
            senderName: user.name,
            content: data.content,
            messageType: data.type || ChatMessageType.TEXT,
            fileUrl: data.fileUrl,
            fileName: data.fileName,
            fileSize: data.fileSize,
            mimeType: data.mimeType,
        });
        return ResponseBuilder.success(message);
    }

    @Post('my-session/end')
    @ApiOperation({ summary: 'End my chat session' })
    async endMySession(@CurrentUser() user: any) {
        const session = await this.chatService.findActiveSession(user.customerId);
        if (!session) {
            return ResponseBuilder.error('No active session', 404);
        }

        const ended = await this.chatService.endSession(session._id.toString());
        return ResponseBuilder.success(ended, 'Chat session ended');
    }

    @Post('my-session/rate')
    @ApiOperation({ summary: 'Rate my chat session' })
    async rateMySession(
        @CurrentUser() user: any,
        @Body() data: { rating: number; feedback?: string }
    ) {
        // Find the most recent ended session
        const session = await this.chatService.findActiveSession(user.customerId);
        if (session) {
            return ResponseBuilder.error('Please end the session first', 400);
        }

        // This would need to find the most recent session - simplified for now
        return ResponseBuilder.error('No session to rate', 404);
    }

    @Put('my-session/page')
    @ApiOperation({ summary: 'Update current page in session' })
    async updatePage(@CurrentUser() user: any, @Body() data: { page: string }) {
        const session = await this.chatService.findActiveSession(user.customerId);
        if (!session) {
            return ResponseBuilder.success(null);
        }

        await this.chatService.updateVisitorPage(session._id.toString(), data.page);
        return ResponseBuilder.success(null, 'Page updated');
    }

    @Put('my-session/read')
    @ApiOperation({ summary: 'Mark messages as read' })
    async markAsRead(@CurrentUser() user: any) {
        const session = await this.chatService.findActiveSession(user.customerId);
        if (!session) {
            return ResponseBuilder.success(null);
        }

        await this.chatService.markMessagesAsRead(session._id.toString(), 'visitor');
        return ResponseBuilder.success(null, 'Messages marked as read');
    }

    // ==================== Admin Chat ====================

    @Get('admin/waiting')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get waiting chat sessions' })
    async getWaitingSessions(@Query('department') department?: string) {
        const sessions = await this.chatService.findWaitingSessions(department);
        return ResponseBuilder.success(sessions);
    }

    @Get('admin/my-sessions')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get my active chat sessions' })
    async getMyActiveSessions(@CurrentUser() user: any) {
        const sessions = await this.chatService.findAgentSessions(user.adminId);
        return ResponseBuilder.success(sessions);
    }

    @Get('admin/stats')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get chat statistics' })
    async getChatStats() {
        const stats = await this.chatService.getChatStats();
        return ResponseBuilder.success(stats);
    }

    @Get('admin/my-stats')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get my chat statistics' })
    async getMyChatStats(@CurrentUser() user: any) {
        const stats = await this.chatService.getAgentChatStats(user.adminId);
        return ResponseBuilder.success(stats);
    }

    @Post('admin/:id/accept')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Accept a waiting chat session' })
    async acceptSession(@CurrentUser() user: any, @Param('id') id: string) {
        const session = await this.chatService.acceptSession(id, user.adminId);
        return ResponseBuilder.success(session, 'Session accepted');
    }

    @Get('admin/:id')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Get chat session details' })
    async getSessionDetails(@Param('id') id: string) {
        const session = await this.chatService.findSessionById(id);
        const messages = await this.chatService.getSessionMessages(id, true);
        return ResponseBuilder.success({ session, messages });
    }

    @Post('admin/:id/messages')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Send message in chat session (admin)' })
    async sendAgentMessage(
        @CurrentUser() user: any,
        @Param('id') id: string,
        @Body() data: any
    ) {
        const message = await this.chatService.addMessage(id, {
            senderType: ChatSenderType.AGENT,
            senderId: user.adminId,
            senderName: user.name,
            content: data.content,
            messageType: data.type || ChatMessageType.TEXT,
            fileUrl: data.fileUrl,
            fileName: data.fileName,
            isInternal: data.isInternal,
            quickReplies: data.quickReplies,
        });
        return ResponseBuilder.success(message);
    }

    @Post('admin/:id/transfer')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Transfer chat session to another agent' })
    async transferSession(
        @CurrentUser() user: any,
        @Param('id') id: string,
        @Body() data: { toAgentId: string; reason: string }
    ) {
        const session = await this.chatService.transferSession(
            id,
            user.adminId,
            data.toAgentId,
            data.reason
        );
        return ResponseBuilder.success(session, 'Session transferred');
    }

    @Post('admin/:id/end')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'End chat session (admin)' })
    async endSession(@CurrentUser() user: any, @Param('id') id: string) {
        const session = await this.chatService.endSession(id, user.adminId);
        return ResponseBuilder.success(session, 'Session ended');
    }

    @Put('admin/:id/read')
    @Roles(UserRole.ADMIN)
    @ApiOperation({ summary: 'Mark messages as read (admin)' })
    async markAgentRead(@Param('id') id: string) {
        await this.chatService.markMessagesAsRead(id, 'agent');
        return ResponseBuilder.success(null, 'Messages marked as read');
    }
}
