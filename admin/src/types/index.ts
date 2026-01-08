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
    name: string;
    email: string;
    phone?: string;
    department?: string;
    employmentStatus: 'active' | 'inactive' | 'suspended';
    roles: Role[];
    avatar?: string;
    createdAt: string;
    updatedAt: string;
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
    phoneNormalized: string;
    status: 'pending' | 'approved' | 'rejected' | 'suspended';
    address?: Address;
    taxNumber?: string;
    commercialRegister?: string;
    tier?: string;
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
    description?: string;
    descriptionAr?: string;
    category?: Category;
    brand?: Brand;
    images: string[];
    price: number;
    compareAtPrice?: number;
    stock: number;
    status: 'draft' | 'published' | 'archived';
    featured: boolean;
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
    isActive: boolean;
}

// Order types
export interface Order {
    _id: string;
    orderNumber: string;
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
    status: OrderStatus;
    paymentStatus: PaymentStatus;
    shippingAddress: Address;
    notes?: string;
    createdAt: string;
    updatedAt: string;
}

export interface OrderItem {
    product: {
        _id: string;
        name: string;
        sku: string;
        image?: string;
    };
    quantity: number;
    price: number;
    total: number;
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
    | 'pending'
    | 'paid'
    | 'partially_paid'
    | 'refunded'
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
export interface DashboardStats {
    totalRevenue: number;
    totalOrders: number;
    totalCustomers: number;
    totalProducts: number;
    revenueChange: number;
    ordersChange: number;
    customersChange: number;
}

export interface ChartData {
    labels: string[];
    datasets: {
        label: string;
        data: number[];
    }[];
}
