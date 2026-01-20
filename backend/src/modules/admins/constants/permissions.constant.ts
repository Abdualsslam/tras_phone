/**
 * ═══════════════════════════════════════════════════════════════
 * 🔑 System Permissions (95 Permissions)
 * ═══════════════════════════════════════════════════════════════
 * Organized by module with granular actions
 */

export const PERMISSIONS = {
    // ═════════════════════════════════════
    // Users Management (5)
    // ═════════════════════════════════════
    USERS: {
        VIEW: 'users.view',
        CREATE: 'users.create',
        UPDATE: 'users.update',
        DELETE: 'users.delete',
        MANAGE_ROLES: 'users.manage_roles',
    },

    // ═════════════════════════════════════
    // Customers Management (8)
    // ═════════════════════════════════════
    CUSTOMERS: {
        VIEW: 'customers.view',
        CREATE: 'customers.create',
        UPDATE: 'customers.update',
        DELETE: 'customers.delete',
        APPROVE: 'customers.approve',
        REJECT: 'customers.reject',
        MANAGE_CREDIT: 'customers.manage_credit',
        VIEW_STATISTICS: 'customers.view_statistics',
    },

    // ═════════════════════════════════════
    // Products Management (10)
    // ═════════════════════════════════════
    PRODUCTS: {
        VIEW: 'products.view',
        CREATE: 'products.create',
        UPDATE: 'products.update',
        DELETE: 'products.delete',
        MANAGE_IMAGES: 'products.manage_images',
        MANAGE_PRICES: 'products.manage_prices',
        MANAGE_STOCK: 'products.manage_stock',
        IMPORT: 'products.import',
        EXPORT: 'products.export',
        VIEW_REVIEWS: 'products.view_reviews',
    },

    // ═════════════════════════════════════
    // Categories & Brands (6)
    // ═════════════════════════════════════
    CATEGORIES: {
        VIEW: 'categories.view',
        CREATE: 'categories.create',
        UPDATE: 'categories.update',
        DELETE: 'categories.delete',
    },

    BRANDS: {
        VIEW: 'brands.view',
        CREATE: 'brands.create',
        UPDATE: 'brands.update',
        DELETE: 'brands.delete',
    },

    // ═════════════════════════════════════
    // Orders Management (10)
    // ═════════════════════════════════════
    ORDERS: {
        VIEW: 'orders.view',
        CREATE: 'orders.create',
        UPDATE: 'orders.update',
        DELETE: 'orders.delete',
        PROCESS: 'orders.process',
        CANCEL: 'orders.cancel',
        REFUND: 'orders.refund',
        VIEW_INVOICES: 'orders.view_invoices',
        GENERATE_INVOICES: 'orders.generate_invoices',
        MANAGE_SHIPPING: 'orders.manage_shipping',
    },

    // ═════════════════════════════════════
    // Inventory Management (8)
    // ═════════════════════════════════════
    INVENTORY: {
        VIEW: 'inventory.view',
        UPDATE: 'inventory.update',
        TRANSFER: 'inventory.transfer',
        ADJUST: 'inventory.adjust',
        COUNT: 'inventory.count',
        VIEW_MOVEMENTS: 'inventory.view_movements',
        MANAGE_WAREHOUSES: 'inventory.manage_warehouses',
        VIEW_ALERTS: 'inventory.view_alerts',
    },

    // ═════════════════════════════════════
    // Pricing & Promotions (8)
    // ═════════════════════════════════════
    PRICING: {
        VIEW: 'pricing.view',
        UPDATE: 'pricing.update',
        MANAGE_LEVELS: 'pricing.manage_levels',
        VIEW_HISTORY: 'pricing.view_history',
    },

    PROMOTIONS: {
        VIEW: 'promotions.view',
        CREATE: 'promotions.create',
        UPDATE: 'promotions.update',
        DELETE: 'promotions.delete',
        MANAGE_COUPONS: 'promotions.manage_coupons',
    },

    // ═════════════════════════════════════
    // Suppliers & Purchases (6)
    // ═════════════════════════════════════
    SUPPLIERS: {
        VIEW: 'suppliers.view',
        CREATE: 'suppliers.create',
        UPDATE: 'suppliers.update',
        DELETE: 'suppliers.delete',
    },

    PURCHASES: {
        VIEW: 'purchases.view',
        CREATE: 'purchases.create',
        UPDATE: 'purchases.update',
        APPROVE: 'purchases.approve',
    },

    // ═════════════════════════════════════
    // Wallet & Loyalty (5)
    // ═════════════════════════════════════
    WALLET: {
        VIEW: 'wallet.view',
        ADD_CREDIT: 'wallet.add_credit',
        DEDUCT: 'wallet.deduct',
        VIEW_TRANSACTIONS: 'wallet.view_transactions',
    },

    LOYALTY: {
        VIEW: 'loyalty.view',
        MANAGE_TIERS: 'loyalty.manage_tiers',
        ADJUST_POINTS: 'loyalty.adjust_points',
    },

    // ═════════════════════════════════════
    // Support & Chat (15)
    // ═════════════════════════════════════
    SUPPORT: {
        // Tickets
        VIEW_TICKETS: 'support.tickets.view',
        CREATE_TICKETS: 'support.tickets.create',
        UPDATE_TICKETS: 'support.tickets.update',
        REPLY_TICKETS: 'support.tickets.reply',
        ASSIGN_TICKETS: 'support.tickets.assign',
        ESCALATE_TICKETS: 'support.tickets.escalate',
        CLOSE_TICKETS: 'support.tickets.close',
        MERGE_TICKETS: 'support.tickets.merge',
        // Chat
        VIEW_CHAT: 'support.chat.view',
        ACCEPT_CHAT: 'support.chat.accept',
        TRANSFER_CHAT: 'support.chat.transfer',
        // Management
        MANAGE_CATEGORIES: 'support.categories.manage',
        MANAGE_CANNED: 'support.canned.manage',
        VIEW_REPORTS: 'support.reports.view',
        EXPORT_DATA: 'support.export',
    },

    // ═════════════════════════════════════
    // Notifications (4)
    // ═════════════════════════════════════
    NOTIFICATIONS: {
        VIEW: 'notifications.view',
        SEND: 'notifications.send',
        MANAGE_TEMPLATES: 'notifications.manage_templates',
        MANAGE_CAMPAIGNS: 'notifications.manage_campaigns',
    },

    // ═════════════════════════════════════
    // Content Management (4)
    // ═════════════════════════════════════
    CONTENT: {
        VIEW: 'content.view',
        CREATE: 'content.create',
        UPDATE: 'content.update',
        DELETE: 'content.delete',
    },

    // ═════════════════════════════════════
    // Reports & Analytics (5)
    // ═════════════════════════════════════
    REPORTS: {
        VIEW_SALES: 'reports.view_sales',
        VIEW_INVENTORY: 'reports.view_inventory',
        VIEW_CUSTOMERS: 'reports.view_customers',
        VIEW_FINANCIAL: 'reports.view_financial',
        EXPORT: 'reports.export',
    },

    // ═════════════════════════════════════
    // Admin & System (8)
    // ═════════════════════════════════════
    ADMINS: {
        VIEW: 'admins.view',
        CREATE: 'admins.create',
        UPDATE: 'admins.update',
        DELETE: 'admins.delete',
    },

    ROLES: {
        VIEW: 'roles.view',
        CREATE: 'roles.create',
        UPDATE: 'roles.update',
        DELETE: 'roles.delete',
        ASSIGN_PERMISSIONS: 'roles.assign_permissions',
    },

    SYSTEM: {
        VIEW_SETTINGS: 'system.view_settings',
        UPDATE_SETTINGS: 'system.update_settings',
        VIEW_LOGS: 'system.view_logs',
        MANAGE_BACKUPS: 'system.manage_backups',
    },
};

