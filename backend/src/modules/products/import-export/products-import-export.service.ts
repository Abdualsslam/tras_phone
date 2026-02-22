import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import * as ExcelJS from 'exceljs';
import { Product, ProductDocument } from '../schemas/product.schema';
import {
  ProductDeviceCompatibility,
  ProductDeviceCompatibilityDocument,
} from '../schemas/product-device-compatibility.schema';
import {
  ImportMode,
  ImportProductsQueryDto,
  ValidationResultDto,
} from './dto/import-products.dto';
import { ExportProductsQueryDto } from './dto/export-filter.dto';
import {
  DeviceCompatibilityRow,
  ProductRow,
  parseBoolean,
  parseNumber,
  parseStringArray,
  validateDeviceCompatibilityRow,
  validatePartialUpdateRow,
  validateProductRow,
  ValidationError,
} from './utils/excel-validator';
import { buildImportResult } from './utils/error-formatter';
import { ReferenceResolver } from './utils/reference-resolver';

const PRODUCT_HEADERS = [
  'id',
  'sku',
  'name',
  'nameAr',
  'slug',
  'brandSlug',
  'categorySlug',
  'additionalCategorySlugs',
  'qualityTypeSlug',
  'basePrice',
  'compareAtPrice',
  'costPrice',
  'stockQuantity',
  'lowStockThreshold',
  'trackInventory',
  'allowBackorder',
  'status',
  'isActive',
  'isFeatured',
  'isNewArrival',
  'isBestSeller',
  'description',
  'descriptionAr',
  'shortDescription',
  'shortDescriptionAr',
  'mainImage',
  'images',
  'video',
  'specifications',
  'weight',
  'dimensions',
  'color',
  'tags',
  'warrantyDays',
  'warrantyDescription',
  'metaTitle',
  'metaTitleAr',
  'metaDescription',
  'metaDescriptionAr',
  'metaKeywords',
  'compatibleDevices',
] as const;

@Injectable()
export class ProductsImportExportService {
  constructor(
    @InjectModel(Product.name)
    private readonly productModel: Model<ProductDocument>,
    @InjectModel(ProductDeviceCompatibility.name)
    private readonly compatibilityModel: Model<ProductDeviceCompatibilityDocument>,
    private readonly referenceResolver: ReferenceResolver,
  ) {}

  async exportTemplate(): Promise<Buffer> {
    const workbook = new ExcelJS.Workbook();

    this.buildProductsSheet(workbook, []);
    this.buildReferencesSheets(workbook, true);
    this.buildCompatibilitySheet(workbook, []);

    const buffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(buffer);
  }

  async exportProducts(query: ExportProductsQueryDto): Promise<Buffer> {
    const workbook = new ExcelJS.Workbook();
    const filter: Record<string, any> = {};

    if (query.brandId) filter.brandId = new Types.ObjectId(query.brandId);
    if (query.categoryId) filter.categoryId = new Types.ObjectId(query.categoryId);
    if (query.qualityTypeId) {
      filter.qualityTypeId = new Types.ObjectId(query.qualityTypeId);
    }
    if (query.status) filter.status = query.status;
    if (!query.includeInactive) filter.isActive = true;
    if (query.search) {
      filter.$or = [
        { name: { $regex: query.search, $options: 'i' } },
        { sku: { $regex: query.search, $options: 'i' } },
      ];
    }

    const products = await this.productModel
      .find(filter)
      .populate('brandId', 'slug')
      .populate('categoryId', 'slug')
      .populate('qualityTypeId', 'code')
      .populate('additionalCategories', 'slug')
      .populate('compatibleDevices', 'slug')
      .lean()
      .exec();

    this.buildProductsSheet(workbook, products as any[]);

    if (query.includeReferences !== false) {
      await this.buildReferencesSheets(workbook, false);
    }

    if (query.includeCompatibility !== false) {
      const productIds = products.map((p: any) => p._id);
      const compat = await this.compatibilityModel
        .find({ productId: { $in: productIds } })
        .populate('productId', 'sku')
        .populate('deviceId', 'slug')
        .lean()
        .exec();
      this.buildCompatibilitySheet(workbook, compat as any[]);
    }

    const buffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(buffer);
  }

