import {
  Injectable,
  NotFoundException,
  ConflictException,
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
import { UsersService } from '@modules/users/users.service';
import { User, UserDocument } from '@modules/users/schemas/user.schema';

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
  ) {}

  /**
   * Create new customer
   */
  async create(
    createCustomerDto: CreateCustomerDto,
  ): Promise<CustomerDocument> {
    // Check if customer already exists for this user
    const existingCustomer = await this.customerModel.findOne({
      userId: createCustomerDto.userId,
    });

    if (existingCustomer) {
      throw new ConflictException('Customer already exists for this user');
    }

    // Use retry mechanism to handle race conditions with customerCode
    let customerCreated = false;
    let retryCount = 0;
    const maxRetries = 5;

    while (!customerCreated && retryCount < maxRetries) {
      try {
        // Check again before creating (race condition check)
        const checkCustomer = await this.customerModel.findOne({
          userId: createCustomerDto.userId,
        });

        if (checkCustomer) {
          throw new ConflictException('Customer already exists for this user');
        }

        // Generate customer code
        const customerCode = await this.generateCustomerCode();

        const customer = await this.customerModel.create({
          ...createCustomerDto,
          customerCode,
        });

        customerCreated = true;
        console.log(
          `[CustomersService] Customer created successfully with code: ${customerCode}`,
        );
        return customer;
      } catch (e: any) {
        if (e instanceof ConflictException) {
          // Re-throw ConflictException as-is
          throw e;
        }

        if (e?.code === 11000) {
          // Duplicate key error - check if customer was created
          const raceConditionCustomer = await this.customerModel.findOne({
            userId: createCustomerDto.userId,
          });

          if (raceConditionCustomer) {
            throw new ConflictException(
              'Customer already exists for this user',
            );
          } else {
            // Duplicate is in customerCode (race condition) - retry with new code
            retryCount++;
            console.log(
              `[CustomersService] Duplicate customerCode detected in create, retrying (${retryCount}/${maxRetries})...`,
            );

            if (retryCount >= maxRetries) {
              throw new ConflictException(
                'Failed to create customer after multiple attempts. Please try again.',
              );
            }
            // Wait a bit before retrying to avoid immediate collision
            await new Promise((resolve) => setTimeout(resolve, 100));
            continue;
          }
        } else {
          // Other errors - throw them
          throw e;
        }
      }
    }

    // This should never be reached, but just in case
    throw new ConflictException('Failed to create customer. Please try again.');
  }

  /**
   * Create customer profile automatically (for auto-creation when profile is missing)
   * This method allows cityId to be optional/null
   */
  async createAutoProfile(
    userId: string,
    priceLevelId: string,
    responsiblePersonName: string = 'Customer',
  ): Promise<CustomerDocument> {
    // Check if customer already exists for this user
    const existingCustomer = await this.customerModel.findOne({
      userId,
    });

    if (existingCustomer) {
      // Customer already exists - return it instead of throwing error
      return existingCustomer;
    }

    // Use retry mechanism to handle race conditions with customerCode
    let customerCreated = false;
    let retryCount = 0;
    const maxRetries = 5;

    while (!customerCreated && retryCount < maxRetries) {
      try {
        // Check again before creating (race condition check)
        const checkCustomer = await this.customerModel.findOne({
          userId,
        });

        if (checkCustomer) {
          // Customer was created by another request - return it
          return checkCustomer;
        }

        // Generate customer code
        const customerCode = await this.generateCustomerCode();

        const customer = await this.customerModel.create({
          userId,
          customerCode,
          responsiblePersonName,
          shopName: 'My Shop',
          businessType: 'shop',
          // cityId is optional - will be updated later
          priceLevelId,
          creditLimit: 0,
          walletBalance: 0,
          loyaltyPoints: 0,
          loyaltyTier: 'bronze',
          preferredContactMethod: 'whatsapp',
        });

        customerCreated = true;
        console.log(
          `[CustomersService] Auto profile created successfully with code: ${customerCode}`,
        );
        return customer;
      } catch (e: any) {
        console.error('[CustomersService] Error creating auto profile:', {
          error: e.message,
          errorCode: e?.code,
          userId,
          retryCount,
        });

        if (e?.code === 11000) {
          // Duplicate key error - check if customer was created
          const raceConditionCustomer = await this.customerModel.findOne({
            userId,
          });

          if (raceConditionCustomer) {
            // Customer was created by another request - return it
            console.log(
              '[CustomersService] Customer created by race condition, returning existing customer',
            );
            return raceConditionCustomer;
          } else {
            // Duplicate is in customerCode (race condition) - retry with new code
            retryCount++;
            console.log(
              `[CustomersService] Duplicate customerCode detected, retrying (${retryCount}/${maxRetries})...`,
            );

            if (retryCount >= maxRetries) {
              throw new ConflictException(
                'Failed to create customer profile after multiple attempts. Please try again.',
              );
            }
            // Wait a bit before retrying to avoid immediate collision
            await new Promise((resolve) => setTimeout(resolve, 100));
            continue;
          }
        } else {
          // Other errors - throw them
          throw e;
        }
      }
    }

    // This should never be reached, but just in case
    throw new ConflictException(
      'Failed to create customer profile. Please try again.',
    );
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
      customerCode: null,
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
    return this.customerModel
      .findOne({ userId })
      .populate('userId', '_id phone email userType status')
      .populate('cityId', 'name nameAr')
      .populate('marketId', 'name nameAr')
      .populate('priceLevelId', 'name discount');
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

    return customer;
  }

  /**
   * Reject customer
   */
  async reject(id: string, reason: string): Promise<CustomerDocument> {
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
   * Generate unique customer code
   * Uses retry mechanism to handle race conditions
   */
  async generateCustomerCode(maxRetries: number = 10): Promise<string> {
    const prefix = 'CUS';
    const date = new Date();
    const year = date.getFullYear().toString().slice(-2);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');

    for (let attempt = 0; attempt < maxRetries; attempt++) {
      // Get count of customers created this month
      const count = await this.customerModel.countDocuments({
        createdAt: {
          $gte: new Date(date.getFullYear(), date.getMonth(), 1),
        },
      });

      // Generate sequence with attempt offset to handle race conditions
      const sequence = (count + 1 + attempt).toString().padStart(4, '0');
      const customerCode = `${prefix}${year}${month}${sequence}`;

      // Check if code already exists
      const existingCustomer = await this.customerModel.findOne({
        customerCode,
      });

      if (!existingCustomer) {
        return customerCode;
      }

      // If code exists, try next sequence number
      console.log(
        `[CustomersService] Customer code ${customerCode} already exists, trying next...`,
      );
    }

    // If all retries failed, throw error
    throw new Error(
      'Failed to generate unique customer code after multiple attempts',
    );
  }

  /**
   * Get all userIds that are linked to customer profiles
   */
  async getLinkedUserIds(): Promise<string[]> {
    const customers = await this.customerModel.find({}).select('userId');
    return customers.map((c) => c.userId.toString());
  }
}
