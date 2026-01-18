import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Brand, BrandDocument } from './schemas/brand.schema';
import { Device, DeviceDocument } from './schemas/device.schema';
import { QualityType, QualityTypeDocument } from './schemas/quality-type.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏷️ Catalog Service (Brands, Devices, Quality Types)
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class CatalogService {
    constructor(
        @InjectModel(Brand.name)
        private brandModel: Model<BrandDocument>,
        @InjectModel(Device.name)
        private deviceModel: Model<DeviceDocument>,
        @InjectModel(QualityType.name)
        private qualityTypeModel: Model<QualityTypeDocument>,
    ) { }

    // ═════════════════════════════════════
    // Brands
    // ═════════════════════════════════════

    async createBrand(data: any): Promise<BrandDocument> {
        const existing = await this.brandModel.findOne({ slug: data.slug });
        if (existing) {
            throw new ConflictException('Brand with this slug already exists');
        }
        return this.brandModel.create(data);
    }

    async findAllBrands(filters?: any): Promise<BrandDocument[]> {
        const query: any = {};
        
        // Only filter by isActive if includeInactive is not true
        // This allows admin to see all brands while public endpoints see only active ones
        if (!filters?.includeInactive) {
            query.isActive = true;
        }
        
        if (filters?.featured) query.isFeatured = true;

        return this.brandModel.find(query).sort({ displayOrder: 1, name: 1 });
    }

    async findBrandBySlug(slug: string): Promise<BrandDocument> {
        const brand = await this.brandModel.findOne({ slug });
        if (!brand) throw new NotFoundException('Brand not found');
        return brand;
    }

    async updateBrand(id: string, data: any): Promise<BrandDocument> {
        const brand = await this.brandModel.findByIdAndUpdate(
            id,
            { $set: data },
            { new: true },
        );
        if (!brand) throw new NotFoundException('Brand not found');
        return brand;
    }

    async deleteBrand(id: string): Promise<void> {
        const result = await this.brandModel.deleteOne({ _id: id });
        if (result.deletedCount === 0) throw new NotFoundException('Brand not found');
    }

    // ═════════════════════════════════════
    // Devices
    // ═════════════════════════════════════

    async createDevice(data: any): Promise<DeviceDocument> {
        const existing = await this.deviceModel.findOne({ slug: data.slug });
        if (existing) {
            throw new ConflictException('Device with this slug already exists');
        }
        return this.deviceModel.create(data);
    }

    async findDevicesByBrand(brandId: string): Promise<DeviceDocument[]> {
        return this.deviceModel
            .find({ brandId, isActive: true })
            .populate('brandId', 'name nameAr slug logo')
            .sort({ releaseYear: -1, displayOrder: 1 });
    }

    async findAllDevices(limit?: number): Promise<DeviceDocument[]> {
        const query = this.deviceModel
            .find({ isActive: true })
            .populate('brandId', 'name nameAr slug logo')
            .sort({ displayOrder: 1, releaseYear: -1 });
        
        if (limit) {
            query.limit(limit);
        }
        
        return query.exec();
    }

    async findPopularDevices(limit: number = 10): Promise<DeviceDocument[]> {
        return this.deviceModel
            .find({ isPopular: true, isActive: true })
            .populate('brandId', 'name nameAr slug logo')
            .limit(limit)
            .sort({ displayOrder: 1 });
    }

    async findDeviceBySlug(slug: string): Promise<DeviceDocument> {
        const device = await this.deviceModel
            .findOne({ slug })
            .populate('brandId');
        if (!device) throw new NotFoundException('Device not found');
        return device;
    }

    async findDeviceByIdOrSlug(identifier: string): Promise<DeviceDocument> {
        const query = /^[0-9a-fA-F]{24}$/.test(identifier)
            ? { _id: identifier }
            : { slug: identifier };
        
        const device = await this.deviceModel
            .findOne(query)
            .populate('brandId');
        if (!device) throw new NotFoundException('Device not found');
        return device;
    }

    async updateDevice(id: string, data: any): Promise<DeviceDocument> {
        const device = await this.deviceModel.findByIdAndUpdate(
            id,
            { $set: data },
            { new: true },
        );
        if (!device) throw new NotFoundException('Device not found');
        return device;
    }

    async deleteDevice(id: string): Promise<void> {
        const result = await this.deviceModel.deleteOne({ _id: id });
        if (result.deletedCount === 0) throw new NotFoundException('Device not found');
    }

    // ═════════════════════════════════════
    // Quality Types
    // ═════════════════════════════════════

    async createQualityType(data: any): Promise<QualityTypeDocument> {
        const existing = await this.qualityTypeModel.findOne({ code: data.code });
        if (existing) {
            throw new ConflictException('Quality type with this code already exists');
        }
        return this.qualityTypeModel.create(data);
    }

    async findAllQualityTypes(): Promise<QualityTypeDocument[]> {
        return this.qualityTypeModel
            .find({ isActive: true })
            .sort({ displayOrder: 1 });
    }

    async findQualityTypeByCode(code: string): Promise<QualityTypeDocument> {
        const qualityType = await this.qualityTypeModel.findOne({ code });
        if (!qualityType) throw new NotFoundException('Quality type not found');
        return qualityType;
    }

    async updateQualityType(id: string, data: any): Promise<QualityTypeDocument> {
        // Check if code is being updated and if it conflicts
        if (data.code) {
            const existing = await this.qualityTypeModel.findOne({ 
                code: data.code, 
                _id: { $ne: id } 
            });
            if (existing) {
                throw new ConflictException('Quality type with this code already exists');
            }
        }
        const qualityType = await this.qualityTypeModel.findByIdAndUpdate(
            id,
            { $set: data },
            { new: true },
        );
        if (!qualityType) throw new NotFoundException('Quality type not found');
        return qualityType;
    }

    async deleteQualityType(id: string): Promise<void> {
        const result = await this.qualityTypeModel.deleteOne({ _id: id });
        if (result.deletedCount === 0) throw new NotFoundException('Quality type not found');
    }

    // ═════════════════════════════════════
    // Seeding
    // ═════════════════════════════════════

    async seedCatalogData(): Promise<void> {
        const brandCount = await this.brandModel.countDocuments();
        if (brandCount > 0) return;

        console.log('Seeding catalog data...');

        // Seed brands
        const brands = await this.brandModel.insertMany([
            { name: 'Apple', nameAr: 'أبل', slug: 'apple', isFeatured: true },
            { name: 'Samsung', nameAr: 'سامسونج', slug: 'samsung', isFeatured: true },
            { name: 'Huawei', nameAr: 'هواوي', slug: 'huawei' },
            { name: 'Xiaomi', nameAr: 'شاومي', slug: 'xiaomi' },
            { name: 'OPPO', nameAr: 'أوبو', slug: 'oppo' },
        ]);

        // Seed quality types
        await this.qualityTypeModel.insertMany([
            { name: 'Original', nameAr: 'أصلي', code: 'original', color: '#22c55e', defaultWarrantyDays: 365, displayOrder: 1 },
            { name: 'OEM', nameAr: 'OEM', code: 'oem', color: '#3b82f6', defaultWarrantyDays: 180, displayOrder: 2 },
            { name: 'AAA Copy', nameAr: 'AAA', code: 'aaa', color: '#f59e0b', defaultWarrantyDays: 90, displayOrder: 3 },
            { name: 'Copy', nameAr: 'نسخة', code: 'copy', color: '#ef4444', defaultWarrantyDays: 30, displayOrder: 4 },
        ]);

        // Seed some devices for Apple
        const apple = brands.find(b => b.slug === 'apple');
        if (apple) {
            await this.deviceModel.insertMany([
                { brandId: apple._id, name: 'iPhone 15 Pro Max', nameAr: 'آيفون 15 برو ماكس', slug: 'iphone-15-pro-max', releaseYear: 2023, isPopular: true },
                { brandId: apple._id, name: 'iPhone 15 Pro', nameAr: 'آيفون 15 برو', slug: 'iphone-15-pro', releaseYear: 2023, isPopular: true },
                { brandId: apple._id, name: 'iPhone 14 Pro Max', nameAr: 'آيفون 14 برو ماكس', slug: 'iphone-14-pro-max', releaseYear: 2022 },
                { brandId: apple._id, name: 'iPhone 14', nameAr: 'آيفون 14', slug: 'iphone-14', releaseYear: 2022 },
            ]);
        }

        console.log('✅ Catalog data seeded successfully');
    }
}
