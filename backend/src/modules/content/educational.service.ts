import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
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
  ) {}

  private toObjectIds(ids?: Types.ObjectId[] | string[]): Types.ObjectId[] {
    if (!Array.isArray(ids)) return [];
    return ids
      .map((id) => id?.toString())
      .filter((id): id is string => Boolean(id) && Types.ObjectId.isValid(id))
      .map((id) => new Types.ObjectId(id));
  }

  private normalizeTargeting(): ContentTargeting {
    return {
      products: [],
      categories: [],
      brands: [],
      devices: [],
      intentTags: [],
    };
  }

  private hasAnyTargeting(relatedProducts?: Types.ObjectId[] | string[]): boolean {
    return this.toObjectIds(relatedProducts).length > 0;
  }

  private validateScopeAndTargeting(
    scope: ContentScope,
    relatedProducts?: Types.ObjectId[] | string[],
  ) {
    if (scope === ContentScope.CONTEXTUAL && !this.hasAnyTargeting(relatedProducts)) {
      throw new BadRequestException(
        'Contextual content must include at least one related product',
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

    const directRelatedProducts = normalizeIdArray(content.relatedProducts || []);

    let score = 0;

    if (context.productId && directRelatedProducts.includes(context.productId)) {
      score += 100;
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
    const normalizedTargeting = this.normalizeTargeting();
    const scope = data.scope || ContentScope.GENERAL;
    this.validateScopeAndTargeting(scope, data.relatedProducts);

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
      query.$or = [{ relatedProducts: productObjectId }];
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

    const contextQuery: any = {
      status: 'published',
      $or: [],
    };

    if (context.productId && Types.ObjectId.isValid(context.productId)) {
      const productObjectId = new Types.ObjectId(context.productId);
      contextQuery.$or.push({ relatedProducts: productObjectId });
    }

    if (contextQuery.$or.length === 0) {
      return { data: [], total: 0 };
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
    const mergedTargeting = this.normalizeTargeting();
    const mergedRelatedProducts =
      data.relatedProducts !== undefined
        ? data.relatedProducts
        : (existing.relatedProducts as Types.ObjectId[]);

    this.validateScopeAndTargeting(mergedScope, mergedRelatedProducts);

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
