import { ValidationError } from './excel-validator';

export interface ImportSummary {
  total: number;
  created: number;
  updated: number;
  skipped: number;
  errors: number;
}

export interface ImportResult {
  success: boolean;
  summary: ImportSummary;
  errors: Array<{
    row: number;
    sheet: string;
    field: string;
    message: string;
    value?: any;
  }>;
  warnings: Array<{
    row: number;
    sheet: string;
    field: string;
    message: string;
  }>;
  missingReferences?: {
    brands: string[];
    categories: string[];
    qualityTypes: string[];
    devices: string[];
  };
}

export function buildImportResult(params: {
  total: number;
  created?: number;
  updated?: number;
  skipped?: number;
  errors?: ValidationError[];
  missingReferences?: ImportResult['missingReferences'];
}): ImportResult {
  const allErrors = params.errors || [];
  const errors = allErrors
    .filter((e) => e.severity === 'error')
    .map((e) => ({
      row: e.row,
      sheet: e.sheet,
      field: e.field,
      message: e.message,
      value: e.value,
    }));

  const warnings = allErrors
    .filter((e) => e.severity === 'warning')
    .map((e) => ({
      row: e.row,
      sheet: e.sheet,
      field: e.field,
      message: e.message,
    }));

  return {
    success: errors.length === 0,
    summary: {
      total: params.total,
      created: params.created || 0,
      updated: params.updated || 0,
      skipped: params.skipped || 0,
      errors: errors.length,
    },
    errors,
    warnings,
    missingReferences: params.missingReferences,
  };
}
