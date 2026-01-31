import { Injectable, NotFoundException, BadRequestException, Inject, forwardRef, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Cart, CartDocument } from './schemas/cart.schema';
import { ProductsService } from '@modules/products/products.service';
import { InventoryService } from '@modules/inventory/inventory.service';
import { CustomersService } from '@modules/customers/customers.service';
import { SyncCartItemDto } from './dto/sync-cart.dto';
import { CheckoutCartDto, CheckoutCartItemDto, CartItemProductDto } from './dto/checkout-session.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🛒 Cart Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class CartService {
    private readonly logger = new Logger(CartService.name);

    constructor(
        @InjectModel(Cart.name)
        private cartModel: Model<CartDocument>,
        @Inject(forwardRef(() => ProductsService))
        private productsService: ProductsService,
        @Inject(forwardRef(() => InventoryService))
        private inventoryService: InventoryService,
        @Inject(forwardRef(() => CustomersService))
        private customersService: CustomersService,
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
        const lastActivityAt = new Date();

        const updated = await this.cartModel.findOneAndUpdate(
            { _id: cart._id },
            {
                $set: {
                    items: [],
                    itemsCount: 0,
                    subtotal: 0,
                    discount: 0,
                    total: 0,
                    couponDiscount: 0,
                    appliedPromotions: [],
                    lastActivityAt,
                },
                $unset: { couponId: '', couponCode: '' },
            },
            { new: true },
        );

        if (!updated) {
            this.logger.warn(`clearCart: findOneAndUpdate did not match cartId=${cart._id}`);
            return cart;
        }
        return updated;
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

    /**
     * Get cart with populated product details for checkout session
     * Returns cart items with product name, image, sku, stock info
     */
    async getCartWithProductDetails(customerId: string): Promise<CheckoutCartDto> {
        const cart = await this.getCart(customerId);

        // Get customer for priceLevelId
        let priceLevelId: string = '';
        try {
            const customer = await this.customersService.findByUserId(customerId);
            priceLevelId = customer?.priceLevelId?.toString() || '';
        } catch (e) {
            // If customer not found, use default
            priceLevelId = '';
        }

        // Populate product details for each item
        const itemsWithDetails: CheckoutCartItemDto[] = [];

        for (const item of cart.items) {
            try {
                const product = await this.productsService.findByIdOrSlug(
                    item.productId.toString(),
                );

                if (!product) continue;

                // Get current price based on customer's price level
                let currentPrice = item.unitPrice;
                if (priceLevelId) {
                    try {
                        currentPrice = await this.productsService.getPrice(
                            item.productId.toString(),
                            priceLevelId,
                        );
                    } catch (e) {
                        // Use existing price if price level not found
                    }
                }

                // Get stock quantity
                let stockQuantity = 0;
                try {
                    stockQuantity = await this.inventoryService.getAvailableQuantity(
                        item.productId.toString(),
                    );
                } catch (e) {
                    // Default to 0 if error
                }

                const productDetails: CartItemProductDto = {
                    name: product.name || '',
                    nameAr: product.nameAr || '',
                    image: product.images?.[0] || product.mainImage || '',
                    sku: product.sku || '',
                    isActive: product.isActive && product.status === 'active',
                    stockQuantity,
                };

                itemsWithDetails.push({
                    productId: item.productId.toString(),
                    quantity: item.quantity,
                    unitPrice: currentPrice,
                    totalPrice: item.quantity * currentPrice,
                    addedAt: item.addedAt,
                    product: productDetails,
                });
            } catch (e) {
                // Skip items with errors (product deleted, etc.)
                continue;
            }
        }

        // Recalculate totals based on current prices
        const subtotal = itemsWithDetails.reduce((sum, item) => sum + item.totalPrice, 0);
        const itemsCount = itemsWithDetails.reduce((sum, item) => sum + item.quantity, 0);

        return {
            id: cart._id.toString(),
            customerId: cart.customerId.toString(),
            status: cart.status,
            items: itemsWithDetails,
            itemsCount,
            subtotal,
            discount: cart.discount || 0,
            taxAmount: cart.taxAmount || 0,
            shippingCost: cart.shippingCost || 0,
            total: subtotal - (cart.couponDiscount || 0) + (cart.taxAmount || 0) + (cart.shippingCost || 0),
            couponCode: cart.couponCode,
            couponDiscount: cart.couponDiscount || 0,
        };
    }

    /**
     * Sync local cart with server
     * Validates stock, prices, and product availability
     */
    async syncCart(
        customerId: string,
        localItems: SyncCartItemDto[],
    ): Promise<{
        cart: CartDocument;
        removedItems: Array<{
            productId: string;
            reason: string;
            productName?: string;
            productNameAr?: string;
        }>;
        priceChangedItems: Array<{
            productId: string;
            oldPrice: number;
            newPrice: number;
            productName?: string;
            productNameAr?: string;
        }>;
        quantityAdjustedItems: Array<{
            productId: string;
            requestedQuantity: number;
            availableQuantity: number;
            finalQuantity: number;
            productName?: string;
            productNameAr?: string;
        }>;
    }> {
        // Get or create cart (customerId here is Customer._id from JWT guard)
        const cart = await this.getCart(customerId);
        this.logger.debug(`syncCart: customerId=${customerId}, cartId=${cart._id}, existingItems=${cart.items?.length ?? 0}`);

        // Get customer for priceLevelId (customerId is Customer._id, so use findById)
        let priceLevelId: string;
        try {
            const customer = await this.customersService.findById(customerId);
            priceLevelId = customer?.priceLevelId?.toString() || '';
        } catch (e) {
            priceLevelId = '';
        }

        // Initialize result arrays
        const removedItems: Array<{
            productId: string;
            reason: string;
            productName?: string;
            productNameAr?: string;
        }> = [];

        const priceChangedItems: Array<{
            productId: string;
            oldPrice: number;
            newPrice: number;
            productName?: string;
            productNameAr?: string;
        }> = [];

        const quantityAdjustedItems: Array<{
            productId: string;
            requestedQuantity: number;
            availableQuantity: number;
            finalQuantity: number;
            productName?: string;
            productNameAr?: string;
        }> = [];

        // Build new items array (plain objects for direct DB update)
        const newItems: { productId: Types.ObjectId; quantity: number; unitPrice: number; totalPrice: number; addedAt: Date }[] = [];

        // Process each local item
        for (const localItem of localItems) {
            let productName: string | undefined;
            let productNameAr: string | undefined;

            try {
                // 1. Check if product exists and is active
                let product;
                try {
                    // Get product - findByIdOrSlug handles both ObjectId and slug
                    // Note: This will increment viewsCount, which is acceptable for sync operations
                    product = await this.productsService.findByIdOrSlug(localItem.productId);
                } catch (e) {
                    // Product not found
                    removedItems.push({
                        productId: localItem.productId,
                        reason: 'deleted',
                    });
                    continue;
                }

                if (!product) {
                    removedItems.push({
                        productId: localItem.productId,
                        reason: 'deleted',
                    });
                    continue;
                }

                if (!product.isActive || product.status !== 'active') {
                    productName = product.name;
                    productNameAr = product.nameAr;
                    removedItems.push({
                        productId: localItem.productId,
                        reason: 'inactive',
                        productName,
                        productNameAr,
                    });
                    continue;
                }

                productName = product.name;
                productNameAr = product.nameAr;

                // 2. Check available stock
                const availableQuantity = await this.inventoryService.getAvailableQuantity(
                    localItem.productId,
                );

                if (availableQuantity === 0) {
                    removedItems.push({
                        productId: localItem.productId,
                        reason: 'out_of_stock',
                        productName,
                        productNameAr,
                    });
                    continue;
                }

                // 3. Get current price
                let currentPrice: number;
                if (priceLevelId) {
                    currentPrice = await this.productsService.getPrice(
                        localItem.productId,
                        priceLevelId,
                    );
                } else {
                    // Fallback to product base price
                    currentPrice = product.basePrice || 0;
                }

                // 4. Check if price changed
                if (Math.abs(currentPrice - localItem.unitPrice) > 0.01) {
                    priceChangedItems.push({
                        productId: localItem.productId,
                        oldPrice: localItem.unitPrice,
                        newPrice: currentPrice,
                        productName,
                        productNameAr,
                    });
                }

                // 5. Adjust quantity if needed
                let finalQuantity = localItem.quantity;
                if (availableQuantity < localItem.quantity) {
                    finalQuantity = availableQuantity;
                    quantityAdjustedItems.push({
                        productId: localItem.productId,
                        requestedQuantity: localItem.quantity,
                        availableQuantity,
                        finalQuantity,
                        productName,
                        productNameAr,
                    });
                }

                // 6. Add/update item in newItems
                const existingItemIndex = newItems.findIndex(
                    (item) => item.productId.toString() === localItem.productId,
                );

                if (existingItemIndex >= 0) {
                    newItems[existingItemIndex].quantity = finalQuantity;
                    newItems[existingItemIndex].unitPrice = currentPrice;
                    newItems[existingItemIndex].totalPrice = finalQuantity * currentPrice;
                } else {
                    newItems.push({
                        productId: new Types.ObjectId(localItem.productId),
                        quantity: finalQuantity,
                        unitPrice: currentPrice,
                        totalPrice: finalQuantity * currentPrice,
                        addedAt: new Date(),
                    });
                }
            } catch (e) {
                // If any error occurs, add to removed items
                removedItems.push({
                    productId: localItem.productId,
                    reason: 'error',
                    productName,
                    productNameAr,
                });
                continue;
            }
        }

        // Compute totals from newItems
        const itemsCount = newItems.reduce((sum, item) => sum + item.quantity, 0);
        const subtotal = newItems.reduce((sum, item) => sum + item.totalPrice, 0);
        const total = subtotal - (cart.couponDiscount || 0) + (cart.taxAmount || 0) + (cart.shippingCost || 0);
        const lastActivityAt = new Date();

        // Persist to DB with findOneAndUpdate (guarantees write; no Mongoose change-tracking)
        const updateResult = await this.cartModel.findOneAndUpdate(
            { _id: cart._id },
            {
                $set: {
                    items: newItems,
                    itemsCount,
                    subtotal,
                    total,
                    lastActivityAt,
                },
            },
            { new: true },
        );

        if (!updateResult) {
            this.logger.error(`syncCart: findOneAndUpdate did not match cartId=${cart._id}`);
            throw new BadRequestException('Cart update failed');
        }

        this.logger.log(`syncCart: saved cartId=${cart._id} items=${updateResult.items?.length ?? 0} itemsCount=${itemsCount} total=${total}`);

        return {
            cart: updateResult,
            removedItems,
            priceChangedItems,
            quantityAdjustedItems,
        };
    }
}
