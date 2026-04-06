import { NestFactory } from '@nestjs/core';
import { getConnectionToken } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import * as ExcelJS from 'exceljs';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { AppModule } from '../app.module';

type ProductCompatRow = {
  sku: string;
  compatibleDevicesRaw: string;
};

type DeviceRef = {
  slug: string;
  name: string;
  nameAr: string;
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

function getCellValue(row: ExcelJS.Row, index?: number): unknown {
  if (!index) return undefined;
  const value = row.getCell(index).value as any;
  if (value && typeof value === 'object' && 'text' in value) {
    return value.text;
  }
  return value;
}

async function readProductsFinal(filePath: string): Promise<ProductCompatRow[]> {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.readFile(filePath);
  const ws = workbook.worksheets[0];
  if (!ws) return [];

  const headerMap = new Map<string, number>();
  ws.getRow(1).eachCell((cell, col) => {
    const key = normalizeHeader(cell.value);
    if (key) headerMap.set(key, col);
  });

  const skuCol = headerMap.get('sku');
  const compCol = headerMap.get('compatibledevices');
  if (!skuCol || !compCol) {
    throw new Error('products_final.xlsx must contain columns: sku, compatibleDevices');
  }

  const rows: ProductCompatRow[] = [];
  ws.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;
    const sku = normalizeText(getCellValue(row, skuCol));
    if (!sku) return;
    const compatibleDevicesRaw = normalizeText(getCellValue(row, compCol));
    rows.push({ sku, compatibleDevicesRaw });
  });

  return rows;
}

async function readDevices(filePath: string): Promise<DeviceRef[]> {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.readFile(filePath);
  const ws = workbook.worksheets[0];
  if (!ws) return [];

  const headerMap = new Map<string, number>();
  ws.getRow(1).eachCell((cell, col) => {
    const key = normalizeHeader(cell.value);
    if (key) headerMap.set(key, col);
  });

  const slugCol = headerMap.get('slug');
  const nameCol = headerMap.get('name');
  const nameArCol = headerMap.get('namear');
  if (!slugCol || !nameCol) {
    throw new Error('devices.xlsx must contain columns: slug, name');
  }

  const rows: DeviceRef[] = [];
  ws.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;
    const slug = normalizeText(getCellValue(row, slugCol)).toLowerCase();
    if (!slug) return;
    rows.push({
      slug,
      name: normalizeText(getCellValue(row, nameCol)),
      nameAr: normalizeText(getCellValue(row, nameArCol)),
    });
  });
  return rows;
}

function buildMatchers(deviceRefs: DeviceRef[], dbDevices: any[]) {
  const allowedSlugs = new Set(deviceRefs.map((d) => d.slug));

  const bySlug = new Map<string, any>();
  const byLoose = new Map<string, any>();
  const modelTokenToId = new Map<string, any>();
  const modelTokenCount = new Map<string, number>();

  for (const device of dbDevices) {
    const slug = normalizeText(device.slug).toLowerCase();
    if (!slug || !allowedSlugs.has(slug)) continue;

    bySlug.set(slug, device._id);

    const variants = [device.name, device.nameAr];
    for (const variant of variants) {
      const loose = normalizeLoose(variant);
      if (loose) byLoose.set(loose, device._id);

      const tokens = String(variant || '')
        .toUpperCase()
        .match(/[A-Z0-9+]{3,}/g);
      if (!tokens) continue;
      for (const token of tokens) {
        if (!/[0-9]/.test(token)) continue;
        modelTokenCount.set(token, (modelTokenCount.get(token) || 0) + 1);
        if (!modelTokenToId.has(token)) modelTokenToId.set(token, device._id);
      }
    }
  }

  const uniqueModelTokenToId = new Map<string, any>();
  for (const [token, count] of modelTokenCount.entries()) {
    if (count === 1) {
      uniqueModelTokenToId.set(token, modelTokenToId.get(token));
    }
  }

  return { bySlug, byLoose, uniqueModelTokenToId };
}

function resolveDeviceId(token: string, matchers: ReturnType<typeof buildMatchers>) {
  const raw = normalizeText(token);
  if (!raw) return undefined;

  const direct = raw.toLowerCase();
  if (matchers.bySlug.has(direct)) return matchers.bySlug.get(direct);

  const slug = slugify(raw);
  if (slug && matchers.bySlug.has(slug)) return matchers.bySlug.get(slug);

  const loose = normalizeLoose(raw);
  if (loose && matchers.byLoose.has(loose)) return matchers.byLoose.get(loose);

  const tokens = raw.toUpperCase().match(/[A-Z0-9+]{3,}/g) || [];
  for (const t of tokens) {
    if (!/[0-9]/.test(t)) continue;
    if (matchers.uniqueModelTokenToId.has(t)) {
      return matchers.uniqueModelTokenToId.get(t);
    }
  }

  return undefined;
}

