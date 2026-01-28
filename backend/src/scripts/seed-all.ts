/**
 * ═══════════════════════════════════════════════════════════════
 * 🌱 Complete Database Seed Script
 * ═══════════════════════════════════════════════════════════════
 * Seeds all core models with dummy data for development/testing
 * 
 * Usage: npm run seed:all
 */

import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { Connection } from 'mongoose';
import { getConnectionToken } from '@nestjs/mongoose';
import * as bcrypt from 'bcrypt';

// ═════════════════════════════════════
// Helper Functions
// ═════════════════════════════════════
const randomItem = <T>(arr: T[]): T => arr[Math.floor(Math.random() * arr.length)];
const randomNumber = (min: number, max: number): number => Math.floor(Math.random() * (max - min + 1)) + min;
const randomPrice = (min: number, max: number): number => parseFloat((Math.random() * (max - min) + min).toFixed(2));
const generateSKU = (prefix: string, index: number): string => `${prefix}-${String(index).padStart(5, '0')}`;
const randomDate = (daysAgo: number): Date => new Date(Date.now() - Math.random() * daysAgo * 24 * 60 * 60 * 1000);

async function seedAll() {
    console.log('\n🌱 Starting complete database seed...\n');
    console.log('═'.repeat(50));

    const app = await NestFactory.createApplicationContext(AppModule);

    try {
        // Get MongoDB connection directly
        const connection = app.get<Connection>(getConnectionToken());

        // Get collections directly from MongoDB
        const usersCollection = connection.collection('users');
        const adminUsersCollection = connection.collection('admin_users');
        const customersCollection = connection.collection('customers');
        const categoriesCollection = connection.collection('categories');
        const brandsCollection = connection.collection('brands');
        const qualityTypesCollection = connection.collection('quality_types');
        const productsCollection = connection.collection('products');
        const ordersCollection = connection.collection('orders');
        const warehousesCollection = connection.collection('warehouses');
        const couponsCollection = connection.collection('coupons');
        const ticketsCollection = connection.collection('tickets');
        const notificationsCollection = connection.collection('notifications');

        // ═════════════════════════════════════
        // 1. Seed Admin
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Admin...');

        let adminUser = await usersCollection.findOne({ email: 'admin@trasphone.com' });
        if (!adminUser) {
            const hashedPassword = await bcrypt.hash('Admin@123456', 10);
            const result = await usersCollection.insertOne({
                phone: '+966500000000',
                email: 'admin@trasphone.com',
                password: hashedPassword,
                userType: 'admin',
                status: 'active',
                phoneVerifiedAt: new Date(),
                emailVerifiedAt: new Date(),
                createdAt: new Date(),
                updatedAt: new Date(),
            });

            adminUser = { _id: result.insertedId } as any;

            await adminUsersCollection.insertOne({
                userId: result.insertedId,
                employeeCode: 'EMP001',
                fullName: 'Super Admin',
                fullNameAr: 'المدير العام',
                department: 'Management',
                position: 'Super Administrator',
                isSuperAdmin: true,
                canAccessWeb: true,
                canAccessMobile: true,
                employmentStatus: 'active',
                hireDate: new Date(),
                createdAt: new Date(),
                updatedAt: new Date(),
            });
            console.log('   ✅ Admin created');
        } else {
            console.log('   ⏭️  Admin already exists');
        }

        // ═════════════════════════════════════
        // 2. Seed Categories
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Categories...');

        const categoriesData = [
            { name: 'Screens', nameAr: 'شاشات', slug: 'screens', order: 1 },
            { name: 'Batteries', nameAr: 'بطاريات', slug: 'batteries', order: 2 },
            { name: 'Charging Ports', nameAr: 'منافذ الشحن', slug: 'charging-ports', order: 3 },
            { name: 'Back Covers', nameAr: 'أغطية خلفية', slug: 'back-covers', order: 4 },
            { name: 'Cameras', nameAr: 'كاميرات', slug: 'cameras', order: 5 },
            { name: 'Speakers', nameAr: 'سماعات', slug: 'speakers', order: 6 },
            { name: 'Buttons & Flex', nameAr: 'أزرار وكابلات', slug: 'buttons-flex', order: 7 },
            { name: 'Tools', nameAr: 'أدوات', slug: 'tools', order: 8 },
        ];

        const categories: any[] = [];
        for (const cat of categoriesData) {
            let category = await categoriesCollection.findOne({ slug: cat.slug });
            if (!category) {
                const result = await categoriesCollection.insertOne({
                    ...cat,
                    isActive: true,
                    createdAt: new Date(),
                    updatedAt: new Date(),
                });
                category = { _id: result.insertedId, ...cat };
            }
            categories.push(category);
        }
        console.log(`   ✅ ${categories.length} categories ready`);

        // ═════════════════════════════════════
        // 3. Seed Brands
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Brands...');

        const brandsData = [
            { name: 'Apple', nameAr: 'أبل', slug: 'apple' },
            { name: 'Samsung', nameAr: 'سامسونج', slug: 'samsung' },
            { name: 'Huawei', nameAr: 'هواوي', slug: 'huawei' },
            { name: 'Xiaomi', nameAr: 'شاومي', slug: 'xiaomi' },
            { name: 'OnePlus', nameAr: 'ون بلس', slug: 'oneplus' },
            { name: 'OPPO', nameAr: 'أوبو', slug: 'oppo' },
            { name: 'Vivo', nameAr: 'فيفو', slug: 'vivo' },
            { name: 'Google', nameAr: 'جوجل', slug: 'google' },
        ];

        const brands: any[] = [];
        for (const br of brandsData) {
            let brand = await brandsCollection.findOne({ slug: br.slug });
            if (!brand) {
                const result = await brandsCollection.insertOne({
                    ...br,
                    isActive: true,
                    isFeatured: true,
                    createdAt: new Date(),
                    updatedAt: new Date(),
                });
                brand = { _id: result.insertedId, ...br };
            }
            brands.push(brand);
        }
        console.log(`   ✅ ${brands.length} brands ready`);

        // ═════════════════════════════════════
        // 4. Seed Quality Types
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Quality Types...');

        let qualityType = await qualityTypesCollection.findOne({ slug: 'original' });
        if (!qualityType) {
            const result = await qualityTypesCollection.insertOne({
                name: 'Original',
                nameAr: 'أصلي',
                slug: 'original',
                order: 1,
                isActive: true,
                createdAt: new Date(),
                updatedAt: new Date(),
            });
            qualityType = { _id: result.insertedId };
        }
        console.log('   ✅ Quality types ready');

        // ═════════════════════════════════════
        // 5. Seed Products
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Products...');

        const productNames = [
            'LCD Screen Assembly', 'OLED Display', 'Battery 3000mAh', 'Battery 4500mAh',
            'Charging Port Flex', 'USB-C Connector', 'Back Glass Cover', 'Metal Back Panel',
            'Rear Camera Module', 'Front Camera', 'Earpiece Speaker', 'Loudspeaker',
            'Power Button Flex', 'Volume Button Flex', 'Repair Tool Kit', 'Screwdriver Set',
        ];

        const existingProducts = await productsCollection.countDocuments();
        if (existingProducts < 50) {
            const productsToCreate: any[] = [];
            for (let i = 0; i < 50; i++) {
                const brand = randomItem(brands);
                const category = randomItem(categories);
                const name = randomItem(productNames);
                const basePrice = randomPrice(50, 500);
                const sku = generateSKU('PRD', existingProducts + i + 1);
                const slug = `${brand.slug}-${name.toLowerCase().replace(/\s+/g, '-')}-${Date.now()}-${i}`;

                productsToCreate.push({
                    sku,
                    name: `${brand.name} ${name}`,
                    nameAr: `${name} ${brand.nameAr}`,
                    slug,
                    description: `High quality ${name.toLowerCase()} for ${brand.name} devices`,
                    descriptionAr: `قطعة غيار عالية الجودة`,
                    categoryId: category._id,
                    brandId: brand._id,
                    qualityTypeId: qualityType._id,
                    basePrice: basePrice,
                    costPrice: basePrice * 0.6,
                    stockQuantity: randomNumber(0, 200),
                    lowStockThreshold: 10,
                    status: randomItem(['active', 'active', 'active', 'draft']),
                    isActive: true,
                    isFeatured: Math.random() > 0.7,
                    weight: randomNumber(10, 500),
                    createdAt: randomDate(90),
                    updatedAt: new Date(),
                });
            }
            await productsCollection.insertMany(productsToCreate);
            console.log(`   ✅ 50 products created`);
        } else {
            console.log(`   ⏭️  Products already exist (${existingProducts})`);
        }

        // ═════════════════════════════════════
        // 6. Seed Customers
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Customers...');

        // First create a city and price level if needed
        const citiesCollection = connection.collection('cities');
        const priceLevelsCollection = connection.collection('price_levels');

        let city = await citiesCollection.findOne({ slug: 'riyadh' });
        if (!city) {
            const result = await citiesCollection.insertOne({
                name: 'Riyadh',
                nameAr: 'الرياض',
                slug: 'riyadh',
                isActive: true,
                createdAt: new Date(),
                updatedAt: new Date(),
            });
            city = { _id: result.insertedId };
        }

        let priceLevel = await priceLevelsCollection.findOne({ slug: 'retail' });
        if (!priceLevel) {
            const result = await priceLevelsCollection.insertOne({
                name: 'Retail',
                nameAr: 'تجزئة',
                slug: 'retail',
                discount: 0,
                isDefault: true,
                isActive: true,
                createdAt: new Date(),
                updatedAt: new Date(),
            });
            priceLevel = { _id: result.insertedId };
        }

        const customerNames = [
            { shop: 'شركة الهواتف الذكية', contact: 'أحمد محمد' },
            { shop: 'مؤسسة الاتصالات المتقدمة', contact: 'خالد عبدالله' },
            { shop: 'متجر موبايل بلس', contact: 'فهد السعيد' },
            { shop: 'شركة تقنية الجوال', contact: 'محمد العتيبي' },
            { shop: 'مركز صيانة الهواتف', contact: 'سعد الحربي' },
            { shop: 'مؤسسة الإلكترونيات الحديثة', contact: 'عبدالرحمن النصر' },
            { shop: 'شركة موبايل تك', contact: 'تركي القحطاني' },
            { shop: 'متجر الجوالات الذكية', contact: 'ناصر الشمري' },
            { shop: 'مؤسسة التقنية الرقمية', contact: 'بندر المطيري' },
            { shop: 'شركة الهاتف العربي', contact: 'سلطان الدوسري' },
        ];

        const existingCustomers = await customersCollection.countDocuments();
        if (existingCustomers < 10) {
            const hashedPassword = await bcrypt.hash('Customer@123', 10);

            for (let i = 0; i < customerNames.length; i++) {
                const cust = customerNames[i];
                const phone = `+9665${String(randomNumber(10000000, 99999999))}`;

                const userResult = await usersCollection.insertOne({
                    phone,
                    email: `customer${Date.now()}${i}@example.com`,
                    password: hashedPassword,
                    userType: 'customer',
                    status: 'active',
                    phoneVerifiedAt: new Date(),
                    createdAt: randomDate(180),
                    updatedAt: new Date(),
                });

                await customersCollection.insertOne({
                    userId: userResult.insertedId,
                    responsiblePersonName: cust.contact,
                    shopName: cust.shop,
                    shopNameAr: cust.shop,
                    businessType: randomItem(['shop', 'technician', 'distributor']),
                    cityId: city._id,
                    priceLevelId: priceLevel._id,
                    creditLimit: randomNumber(5000, 50000),
                    creditUsed: 0,
                    walletBalance: 0,
                    loyaltyPoints: 0,
                    loyaltyTier: 'bronze',
                    riskScore: 50,
                    totalOrders: randomNumber(0, 50),
                    totalSpent: randomNumber(0, 100000),
                    createdAt: randomDate(180),
                    updatedAt: new Date(),
                });
            }
            console.log(`   ✅ 10 customers created`);
        } else {
            console.log(`   ⏭️  Customers already exist (${existingCustomers})`);
        }

        // ═════════════════════════════════════
        // 7. Seed Warehouses
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Warehouses...');

        const warehousesData = [
            { name: 'المستودع الرئيسي', nameEn: 'Main Warehouse', code: 'WH-MAIN', city: 'الرياض', isDefault: true },
            { name: 'مستودع جدة', nameEn: 'Jeddah Warehouse', code: 'WH-JED', city: 'جدة', isDefault: false },
            { name: 'مستودع الدمام', nameEn: 'Dammam Warehouse', code: 'WH-DAM', city: 'الدمام', isDefault: false },
        ];

        for (const wh of warehousesData) {
            const exists = await warehousesCollection.findOne({ code: wh.code });
            if (!exists) {
                await warehousesCollection.insertOne({
                    ...wh,
                    address: { city: wh.city, country: 'Saudi Arabia' },
                    isActive: true,
                    createdAt: new Date(),
                    updatedAt: new Date(),
                });
            }
        }
        console.log(`   ✅ Warehouses ready`);

        // ═════════════════════════════════════
        // 8. Seed Coupons
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Coupons...');

        const couponsData = [
            { code: 'WELCOME10', type: 'percentage', value: 10, description: 'خصم ترحيبي 10%' },
            { code: 'SAVE50', type: 'fixed', value: 50, description: 'خصم 50 ريال' },
            { code: 'SUMMER20', type: 'percentage', value: 20, description: 'عرض الصيف 20%' },
            { code: 'VIP15', type: 'percentage', value: 15, description: 'خصم VIP' },
            { code: 'FLASH30', type: 'fixed', value: 30, description: 'عرض فلاش' },
        ];

        for (const cp of couponsData) {
            const exists = await couponsCollection.findOne({ code: cp.code });
            if (!exists) {
                await couponsCollection.insertOne({
                    ...cp,
                    isActive: true,
                    usageLimit: randomNumber(50, 200),
                    usageCount: randomNumber(0, 30),
                    minOrderAmount: cp.type === 'fixed' ? cp.value * 2 : 100,
                    startDate: new Date(),
                    endDate: new Date(Date.now() + 90 * 24 * 60 * 60 * 1000),
                    createdAt: new Date(),
                    updatedAt: new Date(),
                });
            }
        }
        console.log(`   ✅ Coupons ready`);

        // ═════════════════════════════════════
        // 9. Seed Orders
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Orders...');

        const existingOrders = await ordersCollection.countDocuments();
        if (existingOrders < 20) {
            const customers = await customersCollection.find().limit(10).toArray();
            const products = await productsCollection.find().limit(20).toArray();

            if (customers.length > 0 && products.length > 0) {
                const orderStatuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered'];
                const paymentStatuses = ['pending', 'paid', 'paid', 'paid'];

                for (let i = 0; i < 20; i++) {
                    const customer = randomItem(customers) as any;
                    const itemCount = randomNumber(1, 5);
                    let subtotal = 0;
                    const items: any[] = [];

                    for (let j = 0; j < itemCount; j++) {
                        const product = randomItem(products) as any;
                        const quantity = randomNumber(1, 10);
                        const price = randomPrice(50, 300);
                        subtotal += price * quantity;

                        items.push({
                            product: product._id,
                            productSnapshot: {
                                name: product.name,
                                sku: product.sku,
                                price: price,
                            },
                            quantity,
                            unitPrice: price,
                            totalPrice: price * quantity,
                        });
                    }

                    await ordersCollection.insertOne({
                        orderNumber: `ORD-${String(Date.now()).slice(-6)}${i}`,
                        customer: customer._id,
                        items,
                        subtotal,
                        discount: Math.random() > 0.7 ? randomNumber(10, 50) : 0,
                        tax: subtotal * 0.15,
                        total: subtotal * 1.15,
                        status: randomItem(orderStatuses),
                        paymentStatus: randomItem(paymentStatuses),
                        paymentMethod: randomItem(['bank_transfer', 'cash', 'credit']),
                        shippingAddress: {
                            city: randomItem(['الرياض', 'جدة', 'الدمام']),
                            country: 'Saudi Arabia',
                        },
                        createdAt: randomDate(60),
                        updatedAt: new Date(),
                    });
                }
                console.log(`   ✅ 20 orders created`);
            }
        } else {
            console.log(`   ⏭️  Orders already exist (${existingOrders})`);
        }

        // ═════════════════════════════════════
        // 10. Seed Support Tickets
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Support Tickets...');

        const existingTickets = await ticketsCollection.countDocuments();
        if (existingTickets < 10) {
            const customers = await customersCollection.find().limit(5).toArray();
            const ticketSubjects = [
                'استفسار عن الشحن',
                'مشكلة في الطلب',
                'طلب استرجاع',
                'استفسار عن المنتج',
                'شكوى',
                'اقتراح',
                'طلب فاتورة',
                'تغيير العنوان',
            ];

            for (let i = 0; i < 10; i++) {
                const customer = randomItem(customers) as any;
                await ticketsCollection.insertOne({
                    ticketNumber: `TKT-${String(Date.now()).slice(-6)}${i}`,
                    customer: customer?._id,
                    subject: randomItem(ticketSubjects),
                    description: 'وصف التذكرة - بيانات وهمية للاختبار',
                    status: randomItem(['open', 'open', 'in_progress', 'resolved']),
                    priority: randomItem(['low', 'medium', 'medium', 'high']),
                    createdAt: randomDate(30),
                    updatedAt: new Date(),
                });
            }
            console.log(`   ✅ 10 support tickets created`);
        } else {
            console.log(`   ⏭️  Tickets already exist (${existingTickets})`);
        }

        // ═════════════════════════════════════
        // 11. Seed Notifications
        // ═════════════════════════════════════
        console.log('\n📍 Seeding Notifications...');

        const existingNotifications = await notificationsCollection.countDocuments();
        if (existingNotifications < 20) {
            const notificationTitles = [
                { title: 'طلب جديد', titleEn: 'New Order' },
                { title: 'تم شحن طلبك', titleEn: 'Order Shipped' },
                { title: 'مخزون منخفض', titleEn: 'Low Stock Alert' },
                { title: 'عميل جديد', titleEn: 'New Customer' },
                { title: 'تم الدفع', titleEn: 'Payment Received' },
            ];

            for (let i = 0; i < 20; i++) {
                const notif = randomItem(notificationTitles);
                await notificationsCollection.insertOne({
                    recipient: adminUser!._id,
                    recipientType: 'admin',
                    title: notif.title,
                    titleEn: notif.titleEn,
                    body: 'محتوى الإشعار - بيانات وهمية',
                    bodyEn: 'Notification content - dummy data',
                    type: randomItem(['order', 'payment', 'stock', 'customer']),
                    read: Math.random() > 0.5,
                    createdAt: randomDate(14),
                    updatedAt: new Date(),
                });
            }
            console.log(`   ✅ 20 notifications created`);
        } else {
            console.log(`   ⏭️  Notifications already exist (${existingNotifications})`);
        }

        // ═════════════════════════════════════
        // Summary
        // ═════════════════════════════════════
        console.log('\n' + '═'.repeat(50));
        console.log('🎉 Database seeding completed!');
        console.log('═'.repeat(50));
        console.log('\n📊 Summary:');
        console.log(`   • Categories: ${await categoriesCollection.countDocuments()}`);
        console.log(`   • Brands: ${await brandsCollection.countDocuments()}`);
        console.log(`   • Products: ${await productsCollection.countDocuments()}`);
        console.log(`   • Customers: ${await customersCollection.countDocuments()}`);
        console.log(`   • Orders: ${await ordersCollection.countDocuments()}`);
        console.log(`   • Tickets: ${await ticketsCollection.countDocuments()}`);
        console.log(`   • Notifications: ${await notificationsCollection.countDocuments()}`);
        console.log('\n📧 Admin Login:');
        console.log('   Email: admin@trasphone.com');
        console.log('   Password: Admin@123456\n');

    } catch (error) {
        console.error('\n❌ Error seeding database:', error);
    } finally {
        await app.close();
    }
}

seedAll();
