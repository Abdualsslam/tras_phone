import { NestFactory } from '@nestjs/core';
import { getConnectionToken } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import * as ExcelJS from 'exceljs';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { AppModule } from '../app.module';

type ProductInput = {
  sku: string;
  name: string;
  nameAr: string;
  slug: string;
  brandSlug: string;
  categorySlug: string;
  qualityTypeSlug: string;
  basePrice?: number;
  shortDescription?: string;
  shortDescriptionAr?: string;
  mainImage?: string;
  warrantyDays?: number;
  warrantyDescription?: string;
  compatibleDevicesRaw?: string;
};

function normalizeHeader(value: unknown): string {
  return String(value ?? '')
    .trim()
    .toLowerCase();
}

function normalizeText(value: unknown): string {
  return String(value ?? '')
    .trim()
    .replace(/\s+/g, ' ');
}

function normalizeLoose(value: unknown): string {
  return String(value ?? '')
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^\p{L}\p{N}]+/gu, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function slugify(value: unknown): string {
  return String(value ?? '')
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}

function toNumber(value: unknown): number | undefined {
  if (value === null || value === undefined || value === '') return undefined;
  const num = Number(value);
  if (!Number.isFinite(num)) return undefined;
  return num;
}

function toInt(value: unknown): number | undefined {
  const num = toNumber(value);
  if (num === undefined) return undefined;
  return Math.round(num);
}

function getCellValue(row: ExcelJS.Row, index?: number): unknown {
  if (!index) return undefined;
  const value = row.getCell(index).value as any;
  if (value && typeof value === 'object' && 'text' in value) {
    return value.text;
  }
  return value;
}

async function readProducts(filePath: string): Promise<ProductInput[]> {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.readFile(filePath);
  const ws = workbook.worksheets[0];
  if (!ws) return [];

  const headerMap = new Map<string, number>();
  ws.getRow(1).eachCell((cell, col) => {
    const key = normalizeHeader(cell.value);
    if (key) headerMap.set(key, col);
  });

  const rows: ProductInput[] = [];
  ws.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;

    const sku = normalizeText(getCellValue(row, headerMap.get('sku')));
    const name = normalizeText(getCellValue(row, headerMap.get('name')));
    const nameArRaw = normalizeText(getCellValue(row, headerMap.get('namear')));
    const slugRaw = normalizeText(getCellValue(row, headerMap.get('slug')));
    const brandSlug = normalizeText(
      getCellValue(row, headerMap.get('brandslug')),
    ).toLowerCase();
    const categorySlug = normalizeText(
      getCellValue(row, headerMap.get('categoryslug')),
    ).toLowerCase();
    const qualityTypeSlug = normalizeText(
      getCellValue(row, headerMap.get('qualitytypeslug')),
    ).toLowerCase();

    if (!sku || !name || !slugRaw || !brandSlug || !categorySlug || !qualityTypeSlug) {
      return;
    }

    rows.push({
      sku,
      name,
      nameAr: nameArRaw || name,
      slug: slugRaw.toLowerCase(),
      brandSlug,
      categorySlug,
      qualityTypeSlug,
      basePrice: toNumber(getCellValue(row, headerMap.get('baseprice'))),
      shortDescription: normalizeText(
        getCellValue(row, headerMap.get('shortdescription')),
      ),
      shortDescriptionAr: normalizeText(
        getCellValue(row, headerMap.get('shortdescriptionar')),
      ),
      mainImage: normalizeText(getCellValue(row, headerMap.get('mainimage'))),
      warrantyDays: toInt(getCellValue(row, headerMap.get('warrantydays'))),
      warrantyDescription: normalizeText(
        getCellValue(row, headerMap.get('warrantydescription')),
      ),
      compatibleDevicesRaw: normalizeText(
        getCellValue(row, headerMap.get('compatibledevices')),
      ),
    });
  });

  return rows;
}

