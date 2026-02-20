import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Product, ProductDocument } from '@modules/products/schemas/product.schema';
import {
  EducationalCategory,
  EducationalCategoryDocument,
} from './schemas/educational-category.schema';
import {
  EducationalContent,
  EducationalContentDocument,
  ContentScope,
  ContentTargeting,
  ContentType,
} from './schemas/educational-content.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📚 Educational Content Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class EducationalService {
  constructor(
    @InjectModel(EducationalCategory.name)
    private categoryModel: Model<EducationalCategoryDocument>,
    @InjectModel(EducationalContent.name)
    private contentModel: Model<EducationalContentDocument>,
    @InjectModel(Product.name)
    private productModel: Model<ProductDocument>,
  ) {}

  private toObjectIds(ids?: Types.ObjectId[] | string[]): Types.ObjectId[] {
    if (!Array.isArray(ids)) return [];
    return ids
      .map((id) => id?.toString())
      .filter((id): id is string => Boolean(id) && Types.ObjectId.isValid(id))
      .map((id) => new Types.ObjectId(id));
  }

  private normalizeTargeting(
    targeting?: Partial<ContentTargeting>,
  ): ContentTargeting {
    return {
      products: this.toObjectIds(targeting?.products as Types.ObjectId[]),
      categories: this.toObjectIds(targeting?.categories as Types.ObjectId[]),
      brands: this.toObjectIds(targeting?.brands as Types.ObjectId[]),
      devices: this.toObjectIds(targeting?.devices as Types.ObjectId[]),
      intentTags: Array.isArray(targeting?.intentTags)
        ? targeting!.intentTags
            .map((tag) => tag?.trim().toLowerCase())
            .filter((tag): tag is string => Boolean(tag))
        : [],
    };
  }

  private hasAnyTargeting(
    targeting?: Partial<ContentTargeting>,
    relatedProducts?: Types.ObjectId[] | string[],
  ): boolean {
    return (
      this.toObjectIds(relatedProducts).length > 0 ||
      this.toObjectIds(targeting?.products as Types.ObjectId[]).length > 0 ||
      this.toObjectIds(targeting?.categories as Types.ObjectId[]).length > 0 ||
      this.toObjectIds(targeting?.brands as Types.ObjectId[]).length > 0 ||
      this.toObjectIds(targeting?.devices as Types.ObjectId[]).length > 0 ||
      (targeting?.intentTags?.length ?? 0) > 0
    );
  }

  private validateScopeAndTargeting(
    scope: ContentScope,
    targeting?: Partial<ContentTargeting>,
    relatedProducts?: Types.ObjectId[] | string[],
  ) {
    if (
      scope === ContentScope.CONTEXTUAL &&
      !this.hasAnyTargeting(targeting, relatedProducts)
    ) {
      throw new BadRequestException(
        'Contextual content must include at least one targeting field',
      );
    }
  }

  private calculateContextScore(
    content: any,
    context: {
      productId?: string;
      categoryId?: string;
      brandId?: string;
      deviceId?: string;
      tags?: string[];
    },
  ): number {
    const normalizeIdArray = (ids: any[]): string[] =>
      Array.isArray(ids)
        ? ids
            .map((id) =>
              typeof id === 'object' && id !== null
                ? (id._id?.toString?.() ?? id.toString?.())
                : id?.toString?.(),
            )
            .filter(Boolean)
        : [];

    const targeting = content.targeting || {};
    const directRelatedProducts = normalizeIdArray(content.relatedProducts || []);
    const targetingProducts = normalizeIdArray(targeting.products || []);
    const targetingCategories = normalizeIdArray(targeting.categories || []);
    const targetingBrands = normalizeIdArray(targeting.brands || []);
    const targetingDevices = normalizeIdArray(targeting.devices || []);
    const targetingIntentTags = Array.isArray(targeting.intentTags)
      ? targeting.intentTags.map((tag: string) => tag.toLowerCase())
      : [];

    let score = 0;

    if (
      context.productId &&
      (directRelatedProducts.includes(context.productId) ||
        targetingProducts.includes(context.productId))
    ) {
      score += 100;
    }

    if (context.categoryId && targetingCategories.includes(context.categoryId)) {
      score += 60;
    }

    if (context.brandId && targetingBrands.includes(context.brandId)) {
      score += 45;
    }

    if (context.deviceId && targetingDevices.includes(context.deviceId)) {
      score += 40;
    }

    if (context.tags?.length) {
      const matches = context.tags.filter((tag) =>
        targetingIntentTags.includes(tag.toLowerCase()),
      );
      score += matches.length * 20;
    }

    if (content.isFeatured) {
      score += 10;
    }

    if (content.scope === ContentScope.GENERAL) {
      score += 5;
    }

    return score;
  }

  // ═════════════════════════════════════
  // Categories
  // ═════════════════════════════════════

  async createCategory(
    data: Partial<EducationalCategory>,
  ): Promise<EducationalCategoryDocument> {
    return this.categoryModel.create(data);
  }

  async getCategories(
    activeOnly: boolean = true,
  ): Promise<EducationalCategoryDocument[]> {
    const query = activeOnly ? { isActive: true } : {};
    return this.categoryModel
      .find(query)
      .sort({ sortOrder: 1 })
      .lean() as unknown as Promise<EducationalCategoryDocument[]>;
  }

  async getCategoryBySlug(slug: string): Promise<EducationalCategoryDocument> {
    const category = await this.categoryModel.findOne({ slug, isActive: true });
    if (!category) throw new NotFoundException('Category not found');
    return category;
  }

  async updateCategory(
    id: string,
    data: Partial<EducationalCategory>,
  ): Promise<EducationalCategoryDocument> {
    const category = await this.categoryModel.findByIdAndUpdate(id, data, {
      new: true,
    });
    if (!category) throw new NotFoundException('Category not found');
    return category;
  }

  async deleteCategory(id: string): Promise<void> {
    const result = await this.categoryModel.findByIdAndDelete(id);
    if (!result) throw new NotFoundException('Category not found');
  }

  // ═════════════════════════════════════
  // Content
  // ═════════════════════════════════════

  async createContent(
    data: Partial<EducationalContent>,
    createdBy?: string,
  ): Promise<EducationalContentDocument> {
    const normalizedTargeting = this.normalizeTargeting(data.targeting);
    const scope = data.scope || ContentScope.GENERAL;
    this.validateScopeAndTargeting(scope, normalizedTargeting, data.relatedProducts);

    const content = await this.contentModel.create({
      ...data,
      scope,
      targeting: normalizedTargeting,
      createdBy: createdBy ? new Types.ObjectId(createdBy) : undefined,
    });

    // Update category content count
    await this.categoryModel.findByIdAndUpdate(data.categoryId, {
      $inc: { contentCount: 1 },
    });

    return content;
  }

  async getContent(filters?: {
    categoryId?: string;
    scope?: ContentScope;
    productId?: string;
    type?: ContentType;
    status?: string;
    featured?: boolean;
    search?: string;
    page?: number;
    limit?: number;
  }): Promise<{ data: EducationalContentDocument[]; total: number }> {
    const {
      categoryId,
      scope,
      productId,
      type,
      status = 'published',
      featured,
      search,
      page = 1,
      limit = 20,
    } = filters || {};

    const query: any = {};

    if (categoryId) query.categoryId = new Types.ObjectId(categoryId);
    if (scope) query.scope = scope;
    if (type) query.type = type;
    if (status) query.status = status;
    if (featured !== undefined) query.isFeatured = featured;
    if (search) query.$text = { $search: search };
    if (productId && Types.ObjectId.isValid(productId)) {
      const productObjectId = new Types.ObjectId(productId);
      query.$or = [
        { relatedProducts: productObjectId },
        { 'targeting.products': productObjectId },
      ];
    }

    const [data, total] = await Promise.all([
      this.contentModel
        .find(query)
        .populate('categoryId', 'name nameAr slug')
        .sort({ isFeatured: -1, createdAt: -1 })
        .skip((page - 1) * limit)
        .limit(limit)
        .lean() as unknown as Promise<EducationalContentDocument[]>,
      this.contentModel.countDocuments(query),
    ]);

    return { data, total };
  }

  async getContentBySlug(slug: string): Promise<EducationalContentDocument> {
    const content = await this.contentModel
      .findOne({ slug, status: 'published' })
      .populate('categoryId', 'name nameAr slug')
      .populate('relatedProducts', 'name nameAr slug mainImage basePrice')
      .populate('relatedContent', 'title titleAr slug featuredImage')
      .populate('targeting.products', 'name nameAr slug mainImage basePrice')
      .populate('targeting.categories', 'name nameAr slug')
      .populate('targeting.brands', 'name nameAr slug')
      .populate('targeting.devices', 'name nameAr slug');

    if (!content) throw new NotFoundException('Content not found');

    // Increment view count
    await this.contentModel.findByIdAndUpdate(content._id, {
      $inc: { viewCount: 1 },
    });

    return content;
  }

  async getContentById(id: string): Promise<EducationalContentDocument> {
    const content = await this.contentModel
      .findById(id)
      .populate('categoryId', 'name nameAr slug')
      .populate('targeting.products', 'name nameAr slug')
      .populate('targeting.categories', 'name nameAr slug')
      .populate('targeting.brands', 'name nameAr slug')
      .populate('targeting.devices', 'name nameAr slug');

    if (!content) throw new NotFoundException('Content not found');
    return content;
  }

  async getFeaturedContent(
    limit: number = 6,
  ): Promise<EducationalContentDocument[]> {
    return this.contentModel
      .find({ status: 'published', isFeatured: true })
      .populate('categoryId', 'name nameAr slug')
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean() as unknown as Promise<EducationalContentDocument[]>;
  }

  async getContentByCategory(
    categorySlug: string,
    limit: number = 20,
  ): Promise<EducationalContentDocument[]> {
    const category = await this.getCategoryBySlug(categorySlug);

    return this.contentModel
      .find({ categoryId: category._id, status: 'published' })
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean() as unknown as Promise<EducationalContentDocument[]>;
  }

  async getContentByContext(context: {
    productId?: string;
    categoryId?: string;
    brandId?: string;
    deviceId?: string;
    tags?: string[];
    page?: number;
    limit?: number;
  }): Promise<{ data: EducationalContentDocument[]; total: number }> {
    const page = Math.max(1, context.page || 1);
    const limit = Math.max(1, Math.min(context.limit || 20, 50));

    let resolvedCategoryId = context.categoryId;
    let resolvedBrandId = context.brandId;
    let resolvedDeviceId = context.deviceId;

    if (context.productId && Types.ObjectId.isValid(context.productId)) {
      const product = await this.productModel
        .findById(context.productId)
        .select('categoryId brandId compatibleDevices')
        .lean();

      if (product) {
        resolvedCategoryId ||= product.categoryId?.toString?.();
        resolvedBrandId ||= product.brandId?.toString?.();
        if (!resolvedDeviceId && Array.isArray(product.compatibleDevices)) {
          resolvedDeviceId = product.compatibleDevices[0]?.toString?.();
        }
      }
    }

    const contextTagSet = new Set(
      (context.tags || [])
        .map((tag) => tag.trim().toLowerCase())
        .filter(Boolean),
    );

    const contextQuery: any = {
      status: 'published',
      $or: [{ scope: ContentScope.GENERAL }, { scope: ContentScope.HYBRID }],
    };

    const contextualOrConditions: any[] = [];
    if (context.productId && Types.ObjectId.isValid(context.productId)) {
      const productObjectId = new Types.ObjectId(context.productId);
      contextualOrConditions.push({ relatedProducts: productObjectId });
      contextualOrConditions.push({ 'targeting.products': productObjectId });
    }
    if (resolvedCategoryId && Types.ObjectId.isValid(resolvedCategoryId)) {
      contextualOrConditions.push({
        'targeting.categories': new Types.ObjectId(resolvedCategoryId),
      });
    }
    if (resolvedBrandId && Types.ObjectId.isValid(resolvedBrandId)) {
      contextualOrConditions.push({
        'targeting.brands': new Types.ObjectId(resolvedBrandId),
      });
    }
    if (resolvedDeviceId && Types.ObjectId.isValid(resolvedDeviceId)) {
      contextualOrConditions.push({
        'targeting.devices': new Types.ObjectId(resolvedDeviceId),
      });
    }
    if (contextTagSet.size > 0) {
      contextualOrConditions.push({
        'targeting.intentTags': { $in: Array.from(contextTagSet) },
      });
    }

    if (contextualOrConditions.length > 0) {
      contextQuery.$or.push(...contextualOrConditions);
    }

    const rawContent = await this.contentModel
      .find(contextQuery)
      .populate('categoryId', 'name nameAr slug')
      .sort({ isFeatured: -1, createdAt: -1 })
      .limit(200)
      .lean();

    const scored = rawContent
      .map((item: any) => ({
        item,
        score: this.calculateContextScore(item, {
          productId: context.productId,
          categoryId: resolvedCategoryId,
          brandId: resolvedBrandId,
          deviceId: resolvedDeviceId,
          tags: Array.from(contextTagSet),
        }),
      }))
      .sort((a, b) => {
        if (b.score !== a.score) return b.score - a.score;
        return (
          new Date(b.item.createdAt).getTime() -
          new Date(a.item.createdAt).getTime()
        );
      });

    const paged = scored
      .slice((page - 1) * limit, page * limit)
      .map((entry) => entry.item) as EducationalContentDocument[];

    return {
      data: paged,
      total: scored.length,
    };
  }

  async updateContent(
    id: string,
    data: Partial<EducationalContent>,
    updatedBy?: string,
  ): Promise<EducationalContentDocument> {
    const existing = await this.contentModel.findById(id).lean();
    if (!existing) throw new NotFoundException('Content not found');

    const mergedScope = data.scope || existing.scope || ContentScope.GENERAL;
    const mergedTargeting = this.normalizeTargeting({
      ...(existing.targeting || {}),
      ...(data.targeting || {}),
    });
    const mergedRelatedProducts =
      data.relatedProducts !== undefined
        ? data.relatedProducts
        : (existing.relatedProducts as Types.ObjectId[]);

    this.validateScopeAndTargeting(
      mergedScope,
      mergedTargeting,
      mergedRelatedProducts,
    );

    const updateData: any = {
      ...data,
      scope: mergedScope,
      targeting: mergedTargeting,
      updatedBy: updatedBy ? new Types.ObjectId(updatedBy) : undefined,
    };

    // Handle publish
    if (data.status === 'published') {
      updateData.publishedAt = new Date();
    }

    const content = await this.contentModel.findByIdAndUpdate(id, updateData, {
      new: true,
    });
    if (!content) throw new NotFoundException('Content not found');
    return content;
  }

  async deleteContent(id: string): Promise<void> {
    const content = await this.contentModel.findById(id);
    if (!content) throw new NotFoundException('Content not found');

    // Update category count
    await this.categoryModel.findByIdAndUpdate(content.categoryId, {
      $inc: { contentCount: -1 },
    });

    await this.contentModel.findByIdAndDelete(id);
  }

  async likeContent(id: string): Promise<void> {
    await this.contentModel.findByIdAndUpdate(id, { $inc: { likeCount: 1 } });
  }

  async shareContent(id: string): Promise<void> {
    await this.contentModel.findByIdAndUpdate(id, { $inc: { shareCount: 1 } });
  }

  // ═════════════════════════════════════
  // Seed
  // ═════════════════════════════════════

  async seedDefaultCategories(): Promise<void> {
    const count = await this.categoryModel.countDocuments();
    if (count > 0) return;

    const categories = [
      {
        name: 'Screen Repair',
        nameAr: 'إصلاح الشاشات',
        slug: 'screen-repair',
        icon: 'smartphone',
        sortOrder: 1,
      },
      {
        name: 'Battery Replacement',
        nameAr: 'تبديل البطاريات',
        slug: 'battery-replacement',
        icon: 'battery',
        sortOrder: 2,
      },
      {
        name: 'Parts Guide',
        nameAr: 'دليل القطع',
        slug: 'parts-guide',
        icon: 'cpu',
        sortOrder: 3,
      },
      {
        name: 'Tools & Equipment',
        nameAr: 'الأدوات والمعدات',
        slug: 'tools-equipment',
        icon: 'tool',
        sortOrder: 4,
      },
      {
        name: 'Tips & Tricks',
        nameAr: 'نصائح وحيل',
        slug: 'tips-tricks',
        icon: 'lightbulb',
        sortOrder: 5,
      },
    ];

    await this.categoryModel.insertMany(categories);
  }
}