  async validateImport(file: UploadedExcelFile): Promise<ValidationResultDto> {
    if (!file?.buffer) {
      throw new BadRequestException('Excel file is required');
    }

    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(file.buffer as any);

    const products = this.readSheetRows<ProductRow>(workbook, 'Products');
    const compatibility = this.readSheetRows<DeviceCompatibilityRow>(
      workbook,
      'DeviceCompatibility',
      false,
    );

    const errors: ValidationError[] = [];

    products.forEach((row, idx) => {
      errors.push(...validateProductRow(row, idx + 2));
    });

    compatibility.forEach((row, idx) => {
      errors.push(...validateDeviceCompatibilityRow(row, idx + 2));
    });

    const brandSlugs = uniq(products.map((r) => r.brandSlug).filter(Boolean));
    const categorySlugs = uniq(products.map((r) => r.categorySlug).filter(Boolean));
    const qualityTypeCodes = uniq(
      products.map((r) => r.qualityTypeSlug).filter(Boolean),
    );
    const deviceSlugs = uniq([
      ...products.flatMap((r) => parseStringArray(r.compatibleDevices)),
      ...compatibility.map((r) => r.deviceSlug),
    ]);

    const missingReferences = await this.referenceResolver.findMissingReferences(
      brandSlugs,
      categorySlugs,
      qualityTypeCodes,
      deviceSlugs,
    );

    if (hasMissingReferences(missingReferences)) {
      for (const slug of missingReferences.brands) {
        errors.push({
          row: 0,
          sheet: 'Brands',
          field: 'slug',
          message: `Brand not found: ${slug}`,
          value: slug,
          severity: 'error',
        });
      }
      for (const slug of missingReferences.categories) {
        errors.push({
          row: 0,
          sheet: 'Categories',
          field: 'slug',
          message: `Category not found: ${slug}`,
          value: slug,
          severity: 'error',
        });
      }
      for (const code of missingReferences.qualityTypes) {
        errors.push({
          row: 0,
          sheet: 'QualityTypes',
          field: 'code',
          message: `Quality type not found: ${code}`,
          value: code,
          severity: 'error',
        });
      }
      for (const slug of missingReferences.devices) {
        errors.push({
          row: 0,
          sheet: 'Devices',
          field: 'slug',
          message: `Device not found: ${slug}`,
          value: slug,
          severity: 'error',
        });
      }
    }

    const refs = await this.referenceResolver.getReferenceData();

    return {
      isValid: errors.filter((e) => e.severity === 'error').length === 0,
      totalRows: products.length,
      references: {
        brands: refs.brands.map((b: any) => ({
          slug: b.slug,
          name: b.name,
          exists: true,
        })),
        categories: refs.categories.map((c: any) => ({
          slug: c.slug,
          name: c.name,
          exists: true,
        })),
        qualityTypes: refs.qualityTypes.map((q: any) => ({
          code: q.code,
          name: q.name,
          exists: true,
        })),
        devices: refs.devices.map((d: any) => ({
          slug: d.slug,
          name: d.name,
          exists: true,
        })),
      },
      errors: errors.map((e) => ({
        row: e.row,
        sheet: e.sheet,
        field: e.field,
        message: e.message,
        value: e.value,
      })),
      missingReferences,
    };
  }