function buildUniqueSlug(
  baseSlug: string,
  sku: string,
  slugOwnerBySku: Map<string, string>,
): string {
  const ownerCanUse = (candidate: string) => {
    const owner = slugOwnerBySku.get(candidate);
    return !owner || owner === sku;
  };

  let slug = baseSlug || slugify(sku) || `product-${Date.now()}`;
  if (ownerCanUse(slug)) {
    slugOwnerBySku.set(slug, sku);
    return slug;
  }

  const suffix = slugify(sku) || 'sku';
  slug = `${baseSlug}-${suffix}`;
  if (ownerCanUse(slug)) {
    slugOwnerBySku.set(slug, sku);
    return slug;
  }

  let i = 2;
  let candidate = `${slug}-${i}`;
  while (!ownerCanUse(candidate)) {
    i += 1;
    candidate = `${slug}-${i}`;
  }
  slugOwnerBySku.set(candidate, sku);
  return candidate;
}

async function ensureBrandsAndCategories(
  connection: Connection,
  rows: ProductInput[],
) {
  const brandsCollection = connection.collection('brands');
  const categoriesCollection = connection.collection('categories');
  const now = new Date();

  const brandSlugs = [...new Set(rows.map((r) => r.brandSlug))];
  const categorySlugs = [...new Set(rows.map((r) => r.categorySlug))];

  const existingBrands = await brandsCollection
    .find({ slug: { $in: brandSlugs } }, { projection: { slug: 1 } })
    .toArray();
  const existingBrandSet = new Set(existingBrands.map((b) => String(b.slug)));

  const missingBrands = brandSlugs.filter((slug) => !existingBrandSet.has(slug));
  if (missingBrands.length) {
    await brandsCollection.insertMany(
      missingBrands.map((slug) => ({
        slug,
        name: slug
          .split('-')
          .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
          .join(' '),
        nameAr: slug
          .split('-')
          .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
          .join(' '),
        isActive: true,
        isFeatured: false,
        displayOrder: 0,
        productsCount: 0,
        createdAt: now,
        updatedAt: now,
      })),
    );
  }

  const existingCategories = await categoriesCollection
    .find({ slug: { $in: categorySlugs } }, { projection: { slug: 1 } })
    .toArray();
  const existingCategorySet = new Set(
    existingCategories.map((c) => String(c.slug)),
  );

  const missingCategories = categorySlugs.filter(
    (slug) => !existingCategorySet.has(slug),
  );
  if (missingCategories.length) {
    await categoriesCollection.insertMany(
      missingCategories.map((slug) => {
        const name = slug
          .split('-')
          .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
          .join(' ');

        return {
          slug,
          name,
          nameAr: name,
          parentId: null,
          ancestors: [],
          level: 0,
          path: slug,
          isActive: true,
          isFeatured: false,
          displayOrder: 0,
          productsCount: 0,
          childrenCount: 0,
          createdAt: now,
          updatedAt: now,
        };
      }),
    );
  }

  return {
    createdBrands: missingBrands.length,
    createdCategories: missingCategories.length,
  };
}

function buildDeviceMatchers(deviceDocs: any[]) {
  const bySlug = new Map<string, any>();
  const byLooseName = new Map<string, any>();
  const byModelToken = new Map<string, any>();
  const modelTokenCount = new Map<string, number>();

  for (const doc of deviceDocs) {
    const id = doc._id;
    const slug = normalizeText(doc.slug).toLowerCase();
    if (slug) bySlug.set(slug, id);

    const name = normalizeLoose(doc.name);
    if (name) byLooseName.set(name, id);

    const nameAr = normalizeLoose(doc.nameAr);
    if (nameAr) byLooseName.set(nameAr, id);

    const tokens = String(doc.name || '')
      .toUpperCase()
      .match(/[A-Z0-9+]{3,}/g);

    if (!tokens) continue;
    for (const token of tokens) {
      if (!/[0-9]/.test(token)) continue;
      modelTokenCount.set(token, (modelTokenCount.get(token) || 0) + 1);
      if (!byModelToken.has(token)) {
        byModelToken.set(token, id);
      }
    }
  }

  const uniqueModelTokenMap = new Map<string, any>();
  for (const [token, count] of modelTokenCount.entries()) {
    if (count === 1) {
      uniqueModelTokenMap.set(token, byModelToken.get(token));
    }
  }

  return { bySlug, byLooseName, uniqueModelTokenMap };
}

