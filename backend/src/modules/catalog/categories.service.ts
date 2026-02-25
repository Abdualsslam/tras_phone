import { Injectable, NotFoundException, ConflictException, Inject, forwardRef } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Category, CategoryDocument } from './schemas/category.schema';
import { ProductsService } from '@modules/products/products.service';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📂 Categories Service (Hierarchical)
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class CategoriesService {
    constructor(
        @InjectModel(Category.name)
        private categoryModel: Model<CategoryDocument>,
        @InjectModel('Product')
        private productModel: Model<any>,
        @Inject(forwardRef(() => ProductsService))
        private productsService: ProductsService,
    ) { }

    private readMediaUrl(value: unknown): string | undefined {
        if (typeof value === 'string') {
            const trimmed = value.trim();
            return trimmed.length > 0 ? trimmed : undefined;
        }

        if (value && typeof value === 'object') {
            const candidate =
                (value as any).url ??
                (value as any).secureUrl ??
                (value as any).secure_url ??
                (value as any).path ??
                (value as any).src;

            return this.readMediaUrl(candidate);
        }

        return undefined;
    }

    private normalizeCategory(category: any): any {
        const image =
            this.readMediaUrl(category?.image) ??
            this.readMediaUrl(category?.imageUrl) ??
            this.readMediaUrl(category?.icon);

        return {
            ...category,
            image: image ?? null,
            imageUrl: image ?? null,
        };
    }

    private normalizeCategoryInput(data: any): any {
        if (!data || typeof data !== 'object') {
            return data;
        }

        const normalized = { ...data };
        const image =
            this.readMediaUrl(normalized.image) ??
            this.readMediaUrl(normalized.imageUrl) ??
            this.readMediaUrl(normalized.icon);

        if (image) {
            normalized.image = image;
        }

        return normalized;
    }

    /**
     * Create category
     */
    async create(data: any): Promise<CategoryDocument> {
        const normalizedData = this.normalizeCategoryInput(data);

        // Check slug uniqueness
        const existing = await this.categoryModel.findOne({ slug: normalizedData.slug });
        if (existing) {
            throw new ConflictException('Category with this slug already exists');
        }

        let ancestors: any[] = [];
        let level = 0;
        let path = normalizedData.slug;

        // If has parent, build hierarchy
        if (normalizedData.parentId) {
            const parent = await this.categoryModel.findById(normalizedData.parentId);
            if (!parent) {
                throw new NotFoundException('Parent category not found');
            }

            ancestors = [...parent.ancestors, parent._id];
            level = parent.level + 1;
            path = `${parent.path}/${normalizedData.slug}`;

            // Update parent's children count
            await this.categoryModel.findByIdAndUpdate(normalizedData.parentId, {
                $inc: { childrenCount: 1 },
            });
        }

        const category = await this.categoryModel.create({
            ...normalizedData,
            ancestors,
            level,
            path,
        });

        return this.normalizeCategory(category.toObject()) as any;
    }

    /**
     * Get all root categories
     */
    async findRoots(): Promise<any[]> {
        const categories = await this.categoryModel
            .find({ parentId: null, isActive: true })
            .sort({ displayOrder: 1, name: 1 })
            .lean();

        return categories.map((category) => this.normalizeCategory(category));
    }

    /**
     * Get children of a category
     */
    async findChildren(parentId: string): Promise<any[]> {
        const categories = await this.categoryModel
            .find({ parentId, isActive: true })
            .sort({ displayOrder: 1, name: 1 })
            .lean();

        return categories.map((category) => this.normalizeCategory(category));
    }

    /**
     * Get full tree
     */
    async getTree(): Promise<any[]> {
        const categories = await this.categoryModel
            .find({ isActive: true })
            .sort({ level: 1, displayOrder: 1 })
            .lean();

        // Get product counts per category
        const productCounts = await this.productModel.aggregate([
            { $match: { status: { $in: ['active', 'draft'] } } },
            { $group: { _id: '$categoryId', count: { $sum: 1 } } },
        ]);

        // Create a map of category ID to product count
        const countMap = new Map<string, number>();
        productCounts.forEach((item: any) => {
            if (item._id) {
                countMap.set(item._id.toString(), item.count);
            }
        });

        // Add product count to each category
        const categoriesWithCount = categories.map((cat: any) =>
            this.normalizeCategory({
                ...cat,
                productsCount: countMap.get(cat._id.toString()) || 0,
            }),
        );

        return this.buildTree(categoriesWithCount);
    }

    /**
     * Build tree structure from flat array
     */
    private buildTree(categories: any[]): any[] {
        const map = new Map();
        const roots: any[] = [];

        // Create map
        categories.forEach((cat) => {
            map.set(cat._id.toString(), { ...cat, children: [] });
        });

        // Build tree
        categories.forEach((cat) => {
            const node = map.get(cat._id.toString());
            if (cat.parentId) {
                const parent = map.get(cat.parentId.toString());
                if (parent) {
                    parent.children.push(node);
                }
            } else {
                roots.push(node);
            }
        });

        return roots;
    }

    /**
     * Find category by ID or slug
     */
    async findByIdOrSlug(identifier: string): Promise<CategoryDocument> {
        const query = Types.ObjectId.isValid(identifier)
            ? { _id: identifier }
            : { slug: identifier };

        const category = await this.categoryModel.findOne(query);
        if (!category) {
            throw new NotFoundException('Category not found');
        }

        return category;
    }

    /**
     * Get all descendant category IDs (recursive)
     * Uses ancestors array to find all nested descendants efficiently
     */
    async getAllDescendantIds(categoryId: string): Promise<string[]> {
        const categoryIds: string[] = [categoryId];
        const categoryObjectId = new Types.ObjectId(categoryId);
        
        // Get all categories that have this category in their ancestors array
        // This includes all nested descendants (children, grandchildren, etc.)
        const descendants = await this.categoryModel.find({
            ancestors: categoryObjectId,
            isActive: true,
        }).select('_id').lean();

        descendants.forEach((desc: any) => {
            categoryIds.push(desc._id.toString());
        });

        return categoryIds;
    }

    /**
     * Get category with ancestors (breadcrumb)
     */
    async findWithBreadcrumb(id: string): Promise<{
        category: any;
        breadcrumb: any[];
    }> {
        const category = await this.categoryModel.findById(id).lean();
        if (!category) {
            throw new NotFoundException('Category not found');
        }

        const breadcrumb = await this.categoryModel
            .find({ _id: { $in: category.ancestors } })
            .sort({ level: 1 })
            .lean();

        return {
            category: this.normalizeCategory(category),
            breadcrumb: breadcrumb.map((item) => this.normalizeCategory(item)),
        };
    }

    /**
     * Get products by category
     * - If category has children: gets products from all descendant categories
     * - If category has no children: gets products from the category directly
     */
    async getCategoryProducts(identifier: string, filters?: any): Promise<{
        data: any[];
        total: number;
        pagination: any;
    }> {
        // Find category by ID or slug
        const category = await this.findByIdOrSlug(identifier);

        let categoryIds: string[] = [category._id.toString()];

        // If category has children, get all descendant category IDs
        if (category.childrenCount > 0) {
            categoryIds = await this.getAllDescendantIds(category._id.toString());
        }

        // Prepare filters for products service
        // Convert sortBy/sortOrder to sort/order format expected by productsService
        const { sortBy, sortOrder, ...restFilters } = filters || {};
        const sort = sortBy || 'createdAt';
        const order = sortOrder || 'desc';

        const productFilters = {
            ...restFilters,
            categoryId: categoryIds.length === 1 
                ? categoryIds[0] 
                : undefined, // Will be handled specially for multiple categories
            status: filters?.status || 'active',
            sort,
            order,
        };

        // If multiple categories, we need to use $in query
        // Since productsService.findAll uses categoryId as single value,
        // we'll query directly using productModel for multiple categories
        if (categoryIds.length > 1) {
            const { page = 1, limit = 20, search, brandId, qualityTypeId, deviceId, minPrice, maxPrice } = restFilters || {};

            const query: any = {
                categoryId: { $in: categoryIds.map(id => new Types.ObjectId(id)) },
                status: 'active',
            };

            if (search) {
                query.$text = { $search: search };
            }
            if (brandId) query.brandId = new Types.ObjectId(brandId);
            if (qualityTypeId) query.qualityTypeId = new Types.ObjectId(qualityTypeId);
            if (deviceId) {
                query.compatibleDevices = {
                    $in: [new Types.ObjectId(deviceId), deviceId as any],
                };
            }

            if (minPrice || maxPrice) {
                query.basePrice = {};
                if (minPrice) query.basePrice.$gte = minPrice;
                if (maxPrice) query.basePrice.$lte = maxPrice;
            }

            const skip = (page - 1) * limit;
            const sortObj: any = { [sort]: order === 'desc' ? -1 : 1 };

            const [data, total] = await Promise.all([
                this.productModel
                    .find(query)
                    .populate('brandId', 'name nameAr slug')
                    .populate('categoryId', 'name nameAr slug')
                    .populate('qualityTypeId', 'name nameAr code color')
                    .skip(skip)
                    .limit(limit)
                    .sort(sortObj)
                    .lean(),
                this.productModel.countDocuments(query),
            ]);

            return {
                data,
                total,
                pagination: {
                    page,
                    limit,
                    pages: Math.ceil(total / limit),
                },
            };
        } else {
            // Single category, use productsService
            return await this.productsService.findAll(productFilters);
        }
    }

    /**
     * Update category
     */
    async update(id: string, data: any): Promise<CategoryDocument> {
        const normalizedData = this.normalizeCategoryInput(data);

        const category = await this.categoryModel.findByIdAndUpdate(
            id,
            { $set: normalizedData },
            { new: true },
        );

        if (!category) {
            throw new NotFoundException('Category not found');
        }

        return this.normalizeCategory(category.toObject()) as any;
    }

    /**
     * Delete category (and reassign children to parent)
     */
    async delete(id: string): Promise<void> {
        const category = await this.categoryModel.findById(id);
        if (!category) {
            throw new NotFoundException('Category not found');
        }

        // Move children to parent
        await this.categoryModel.updateMany(
            { parentId: id },
            {
                $set: { parentId: category.parentId },
                $pull: { ancestors: id },
            },
        );

        // Decrement parent's children count
        if (category.parentId) {
            await this.categoryModel.findByIdAndUpdate(category.parentId, {
                $inc: { childrenCount: -1 },
            });
        }

        await category.deleteOne();
    }
}