  async importProducts(file: UploadedExcelFile, query: ImportProductsQueryDto) {
    const validation = await this.validateImport(file);
    if (!validation.isValid && !query.skipValidation) {
      return {
        success: false,
        validation,
      };
    }

    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(file.buffer as any);

    const rows = this.readSheetRows<ProductRow>(workbook, 'Products');
    const compatibility = this.readSheetRows<DeviceCompatibilityRow>(
      workbook,
      'DeviceCompatibility',
      false,
    );

    const refs = await this.referenceResolver.loadAllReferences();
    const errors: ValidationError[] = [];
    let created = 0;
    let updated = 0;
    let skipped = 0;

    for (let i = 0; i < rows.length; i += 1) {
      const rowNumber = i + 2;
      const row = rows[i];

      try {
        const existingBySku = await this.productModel.findOne({ sku: row.sku }).exec();

        if (row.id && existingBySku && String(existingBySku._id) !== row.id) {
          errors.push({
            row: rowNumber,
            sheet: 'Products',
            field: 'id',
            message: `Second verification failed: SKU ${row.sku} belongs to another product`,
            value: row.id,
            severity: 'error',
          });
          skipped += 1;
          continue;
        }

        const productData = this.mapProductRow(row, refs);
        const mode = query.mode || ImportMode.UPSERT;

        if (mode === ImportMode.CREATE && existingBySku) {
          skipped += 1;
          continue;
        }

        if (mode === ImportMode.UPDATE && !existingBySku) {
          errors.push({
            row: rowNumber,
            sheet: 'Products',
            field: 'sku',
            message: `Product not found for update: ${row.sku}`,
            value: row.sku,
            severity: 'error',
          });
          skipped += 1;
          continue;
        }

        if (existingBySku) {
          await this.productModel
            .updateOne({ _id: existingBySku._id }, { $set: productData })
            .exec();
          updated += 1;
        } else {
          await this.productModel.create(productData);
          created += 1;
        }
      } catch (error: any) {
        errors.push({
          row: rowNumber,
          sheet: 'Products',
          field: '',
          message: error?.message || 'Failed to process row',
          severity: 'error',
        });
        skipped += 1;
      }
    }

    await this.processCompatibilityRows(compatibility, errors);

    return buildImportResult({
      total: rows.length,
      created,
      updated,
      skipped,
      errors,
      missingReferences: validation.missingReferences,
    });
  }

  async partialUpdate(file: UploadedExcelFile) {
    if (!file?.buffer) {
      throw new BadRequestException('Excel file is required');
    }

    const workbook = new ExcelJS.Workbook();
    await workbook.xlsx.load(file.buffer as any);

    const rows = this.readSheetRows<Record<string, any>>(workbook, 'Products');
    const errors: ValidationError[] = [];
    let updated = 0;
    let skipped = 0;

    for (let i = 0; i < rows.length; i += 1) {
      const rowNumber = i + 2;
      const row = rows[i];

      errors.push(...validatePartialUpdateRow(row, rowNumber));

      const query: Record<string, any> = {};
      if (row.id) query._id = row.id;
      else query.sku = row.sku;

      const product = await this.productModel.findOne(query).exec();
      if (!product) {
        errors.push({
          row: rowNumber,
          sheet: 'Products',
          field: row.id ? 'id' : 'sku',
          message: 'Product not found',
          value: row.id || row.sku,
          severity: 'error',
        });
        skipped += 1;
        continue;
      }

      if (row.sku && row.id && String(product._id) !== row.id) {
        errors.push({
          row: rowNumber,
          sheet: 'Products',
          field: 'id',
          message: 'Second verification failed (id + sku mismatch)',
          value: row.id,
          severity: 'error',
        });
        skipped += 1;
        continue;
      }

      const patch: Record<string, any> = {};
      if (row.basePrice !== undefined && row.basePrice !== '') {
        patch.basePrice = parseNumber(row.basePrice);
      }
      if (row.compareAtPrice !== undefined && row.compareAtPrice !== '') {
        patch.compareAtPrice = parseNumber(row.compareAtPrice);
      }
      if (row.costPrice !== undefined && row.costPrice !== '') {
        patch.costPrice = parseNumber(row.costPrice);
      }
      if (row.stockQuantity !== undefined && row.stockQuantity !== '') {
        patch.stockQuantity = parseNumber(row.stockQuantity);
      }
      if (row.lowStockThreshold !== undefined && row.lowStockThreshold !== '') {
        patch.lowStockThreshold = parseNumber(row.lowStockThreshold);
      }
      if (row.status) patch.status = row.status;
      if (row.isActive !== undefined && row.isActive !== '') {
        patch.isActive = parseBoolean(row.isActive);
      }
      if (row.isFeatured !== undefined && row.isFeatured !== '') {
        patch.isFeatured = parseBoolean(row.isFeatured);
      }
      if (row.isNewArrival !== undefined && row.isNewArrival !== '') {
        patch.isNewArrival = parseBoolean(row.isNewArrival);
      }
      if (row.isBestSeller !== undefined && row.isBestSeller !== '') {
        patch.isBestSeller = parseBoolean(row.isBestSeller);
      }

      await this.productModel.updateOne({ _id: product._id }, { $set: patch }).exec();
      updated += 1;
    }

    return buildImportResult({
      total: rows.length,
      updated,
      skipped,
      errors,
    });
  }

