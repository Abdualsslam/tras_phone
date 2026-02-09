/**
 * ═══════════════════════════════════════════════════════════════
 * 🔧 Fix Admin Super Permissions
 * ═══════════════════════════════════════════════════════════════
 * Sets isSuperAdmin: true for admin users to grant full permission access.
 * Run when admin gets 403 for roles.view, admins.view, etc.
 *
 * Usage: npx ts-node -r tsconfig-paths/register src/scripts/fix-admin-super.ts
 *        npx ts-node -r tsconfig-paths/register src/scripts/fix-admin-super.ts --email admin@trasphone.com
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { getModelToken } from '@nestjs/mongoose';
import { Model } from 'mongoose';

async function fixAdminSuper() {
  console.log('🔧 Fixing admin super permissions...\n');

  const app = await NestFactory.createApplicationContext(AppModule);

  try {
    const userModel = app.get<Model<any>>(getModelToken('User'));
    const adminUserModel = app.get<Model<any>>(getModelToken('AdminUser'));

    const email = process.argv.includes('--email')
      ? process.argv[process.argv.indexOf('--email') + 1]
      : 'admin@trasphone.com';

    const user = await userModel.findOne({
      $or: [{ email }, { phone: '+966500000000' }],
      userType: 'admin',
    });

    if (!user) {
      console.log(`❌ No admin user found with email/phone: ${email}`);
      await app.close();
      return;
    }

    let adminUser = await adminUserModel.findOne({ userId: user._id });

    if (!adminUser) {
      console.log('⚠️  AdminUser profile not found. Creating it now...');
      const employeeCode = `EMP${String(Date.now()).slice(-6)}`;
      adminUser = await adminUserModel.create({
        userId: user._id,
        employeeCode,
        fullName: (user as any).fullName || 'Admin',
        fullNameAr: 'المدير',
        department: 'Management',
        position: 'Administrator',
        isSuperAdmin: true,
        canAccessWeb: true,
        canAccessMobile: true,
        employmentStatus: 'active',
        hireDate: new Date(),
      });
      console.log(`✅ AdminUser profile created with isSuperAdmin: true`);
      console.log(`   User ID: ${user._id}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Employee Code: ${employeeCode}`);
      console.log('\n   Admin now has full system access. Please log in again.');
      await app.close();
      return;
    }

    if (adminUser.isSuperAdmin) {
      console.log('✅ Admin already has super admin permissions');
      console.log(`   Email: ${user.email}`);
      await app.close();
      return;
    }

    await adminUserModel.updateOne(
      { _id: adminUser._id },
      { $set: { isSuperAdmin: true } },
    );

    console.log('✅ Successfully set isSuperAdmin: true');
    console.log(`   User ID: ${user._id}`);
    console.log(`   Email: ${user.email}`);
    console.log('\n   Admin now has full system access. Please log in again.');
  } catch (error: any) {
    console.error('❌ Error:', error.message);
  } finally {
    await app.close();
  }
}

fixAdminSuper();
