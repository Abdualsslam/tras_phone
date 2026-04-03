import { NestFactory } from '@nestjs/core';
import { getConnectionToken } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import * as ExcelJS from 'exceljs';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { AppModule } from '../app.module';

type BrandRow = {
  slug: string;
  name: string;
  nameAr: string;
  isActive: boolean;
};

type DeviceRow = {
  slug: string;
  name: string;
  nameAr: string;
  brandSlug: string;
  isActive: boolean;
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

function toBoolean(value: unknown, defaultValue: boolean): boolean {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'number') return value !== 0;
  const text = String(value ?? '')
    .trim()
    .toLowerCase();
  if (!text) return defaultValue;
  if (['1', 'true', 'yes', 'y'].includes(text)) return true;
  if (['0', 'false', 'no', 'n'].includes(text)) return false;
  return defaultValue;
}

function getCellValue(row: ExcelJS.Row, index: number | undefined): unknown {
  if (!index) return undefined;
  const value = row.getCell(index).value as any;
  if (value && typeof value === 'object' && 'text' in value) {
    return value.text;
  }
  return value;
}

function getHeaderIndexMap(worksheet: ExcelJS.Worksheet): Map<string, number> {
  const map = new Map<string, number>();
  const headerRow = worksheet.getRow(1);

  headerRow.eachCell((cell, col) => {
    const header = normalizeHeader(cell.value);
    if (header) map.set(header, col);
  });

  return map;
}

async function readBrands(filePath: string): Promise<BrandRow[]> {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.readFile(filePath);
  const worksheet = workbook.worksheets[0];
  if (!worksheet) return [];

  const headers = getHeaderIndexMap(worksheet);
  const rows: BrandRow[] = [];

  worksheet.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;

    const slug = normalizeText(getCellValue(row, headers.get('slug')));
    const name = normalizeText(getCellValue(row, headers.get('name')));
    const nameArRaw = normalizeText(getCellValue(row, headers.get('namear')));
    const isActiveRaw = getCellValue(row, headers.get('isactive'));

    if (!slug || !name) return;

    rows.push({
      slug,
      name,
      nameAr: nameArRaw || name,
      isActive: toBoolean(isActiveRaw, true),
    });
  });

  return rows;
}

async function readDevices(filePath: string): Promise<DeviceRow[]> {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.readFile(filePath);
  const worksheet = workbook.worksheets[0];
  if (!worksheet) return [];

  const headers = getHeaderIndexMap(worksheet);
  const rows: DeviceRow[] = [];

  worksheet.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;

    const slug = normalizeText(getCellValue(row, headers.get('slug')));
    const name = normalizeText(getCellValue(row, headers.get('name')));
    const nameArRaw = normalizeText(getCellValue(row, headers.get('namear')));
    const brandSlug = normalizeText(getCellValue(row, headers.get('brandslug')));
    const isActiveRaw = getCellValue(row, headers.get('isactive'));

    if (!slug || !name || !brandSlug) return;

    rows.push({
      slug,
      name,
      nameAr: nameArRaw || name,
      brandSlug,
      isActive: toBoolean(isActiveRaw, true),
    });
  });

  return rows;
}

async function importBrands(
  connection: Connection,
  brands: BrandRow[],
): Promise<{ created: number; updated: number }> {
  const collection = connection.collection('brands');
  const now = new Date();
  const existing = await collection
    .find(
      { slug: { $in: brands.map((b) => b.slug) } },
      { projection: { slug: 1 } },
    )
    .toArray();
  const existingSlugs = new Set(existing.map((doc) => String(doc.slug)));

  const ops = brands.map((brand) => ({
    updateOne: {
      filter: { slug: brand.slug },
      update: {
        $set: {
          name: brand.name,
          nameAr: brand.nameAr,
          isActive: brand.isActive,
          updatedAt: now,
        },
        $setOnInsert: {
          slug: brand.slug,
          isFeatured: false,
          displayOrder: 0,
          productsCount: 0,
          createdAt: now,
        },
      },
      upsert: true,
    },
  }));

  if (ops.length) {
    await collection.bulkWrite(ops, { ordered: false });
  }

  const updated = brands.filter((b) => existingSlugs.has(b.slug)).length;
  const created = brands.length - updated;
  return { created, updated };
}

async function importDevices(
  connection: Connection,
  devices: DeviceRow[],
): Promise<{ created: number; updated: number; skipped: number }> {
  const brandsCollection = connection.collection('brands');
  const devicesCollection = connection.collection('devices');

  const brandDocs = await brandsCollection.find({}, { projection: { slug: 1 } }).toArray();
  const brandMap = new Map<string, any>();
  for (const doc of brandDocs) {
    if (doc.slug) brandMap.set(String(doc.slug), doc._id);
  }

  const now = new Date();
  const existing = await devicesCollection
    .find(
      { slug: { $in: devices.map((d) => d.slug) } },
      { projection: { slug: 1 } },
    )
    .toArray();
  const existingSlugs = new Set(existing.map((doc) => String(doc.slug)));

  let created = 0;
  let updated = 0;
  let skipped = 0;
  const ops: any[] = [];

  for (const device of devices) {
    const brandId = brandMap.get(device.brandSlug);
    if (!brandId) {
      skipped += 1;
      console.warn(
        `Skipping device '${device.slug}': brandSlug '${device.brandSlug}' not found`,
      );
      continue;
    }

    if (existingSlugs.has(device.slug)) {
      updated += 1;
    } else {
      created += 1;
    }
    ops.push({
      updateOne: {
        filter: { slug: device.slug },
        update: {
          $set: {
            name: device.name,
            nameAr: device.nameAr,
            brandId,
            isActive: device.isActive,
            updatedAt: now,
          },
          $setOnInsert: {
            slug: device.slug,
            isPopular: false,
            displayOrder: 0,
            productsCount: 0,
            createdAt: now,
          },
        },
        upsert: true,
      },
    });
  }

  if (ops.length) {
    await devicesCollection.bulkWrite(ops, { ordered: false });
  }

  return { created, updated, skipped };
}

async function main() {
  const brandsPath = resolve(process.argv[2] ?? '../brands.xlsx');
  const devicesPath = resolve(process.argv[3] ?? '../devices.xlsx');

  if (!existsSync(brandsPath)) {
    throw new Error(`Brands file not found: ${brandsPath}`);
  }
  if (!existsSync(devicesPath)) {
    throw new Error(`Devices file not found: ${devicesPath}`);
  }

  console.log('Importing catalog references from Excel...');
  console.log(`Brands file: ${brandsPath}`);
  console.log(`Devices file: ${devicesPath}`);

  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const connection = app.get<Connection>(getConnectionToken());

    const brands = await readBrands(brandsPath);
    const devices = await readDevices(devicesPath);

    console.log(`Parsed brands rows: ${brands.length}`);
    console.log(`Parsed devices rows: ${devices.length}`);

    const brandsResult = await importBrands(connection, brands);
    console.log(
      `Brands => created: ${brandsResult.created}, updated: ${brandsResult.updated}`,
    );

    const devicesResult = await importDevices(connection, devices);
    console.log(
      `Devices => created: ${devicesResult.created}, updated: ${devicesResult.updated}, skipped: ${devicesResult.skipped}`,
    );

    console.log('Done.');
  } finally {
    await app.close();
  }

  process.exit(0);
}

main().catch((error) => {
  console.error('Import failed:', error?.message || error);
  process.exit(1);
});
