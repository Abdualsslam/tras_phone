import {
    Injectable,
    NotFoundException,
    ConflictException,
    BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Customer, CustomerDocument } from './schemas/customer.schema';
import {
    CustomerAddress,
    CustomerAddressDocument,
} from './schemas/customer-address.schema';
import {
    CustomerPriceLevelHistory,
    CustomerPriceLevelHistoryDocument,
} from './schemas/customer-price-level-history.schema';
import { CreateCustomerDto } from './dto/create-customer.dto';
import { UpdateCustomerDto } from './dto/update-customer.dto';
import { CreateAddressDto } from './dto/create-address.dto';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👥 Customers Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class CustomersService {
    constructor(
        @InjectModel(Customer.name)
        private customerModel: Model<CustomerDocument>,
        @InjectModel(CustomerAddress.name)
        private addressModel: Model<CustomerAddressDocument>,
        @InjectModel(CustomerPriceLevelHistory.name)
        private priceLevelHistoryModel: Model<CustomerPriceLevelHistoryDocument>,
    ) { }

    /**
     * Create new customer
     */
    async create(createCustomerDto: CreateCustomerDto): Promise<CustomerDocument> {
        // Check if customer already exists for this user
        const existingCustomer = await this.customerModel.findOne({
            userId: createCustomerDto.userId,
        });

        if (existingCustomer) {
            throw new ConflictException('Customer already exists for this user');
        }

        // Generate customer code
        const customerCode = await this.generateCustomerCode();

        // Create customer
        const customer = await this.customerModel.create({
            ...createCustomerDto,
            customerCode,
        });

        return customer;
    }

    /**
     * Find all customers with pagination and filters
     */
    async findAll(filters?: any) {
        const {
            page = 1,
            limit = 20,
            search,
            cityId,
            priceLevelId,
            loyaltyTier,
            businessType,
        } = filters || {};

        const query: any = {};

        if (search) {
            query.$text = { $search: search };
        }

        if (cityId) {
            query.cityId = cityId;
        }

        if (priceLevelId) {
            query.priceLevelId = priceLevelId;
        }

        if (loyaltyTier) {
            query.loyaltyTier = loyaltyTier;
        }

        if (businessType) {
            query.businessType = businessType;
        }

        const skip = (page - 1) * limit;

        const [customers, total] = await Promise.all([
            this.customerModel
                .find(query)
                .populate('userId', 'phone email')
                .populate('cityId', 'name nameAr')
                .populate('priceLevelId', 'name discount')
                .skip(skip)
                .limit(limit)
                .sort({ createdAt: -1 }),
            this.customerModel.countDocuments(query),
        ]);

        return {
            data: customers,
            pagination: {
                total,
                page,
                limit,
                pages: Math.ceil(total / limit),
            },
        };
    }

    /**
     * Find customer by ID
     */
    async findById(id: string): Promise<CustomerDocument> {
        const customer = await this.customerModel
            .findById(id)
            .populate('userId', 'phone email avatar')
            .populate('cityId', 'name nameAr')
            .populate('marketId', 'name nameAr')
            .populate('priceLevelId', 'name discount')
            .populate('assignedSalesRepId', 'responsiblePersonName');

        if (!customer) {
            throw new NotFoundException('Customer not found');
        }

        return customer;
    }

    /**
     * Find customer by user ID
     */
    async findByUserId(userId: string): Promise<CustomerDocument | null> {
        return this.customerModel.findOne({ userId }).populate('priceLevelId');
    }

    /**
     * Update customer
     */
    async update(
        id: string,
        updateCustomerDto: UpdateCustomerDto,
    ): Promise<CustomerDocument> {
        const customer = await this.customerModel.findById(id);

        if (!customer) {
            throw new NotFoundException('Customer not found');
        }

        // If price level is being changed, track history
        if (
            updateCustomerDto.priceLevelId &&
            updateCustomerDto.priceLevelId !== customer.priceLevelId.toString()
        ) {
            await this.priceLevelHistoryModel.create({
                customerId: customer._id,
                fromPriceLevelId: customer.priceLevelId,
                toPriceLevelId: updateCustomerDto.priceLevelId,
                reason: 'Admin update',
            });
        }

        Object.assign(customer, updateCustomerDto);
        await customer.save();

        return customer;
    }

    /**
     * Approve customer
     */
    async approve(id: string, adminId: string): Promise<CustomerDocument> {
        const customer = await this.customerModel.findByIdAndUpdate(
            id,
            {
                approvedBy: adminId,
                approvedAt: new Date(),
            },
            { new: true, runValidators: false }
        ).populate('userId');

        if (!customer) {
            throw new NotFoundException('Customer not found');
        }

        // TODO: Update user status to 'active'
        // await this.usersService.update(customer.userId, { status: 'active' });

        return customer;
    }

    /**
     * Reject customer
     */
    async reject(
        id: string,
        reason: string,
    ): Promise<CustomerDocument> {
        const customer = await this.customerModel.findByIdAndUpdate(
            id,
            {
                rejectionReason: reason,
            },
            { new: true, runValidators: false }
        );

        if (!customer) {
            throw new NotFoundException('Customer not found');
        }

        return customer;
    }

    /**
     * Delete customer (soft delete)
     */
    async delete(id: string): Promise<void> {
        const customer = await this.customerModel.findById(id).populate('userId');

        if (!customer) {
            throw new NotFoundException('Customer not found');
        }

        // TODO: Soft delete user as well
        // await this.usersService.delete(customer.userId._id);

        await customer.deleteOne();
    }

    /**
     * Update credit limit
     */
    async updateCreditLimit(
        id: string,
        creditLimit: number,
    ): Promise<CustomerDocument> {
        const customer = await this.customerModel.findById(id);

        if (!customer) {
            throw new NotFoundException('Customer not found');
        }

        customer.creditLimit = creditLimit;
        await customer.save();

        return customer;
    }

    /**
     * Update statistics after order
     */
    async updateStatistics(
        customerId: string,
        orderValue: number,
    ): Promise<void> {
        const customer = await this.customerModel.findById(customerId);

        if (!customer) {
            return;
        }

        customer.totalOrders += 1;
        customer.totalSpent += orderValue;
        customer.averageOrderValue = customer.totalSpent / customer.totalOrders;
        customer.lastOrderAt = new Date();

        await customer.save();
    }

    // ═════════════════════════════════════
    // Addresses Management
    // ═════════════════════════════════════

    /**
     * Get customer addresses
     */
    async getAddresses(customerId: string): Promise<CustomerAddressDocument[]> {
        return this.addressModel.find({ customerId }).populate('cityId marketId');
    }

    /**
     * Create address
     */
    async createAddress(
        customerId: string,
        createAddressDto: CreateAddressDto,
    ): Promise<CustomerAddressDocument> {
        // Verify customer exists
        const customer = await this.customerModel.findById(customerId);
        if (!customer) {
            throw new NotFoundException('Customer not found');
        }

        // If this is set as default, unset others
        if (createAddressDto.isDefault) {
            await this.addressModel.updateMany(
                { customerId },
                { isDefault: false },
            );
        }

        const address = await this.addressModel.create({
            customerId,
            ...createAddressDto,
        });

        return address;
    }

    /**
     * Update address
     */
    async updateAddress(
        customerId: string,
        addressId: string,
        updateData: Partial<CreateAddressDto>,
    ): Promise<CustomerAddressDocument> {
        const address = await this.addressModel.findOne({
            _id: addressId,
            customerId,
        });

        if (!address) {
            throw new NotFoundException('Address not found');
        }

        // If setting as default, unset others
        if (updateData.isDefault) {
            await this.addressModel.updateMany(
                { customerId, _id: { $ne: addressId } },
                { isDefault: false },
            );
        }

        Object.assign(address, updateData);
        await address.save();

        return address;
    }

    /**
     * Delete address
     */
    async deleteAddress(customerId: string, addressId: string): Promise<void> {
        const result = await this.addressModel.deleteOne({
            _id: addressId,
            customerId,
        });

        if (result.deletedCount === 0) {
            throw new NotFoundException('Address not found');
        }
    }

    // ═════════════════════════════════════
    // Helper Methods
    // ═════════════════════════════════════

    /**
     * Generate unique customer code
     */
    private async generateCustomerCode(): Promise<string> {
        const prefix = 'CUS';
        const date = new Date();
        const year = date.getFullYear().toString().slice(-2);
        const month = (date.getMonth() + 1).toString().padStart(2, '0');

        // Get count of customers created this month
        const count = await this.customerModel.countDocuments({
            createdAt: {
                $gte: new Date(date.getFullYear(), date.getMonth(), 1),
            },
        });

        const sequence = (count + 1).toString().padStart(4, '0');

        return `${prefix}${year}${month}${sequence}`;
    }

    /**
     * Get all userIds that are linked to customer profiles
     */
    async getLinkedUserIds(): Promise<string[]> {
        const customers = await this.customerModel.find({}).select('userId');
        return customers.map(c => c.userId.toString());
    }
}
