// Common types used across the admin dashboard

export interface ApiResponse<T> {
    status: 'success' | 'error';
    statusCode: number;
    message: string;
    messageAr: string;
    data: T;
    meta?: {
        pagination?: PaginationMeta;
    };
    timestamp: string;
    path: string;
}

export interface PaginationMeta {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasNextPage: boolean;
    hasPreviousPage: boolean;
}

export interface PaginatedResponse<T> {
    items: T[];
    pagination: PaginationMeta;
}

export interface PermissionDescriptor {
    _id?: string;
    name?: string;
    permission?: string;
    module?: string;
    action?: string;
}

export interface AccessRequirement {
    anyOf?: string[];
    allOf?: string[];
}

export interface AdminRole {
    _id?: string;
    name?: string;
    nameAr?: string;
    permissions?: Array<string | PermissionDescriptor>;
}

// Auth types
export interface LoginRequest {
    email: string;
    password: string;
}

export interface LoginResponse {
    accessToken: string;
    refreshToken: string;
    user: Admin;
}

export interface Admin {
    _id: string;
    userId: {
        _id: string;
        phone: string;
        email: string;
        avatar?: string;
    };
    employeeCode: string;
    fullName: string;
    fullNameAr: string;
    department: string;
    position: string;
    isSuperAdmin: boolean;
    canAccessWeb: boolean;
    canAccessMobile: boolean;
    employmentStatus: 'active' | 'on_leave' | 'suspended' | 'terminated';
    hireDate: string;
    createdAt: string;
    updatedAt: string;
    totalOrdersProcessed?: number;
    totalCustomersManaged?: number;
    permissions?: Array<string | PermissionDescriptor>;
    roles?: Array<string | AdminRole>;
    role?: string | AdminRole;
    featureFlags?: string[];
    features?: string[];
}

export interface Role {
    _id: string;
    name: string;
    description?: string;
    permissions: string[];
}

// Customer types
export interface Customer {
    _id: string;
    companyName: string;
    contactName: string;
    email: string;
    phone: string;
    phoneNormalized?: string;
    status: 'pending' | 'approved' | 'rejected' | 'suspended';
    address?: Address | string;
    taxNumber?: string;
    commercialRegister?: string;
    tier?: string;
    businessType?: string;
    cityId?: string | { _id: string; name: string; nameAr: string };
    priceLevelId?: string | { _id: string; name: string; nameAr?: string; discount?: number };
    creditLimit?: number;
    creditUsed?: number;
    availableCredit?: number;
    walletBalance?: number;
    loyaltyPoints?: number;
    loyaltyTier?: string;
    totalOrders?: number;
    totalSpent?: number;
    averageOrderValue?: number;
    lastOrderAt?: string;
    nationalId?: string;
    approvedAt?: string;
    internalNotes?: string;
    canCashRefund?: boolean;
    canCashOnDelivery?: boolean;
    isTaxable?: boolean;
    createdAt: string;
    updatedAt: string;
}

export interface Address {
    street?: string;
    city?: string;
    state?: string;
    country?: string;
    postalCode?: string;
}

// Product types
export interface Product {
    _id: string;
    name: string;
    nameAr?: string;
    sku: string;
    slug?: string;
    description?: string;
    descriptionAr?: string;
    shortDescription?: string;
    shortDescriptionAr?: string;
    category?: Category;
    brand?: Brand;
    qualityTypeId?: string;
    mainImage?: string;
    images: string[];
    video?: string;
    price: number;
    compareAtPrice?: number;
    costPrice?: number;
    stock: number;
    lowStockThreshold?: number;
    minOrderQuantity?: number;
    maxOrderQuantity?: number;
    status: 'draft' | 'active' | 'inactive' | 'out_of_stock' | 'discontinued' | 'published' | 'archived';
    isActive?: boolean;
    featured: boolean;
    trackInventory?: boolean;
    allowBackorder?: boolean;
    additionalCategories?: string[];
    tags?: string[];
    specifications?: Record<string, any>;
    weight?: number;
    dimensions?: string;
    color?: string;
    relatedProducts?: string[];
    averageRating?: number;
    reviewsCount?: number;
    createdAt: string;
    updatedAt: string;
}