  private mapProductRow(row: ProductRow, refs: Awaited<ReturnType<ReferenceResolver['loadAllReferences']>>) {
    const brandId = this.referenceResolver.resolveBrand(row.brandSlug, refs);
    const categoryId = this.referenceResolver.resolveCategory(row.categorySlug, refs);
    const qualityTypeId = this.referenceResolver.resolveQualityType(
      row.qualityTypeSlug,
      refs,
    );

    if (!brandId || !categoryId || !qualityTypeId) {
      throw new BadRequestException('Invalid reference values (brand/category/quality)');
    }

    const additionalCategoryIds = parseStringArray(row.additionalCategorySlugs)
      .map((slug) => this.referenceResolver.resolveCategory(slug, refs))
      .filter(Boolean) as Types.ObjectId[];

    const compatibleDeviceIds = this.referenceResolver.resolveDevices(
      parseStringArray(row.compatibleDevices),
      refs,
    );

    return {
      sku: row.sku,
      name: row.name,
      nameAr: row.nameAr,
      slug: row.slug,
      description: row.description,
      descriptionAr: row.descriptionAr,
      shortDescription: row.shortDescription,
      shortDescriptionAr: row.shortDescriptionAr,
      brandId,
      categoryId,
      additionalCategories: additionalCategoryIds,
      qualityTypeId,
      compatibleDevices: compatibleDeviceIds,
      basePrice: parseNumber(row.basePrice) || 0,
      compareAtPrice: parseNumber(row.compareAtPrice),
      costPrice: parseNumber(row.costPrice),
      stockQuantity: parseNumber(row.stockQuantity) ?? 0,
      lowStockThreshold: parseNumber(row.lowStockThreshold) ?? 5,
      trackInventory:
        row.trackInventory === undefined ? true : parseBoolean(row.trackInventory),
      allowBackorder: parseBoolean((row as any).allowBackorder),
      status: row.status || 'draft',
      isActive: row.isActive === undefined ? true : parseBoolean(row.isActive),
      isFeatured: parseBoolean(row.isFeatured),
      isNewArrival: parseBoolean(row.isNewArrival),
      isBestSeller: parseBoolean(row.isBestSeller),
      mainImage: row.mainImage,
      images: parseStringArray(row.images),
      video: row.video,
      specifications: safeJsonParse(row.specifications),
      weight: parseNumber(row.weight),
      dimensions: row.dimensions,
      color: row.color,
      tags: parseStringArray(row.tags),
      warrantyDays: parseNumber(row.warrantyDays),
      warrantyDescription: row.warrantyDescription,
      metaTitle: row.metaTitle,
      metaTitleAr: row.metaTitleAr,
      metaDescription: row.metaDescription,
      metaDescriptionAr: row.metaDescriptionAr,
      metaKeywords: parseStringArray(row.metaKeywords),
    };
  }