async function main() {
  const productsFinalPath = resolve(process.argv[2] ?? '../data/products_final.xlsx');
  const devicesPath = resolve(process.argv[3] ?? '../data/devices.xlsx');

  if (!existsSync(productsFinalPath)) {
    throw new Error(`products_final file not found: ${productsFinalPath}`);
  }
  if (!existsSync(devicesPath)) {
    throw new Error(`devices file not found: ${devicesPath}`);
  }

  const productRows = await readProductsFinal(productsFinalPath);
  const deviceRefs = await readDevices(devicesPath);

  console.log(`Loaded products_final rows: ${productRows.length}`);
  console.log(`Loaded devices refs rows: ${deviceRefs.length}`);

  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const connection = app.get<Connection>(getConnectionToken());
    const productsCollection = connection.collection('products');
    const devicesCollection = connection.collection('devices');

    const dbDevices = await devicesCollection
      .find({}, { projection: { _id: 1, slug: 1, name: 1, nameAr: 1 } })
      .toArray();

    const matchers = buildMatchers(deviceRefs, dbDevices);
    const now = new Date();

    const unresolvedTokenCount = new Map<string, number>();
    const unresolvedSkuRows: string[] = [];
    const updateOps: any[] = [];
    let productsFound = 0;
    let productsMissing = 0;
    let productsWithAnyCompatible = 0;

    for (const row of productRows) {
      const product = await productsCollection.findOne(
        { sku: row.sku },
        { projection: { _id: 1 } },
      );
      if (!product) {
        productsMissing += 1;
        continue;
      }
      productsFound += 1;

      const ids: any[] = [];
      const seenIds = new Set<string>();

      const unresolvedForRow: string[] = [];
      const tokens = String(row.compatibleDevicesRaw || '')
        .split(',')
        .map((x) => normalizeText(x))
        .filter(Boolean);

      for (const token of tokens) {
        const deviceId = resolveDeviceId(token, matchers);
        if (!deviceId) {
          unresolvedTokenCount.set(token, (unresolvedTokenCount.get(token) || 0) + 1);
          unresolvedForRow.push(token);
          continue;
        }

        const idStr = String(deviceId);
        if (seenIds.has(idStr)) continue;
        seenIds.add(idStr);
        ids.push(deviceId);
      }

      if (ids.length > 0) {
        productsWithAnyCompatible += 1;
      }

      if (unresolvedForRow.length > 0) {
        unresolvedSkuRows.push(`${row.sku},"${unresolvedForRow.join(' | ').replace(/"/g, '""')}"`);
      }

      updateOps.push({
        updateOne: {
          filter: { _id: product._id },
          update: {
            $set: {
              compatibleDevices: ids,
              updatedAt: now,
            },
          },
        },
      });
    }

    if (updateOps.length) {
      await productsCollection.bulkWrite(updateOps, { ordered: false });
    }

    const reportsDir = resolve('../data/import_reports');
    mkdirSync(reportsDir, { recursive: true });

    const unresolvedTokenRows = [...unresolvedTokenCount.entries()]
      .sort((a, b) => b[1] - a[1])
      .map(([token, count]) => `"${token.replace(/"/g, '""')}",${count}`);
    writeFileSync(
      resolve('../data/import_reports/compatibility_unmatched_tokens.csv'),
      ['token,count', ...unresolvedTokenRows].join('\n'),
      'utf8',
    );

    writeFileSync(
      resolve('../data/import_reports/compatibility_unmatched_by_sku.csv'),
      ['sku,unmatchedTokens', ...unresolvedSkuRows].join('\n'),
      'utf8',
    );

    const summary = {
      productsInProductsFinal: productRows.length,
      productsFoundInDb: productsFound,
      productsMissingInDb: productsMissing,
      productsWithAnyCompatible,
      unmatchedUniqueTokens: unresolvedTokenCount.size,
    };
    writeFileSync(
      resolve('../data/import_reports/compatibility_sync_summary.json'),
      JSON.stringify(summary, null, 2),
      'utf8',
    );

    console.log(`Products found in DB: ${productsFound}`);
    console.log(`Products missing in DB: ${productsMissing}`);
    console.log(`Products linked to >=1 device: ${productsWithAnyCompatible}`);
    console.log(`Unmatched unique tokens: ${unresolvedTokenCount.size}`);
    console.log(
      `Reports: ${resolve('../data/import_reports/compatibility_unmatched_tokens.csv')}`,
    );
    console.log('Done.');
  } finally {
    await app.close();
  }

  process.exit(0);
}

main().catch((error) => {
  console.error('Compatibility sync failed:', error?.message || error);
  process.exit(1);
});
