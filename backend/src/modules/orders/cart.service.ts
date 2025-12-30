import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Cart, CartDocument } from './schemas/cart.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Cart Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class CartService {
    constructor(
        @InjectModel(Cart.name)
        private cartModel: Model<CartDocument>,
    ) { }

    /**
     * Get or create cart for customer
     */
    async getCart(customerId: string): Promise<CartDocument> {
        let cart = await this.cartModel.findOne({
            customerId,
            status: 'active',
        });

        if (!cart) {
            cart = await this.cartModel.create({
                customerId,
                status: 'active',
                items: [],
            });
        }

        return cart;
    }

    /**
     * Add item to cart
     */
    async addItem(
        customerId: string,
        productId: string,
        quantity: number,
        unitPrice: number,
    ): Promise<CartDocument> {
        const cart = await this.getCart(customerId);

        const existingItemIndex = cart.items.findIndex(
            (item) => item.productId.toString() === productId,
        );

        if (existingItemIndex >= 0) {
            // Update existing item
            cart.items[existingItemIndex].quantity += quantity;
            cart.items[existingItemIndex].totalPrice =
                cart.items[existingItemIndex].quantity * cart.items[existingItemIndex].unitPrice;
        } else {
            // Add new item
            cart.items.push({
                productId: new Types.ObjectId(productId),
                quantity,
                unitPrice,
                totalPrice: quantity * unitPrice,
                addedAt: new Date(),
            });
        }

        await this.recalculateTotals(cart);
        cart.lastActivityAt = new Date();

        return cart.save();
    }

    /**
     * Update item quantity
     */
    async updateItemQuantity(
        customerId: string,
        productId: string,
        quantity: number,
    ): Promise<CartDocument> {
        const cart = await this.getCart(customerId);

        const itemIndex = cart.items.findIndex(
            (item) => item.productId.toString() === productId,
        );

        if (itemIndex < 0) {
            throw new NotFoundException('Item not found in cart');
        }

        if (quantity <= 0) {
            // Remove item
            cart.items.splice(itemIndex, 1);
        } else {
            // Update quantity
            cart.items[itemIndex].quantity = quantity;
            cart.items[itemIndex].totalPrice = quantity * cart.items[itemIndex].unitPrice;
        }

        await this.recalculateTotals(cart);
        cart.lastActivityAt = new Date();

        return cart.save();
    }

    /**
     * Remove item from cart
     */
    async removeItem(customerId: string, productId: string): Promise<CartDocument> {
        return this.updateItemQuantity(customerId, productId, 0);
    }

    /**
     * Clear cart
     */
    async clearCart(customerId: string): Promise<CartDocument> {
        const cart = await this.getCart(customerId);

        cart.items = [];
        cart.couponId = undefined;
        cart.couponCode = undefined;
        cart.couponDiscount = 0;
        cart.appliedPromotions = [];

        await this.recalculateTotals(cart);
        cart.lastActivityAt = new Date();

        return cart.save();
    }

    /**
     * Apply coupon to cart
     */
    async applyCoupon(
        customerId: string,
        couponId: string | undefined,
        couponCode: string,
        discountAmount: number,
    ): Promise<CartDocument> {
        const cart = await this.getCart(customerId);

        cart.couponId = couponId ? new Types.ObjectId(couponId) : undefined;
        cart.couponCode = couponCode;
        cart.couponDiscount = discountAmount;

        await this.recalculateTotals(cart);
        cart.lastActivityAt = new Date();

        return cart.save();
    }

    /**
     * Remove coupon from cart
     */
    async removeCoupon(customerId: string): Promise<CartDocument> {
        const cart = await this.getCart(customerId);

        cart.couponId = undefined;
        cart.couponCode = undefined;
        cart.couponDiscount = 0;

        await this.recalculateTotals(cart);
        cart.lastActivityAt = new Date();

        return cart.save();
    }

    /**
     * Mark cart as converted (after order creation)
     */
    async convertCart(customerId: string, orderId: string): Promise<void> {
        await this.cartModel.findOneAndUpdate(
            { customerId, status: 'active' },
            {
                $set: {
                    status: 'converted',
                    convertedAt: new Date(),
                    orderId,
                },
            },
        );
    }

    /**
     * Recalculate cart totals
     */
    private async recalculateTotals(cart: CartDocument): Promise<void> {
        cart.itemsCount = cart.items.reduce((sum, item) => sum + item.quantity, 0);
        cart.subtotal = cart.items.reduce((sum, item) => sum + item.totalPrice, 0);
        cart.discount = cart.couponDiscount;
        cart.total = cart.subtotal - cart.discount + cart.taxAmount + cart.shippingCost;
    }

    /**
     * Get abandoned carts (for marketing)
     */
    async getAbandonedCarts(hoursAgo: number = 24): Promise<CartDocument[]> {
        const cutoffDate = new Date(Date.now() - hoursAgo * 60 * 60 * 1000);

        return this.cartModel
            .find({
                status: 'active',
                'items.0': { $exists: true }, // Has items
                lastActivityAt: { $lt: cutoffDate },
            })
            .populate('customerId', 'responsiblePersonName email phone')
            .limit(100);
    }
}