  private async processCompatibilityRows(
    rows: DeviceCompatibilityRow[],
    errors: ValidationError[],
  ): Promise<void> {
    if (!rows.length) return;

    const refs = await this.referenceResolver.loadAllReferences();

    for (let i = 0; i < rows.length; i += 1) {
      const row = rows[i];
      const rowNumber = i + 2;
      const product = await this.productModel.findOne({ sku: row.productSku }).exec();
      const deviceId = this.referenceResolver.resolveDevice(row.deviceSlug, refs);

      if (!product) {
        errors.push({
          row: rowNumber,
          sheet: 'DeviceCompatibility',
          field: 'productSku',
          message: `Product not found: ${row.productSku}`,
          value: row.productSku,
          severity: 'error',
        });
        continue;
      }

      if (!deviceId) {
        errors.push({
          row: rowNumber,
          sheet: 'DeviceCompatibility',
          field: 'deviceSlug',
          message: `Device not found: ${row.deviceSlug}`,
          value: row.deviceSlug,
          severity: 'error',
        });
        continue;
      }

      await this.compatibilityModel
        .updateOne(
          { productId: product._id, deviceId },
          {
            $set: {
              isVerified: parseBoolean(row.isVerified),
              compatibilityNotes: row.compatibilityNotes,
            },
          },
          { upsert: true },
        )
        .exec();
    }
  }

  private buildProductsSheet(workbook: ExcelJS.Workbook, products: any[]) {
    const ws = workbook.addWorksheet('Products');
    ws.addRow(PRODUCT_HEADERS as unknown as string[]);
    ws.getRow(1).font = { bold: true };

    for (const p of products) {
      ws.addRow([
        stringifyId(p._id),
        p.sku || '',
        p.name || '',
        p.nameAr || '',
        p.slug || '',
        p.brandId?.slug || '',
        p.categoryId?.slug || '',
        (p.additionalCategories || []).map((c: any) => c.slug).join(','),
        p.qualityTypeId?.code || '',
        p.basePrice ?? '',
        p.compareAtPrice ?? '',
        p.costPrice ?? '',
        p.stockQuantity ?? '',
        p.lowStockThreshold ?? '',
        p.trackInventory ?? '',
        p.allowBackorder ?? '',
        p.status || '',
        p.isActive ?? '',
        p.isFeatured ?? '',
        p.isNewArrival ?? '',
        p.isBestSeller ?? '',
        p.description || '',
        p.descriptionAr || '',
        p.shortDescription || '',
        p.shortDescriptionAr || '',
        p.mainImage || '',
        (p.images || []).join(','),
        p.video || '',
        p.specifications ? JSON.stringify(p.specifications) : '',
        p.weight ?? '',
        p.dimensions || '',
        p.color || '',
        (p.tags || []).join(','),
        p.warrantyDays ?? '',
        p.warrantyDescription || '',
        p.metaTitle || '',
        p.metaTitleAr || '',
        p.metaDescription || '',
        p.metaDescriptionAr || '',
        (p.metaKeywords || []).join(','),
        (p.compatibleDevices || []).map((d: any) => d.slug).join(','),
      ]);
    }
  }

  private async buildReferencesSheets(
    workbook: ExcelJS.Workbook,
    onlyHeaders: boolean,
  ): Promise<void> {
    const brandsWs = workbook.addWorksheet('Brands');
    brandsWs.addRow(['slug', 'name', 'nameAr', 'isActive']);
    brandsWs.getRow(1).font = { bold: true };

    const categoriesWs = workbook.addWorksheet('Categories');
    categoriesWs.addRow(['slug', 'name', 'nameAr', 'parentSlug', 'level', 'isActive']);
    categoriesWs.getRow(1).font = { bold: true };

    const devicesWs = workbook.addWorksheet('Devices');
    devicesWs.addRow(['slug', 'name', 'nameAr', 'brandSlug', 'isActive']);
    devicesWs.getRow(1).font = { bold: true };

    const qualityWs = workbook.addWorksheet('QualityTypes');
    qualityWs.addRow(['code', 'name', 'nameAr', 'isActive']);
    qualityWs.getRow(1).font = { bold: true };

    if (onlyHeaders) return;

    const refs = await this.referenceResolver.getReferenceData();

    refs.brands.forEach((b: any) => {
      brandsWs.addRow([b.slug, b.name, b.nameAr, b.isActive]);
    });

    const catById = new Map(
      refs.categories.map((c: any) => [String(c._id), c.slug]),
    );
    refs.categories.forEach((c: any) => {
      categoriesWs.addRow([
        c.slug,
        c.name,
        c.nameAr,
        c.parentId ? catById.get(String(c.parentId)) || '' : '',
        c.level || 0,
        c.isActive,
      ]);
    });

    const brandById = new Map(refs.brands.map((b: any) => [String(b._id), b.slug]));
    refs.devices.forEach((d: any) => {
      devicesWs.addRow([
        d.slug,
        d.name,
        d.nameAr,
        brandById.get(String(d.brandId)) || '',
        d.isActive,
      ]);
    });

    refs.qualityTypes.forEach((q: any) => {
      qualityWs.addRow([q.code, q.name, q.nameAr, q.isActive]);
    });
  }

