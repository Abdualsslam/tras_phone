import { NestFactory } from '@nestjs/core';
import { getConnectionToken } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import * as ExcelJS from 'exceljs';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { AppModule } from '../app.module';

type CategoryRow = {
  slug: string;
  name: string;
  nameAr: string;
  parentSlug: string;
  level: number;
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

function toBoolean(value: unknown, fallback: boolean): boolean {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'number') return value !== 0;
  const text = String(value ?? '')
    .trim()
    .toLowerCase();
  if (!text) return fallback;
  if (['1', 'true', 'yes', 'y'].includes(text)) return true;
  if (['0', 'false', 'no', 'n'].includes(text)) return false;
  return fallback;
}

function toNumber(value: unknown, fallback: number): number {
  if (typeof value === 'number' && !Number.isNaN(value)) return value;
  const parsed = Number(String(value ?? '').trim());
  return Number.isFinite(parsed) ? parsed : fallback;
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
  worksheet.getRow(1).eachCell((cell, col) => {
    const header = normalizeHeader(cell.value);
    if (header) map.set(header, col);
  });
  return map;
}

async function readCategories(filePath: string): Promise<CategoryRow[]> {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.readFile(filePath);
  const worksheet = workbook.worksheets[0];
  if (!worksheet) return [];

  const headers = getHeaderIndexMap(worksheet);
  const rows: CategoryRow[] = [];

  worksheet.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;

    const slug = normalizeText(getCellValue(row, headers.get('slug')));
    const name = normalizeText(getCellValue(row, headers.get('name')));
    const nameArRaw = normalizeText(getCellValue(row, headers.get('namear')));
    const parentSlug = normalizeText(getCellValue(row, headers.get('parentslug')));
    const levelRaw = getCellValue(row, headers.get('level'));
    const isActiveRaw = getCellValue(row, headers.get('isactive'));

    if (!slug || !name) return;

    rows.push({
      slug,
      name,
      nameAr: nameArRaw || name,
      parentSlug,
      level: toNumber(levelRaw, parentSlug ? 1 : 0),
      isActive: toBoolean(isActiveRaw, true),
    });
  });

  return rows;
}

async function importCategories(connection: Connection, rows: CategoryRow[]) {
  const collection = connection.collection('categories');
  const now = new Date();

  const existing = await collection
    .find(
      { slug: { $in: rows.map((r) => r.slug) } },
      { projection: { slug: 1 } },
    )
    .toArray();
  const existingSlugs = new Set(existing.map((doc) => String(doc.slug)));

  const allForParents = await collection
    .find({}, { projection: { slug: 1, _id: 1 } })
    .toArray();
  const parentIdBySlug = new Map<string, any>();
  for (const doc of allForParents) {
    if (doc.slug) parentIdBySlug.set(String(doc.slug), doc._id);
  }

  const roots = rows.filter((r) => !r.parentSlug);
  const children = rows.filter((r) => !!r.parentSlug);

  const upsertBatch = async (batch: CategoryRow[]) => {
    const ops: any[] = [];

    for (const item of batch) {
      const parentId = item.parentSlug ? parentIdBySlug.get(item.parentSlug) : undefined;
      if (item.parentSlug && !parentId) {
        console.warn(
          `Skipping category '${item.slug}': parentSlug '${item.parentSlug}' not found`,
        );
        continue;
      }

      const ancestors = parentId ? [parentId] : [];
      const level = parentId ? Math.max(1, item.level || 1) : 0;
      const path = item.parentSlug && parentId ? `${item.parentSlug}/${item.slug}` : item.slug;

      ops.push({
        updateOne: {
          filter: { slug: item.slug },
          update: {
            $set: {
              name: item.name,
              nameAr: item.nameAr,
              parentId: parentId ?? null,
              ancestors,
              level,
              path,
              isActive: item.isActive,
              updatedAt: now,
            },
            $setOnInsert: {
              slug: item.slug,
              isFeatured: false,
              displayOrder: 0,
              productsCount: 0,
              childrenCount: 0,
              createdAt: now,
            },
          },
          upsert: true,
        },
      });
    }

    if (ops.length) {
      await collection.bulkWrite(ops, { ordered: false });
    }
  };

  await upsertBatch(roots);

  const refreshed = await collection
    .find({}, { projection: { slug: 1, _id: 1 } })
    .toArray();
  parentIdBySlug.clear();
  for (const doc of refreshed) {
    if (doc.slug) parentIdBySlug.set(String(doc.slug), doc._id);
  }

  await upsertBatch(children);

  const updated = rows.filter((r) => existingSlugs.has(r.slug)).length;
  const created = rows.length - updated;
  return { created, updated };
}

async function main() {
  const categoriesPath = resolve(process.argv[2] ?? '../categories.xlsx');
  if (!existsSync(categoriesPath)) {
    throw new Error(`Categories file not found: ${categoriesPath}`);
  }

  console.log('Importing categories from Excel...');
  console.log(`Categories file: ${categoriesPath}`);

  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const connection = app.get<Connection>(getConnectionToken());
    const rows = await readCategories(categoriesPath);
    console.log(`Parsed categories rows: ${rows.length}`);

    const result = await importCategories(connection, rows);
    console.log(`Categories => created: ${result.created}, updated: ${result.updated}`);
    console.log('Done.');
  } finally {
    await app.close();
  }

  process.exit(0);
}

main().catch((error) => {
  console.error('Categories import failed:', error?.message || error);
  process.exit(1);
});
