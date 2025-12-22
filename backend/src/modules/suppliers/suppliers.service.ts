import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Supplier, SupplierDocument } from './schemas/supplier.schema';
import { PurchaseOrder, PurchaseOrderDocument } from './schemas/purchase-order.schema';
import { PurchaseOrderItem, PurchaseOrderItemDocument } from './schemas/purchase-order-item.schema';
import { SupplierPayment, SupplierPaymentDocument } from './schemas/supplier-payment.schema';
import { SupplierProduct, SupplierProductDocument } from './schemas/supplier-product.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 🏢 Suppliers Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class SuppliersService {
    constructor(
        @InjectModel(Supplier.name)
        private supplierModel: Model<SupplierDocument>,
        @InjectModel(PurchaseOrder.name)
        private purchaseOrderModel: Model<PurchaseOrderDocument>,
        @InjectModel(PurchaseOrderItem.name)
        private purchaseOrderItemModel: Model<PurchaseOrderItemDocument>,
        @InjectModel(SupplierPayment.name)
        private supplierPaymentModel: Model<SupplierPaymentDocument>,
        @InjectModel(SupplierProduct.name)
        private supplierProductModel: Model<SupplierProductDocument>,
    ) { }

    // ═════════════════════════════════════
    // Suppliers CRUD
    // ═════════════════════════════════════

    async createSupplier(data: any): Promise<SupplierDocument> {
        const code = await this.generateSupplierCode();
        return this.supplierModel.create({ ...data, code });
    }

    async findAllSuppliers(filters?: any): Promise<SupplierDocument[]> {
        const query: any = {};
        if (filters?.active !== undefined) query.isActive = filters.active;
        if (filters?.preferred) query.isPreferred = true;
        if (filters?.type) query.type = filters.type;

        return this.supplierModel.find(query).sort({ name: 1 });
    }

    async findSupplierById(id: string): Promise<SupplierDocument> {
        const supplier = await this.supplierModel.findById(id);
        if (!supplier) throw new NotFoundException('Supplier not found');
        return supplier;
    }

    async updateSupplier(id: string, data: any): Promise<SupplierDocument> {
        const supplier = await this.supplierModel.findByIdAndUpdate(id, { $set: data }, { new: true });
        if (!supplier) throw new NotFoundException('Supplier not found');
        return supplier;
    }

    async deleteSupplier(id: string): Promise<void> {
        const result = await this.supplierModel.deleteOne({ _id: id });
        if (result.deletedCount === 0) throw new NotFoundException('Supplier not found');
    }

    // ═════════════════════════════════════
    // Purchase Orders
    // ═════════════════════════════════════

    async createPurchaseOrder(data: any, items: any[]): Promise<PurchaseOrderDocument> {
        const orderNumber = await this.generatePurchaseOrderNumber();

        // Calculate totals
        let subtotal = 0;
        let taxAmount = 0;

        const orderItems = items.map((item) => {
            const itemTotal = item.unitPrice * item.orderedQuantity;
            const itemTax = item.taxRate ? (itemTotal * item.taxRate) / 100 : 0;
            subtotal += itemTotal;
            taxAmount += itemTax;

            return {
                ...item,
                totalPrice: itemTotal + itemTax,
                taxAmount: itemTax,
            };
        });

        const total = subtotal + taxAmount + (data.shippingCost || 0) - (data.discount || 0);

        // Create order
        const order = await this.purchaseOrderModel.create({
            ...data,
            orderNumber,
            subtotal,
            taxAmount,
            total,
        });

        // Create order items
        await this.purchaseOrderItemModel.insertMany(
            orderItems.map((item) => ({ ...item, purchaseOrderId: order._id })),
        );

        // Update supplier statistics
        await this.supplierModel.findByIdAndUpdate(data.supplierId, {
            $inc: { totalOrders: 1 },
            $set: { lastOrderDate: new Date() },
        });

        return order;
    }

    async findAllPurchaseOrders(filters?: any): Promise<{ data: PurchaseOrderDocument[]; total: number }> {
        const { page = 1, limit = 20, supplierId, status, paymentStatus } = filters || {};

        const query: any = {};
        if (supplierId) query.supplierId = supplierId;
        if (status) query.status = status;
        if (paymentStatus) query.paymentStatus = paymentStatus;

        const [data, total] = await Promise.all([
            this.purchaseOrderModel
                .find(query)
                .populate('supplierId', 'name code')
                .populate('warehouseId', 'name code')
                .skip((page - 1) * limit)
                .limit(limit)
                .sort({ createdAt: -1 }),
            this.purchaseOrderModel.countDocuments(query),
        ]);

        return { data, total };
    }

    async findPurchaseOrderById(id: string): Promise<{ order: PurchaseOrderDocument; items: PurchaseOrderItemDocument[] }> {
        const order = await this.purchaseOrderModel
            .findById(id)
            .populate('supplierId')
            .populate('warehouseId');

        if (!order) throw new NotFoundException('Purchase order not found');

        const items = await this.purchaseOrderItemModel
            .find({ purchaseOrderId: id })
            .populate('productId', 'name nameAr sku mainImage');

        return { order, items };
    }

    async updatePurchaseOrderStatus(id: string, status: string, userId?: string): Promise<PurchaseOrderDocument> {
        const updateData: any = { status };

        if (status === 'approved') {
            updateData.approvedBy = userId;
            updateData.approvedAt = new Date();
        } else if (status === 'received') {
            updateData.receivedBy = userId;
            updateData.receivedAt = new Date();
            updateData.actualDeliveryDate = new Date();
        }

        const order = await this.purchaseOrderModel.findByIdAndUpdate(id, { $set: updateData }, { new: true });
        if (!order) throw new NotFoundException('Purchase order not found');

        return order;
    }

    async receivePurchaseOrder(id: string, receivedItems: { itemId: string; receivedQuantity: number; damagedQuantity?: number }[]): Promise<void> {
        const { order, items } = await this.findPurchaseOrderById(id);

        let allReceived = true;

        for (const received of receivedItems) {
            const item = items.find((i) => i._id.toString() === received.itemId);
            if (!item) continue;

            const newReceivedQty = item.receivedQuantity + received.receivedQuantity;
            const status = newReceivedQty >= item.orderedQuantity ? 'received' : 'partial';

            if (status !== 'received') allReceived = false;

            await this.purchaseOrderItemModel.findByIdAndUpdate(received.itemId, {
                $set: { status },
                $inc: {
                    receivedQuantity: received.receivedQuantity,
                    damagedQuantity: received.damagedQuantity || 0,
                },
            });
        }

        // Update order status
        await this.purchaseOrderModel.findByIdAndUpdate(id, {
            $set: {
                status: allReceived ? 'received' : 'partial_received',
                receivedAt: new Date(),
            },
        });

        // Update supplier total purchases
        await this.supplierModel.findByIdAndUpdate(order.supplierId, {
            $inc: { totalPurchases: order.total },
        });
    }

    // ═════════════════════════════════════
    // Payments
    // ═════════════════════════════════════

    async createPayment(data: any): Promise<SupplierPaymentDocument> {
        const paymentNumber = await this.generatePaymentNumber();

        const payment = await this.supplierPaymentModel.create({
            ...data,
            paymentNumber,
        });

        // Update purchase order paid amount
        if (data.purchaseOrderId) {
            const order = await this.purchaseOrderModel.findById(data.purchaseOrderId);
            if (order) {
                const newPaidAmount = order.paidAmount + data.amount;
                const paymentStatus = newPaidAmount >= order.total ? 'paid' : 'partial';

                await this.purchaseOrderModel.findByIdAndUpdate(data.purchaseOrderId, {
                    $set: { paidAmount: newPaidAmount, paymentStatus },
                });
            }
        }

        // Update supplier balance
        await this.supplierModel.findByIdAndUpdate(data.supplierId, {
            $inc: { currentBalance: -data.amount },
        });

        return payment;
    }

    async getSupplierPayments(supplierId: string): Promise<SupplierPaymentDocument[]> {
        return this.supplierPaymentModel
            .find({ supplierId })
            .populate('purchaseOrderId', 'orderNumber')
            .sort({ paymentDate: -1 });
    }

    // ═════════════════════════════════════
    // Supplier Products
    // ═════════════════════════════════════

    async addSupplierProduct(data: any): Promise<SupplierProductDocument> {
        return this.supplierProductModel.create(data);
    }

    async getSupplierProducts(supplierId: string): Promise<SupplierProductDocument[]> {
        return this.supplierProductModel
            .find({ supplierId, isActive: true })
            .populate('productId', 'name nameAr sku mainImage');
    }

    async getProductSuppliers(productId: string): Promise<SupplierProductDocument[]> {
        return this.supplierProductModel
            .find({ productId, isActive: true })
            .populate('supplierId', 'name code')
            .sort({ isPreferred: -1, costPrice: 1 });
    }

    // ═════════════════════════════════════
    // Helpers
    // ═════════════════════════════════════

    private async generateSupplierCode(): Promise<string> {
        const count = await this.supplierModel.countDocuments();
        return `SUP${(count + 1).toString().padStart(4, '0')}`;
    }

    private async generatePurchaseOrderNumber(): Promise<string> {
        const date = new Date();
        const prefix = 'PO';
        const year = date.getFullYear().toString().slice(-2);
        const month = (date.getMonth() + 1).toString().padStart(2, '0');

        const count = await this.purchaseOrderModel.countDocuments({
            createdAt: { $gte: new Date(date.getFullYear(), date.getMonth(), 1) },
        });

        return `${prefix}${year}${month}${(count + 1).toString().padStart(4, '0')}`;
    }

    private async generatePaymentNumber(): Promise<string> {
        const date = new Date();
        const prefix = 'PAY';
        const dateStr = date.toISOString().slice(0, 10).replace(/-/g, '');

        const count = await this.supplierPaymentModel.countDocuments({
            createdAt: { $gte: new Date(date.setHours(0, 0, 0, 0)) },
        });

        return `${prefix}${dateStr}${(count + 1).toString().padStart(3, '0')}`;
    }
}