/**
 * Get all permissions as flat array
 */
export function getAllPermissions(): string[] {
    const permissions: string[] = [];

    Object.values(PERMISSIONS).forEach((module) => {
        Object.values(module).forEach((permission) => {
            permissions.push(permission as string);
        });
    });

    return permissions;
}

/**
 * Permission metadata for seeding
 */
export const PERMISSION_METADATA = [
    // Users
    { name: PERMISSIONS.USERS.VIEW, module: 'users', action: 'view', displayName: 'View Users', displayNameAr: 'عرض المستخدمين' },
    { name: PERMISSIONS.USERS.CREATE, module: 'users', action: 'create', displayName: 'Create Users', displayNameAr: 'إنشاء المستخدمين' },
    { name: PERMISSIONS.USERS.UPDATE, module: 'users', action: 'update', displayName: 'Update Users', displayNameAr: 'تحديث المستخدمين' },
    { name: PERMISSIONS.USERS.DELETE, module: 'users', action: 'delete', displayName: 'Delete Users', displayNameAr: 'حذف المستخدمين' },
    { name: PERMISSIONS.USERS.MANAGE_ROLES, module: 'users', action: 'manage_roles', displayName: 'Manage User Roles', displayNameAr: 'إدارة أدوار المستخدمين' },

    // Customers
    { name: PERMISSIONS.CUSTOMERS.VIEW, module: 'customers', action: 'view', displayName: 'View Customers', displayNameAr: 'عرض العملاء' },
    { name: PERMISSIONS.CUSTOMERS.CREATE, module: 'customers', action: 'create', displayName: 'Create Customers', displayNameAr: 'إنشاء العملاء' },
    { name: PERMISSIONS.CUSTOMERS.UPDATE, module: 'customers', action: 'update', displayName: 'Update Customers', displayNameAr: 'تحديث العملاء' },
    { name: PERMISSIONS.CUSTOMERS.DELETE, module: 'customers', action: 'delete', displayName: 'Delete Customers', displayNameAr: 'حذف العملاء' },
    { name: PERMISSIONS.CUSTOMERS.APPROVE, module: 'customers', action: 'approve', displayName: 'Approve Customers', displayNameAr: 'الموافقة على العملاء' },
    { name: PERMISSIONS.CUSTOMERS.REJECT, module: 'customers', action: 'reject', displayName: 'Reject Customers', displayNameAr: 'رفض العملاء' },
    { name: PERMISSIONS.CUSTOMERS.MANAGE_CREDIT, module: 'customers', action: 'manage_credit', displayName: 'Manage Customer Credit', displayNameAr: 'إدارة ائتمان العملاء' },
    { name: PERMISSIONS.CUSTOMERS.VIEW_STATISTICS, module: 'customers', action: 'view_statistics', displayName: 'View Customer Statistics', displayNameAr: 'عرض إحصائيات العملاء' },

    // ... (يمكن إضافة الباقي أو تحميلها من ملف JSON)
];
