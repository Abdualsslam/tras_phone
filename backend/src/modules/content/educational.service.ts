import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  EducationalCategory,
  EducationalCategoryDocument,
} from './schemas/educational-category.schema';
import {
  EducationalContent,
  EducationalContentDocument,
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
    const content = await this.contentModel.create({
      ...data,
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
    type?: ContentType;
    status?: string;
    featured?: boolean;
    search?: string;
    page?: number;
    limit?: number;
  }): Promise<{ data: EducationalContentDocument[]; total: number }> {
    const {
      categoryId,
      type,
      status = 'published',
      featured,
      search,
      page = 1,
      limit = 20,
    } = filters || {};

    const query: any = {};

    if (categoryId) query.categoryId = new Types.ObjectId(categoryId);
    if (type) query.type = type;
    if (status) query.status = status;
    if (featured !== undefined) query.isFeatured = featured;
    if (search) query.$text = { $search: search };

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
      .populate('relatedContent', 'title titleAr slug featuredImage');

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
      .populate('categoryId', 'name nameAr slug');

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

  async updateContent(
    id: string,
    data: Partial<EducationalContent>,
    updatedBy?: string,
  ): Promise<EducationalContentDocument> {
    const updateData: any = {
      ...data,
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
