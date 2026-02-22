import {
  BadRequestException,
  Controller,
  Get,
  Post,
  Query,
  Res,
  StreamableFile,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiBody,
  ApiConsumes,
  ApiOperation,
  ApiQuery,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import { Response } from 'express';
import { Roles } from '@decorators/roles.decorator';
import { UserRole } from '@common/enums/user-role.enum';
import { JwtAuthGuard } from '@guards/jwt-auth.guard';
import { RolesGuard } from '@guards/roles.guard';
import { ResponseBuilder } from '@common/interfaces/response.interface';
import { ProductsImportExportService } from './products-import-export.service';
import {
  ExportProductsQueryDto,
  ImportProductsQueryDto,
} from './dto';

@ApiTags('Products Import/Export')
@Controller('products/import-export')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth('JWT-auth')
export class ProductsImportExportController {
  constructor(private readonly service: ProductsImportExportService) {}

  @Get('template')
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Download products Excel template' })
  async downloadTemplate(@Res({ passthrough: true }) res: Response) {
    const buffer = await this.service.exportTemplate();
    res.set({
      'Content-Type':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'Content-Disposition': `attachment; filename=products-template-${Date.now()}.xlsx`,
    });
    return new StreamableFile(buffer);
  }

  @Get('export')
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @ApiOperation({ summary: 'Export products to Excel' })
  async exportProducts(
    @Query() query: ExportProductsQueryDto,
    @Res({ passthrough: true }) res: Response,
  ) {
    const buffer = await this.service.exportProducts(query);
    res.set({
      'Content-Type':
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'Content-Disposition': `attachment; filename=products-export-${Date.now()}.xlsx`,
    });
    return new StreamableFile(buffer);
  }

  @Post('validate')
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
      required: ['file'],
    },
  })
  @ApiOperation({ summary: 'Validate Excel import file without saving' })
  async validate(@UploadedFile() file?: Express.Multer.File) {
    if (!file?.buffer) {
      throw new BadRequestException('No file uploaded');
    }
    const result = await this.service.validateImport(file);
    return ResponseBuilder.success(result, 'Validation completed', 'تم التحقق من الملف');
  }

  @Post('import')
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiQuery({ name: 'mode', required: false, enum: ['create', 'update', 'upsert'] })
  @ApiQuery({ name: 'skipValidation', required: false, type: Boolean })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
      required: ['file'],
    },
  })
  @ApiOperation({ summary: 'Import products from Excel file' })
  @ApiResponse({ status: 200, description: 'Import completed' })
  async importProducts(
    @UploadedFile() file: Express.Multer.File,
    @Query() query: ImportProductsQueryDto,
  ) {
    if (!file?.buffer) {
      throw new BadRequestException('No file uploaded');
    }

    const result = await this.service.importProducts(file, query);
    return ResponseBuilder.success(result, 'Import completed', 'تم استيراد البيانات');
  }

  @Post('partial')
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        file: {
          type: 'string',
          format: 'binary',
        },
      },
      required: ['file'],
    },
  })
  @ApiOperation({ summary: 'Partial update (price/stock/status) via Excel file' })
  async partialUpdate(@UploadedFile() file: Express.Multer.File) {
    if (!file?.buffer) {
      throw new BadRequestException('No file uploaded');
    }

    const result = await this.service.partialUpdate(file);
    return ResponseBuilder.success(
      result,
      'Partial update completed',
      'تم التحديث الجزئي',
    );
  }
}