  private buildCompatibilitySheet(workbook: ExcelJS.Workbook, rows: any[]) {
    const ws = workbook.addWorksheet('DeviceCompatibility');
    ws.addRow(['productSku', 'deviceSlug', 'isVerified', 'compatibilityNotes']);
    ws.getRow(1).font = { bold: true };

    for (const row of rows) {
      ws.addRow([
        row.productId?.sku || '',
        row.deviceId?.slug || '',
        row.isVerified ?? false,
        row.compatibilityNotes || '',
      ]);
    }
  }

  private readSheetRows<T extends Record<string, any>>(
    workbook: ExcelJS.Workbook,
    sheetName: string,
    required: boolean = true,
  ): T[] {
    const ws = workbook.getWorksheet(sheetName);
    if (!ws) {
      if (required) {
        throw new NotFoundException(`Sheet '${sheetName}' not found in workbook`);
      }
      return [];
    }

    const headerMap = this.getHeaderMap(ws);
    const results: T[] = [];

    ws.eachRow((row, rowNumber) => {
      if (rowNumber === 1) return;
      const output: Record<string, any> = {};
      for (const [header, idx] of headerMap.entries()) {
        output[header] = row.getCell(idx).value as any;
      }

      const hasValue = Object.values(output).some(
        (v) => v !== null && v !== undefined && String(v).trim() !== '',
      );
      if (hasValue) {
        results.push(normalizeCellValues(output) as T);
      }
    });

    return results;
  }

  private getHeaderMap(ws: ExcelJS.Worksheet): Map<string, number> {
    const map = new Map<string, number>();
    const headerRow = ws.getRow(1);
    headerRow.eachCell((cell, colNumber) => {
      const name = String(cell.value || '').trim();
      if (name) map.set(name, colNumber);
    });
    return map;
  }
}

function normalizeCellValues(row: Record<string, any>): Record<string, any> {
  const output: Record<string, any> = {};
  for (const [k, v] of Object.entries(row)) {
    if (v && typeof v === 'object' && 'text' in (v as any)) {
      output[k] = (v as any).text;
    } else {
      output[k] = v;
    }
  }
  return output;
}

function safeJsonParse(value: any): Record<string, any> | undefined {
  if (!value) return undefined;
  try {
    if (typeof value === 'object') return value;
    return JSON.parse(String(value));
  } catch {
    return undefined;
  }
}

function uniq(values: string[]): string[] {
  return [...new Set(values.map((v) => String(v).trim().toLowerCase()))].filter(
    (v) => v,
  );
}

function hasMissingReferences(refs: {
  brands: string[];
  categories: string[];
  qualityTypes: string[];
  devices: string[];
}) {
  return (
    refs.brands.length > 0 ||
    refs.categories.length > 0 ||
    refs.qualityTypes.length > 0 ||
    refs.devices.length > 0
  );
}

function stringifyId(value: any): string {
  if (!value) return '';
  return String(value);
}

interface UploadedExcelFile {
  buffer: Buffer;
  originalname?: string;
  mimetype?: string;
}
