import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
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
import { UsersService } from '@modules/users/users.service';
import { User, UserDocument } from '@modules/users/schemas/user.schema';
import { AuditService } from '@modules/audit/audit.service';
import { AuditAction, AuditResource } from '@modules/audit/schemas/audit-log.schema';

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
    @InjectModel(User.name)
    private userModel: Model<UserDocument>,
    private usersService: UsersService,
    private auditService: AuditService,
  ) {}

  /**
   * Helper method for retry logic with exponential backoff
   */
  private async retryWithBackoff<T>(
    operation: () => Promise<T>,
    maxRetries: number = 3,
    baseDelay: number = 100,
  ): Promise<T> {
    let lastError: any;

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error: any) {
        lastError = error;

        // Only retry on duplicate key errors (11000)
        if (error?.code !== 11000) {
          throw error;
        }

        // Don't retry on the last attempt
        if (attempt === maxRetries - 1) {
          throw error;
        }

        // Calculate exponential backoff delay
        const delay = baseDelay * Math.pow(2, attempt);
        console.log(
          `[CustomersService] Retry attempt ${attempt + 1}/${maxRetries} after ${delay}ms`,
        );

        // Wait before retrying
        await new Promise((resolve) => setTimeout(resolve, delay));
      }
    }

    throw lastError;
  }

  /**
   * Create new customer
   * Uses findOneAndUpdate with upsert to prevent race conditions
   */
  async create(
    createCustomerDto: CreateCustomerDto,
  ): Promise<CustomerDocument> {
    return this.retryWithBackoff(async () => {
      // Use findOneAndUpdate with upsert for atomic operation
      const customer = await this.customerModel.findOneAndUpdate(
        { userId: createCustomerDto.userId },
        { $setOnInsert: createCustomerDto },
        {
          new: true,
          upsert: true,
          runValidators: true,
          setDefaultsOnInsert: true,
        },
      );

      if (!customer) {
        throw new ConflictException('Failed to create customer');
      }

      // Check if this was an insert (new customer) or update (existing)
      const isNewCustomer = customer.get('wasNew', false);

      if (!isNewCustomer) {
        // Customer already existed
        throw new ConflictException('Customer already exists for this user');
      }

      console.log(
        `[CustomersService] Customer created successfully for user: ${createCustomerDto.userId}`,
      );

      return customer;
    });
  }

  /**
   * Create customer profile automatically (for auto-creation when profile is missing)
   * This method allows cityId to be optional/null
   * Uses findOneAndUpdate with upsert to prevent race conditions
   */
  async createAutoProfile(
    userId: string,
    priceLevelId: string,
    responsiblePersonName: string = 'Customer',
  ): Promise<CustomerDocument> {
    // First, check if customer already exists
    const existingCustomer = await this.findByUserId(userId);

    if (existingCustomer) {
      console.log(
        '[CustomersService] Customer already exists, returning existing customer:',
        {
          userId,
          customerId: existingCustomer._id.toString(),
        },
      );
      return existingCustomer;
    }

    // Convert userId to ObjectId
    const userIdObjectId = new Types.ObjectId(userId);
    const priceLevelIdObjectId = new Types.ObjectId(priceLevelId);

    return this.retryWithBackoff(async () => {
      // Use findOneAndUpdate with upsert for atomic operation
      const customer = await this.customerModel.findOneAndUpdate(
        { userId: userIdObjectId },
        {
          $setOnInsert: {
            userId: userIdObjectId,
            responsiblePersonName,
            shopName: 'My Shop',
            businessType: 'shop',
            // cityId is optional - will be updated later
            priceLevelId: priceLevelIdObjectId,
            creditLimit: 0,
            walletBalance: 0,
            loyaltyPoints: 0,
            loyaltyTier: 'bronze',
            preferredContactMethod: 'whatsapp',
            isTaxable: true,
          },
        },
        {
          new: true,
          upsert: true,
          runValidators: true,
          setDefaultsOnInsert: true,
        },
      );

      if (!customer) {
        throw new ConflictException('Failed to create customer profile');
      }

      // Check if this was an insert (new customer) or update (existing)
      const isNewCustomer = customer.get('wasNew', false);

      if (!isNewCustomer) {
        // Customer already existed - return it
        console.log(
          '[CustomersService] Customer already exists (from upsert), returning existing customer',
        );
      } else {
        console.log(
          `[CustomersService] Auto profile created successfully for user: ${userId}`,
        );
      }

      return customer;
    });
  }

  /**
   * Find all customers with pagination and filters
   * Now includes users with userType=customer even if they don't have a customer profile
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

    // Get all linked user IDs first (to exclude them from unlinked users)
    const allLinkedUserIds = await this.customerModel
      .find({})
      .select('userId')
      .lean();
    const linkedUserIdsSet = new Set(
      allLinkedUserIds.map((c) => c.userId.toString()),
    );

    // Get customers with profiles (all, not paginated yet)
    const [allCustomers, customersTotal] = await Promise.all([
      this.customerModel
        .find(query)
        .populate('userId', 'phone email')
        .populate('cityId', 'name nameAr')
        .populate('priceLevelId', 'name discount')
        .sort({ createdAt: -1 })
        .lean(),
      this.customerModel.countDocuments(query),
    ]);

    // Build query for unlinked users
    const unlinkedUsersQuery: any = {
      userType: 'customer',
      status: 'active',
      _id: { $nin: Array.from(linkedUserIdsSet) },
    };

    // Apply search filter to unlinked users (search in phone or email)
    if (search) {
      unlinkedUsersQuery.$or = [
        { phone: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    // Get unlinked customer users
    const unlinkedUsers = await this.userModel
      .find(unlinkedUsersQuery)
      .select('_id phone email createdAt')
      .sort({ createdAt: -1 })
      .lean();

    // Transform unlinked users to customer-like format
    const unlinkedCustomers = unlinkedUsers.map((user) => ({
      _id: user._id,
      userId: {
        _id: user._id,
        phone: user.phone,
        email: user.email,
      },
      responsiblePersonName: null,
      shopName: null,
      shopNameAr: null,
      businessType: null,
      cityId: null,
      priceLevelId: null,
      creditLimit: 0,
      creditUsed: 0,
      walletBalance: 0,
      loyaltyPoints: 0,
      loyaltyTier: 'bronze',
      totalOrders: 0,
      totalSpent: 0,
      averageOrderValue: 0,
      status: 'pending',
      createdAt: user.createdAt,
      updatedAt: user.createdAt,
      // Mark as unlinked
      isUnlinked: true,
    }));

    // Combine customers and unlinked users
    const allCustomersCombined = [...allCustomers, ...unlinkedCustomers];

    // Sort by createdAt descending
    allCustomersCombined.sort((a, b) => {
      const dateA = new Date(a.createdAt).getTime();
      const dateB = new Date(b.createdAt).getTime();
      return dateB - dateA;
    });

    // Apply pagination to combined results
    const paginatedCustomers = allCustomersCombined.slice(skip, skip + limit);
    const total = customersTotal + unlinkedUsers.length;

    return {
      data: paginatedCustomers,
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
    // Convert userId to ObjectId to ensure proper matching
    const userIdObjectId = new Types.ObjectId(userId);

    console.log('[CustomersService] findByUserId:', {
      userId,
      userIdObjectId: userIdObjectId.toString(),
    });

    const customer = await this.customerModel
      .findOne({ userId: userIdObjectId })
      .populate('userId', '_id phone email userType status')
      .populate('cityId', 'name nameAr')
      .populate('marketId', 'name nameAr')
      .populate('priceLevelId', 'name discount');

    console.log('[CustomersService] findByUserId result:', {
      found: !!customer,
      customerId: customer?._id?.toString(),
    });

    return customer;
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

    // Update User if phone, email, or userStatus is provided
    if (
      updateCustomerDto.phone ||
      updateCustomerDto.email !== undefined ||
      updateCustomerDto.userStatus
    ) {
      const userUpdateData: any = {};
      if (updateCustomerDto.phone) {
        userUpdateData.phone = updateCustomerDto.phone;
      }
      if (updateCustomerDto.email !== undefined) {
        userUpdateData.email = updateCustomerDto.email || null;
      }
      if (updateCustomerDto.userStatus) {
        userUpdateData.status = updateCustomerDto.userStatus;
      }

      await this.usersService.update(
        customer.userId.toString(),
        userUpdateData,
      );
    }

    // Separate User fields from Customer fields
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { phone, email, userStatus, ...customerUpdateData } =
      updateCustomerDto;

    // If price level is being changed, track history
    if (
      customerUpdateData.priceLevelId &&
      customerUpdateData.priceLevelId !== customer.priceLevelId.toString()
    ) {
      await this.priceLevelHistoryModel.create({
        customerId: customer._id,
        fromPriceLevelId: customer.priceLevelId,
        toPriceLevelId: customerUpdateData.priceLevelId,
        reason: 'Admin update',
      });
    }

    Object.assign(customer, customerUpdateData);
    await customer.save();

    return customer;
  }

  /**
   * Approve customer
   */
  async approve(id: string, adminId: string): Promise<CustomerDocument> {
    const customer = await this.customerModel
      .findByIdAndUpdate(
        id,
        {
          $set: {
            approvedBy: adminId,
            approvedAt: new Date(),
          },
          $unset: {
            rejectionReason: '',
          },
        },
        { new: true, runValidators: false },
      )
      .populate('userId');

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    // Update user status to 'active' when customer is approved
    const userId =
      typeof customer.userId === 'object' && customer.userId?._id
        ? customer.userId._id.toString()
        : customer.userId.toString();

    await this.usersService.update(userId, { status: 'active' });

    await this.auditService.log({
      action: AuditAction.APPROVE,
      resource: AuditResource.CUSTOMER,
      resourceId: id,
      resourceName: (customer as any).shopName ?? (customer as any).responsiblePersonName ?? id,
      actorType: 'admin',
      actorId: adminId,
      description: `Customer approved: ${(customer as any).shopName ?? id}`,
      descriptionAr: 'تمت الموافقة على العميل',
      severity: 'info',
      success: true,
    }).catch(() => undefined);

    return customer;
  }

  /**
   * Reject customer
   */
  async reject(id: string, reason: string, adminId?: string): Promise<CustomerDocument> {
    const customer = await this.customerModel
      .findByIdAndUpdate(
        id,
        {
          $set: {
            rejectionReason: reason,
          },
          $unset: {
            approvedAt: '',
            approvedBy: '',
          },
        },
        { new: true, runValidators: false },
      )
      .populate('userId');

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    // Update user status to 'suspended' when customer is rejected
    const userId =
      typeof customer.userId === 'object' && customer.userId?._id
        ? customer.userId._id.toString()
        : customer.userId.toString();

    await this.usersService.update(userId, { status: 'suspended' });

    if (adminId) {
      await this.auditService.log({
        action: AuditAction.REJECT,
        resource: AuditResource.CUSTOMER,
        resourceId: id,
        resourceName: (customer as any).shopName ?? (customer as any).responsiblePersonName ?? id,
        actorType: 'admin',
        actorId: adminId,
        description: `Customer rejected: ${reason}`,
        descriptionAr: 'تم رفض العميل',
        severity: 'warning',
        success: true,
      }).catch(() => undefined);
    }

    return customer;
  }

  /**
   * Delete customer (soft delete)
   */
  async delete(id: string, reason?: string): Promise<void> {
    const customer = await this.customerModel.findById(id).populate('userId');

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    // Soft delete user as well
    const userId =
      typeof customer.userId === 'object' && customer.userId?._id
        ? customer.userId._id.toString()
        : customer.userId.toString();

    await this.usersService.delete(userId, reason);

    await customer.deleteOne();
  }

  /**
   * Delete account by customer (self-delete)
   */
  async deleteAccount(customerId: string, reason?: string): Promise<void> {
    const customer = await this.customerModel
      .findById(customerId)
      .populate('userId');

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    const userId =
      typeof customer.userId === 'object' && customer.userId?._id
        ? customer.userId._id.toString()
        : customer.userId.toString();

    await this.usersService.delete(userId, reason);

    // Soft delete customer profile as well
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
   * Increment credit used (when order is placed on credit)
   */
  async incrementCreditUsed(
    customerId: string,
    amount: number,
  ): Promise<CustomerDocument> {
    const customer = await this.customerModel.findByIdAndUpdate(
      customerId,
      { $inc: { creditUsed: amount } },
      { new: true },
    );
    if (!customer) throw new NotFoundException('Customer not found');
    return customer;
  }

  /**
   * Decrement credit used (when payment is made or order is cancelled)
   */
  async decrementCreditUsed(
    customerId: string,
    amount: number,
  ): Promise<CustomerDocument> {
    const customer = await this.customerModel.findById(customerId);
    if (!customer) throw new NotFoundException('Customer not found');
    const newCreditUsed = Math.max(0, (customer.creditUsed ?? 0) - amount);
    customer.creditUsed = newCreditUsed;
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
    return this.addressModel.find({ customerId }).populate('cityId');
  }

  /**
   * Create address
   */
  async createAddress(
    customerId: string,
    createAddressDto: CreateAddressDto,
  ): Promise<CustomerAddressDocument> {
    // Verify customer exists and populate user data
    const customer = await this.customerModel
      .findById(customerId)
      .populate('userId', 'phone email');

    if (!customer) {
      throw new NotFoundException('Customer not found');
    }

    // Auto-fill recipientName and phone from customer profile if not provided
    const addressData: any = {
      customerId,
      ...createAddressDto,
    };

    // Auto-fill recipientName from customer.responsiblePersonName if not provided
    if (!addressData.recipientName && customer.responsiblePersonName) {
      addressData.recipientName = customer.responsiblePersonName;
    }

    // Auto-fill phone from customer.user.phone if not provided
    if (
      !addressData.phone &&
      customer.userId &&
      typeof customer.userId === 'object'
    ) {
      const user = customer.userId as any;
      if (user.phone) {
        addressData.phone = user.phone;
      }
    }

    // If this is set as default, unset others
    if (createAddressDto.isDefault) {
      await this.addressModel.updateMany({ customerId }, { isDefault: false });
    }

    const address = await this.addressModel.create(addressData);

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
   * Get all userIds that are linked to customer profiles
   */
  async getLinkedUserIds(): Promise<string[]> {
    const customers = await this.customerModel.find({}).select('userId');
    return customers.map((c) => c.userId.toString());
  }
}
