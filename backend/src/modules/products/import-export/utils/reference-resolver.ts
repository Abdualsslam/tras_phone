import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Brand } from '@modules/catalog/schemas/brand.schema';
import { Category } from '@modules/catalog/schemas/category.schema';
import { QualityType } from '@modules/catalog/schemas/quality-type.schema';
import { Device } from '@modules/catalog/schemas/device.schema';

export interface ReferenceMaps {
  brands: Map<string, Types.ObjectId>;
  categories: Map<string, Types.ObjectId>;
  qualityTypes: Map<string, Types.ObjectId>;
  devices: Map<string, Types.ObjectId>;
}

export interface ReferenceData {
  brands: Brand[];
  categories: Category[];
  qualityTypes: QualityType[];
  devices: Device[];
}

export interface MissingReferences {
  brands: string[];
  categories: string[];
  qualityTypes: string[];
  devices: string[];
}

@Injectable()
export class ReferenceResolver {
  private readonly logger = new Logger(ReferenceResolver.name);
  private cache: ReferenceMaps | null = null;
  private cacheTime: number = 0;
  private readonly CACHE_TTL = 5 * 60 * 1000; // 5 minutes

  constructor(
    @InjectModel(Brand.name) private brandModel: Model<Brand>,
    @InjectModel(Category.name) private categoryModel: Model<Category>,
    @InjectModel(QualityType.name) private qualityTypeModel: Model<QualityType>,
    @InjectModel(Device.name) private deviceModel: Model<Device>,
  ) {}

  async loadAllReferences(): Promise<ReferenceMaps> {
    if (this.cache && Date.now() - this.cacheTime < this.CACHE_TTL) {
      return this.cache;
    }

    this.logger.log('Loading all references from database...');

    const [brands, categories, qualityTypes, devices] = await Promise.all([
      this.brandModel.find({ isActive: true }).lean().exec(),
      this.categoryModel.find({ isActive: true }).lean().exec(),
      this.qualityTypeModel.find({ isActive: true }).lean().exec(),
      this.deviceModel.find({ isActive: true }).lean().exec(),
    ]);

    const maps: ReferenceMaps = {
      brands: new Map(brands.map((b) => [b.slug.toLowerCase(), b._id as Types.ObjectId])),
      categories: new Map(categories.map((c) => [c.slug.toLowerCase(), c._id as Types.ObjectId])),
      qualityTypes: new Map(qualityTypes.map((q) => [q.code.toLowerCase(), q._id as Types.ObjectId])),
      devices: new Map(devices.map((d) => [d.slug.toLowerCase(), d._id as Types.ObjectId])),
    };

    this.cache = maps;
    this.cacheTime = Date.now();

    this.logger.log(
      `Loaded references: ${brands.length} brands, ${categories.length} categories, ${qualityTypes.length} quality types, ${devices.length} devices`,
    );

    return maps;
  }

  async getReferenceData(): Promise<ReferenceData> {
    const [brands, categories, qualityTypes, devices] = await Promise.all([
      this.brandModel.find({}).lean().exec(),
      this.categoryModel.find({}).lean().exec(),
      this.qualityTypeModel.find({}).lean().exec(),
      this.deviceModel.find({}).lean().exec(),
    ]);

    return { brands, categories, qualityTypes, devices };
  }

  resolveBrand(slug: string, refs: ReferenceMaps): Types.ObjectId | null {
    return refs.brands.get(slug.toLowerCase()) || null;
  }

  resolveCategory(slug: string, refs: ReferenceMaps): Types.ObjectId | null {
    return refs.categories.get(slug.toLowerCase()) || null;
  }

  resolveQualityType(code: string, refs: ReferenceMaps): Types.ObjectId | null {
    return refs.qualityTypes.get(code.toLowerCase()) || null;
  }

  resolveDevice(slug: string, refs: ReferenceMaps): Types.ObjectId | null {
    return refs.devices.get(slug.toLowerCase()) || null;
  }

  resolveDevices(slugs: string[], refs: ReferenceMaps): Types.ObjectId[] {
    const ids: Types.ObjectId[] = [];
    for (const slug of slugs) {
      const id = this.resolveDevice(slug, refs);
      if (id) ids.push(id);
    }
    return ids;
  }

  async findMissingReferences(
    brandSlugs: string[],
    categorySlugs: string[],
    qualityTypeCodes: string[],
    deviceSlugs: string[],
  ): Promise<MissingReferences> {
    const refs = await this.loadAllReferences();

    const missing: MissingReferences = {
      brands: brandSlugs.filter((s) => !refs.brands.has(s.toLowerCase())),
      categories: categorySlugs.filter((s) => !refs.categories.has(s.toLowerCase())),
      qualityTypes: qualityTypeCodes.filter((s) => !refs.qualityTypes.has(s.toLowerCase())),
      devices: deviceSlugs.filter((s) => !refs.devices.has(s.toLowerCase())),
    };

    // Remove duplicates
    missing.brands = [...new Set(missing.brands)];
    missing.categories = [...new Set(missing.categories)];
    missing.qualityTypes = [...new Set(missing.qualityTypes)];
    missing.devices = [...new Set(missing.devices)];

    return missing;
  }

  clearCache(): void {
    this.cache = null;
    this.cacheTime = 0;
    this.logger.log('Reference cache cleared');
  }
}
