import { NestFactory } from '@nestjs/core';
import { getConnectionToken } from '@nestjs/mongoose';
import { Connection } from 'mongoose';
import * as ExcelJS from 'exceljs';
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { AppModule } from '../app.module';

type QualityTypeRow = {
  code: string;
  name: string;
  nameAr: string;
  isActive: boolean;
  displayOrder: number;
  color?: string;
  defaultWarrantyDays?: number;
};

function normalizeHeader(value: unknown): string {
  return String(value ?? '')
    .trim()
    .toLowerCase()
    .replace(/[\s_\-]+/g, '');
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

function toNumber(value: unknown): number | undefined {
  if (value === null || value === undefined || value === '') return undefined;
  const num = Number(value);
  if (!Number.isFinite(num)) return undefined;
  return num;
}

function getCellValue(row: ExcelJS.Row, index?: number): unknown {
  if (!index) return undefined;
  const value = row.getCell(index).value as any;
  if (value && typeof value === 'object' && 'text' in value) {
    return value.text;
  }
  return value;
}

function getHeaderIndexMap(ws: ExcelJS.Worksheet): Map<string, number> {
  const map = new Map<string, number>();
  ws.getRow(1).eachCell((cell, col) => {
    const header = normalizeHeader(cell.value);
    if (header) map.set(header, col);
  });
  return map;
}

async function readQualityTypes(filePath: string): Promise<QualityTypeRow[]> {
  const workbook = new ExcelJS.Workbook();
  await workbook.xlsx.readFile(filePath);
  const ws = workbook.worksheets[0];
  if (!ws) return [];

  const headers = getHeaderIndexMap(ws);

  const codeCol =
    headers.get('code') ??
    headers.get('qualitytypeslug') ??
    headers.get('qualitytypecode') ??
    3;
  const nameCol = headers.get('name') ?? headers.get('qualitytype') ?? 2;
  const nameArCol = headers.get('namear') ?? headers.get('نوعالجودة') ?? 1;
  const isActiveCol = headers.get('isactive');
  const displayOrderCol = headers.get('displayorder');
  const colorCol = headers.get('color');
  const warrantyCol = headers.get('defaultwarrantydays');

  const rows: QualityTypeRow[] = [];

  ws.eachRow((row, rowNumber) => {
    if (rowNumber === 1) return;

    const code = normalizeText(getCellValue(row, codeCol)).toLowerCase();
    const name = normalizeText(getCellValue(row, nameCol));
    const nameAr = normalizeText(getCellValue(row, nameArCol)) || name;
    if (!code || !name) return;

    rows.push({
      code,
      name,
      nameAr,
      isActive: toBoolean(getCellValue(row, isActiveCol), true),
      displayOrder: toNumber(getCellValue(row, displayOrderCol)) ?? rowNumber - 1,
      color: normalizeText(getCellValue(row, colorCol)) || undefined,
      defaultWarrantyDays: toNumber(getCellValue(row, warrantyCol)),
    });
  });

  return rows;
}

async function importQualityTypes(connection: Connection, rows: QualityTypeRow[]) {
  const collection = connection.collection('quality_types');
  const now = new Date();

  const existing = await collection
    .find(
      { code: { $in: rows.map((r) => r.code) } },
      { projection: { code: 1 } },
    )
    .toArray();
  const existingCodes = new Set(existing.map((doc) => String(doc.code)));

  const ops = rows.map((row) => ({
    updateOne: {
      filter: { code: row.code },
      update: {
        $set: {
          name: row.name,
          nameAr: row.nameAr,
          isActive: row.isActive,
          displayOrder: row.displayOrder,
          ...(row.color ? { color: row.color } : {}),
          ...(typeof row.defaultWarrantyDays === 'number'
            ? { defaultWarrantyDays: row.defaultWarrantyDays }
            : {}),
          updatedAt: now,
        },
        $setOnInsert: {
          code: row.code,
          createdAt: now,
        },
      },
      upsert: true,
    },
  }));

  if (ops.length) {
    await collection.bulkWrite(ops, { ordered: false });
  }

  const updated = rows.filter((r) => existingCodes.has(r.code)).length;
  const created = rows.length - updated;
  return { created, updated };
}

async function main() {
  const filePath = resolve(process.argv[2] ?? '../data/quality_types.xlsx');
  if (!existsSync(filePath)) {
    throw new Error(`Quality types file not found: ${filePath}`);
  }

  console.log('Importing quality types from Excel...');
  console.log(`File: ${filePath}`);

  const app = await NestFactory.createApplicationContext(AppModule, {
    logger: ['error', 'warn'],
  });

  try {
    const connection = app.get<Connection>(getConnectionToken());
    const rows = await readQualityTypes(filePath);
    console.log(`Parsed quality types rows: ${rows.length}`);

    const result = await importQualityTypes(connection, rows);
    console.log(
      `QualityTypes => created: ${result.created}, updated: ${result.updated}`,
    );
    console.log('Done.');
  } finally {
    await app.close();
  }

  process.exit(0);
}

main().catch((error) => {
  console.error('Quality types import failed:', error?.message || error);
  process.exit(1);
});