function resolveDeviceId(
  token: string,
  matchers: ReturnType<typeof buildDeviceMatchers>,
): any | undefined {
  const raw = normalizeText(token);
  if (!raw) return undefined;

  const lowerRaw = raw.toLowerCase();
  if (matchers.bySlug.has(lowerRaw)) return matchers.bySlug.get(lowerRaw);

  const slug = slugify(raw);
  if (slug && matchers.bySlug.has(slug)) return matchers.bySlug.get(slug);

  const loose = normalizeLoose(raw);
  if (loose && matchers.byLooseName.has(loose)) return matchers.byLooseName.get(loose);

  const modelTokens = raw.toUpperCase().match(/[A-Z0-9+]{3,}/g) || [];
  for (const t of modelTokens) {
    if (!/[0-9]/.test(t)) continue;
    if (matchers.uniqueModelTokenMap.has(t)) {
      return matchers.uniqueModelTokenMap.get(t);
    }
  }

  return undefined;
}

async function importProducts(connection: Connection, rows: ProductInput[]) {
  const productsCollection = connection.collection('products');
  const brandsCollection = connection.collection('brands');
  const categoriesCollection = connection.collection('categories');
  const qualityTypesCollection = connection.collection('quality_types');
  const devicesCollection = connection.collection('devices');
  const now = new Date();

  const [brandDocs, categoryDocs, qualityDocs, deviceDocs] = await Promise.all([
    brandsCollection.find({}, { projection: { slug: 1 } }).toArray(),
    categoriesCollection.find({}, { projection: { slug: 1 } }).toArray(),
    qualityTypesCollection.find({}, { projection: { code: 1 } }).toArray(),
    devicesCollection
      .find({}, { projection: { slug: 1, name: 1, nameAr: 1 } })
      .toArray(),
  ]);

  const brandIdBySlug = new Map(brandDocs.map((d) => [String(d.slug), d._id]));
  const categoryIdBySlug = new Map(
    categoryDocs.map((d) => [String(d.slug), d._id]),
  );
  const qualityIdByCode = new Map(
    qualityDocs.map((d) => [String(d.code), d._id]),
  );
  const deviceMatchers = buildDeviceMatchers(deviceDocs);

  const existingProducts = await productsCollection
    .find({}, { projection: { sku: 1, slug: 1 } })
    .toArray();
  const existingBySku = new Map(existingProducts.map((p) => [String(p.sku), p]));
  const slugOwnerBySku = new Map(
    existingProducts.map((p) => [String(p.slug), String(p.sku)]),
  );

  const unresolvedDeviceTokens = new Map<string, number>();
  const skippedRows: Array<{ sku: string; reason: string }> = [];

  const ops: any[] = [];
  let created = 0;
  let updated = 0;

  for (const row of rows) {
    const brandId = brandIdBySlug.get(row.brandSlug);
    const categoryId = categoryIdBySlug.get(row.categorySlug);
    const qualityTypeId = qualityIdByCode.get(row.qualityTypeSlug);

    if (!brandId || !categoryId || !qualityTypeId) {
      skippedRows.push({
        sku: row.sku,
        reason: `Missing reference brand/category/quality (${row.brandSlug}/${row.categorySlug}/${row.qualityTypeSlug})`,
      });
      continue;
    }

    const existing = existingBySku.get(row.sku);
    const baseSlug = slugify(row.slug) || slugify(row.name) || slugify(row.sku);

    const currentSlug = existing ? String(existing.slug) : undefined;
    const preferredBase =
      currentSlug && currentSlug === baseSlug ? currentSlug : baseSlug;
    const finalSlug = buildUniqueSlug(preferredBase, row.sku, slugOwnerBySku);

    const compatibleDeviceIds: any[] = [];
    const deviceSet = new Set<string>();
    const tokens = String(row.compatibleDevicesRaw || '')
      .split(',')
      .map((s) => normalizeText(s))
      .filter(Boolean);

    for (const token of tokens) {
      const deviceId = resolveDeviceId(token, deviceMatchers);
      if (!deviceId) {
        unresolvedDeviceTokens.set(token, (unresolvedDeviceTokens.get(token) || 0) + 1);
        continue;
      }
      const idStr = String(deviceId);
      if (deviceSet.has(idStr)) continue;
      deviceSet.add(idStr);
      compatibleDeviceIds.push(deviceId);
    }

    const productDoc = {
      sku: row.sku,
      name: row.name,
      nameAr: row.nameAr || row.name,
      slug: finalSlug,
      shortDescription: row.shortDescription || undefined,
      shortDescriptionAr: row.shortDescriptionAr || undefined,
      brandId,
      categoryId,
      additionalCategories: [],
      qualityTypeId,
      compatibleDevices: compatibleDeviceIds,
      basePrice: row.basePrice ?? 0,
      stockQuantity: 0,
      lowStockThreshold: 5,
      trackInventory: true,
      allowBackorder: false,
      status: 'active',
      isActive: true,
      isFeatured: false,
      isNewArrival: false,
      isBestSeller: false,
      mainImage: row.mainImage || undefined,
      images: [],
      warrantyDays: row.warrantyDays,
      warrantyDescription: row.warrantyDescription || undefined,
      updatedAt: now,
    };

    ops.push({
      updateOne: {
        filter: { sku: row.sku },
        update: {
          $set: productDoc,
          $setOnInsert: {
            createdAt: now,
          },
        },
        upsert: true,
      },
    });

    if (existing) updated += 1;
    else created += 1;
  }

  if (ops.length) {
    await productsCollection.bulkWrite(ops, { ordered: false });
  }

  return {
    created,
    updated,
    skipped: skippedRows.length,
    unresolvedDeviceTokens,
    skippedRows,
  };
}

