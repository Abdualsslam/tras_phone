import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { ShippingZone, ShippingZoneDocument } from './schemas/shipping-zone.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 📦 Shipping Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class ShippingService {
    constructor(
        @InjectModel(ShippingZone.name)
        private shippingZoneModel: Model<ShippingZoneDocument>,
    ) { }

    /**
     * Calculate shipping cost for order
     */
    async calculateShippingCost(
        cityId: string,
        orderAmount: number,
        weight: number = 1,
    ): Promise<{
        cost: number;
        isFree: boolean;
        zone: ShippingZoneDocument;
        estimatedDays: number;
    }> {
        // Find city and get shipping zone
        // For now, we'll get zone directly (will need to populate from city)
        const zone = await this.shippingZoneModel.findOne({
            // This would normally filter by city's zone
            isActive: true,
        });

        if (!zone) {
            throw new NotFoundException('Shipping zone not found for this city');
        }

        // Check if order qualifies for free shipping
        const isFree = Boolean(
            zone.freeShippingThreshold &&
            orderAmount >= zone.freeShippingThreshold
        );

        let cost = 0;

        if (!isFree) {
            // Calculate cost
            cost = zone.baseCost + zone.costPerKg * (weight - 1);
        }

        return {
            cost,
            isFree,
            zone,
            estimatedDays: zone.estimatedDeliveryDays ??
                Math.floor(((zone.minDeliveryDays ?? 1) + (zone.maxDeliveryDays ?? 3)) / 2),
        };
    }

    /**
     * Get shipping options for city
     */
    async getShippingOptions(cityId: string) {
        // This would get the shipping zone for the city
        // and return available options
        return {
            standard: {
                cost: 0,
                estimatedDays: 0,
            },
            express: {
                cost: 0,
                estimatedDays: 0,
            },
        };
    }
}
