/**
 * ═══════════════════════════════════════════════════════════════
 * 🌱 Admin Seed Script
 * ═══════════════════════════════════════════════════════════════
 * Creates a super admin user for initial system access
 *
 * Usage: npx ts-node src/scripts/seed-admin.ts
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { getModelToken } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import * as bcrypt from 'bcrypt';

interface UserDoc {
  _id: any;
  phone: string;
  email?: string;
  password: string;
  userType: string;
  status: string;
}

interface AdminUserDoc {
  _id: any;
  userId: any;
  employeeCode: string;
  fullName: string;
  fullNameAr?: string;
  department?: string;
  position?: string;
  isSuperAdmin: boolean;
  employmentStatus: string;
}

async function seedAdmin() {
  console.log('🌱 Starting admin seed...\n');

  const app = await NestFactory.createApplicationContext(AppModule);

  try {
    const userModel = app.get<Model<UserDoc>>(getModelToken('User'));
    const adminUserModel = app.get<Model<AdminUserDoc>>(
      getModelToken('AdminUser'),
    );

    // Admin credentials
    const adminData = {
      phone: '+966500000000',
      email: 'admin@trasphone.com',
      password: 'Admin@123456',
      fullName: 'Super Admin',
      fullNameAr: 'المدير العام',
      employeeCode: 'EMP001',
      department: 'Management',
      position: 'Super Administrator',
    };

    // Check if admin already exists
    const existingUser = await userModel.findOne({
      $or: [{ phone: adminData.phone }, { email: adminData.email }],
    });

    if (existingUser) {
      console.log('⚠️  Admin user already exists:');
      console.log(`   Email: ${existingUser.email}`);
      console.log(`   Phone: ${existingUser.phone}`);
      console.log('\n   Use these credentials to login.');
      await app.close();
      return;
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(adminData.password, 10);

    // Create base user
    const user = await userModel.create({
      phone: adminData.phone,
      email: adminData.email,
      password: hashedPassword,
      userType: 'admin',
      status: 'active',
      phoneVerifiedAt: new Date(),
      emailVerifiedAt: new Date(),
    });

    console.log('✅ Base user created');

    // Create admin user profile
    await adminUserModel.create({
      userId: user._id,
      employeeCode: adminData.employeeCode,
      fullName: adminData.fullName,
      fullNameAr: adminData.fullNameAr,
      department: adminData.department,
      position: adminData.position,
      isSuperAdmin: true,
      canAccessWeb: true,
      canAccessMobile: true,
      employmentStatus: 'active',
      hireDate: new Date(),
    });

    console.log('✅ Admin profile created');

    console.log('\n════════════════════════════════════════');
    console.log('🎉 Admin created successfully!');
    console.log('════════════════════════════════════════');
    console.log(`📧 Email:    ${adminData.email}`);
    console.log(`📱 Phone:    ${adminData.phone}`);
    console.log(`🔑 Password: ${adminData.password}`);
    console.log(`👤 Name:     ${adminData.fullName}`);
    console.log('════════════════════════════════════════\n');
  } catch (error) {
    console.error('❌ Error seeding admin:', error);
  } finally {
    await app.close();
  }
}

seedAdmin();
