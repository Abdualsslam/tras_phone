import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Warehouse, WarehouseDocument } from './schemas/warehouse.schema';
import { StockLocation, StockLocationDocument } from './schemas/stock-location.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏭 Warehouses Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class WarehousesService {
    constructor(
        @InjectModel(Warehouse.name)
        private warehouseModel: Model<WarehouseDocument>,
        @InjectModel(StockLocation.name)
        private stockLocationModel: Model<StockLocationDocument>,
    ) { }

    async create(data: any): Promise<WarehouseDocument> {
        return this.warehouseModel.create(data);
    }

    async findAll(): Promise<WarehouseDocument[]> {
        return this.warehouseModel.find({ isActive: true }).sort({ isDefault: -1, name: 1 });
    }

    async findById(id: string): Promise<WarehouseDocument> {
        const warehouse = await this.warehouseModel.findById(id);
        if (!warehouse) throw new NotFoundException('Warehouse not found');
        return warehouse;
    }

    async getDefaultWarehouse(): Promise<WarehouseDocument> {
        const warehouse = await this.warehouseModel.findOne({ isDefault: true, isActive: true });
        if (!warehouse) throw new NotFoundException('No default warehouse configured');
        return warehouse;
    }

    async update(id: string, data: any): Promise<WarehouseDocument> {
        const warehouse = await this.warehouseModel.findByIdAndUpdate(id, { $set: data }, { new: true });
        if (!warehouse) throw new NotFoundException('Warehouse not found');
        return warehouse;
    }

    async delete(id: string): Promise<void> {
        const result = await this.warehouseModel.deleteOne({ _id: id });
        if (result.deletedCount === 0) throw new NotFoundException('Warehouse not found');
        await this.stockLocationModel.deleteMany({ warehouseId: id });
    }

    // ═════════════════════════════════════
    // Stock Locations
    // ═════════════════════════════════════

    async createLocation(warehouseId: string, data: any): Promise<StockLocationDocument> {
        await this.findById(warehouseId); // Verify warehouse exists
        return this.stockLocationModel.create({ ...data, warehouseId });
    }

    async getLocations(warehouseId: string): Promise<StockLocationDocument[]> {
        return this.stockLocationModel.find({ warehouseId, isActive: true }).sort({ name: 1 });
    }

    async getAllLocations(warehouseId?: string): Promise<StockLocationDocument[]> {
        const query: any = { isActive: true };
        if (warehouseId) {
            query.warehouseId = warehouseId;
        }
        return this.stockLocationModel.find(query).sort({ name: 1 });
    }

    async updateLocation(id: string, data: any): Promise<StockLocationDocument> {
        const location = await this.stockLocationModel.findByIdAndUpdate(id, { $set: data }, { new: true });
        if (!location) throw new NotFoundException('Location not found');
        return location;
    }

    async deleteLocation(id: string): Promise<void> {
        const result = await this.stockLocationModel.deleteOne({ _id: id });
        if (result.deletedCount === 0) throw new NotFoundException('Location not found');
    }

    /**
     * Seed default warehouse
     */
    async seedDefaultWarehouse(): Promise<void> {
        const count = await this.warehouseModel.countDocuments();
        if (count > 0) return;

        console.log('Seeding default warehouse...');

        await this.warehouseModel.create({
            name: 'Main Warehouse',
            nameAr: 'المستودع الرئيسي',
            code: 'WH-MAIN',
            isDefault: true,
            address: 'Riyadh, Saudi Arabia',
        });

        console.log('✅ Default warehouse seeded');
    }
}
