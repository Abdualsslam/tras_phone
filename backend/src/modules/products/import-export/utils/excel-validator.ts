export interface ValidationError {
  row: number;
  sheet: string;
  field: string;
  message: string;
  value?: any;
  severity: 'error' | 'warning';
}

export interface ValidationResult {
  isValid: boolean;
  errors: ValidationError[];
  warnings: ValidationError[];
}

export interface ProductRow {
  id?: string;
  sku: string;
  name: string;
  nameAr: string;
  slug: string;
  brandSlug: string;
  categorySlug: string;
  additionalCategorySlugs?: string;
  qualityTypeSlug: string;
  basePrice: number;
  compareAtPrice?: number;
  costPrice?: number;
  stockQuantity?: number;
  lowStockThreshold?: number;
  trackInventory?: boolean;
  status?: string;
  isActive?: boolean;
  isFeatured?: boolean;
  isNewArrival?: boolean;
  isBestSeller?: boolean;
  description?: string;
  descriptionAr?: string;
  shortDescription?: string;
  shortDescriptionAr?: string;
  mainImage?: string;
  images?: string;
  video?: string;
  specifications?: string;
  weight?: number;
  dimensions?: string;
  color?: string;
  tags?: string;
  warrantyDays?: number;
  warrantyDescription?: string;
  metaTitle?: string;
  metaTitleAr?: string;
  metaDescription?: string;
  metaDescriptionAr?: string;
  metaKeywords?: string;
  compatibleDevices?: string;
}

export interface DeviceCompatibilityRow {
  productSku: string;
  deviceSlug: string;
  isVerified?: boolean;
  compatibilityNotes?: string;
}

const REQUIRED_FIELDS: (keyof ProductRow)[] = ['sku', 'name', 'nameAr', 'slug', 'brandSlug', 'categorySlug', 'qualityTypeSlug', 'basePrice'];

const VALID_STATUSES = ['draft', 'active', 'inactive', 'out_of_stock', 'discontinued'];

const NUMERIC_FIELDS: (keyof ProductRow)[] = ['basePrice', 'compareAtPrice', 'costPrice', 'stockQuantity', 'lowStockThreshold', 'weight', 'warrantyDays'];

const BOOLEAN_FIELDS: (keyof ProductRow)[] = ['trackInventory', 'isActive', 'isFeatured', 'isNewArrival', 'isBestSeller'];

