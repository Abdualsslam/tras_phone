import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from './schemas/user.schema';

/**
 * ═══════════════════════════════════════════════════════════════
 * 👥 Users Service
 * ═══════════════════════════════════════════════════════════════
 */
@Injectable()
export class UsersService {
    constructor(
        @InjectModel(User.name) private userModel: Model<UserDocument>,
    ) { }

    /**
     * Find user by ID
     */
    async findById(id: string): Promise<UserDocument> {
        const user = await this.userModel.findById(id);

        if (!user) {
            throw new NotFoundException('User not found');
        }

        return user;
    }

    /**
     * Find user by phone
     */
    async findByPhone(phone: string): Promise<UserDocument | null> {
        return this.userModel.findOne({ phone });
    }

    /**
     * Find user by email
     */
    async findByEmail(email: string): Promise<UserDocument | null> {
        return this.userModel.findOne({ email });
    }

    /**
     * Update user
     */
    async update(
        id: string,
        updateData: Partial<User>,
    ): Promise<UserDocument> {
        const user = await this.userModel.findByIdAndUpdate(
            id,
            { $set: updateData },
            { new: true },
        );

        if (!user) {
            throw new NotFoundException('User not found');
        }

        return user;
    }

    /**
     * Delete user (soft delete)
     */
    async delete(id: string): Promise<void> {
        const user = await this.userModel.findById(id);

        if (!user) {
            throw new NotFoundException('User not found');
        }

        user.status = 'deleted';
        user.deletedAt = new Date();
        await user.save();
    }

    /**
     * Find customer-type users that don't have a linked customer profile
     */
    async findUnlinkedCustomerUsers(linkedUserIds: string[]): Promise<UserDocument[]> {
        return this.userModel.find({
            userType: 'customer',
            status: 'active',
            _id: { $nin: linkedUserIds },
        }).select('_id phone email createdAt').sort({ createdAt: -1 });
    }
}
