import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Category, CategoryDocument } from './schemas/category.schema';

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
    ) { }

    /**
     * Create category
     */
    async create(data: any): Promise<CategoryDocument> {
        // Check slug uniqueness
        const existing = await this.categoryModel.findOne({ slug: data.slug });
        if (existing) {
            throw new ConflictException('Category with this slug already exists');
        }

        let ancestors: any[] = [];
        let level = 0;
        let path = data.slug;

        // If has parent, build hierarchy
        if (data.parentId) {
            const parent = await this.categoryModel.findById(data.parentId);
            if (!parent) {
                throw new NotFoundException('Parent category not found');
            }

            ancestors = [...parent.ancestors, parent._id];
            level = parent.level + 1;
            path = `${parent.path}/${data.slug}`;

            // Update parent's children count
            await this.categoryModel.findByIdAndUpdate(data.parentId, {
                $inc: { childrenCount: 1 },
            });
        }

        const category = await this.categoryModel.create({
            ...data,
            ancestors,
            level,
            path,
        });

        return category;
    }

    /**
     * Get all root categories
     */
    async findRoots(): Promise<CategoryDocument[]> {
        return this.categoryModel
            .find({ parentId: null, isActive: true })
            .sort({ displayOrder: 1, name: 1 });
    }

    /**
     * Get children of a category
     */
    async findChildren(parentId: string): Promise<CategoryDocument[]> {
        return this.categoryModel
            .find({ parentId, isActive: true })
            .sort({ displayOrder: 1, name: 1 });
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
        const categoriesWithCount = categories.map((cat: any) => ({
            ...cat,
            productsCount: countMap.get(cat._id.toString()) || 0,
        }));

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
     * Get category with ancestors (breadcrumb)
     */
    async findWithBreadcrumb(id: string): Promise<{
        category: CategoryDocument;
        breadcrumb: CategoryDocument[];
    }> {
        const category = await this.categoryModel.findById(id);
        if (!category) {
            throw new NotFoundException('Category not found');
        }

        const breadcrumb = await this.categoryModel
            .find({ _id: { $in: category.ancestors } })
            .sort({ level: 1 });

        return { category, breadcrumb };
    }

    /**
     * Update category
     */
    async update(id: string, data: any): Promise<CategoryDocument> {
        const category = await this.categoryModel.findByIdAndUpdate(
            id,
            { $set: data },
            { new: true },
        );

        if (!category) {
            throw new NotFoundException('Category not found');
        }

        return category;
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