export function validateProductRow(row: ProductRow, rowNumber: number): ValidationError[] {
  const errors: ValidationError[] = [];

  // Check required fields
  for (const field of REQUIRED_FIELDS) {
    const value = row[field];
    if (value === undefined || value === null || value === '') {
      errors.push({
        row: rowNumber,
        sheet: 'Products',
        field,
        message: `Field '${field}' is required`,
        value,
        severity: 'error',
      });
    }
  }

  // Validate SKU format
  if (row.sku && !/^[A-Z0-9\-_]+$/i.test(row.sku)) {
    errors.push({
      row: rowNumber,
      sheet: 'Products',
      field: 'sku',
      message: 'SKU must contain only alphanumeric characters, hyphens, and underscores',
      value: row.sku,
      severity: 'error',
    });
  }

  // Validate slug format
  if (row.slug && !/^[a-z0-9\-]+$/.test(row.slug)) {
    errors.push({
      row: rowNumber,
      sheet: 'Products',
      field: 'slug',
      message: 'Slug must contain only lowercase alphanumeric characters and hyphens',
      value: row.slug,
      severity: 'error',
    });
  }

  // Validate numeric fields
  for (const field of NUMERIC_FIELDS) {
    const value = row[field];
    if (value !== undefined && value !== null && value !== '') {
      const num = Number(value);
      if (isNaN(num)) {
        errors.push({
          row: rowNumber,
          sheet: 'Products',
          field,
          message: `Field '${field}' must be a number`,
          value,
          severity: 'error',
        });
      } else if (num < 0) {
        errors.push({
          row: rowNumber,
          sheet: 'Products',
          field,
          message: `Field '${field}' must be a positive number`,
          value,
          severity: 'warning',
        });
      }
    }
  }

  // Validate basePrice specifically
  if (row.basePrice !== undefined && row.basePrice !== null) {
    const price = Number(row.basePrice);
    if (isNaN(price) || price <= 0) {
      errors.push({
        row: rowNumber,
        sheet: 'Products',
        field: 'basePrice',
        message: 'Base price must be a positive number',
        value: row.basePrice,
        severity: 'error',
      });
    }
  }

  // Validate status
  if (row.status && !VALID_STATUSES.includes(row.status)) {
    errors.push({
      row: rowNumber,
      sheet: 'Products',
      field: 'status',
      message: `Invalid status. Valid values: ${VALID_STATUSES.join(', ')}`,
      value: row.status,
      severity: 'error',
    });
  }

  // Validate boolean fields
  for (const field of BOOLEAN_FIELDS) {
    const value = row[field];
    if (value !== undefined && value !== null && value !== '') {
      const boolVal = String(value).toLowerCase();
      if (!['true', 'false', '1', '0', 'yes', 'no'].includes(boolVal)) {
        errors.push({
          row: rowNumber,
          sheet: 'Products',
          field,
          message: `Field '${field}' must be a boolean (true/false)`,
          value,
          severity: 'warning',
        });
      }
    }
  }

  // Validate JSON fields
  if (row.specifications) {
    try {
      JSON.parse(row.specifications as string);
    } catch {
      errors.push({
        row: rowNumber,
        sheet: 'Products',
        field: 'specifications',
        message: 'Specifications must be valid JSON',
        value: row.specifications,
        severity: 'warning',
      });
    }
  }

  // Validate URLs
  const urlFields = ['mainImage', 'video'] as const;
  for (const field of urlFields) {
    const value = row[field];
    if (value && !isValidUrl(value as string)) {
      errors.push({
        row: rowNumber,
        sheet: 'Products',
        field,
        message: `Field '${field}' must be a valid URL`,
        value,
        severity: 'warning',
      });
    }
  }

  // Validate images (comma-separated URLs)
  if (row.images) {
    const urls = (row.images as string).split(',').map((s) => s.trim());
    for (const url of urls) {
      if (url && !isValidUrl(url)) {
        errors.push({
          row: rowNumber,
          sheet: 'Products',
          field: 'images',
          message: `Invalid image URL: ${url}`,
          value: url,
          severity: 'warning',
        });
      }
    }
  }

  return errors;
}

export function validateDeviceCompatibilityRow(
  row: DeviceCompatibilityRow,
  rowNumber: number,
): ValidationError[] {
  const errors: ValidationError[] = [];

  if (!row.productSku) {
    errors.push({
      row: rowNumber,
      sheet: 'DeviceCompatibility',
      field: 'productSku',
      message: 'Product SKU is required',
      severity: 'error',
    });
  }

  if (!row.deviceSlug) {
    errors.push({
      row: rowNumber,
      sheet: 'DeviceCompatibility',
      field: 'deviceSlug',
      message: 'Device slug is required',
      severity: 'error',
    });
  }

  return errors;
}

export function validatePartialUpdateRow(row: any, rowNumber: number): ValidationError[] {
  const errors: ValidationError[] = [];

  if (!row.sku && !row.id) {
    errors.push({
      row: rowNumber,
      sheet: 'Products',
      field: 'sku',
      message: 'Either SKU or ID is required for partial update',
      severity: 'error',
    });
  }

  // At least one updateable field should be present
  const updateableFields = [
    'basePrice',
    'compareAtPrice',
    'costPrice',
    'stockQuantity',
    'lowStockThreshold',
    'status',
    'isActive',
    'isFeatured',
    'isNewArrival',
    'isBestSeller',
  ];

  const hasUpdateableField = updateableFields.some((f) => row[f] !== undefined && row[f] !== null && row[f] !== '');

  if (!hasUpdateableField) {
    errors.push({
      row: rowNumber,
      sheet: 'Products',
      field: '',
      message: 'At least one updateable field is required',
      severity: 'error',
    });
  }

  return errors;
}

function isValidUrl(str: string): boolean {
  try {
    new URL(str);
    return true;
  } catch {
    return false;
  }
}

export function parseBoolean(value: any): boolean {
  if (typeof value === 'boolean') return value;
  const strVal = String(value).toLowerCase();
  return ['true', '1', 'yes'].includes(strVal);
}

export function parseNumber(value: any): number | undefined {
  if (value === undefined || value === null || value === '') return undefined;
  const num = Number(value);
  return isNaN(num) ? undefined : num;
}

export function parseStringArray(value: any): string[] {
  if (!value) return [];
  if (Array.isArray(value)) return value.map((s) => String(s).trim());
  return String(value)
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s);
}