export interface Category {
    _id: string;
    name: string;
    nameAr?: string;
    slug: string;
    description?: string;
    image?: string;
    parent?: string;
    order: number;
    isActive: boolean;
}

export interface Brand {
    _id: string;
    name: string;
    nameAr?: string;
    slug: string;
    logo?: string;
    isFeatured?: boolean;
    isActive: boolean;
}

// Order types
export interface Order {
    _id: string;
    orderNumber: string;
    customerId?: string | {
        _id?: string;
        shopName?: string;
        responsiblePersonName?: string;
        phone?: string;
    };
    customer: {
        _id: string;
        companyName: string;
        contactName: string;
        email: string;
        phone: string;
    };
    items: OrderItem[];
    subtotal: number;
    discount: number;
    tax: number;
    total: number;
    paidAmount?: number;
    walletAmountUsed?: number;
    status: OrderStatus;
    paymentStatus: PaymentStatus;
    paymentMethod?: string;
    transferStatus?: 'not_required' | 'awaiting_receipt' | 'receipt_uploaded' | 'verified' | 'rejected';
    transferReceiptImage?: string;
    transferReference?: string;
    transferDate?: string;
    transferVerifiedAt?: string;
    rejectionReason?: string;
    shippingAddress: Address;
    notes?: string;
    createdAt: string;
    updatedAt: string;
}

export interface OrderItem {
    _id: string;
    product: string | {
        _id: string;
        name: string;
        sku: string;
        image?: string;
    };
    productSnapshot?: {
        name: string;
        sku: string;
        price: number;
    };
    quantity: number;
    unitPrice: number;
    totalPrice: number;
    discount?: number;
    // Legacy fields for compatibility
    price?: number;
    total?: number;
}

export type OrderStatus =
    | 'pending'
    | 'confirmed'
    | 'processing'
    | 'shipped'
    | 'delivered'
    | 'cancelled'
    | 'refunded';

export type PaymentStatus =
    | 'unpaid'
    | 'partial'
    | 'paid'
    | 'refunded'
    // legacy values still tolerated in UI
    | 'pending'
    | 'partially_paid'
    | 'failed';

// Notification types
export interface Notification {
    _id: string;
    title: string;
    titleAr?: string;
    body: string;
    bodyAr?: string;
    type: 'info' | 'warning' | 'success' | 'error';
    read: boolean;
    createdAt: string;
}

// Support ticket types
export interface Ticket {
    _id: string;
    ticketNumber: string;
    customer: {
        _id: string;
        companyName: string;
        contactName: string;
    };
    subject: string;
    description: string;
    status: 'open' | 'in_progress' | 'resolved' | 'closed';
    priority: 'low' | 'medium' | 'high' | 'urgent';
    assignedTo?: Admin;
    createdAt: string;
    updatedAt: string;
}

// Analytics types
// Note: DashboardStats is now defined in api/analytics.api.ts
// This interface is kept for backward compatibility but may be removed in the future
export interface DashboardStats {
    overview: {
        orders: {
            today: number;
            thisMonth: number;
            lastMonth: number;
            change: number;
        };
        revenue: {
            today: number;
            thisMonth: number;
            lastMonth: number;
            change: number;
        };
        customers: {
            total: number;
            newThisMonth: number;
        };
        products: {
            total: number;
            active: number;
        };
    };
    salesChart: any[];
    topProducts: any[];
    topCustomers: any[];
    lowStock: any[];
    recentOrders: any[];
    pendingActions: {
        pendingOrders: number;
        pendingPayments: number;
        pendingReturns: number;
        pendingApprovals: number;
        lowStockCount: number;
        total: number;
    };
}

export interface ChartData {
    labels: string[];
    datasets: {
        label: string;
        data: number[];
    }[];
}