async function main() {
  const filePath = resolve(process.argv[2] ?? '../data/products_final.xlsx');
  if (!existsSync(filePath)) {
    throw new Error(`Products file not found: ${filePath}`);
  }

  console.log('Importing products from Excel...');
  console.log(`File: ${filePath}`);

  const rows = await readProducts(filePath);
  console.log(`Parsed product rows: ${rows.length}`);

  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const connection = app.get<Connection>(getConnectionToken());

    const ensureResult = await ensureBrandsAndCategories(connection, rows);
    console.log(
      `Auto-created brands: ${ensureResult.createdBrands}, categories: ${ensureResult.createdCategories}`,
    );

    const result = await importProducts(connection, rows);

    console.log(
      `Products => created: ${result.created}, updated: ${result.updated}, skipped: ${result.skipped}`,
    );

    const reportDir = resolve('../data/import_reports');
    mkdirSync(reportDir, { recursive: true });

    const unresolvedTokens = [...result.unresolvedDeviceTokens.entries()].sort(
      (a, b) => b[1] - a[1],
    );
    const unresolvedCsv = [
      'token,count',
      ...unresolvedTokens.map(([token, count]) => `"${token.replace(/"/g, '""')}",${count}`),
    ].join('\n');
    const unresolvedPath = resolve(
      '../data/import_reports/products_unmatched_devices.csv',
    );
    writeFileSync(unresolvedPath, unresolvedCsv, 'utf8');

    const skippedCsv = [
      'sku,reason',
      ...result.skippedRows.map(
        (r) => `"${r.sku.replace(/"/g, '""')}","${r.reason.replace(/"/g, '""')}"`,
      ),
    ].join('\n');
    const skippedPath = resolve('../data/import_reports/products_skipped_rows.csv');
    writeFileSync(skippedPath, skippedCsv, 'utf8');

    console.log(
      `Unmatched compatible device tokens: ${unresolvedTokens.length} (report: ${unresolvedPath})`,
    );
    console.log(`Skipped rows report: ${skippedPath}`);
    console.log('Done.');
  } finally {
    await app.close();
  }

  process.exit(0);
}

main().catch((error) => {
  console.error('Products import failed:', error?.message || error);
  process.exit(1);
});
