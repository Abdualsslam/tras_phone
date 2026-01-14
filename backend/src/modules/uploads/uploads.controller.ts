import {
    Controller,
    Post,
    Delete,
    Body,
    Param,
    UseGuards,
    HttpCode,
    HttpStatus,
} from '@nestjs/common';
import {
    ApiTags,
    ApiOperation,
    ApiBearerAuth,
    ApiResponse,
    ApiBody,
    ApiProperty,
} from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsArray, ValidateNested, ArrayMinSize } from 'class-validator';
import { Type } from 'class-transformer';
import { UploadsService } from './uploads.service';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { ApiResponseDto } from '@common/dto/api-response.dto';
import { ApiAuthErrorResponses } from '@common/decorators/api-error-responses.decorator';

class FileItemDto {
    @ApiProperty({ example: 'data:image/jpeg;base64,/9j/4AAQSkZJRg...' })
    @IsString()
    @IsNotEmpty()
    base64: string;

    @ApiProperty({ example: 'product-image.jpg' })
    @IsString()
    @IsNotEmpty()
    filename: string;
}

class UploadFileDto {
    @ApiProperty({
        example: 'data:image/jpeg;base64,/9j/4AAQSkZJRg...',
        description: 'Base64 encoded file with data URI prefix'
    })
    @IsString()
    @IsNotEmpty()
    base64: string;

    @ApiProperty({
        example: 'product-image.jpg',
        description: 'Original filename'
    })
    @IsString()
    @IsNotEmpty()
    filename: string;

    @ApiProperty({
        example: 'products',
        description: 'Storage folder (default: products)',
        required: false
    })
    @IsString()
    @IsOptional()
    folder?: string;
}

class UploadMultipleDto {
    @ApiProperty({
        type: [FileItemDto],
        description: 'Array of files to upload'
    })
    @IsArray()
    @ArrayMinSize(1)
    @ValidateNested({ each: true })
    @Type(() => FileItemDto)
    files: FileItemDto[];

    @ApiProperty({
        example: 'products',
        description: 'Storage folder (default: products)',
        required: false
    })
    @IsString()
    @IsOptional()
    folder?: string;
}

/**
 * ═══════════════════════════════════════════════════════════════
 * 📤 Uploads Controller
 * ═══════════════════════════════════════════════════════════════
 */
@ApiTags('Uploads')
@Controller('uploads')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class UploadsController {
    constructor(private readonly uploadsService: UploadsService) { }

    @Post('single')
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Upload single file',
        description: 'Upload a single file (image or video) using base64 encoding',
    })
    @ApiBody({
        schema: {
            type: 'object',
            required: ['base64', 'filename'],
            properties: {
                base64: {
                    type: 'string',
                    description: 'Base64 encoded file with data URI prefix',
                    example: 'data:image/jpeg;base64,/9j/4AAQSkZJRg...',
                },
                filename: {
                    type: 'string',
                    description: 'Original filename',
                    example: 'product-image.jpg',
                },
                folder: {
                    type: 'string',
                    description: 'Storage folder (default: products)',
                    example: 'products',
                },
            },
        },
    })
    @ApiResponse({
        status: 201,
        description: 'File uploaded successfully',
        type: ApiResponseDto,
    })
    @ApiAuthErrorResponses()
    async uploadSingle(@Body() body: UploadFileDto) {
        const result = await this.uploadsService.uploadBase64(
            body.base64,
            body.filename,
            body.folder || 'products',
        );
        return ResponseBuilder.created(
            result,
            'File uploaded successfully',
            'تم رفع الملف بنجاح',
        );
    }

    @Post('multiple')
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @HttpCode(HttpStatus.CREATED)
    @ApiOperation({
        summary: 'Upload multiple files',
        description: 'Upload multiple files at once using base64 encoding',
    })
    @ApiBody({
        schema: {
            type: 'object',
            required: ['files'],
            properties: {
                files: {
                    type: 'array',
                    items: {
                        type: 'object',
                        properties: {
                            base64: { type: 'string' },
                            filename: { type: 'string' },
                        },
                    },
                },
                folder: {
                    type: 'string',
                    example: 'products',
                },
            },
        },
    })
    @ApiResponse({
        status: 201,
        description: 'Files uploaded successfully',
        type: ApiResponseDto,
    })
    @ApiAuthErrorResponses()
    async uploadMultiple(@Body() body: UploadMultipleDto) {
        const results = await this.uploadsService.uploadMultiple(
            body.files,
            body.folder || 'products',
        );
        return ResponseBuilder.created(
            results,
            'Files uploaded successfully',
            'تم رفع الملفات بنجاح',
        );
    }

    @Delete(':key')
    @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
    @HttpCode(HttpStatus.OK)
    @ApiOperation({
        summary: 'Delete file',
        description: 'Delete a file from storage by its key',
    })
    @ApiResponse({
        status: 200,
        description: 'File deleted successfully',
        type: ApiResponseDto,
    })
    @ApiAuthErrorResponses()
    async deleteFile(@Param('key') key: string) {
        await this.uploadsService.deleteFile(decodeURIComponent(key));
        return ResponseBuilder.success(
            null,
            'File deleted successfully',
            'تم حذف الملف بنجاح',
        );
    }
}
