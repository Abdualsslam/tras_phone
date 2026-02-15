import type { LucideIcon } from 'lucide-react';
import {
    BarChart3,
    Bell,
    BookOpen,
    Building2,
    FileText,
    FolderTree,
    HeadphonesIcon,
    History,
    Key,
    Layers,
    LayoutDashboard,
    MessageSquare,
    Package,
    RotateCcw,
    Settings,
    Shield,
    ShoppingCart,
    Smartphone,
    Tags,
    UserCheck,
    Users,
    Wallet,
    Warehouse,
} from 'lucide-react';
import type { AccessRequirement } from '@/types';

export interface SidebarItemConfig {
    id: string;
    path: string;
    labelKey: string;
    icon: LucideIcon;
    access?: AccessRequirement;
    featureFlags?: string[];
}

export interface SidebarSectionConfig {
    id: string;
    labelKey: string;
    items: SidebarItemConfig[];
}

const anyOf = (...permissions: string[]): AccessRequirement => ({ anyOf: permissions });

export const sidebarSections: SidebarSectionConfig[] = [
    {
        id: 'overview',
        labelKey: 'sidebarGroups.overview',
        items: [
            { id: 'dashboard', icon: LayoutDashboard, path: '/', labelKey: 'sidebar.dashboard' },
            { id: 'analytics', icon: BarChart3, path: '/analytics', labelKey: 'sidebar.analytics', access: anyOf('reports.view_sales', 'reports.view_inventory', 'reports.view_customers', 'reports.view_financial') },
        ],
    },
    {
        id: 'operations',
        labelKey: 'sidebarGroups.operations',
        items: [
            { id: 'customers', icon: UserCheck, path: '/customers', labelKey: 'sidebar.customers', access: anyOf('customers.view') },
            { id: 'orders', icon: ShoppingCart, path: '/orders', labelKey: 'sidebar.orders', access: anyOf('orders.view') },
            { id: 'returns', icon: RotateCcw, path: '/returns', labelKey: 'sidebar.returns', access: anyOf('returns.view', 'orders.refund') },
            { id: 'inventory', icon: Warehouse, path: '/inventory', labelKey: 'sidebar.inventory', access: anyOf('inventory.view') },
            { id: 'wallet', icon: Wallet, path: '/wallet', labelKey: 'sidebar.wallet', access: anyOf('wallet.view') },
            { id: 'notifications', icon: Bell, path: '/notifications', labelKey: 'sidebar.notifications', access: anyOf('notifications.view') },
            { id: 'support', icon: HeadphonesIcon, path: '/support', labelKey: 'sidebar.support', access: anyOf('support.tickets.view') },
            { id: 'liveChat', icon: MessageSquare, path: '/live-chat', labelKey: 'sidebar.liveChat', access: anyOf('support.chat.view') },
        ],
    },
    {
        id: 'catalog',
        labelKey: 'sidebarGroups.catalog',
        items: [
            { id: 'products', icon: Package, path: '/products', labelKey: 'sidebar.products', access: anyOf('products.view') },
            { id: 'priceLevels', icon: Layers, path: '/price-levels', labelKey: 'sidebar.priceLevels', access: anyOf('pricing.view', 'pricing.manage_levels') },
            { id: 'categories', icon: FolderTree, path: '/categories', labelKey: 'sidebar.categories', access: anyOf('categories.view') },
            { id: 'catalogPage', icon: Smartphone, path: '/catalog', labelKey: 'sidebar.catalog', access: anyOf('products.view', 'categories.view', 'brands.view') },
            { id: 'promotions', icon: Tags, path: '/promotions', labelKey: 'sidebar.promotions', access: anyOf('promotions.view') },
            { id: 'content', icon: Layers, path: '/content', labelKey: 'sidebar.content', access: anyOf('content.view') },
            { id: 'educationalContent', icon: BookOpen, path: '/educational-content', labelKey: 'sidebar.educationalContent', access: anyOf('content.view') },
        ],
    },
    {
        id: 'procurement',
        labelKey: 'sidebarGroups.procurement',
        items: [
            { id: 'suppliers', icon: Building2, path: '/suppliers', labelKey: 'sidebar.suppliers', access: anyOf('suppliers.view') },
            { id: 'purchaseOrders', icon: FileText, path: '/purchase-orders', labelKey: 'sidebar.purchaseOrders', access: anyOf('purchases.view') },
        ],
    },
    {
        id: 'administration',
        labelKey: 'sidebarGroups.administration',
        items: [
            { id: 'admins', icon: Users, path: '/admins', labelKey: 'sidebar.admins', access: anyOf('admins.view', 'users.view') },
            { id: 'roles', icon: Shield, path: '/roles', labelKey: 'sidebar.roles', access: anyOf('roles.view', 'users.manage_roles') },
            { id: 'passwordResetRequests', icon: Key, path: '/password-reset-requests', labelKey: 'sidebar.passwordResetRequests', access: anyOf('users.view', 'users.update', 'admins.view') },
            { id: 'audit', icon: History, path: '/audit', labelKey: 'sidebar.audit', access: anyOf('system.view_logs') },
            { id: 'settings', icon: Settings, path: '/settings', labelKey: 'sidebar.settings', access: anyOf('system.view_settings') },
        ],
    },
];

export const routeAccessConfig: Record<string, AccessRequirement | undefined> = {
    '/': undefined,
    '/admins': anyOf('admins.view', 'users.view'),
    '/customers': anyOf('customers.view'),
    '/password-reset-requests': anyOf('users.view', 'users.update', 'admins.view'),
    '/products': anyOf('products.view'),
    '/price-levels': anyOf('pricing.view', 'pricing.manage_levels'),
    '/categories': anyOf('categories.view'),
    '/catalog': anyOf('products.view', 'categories.view', 'brands.view'),
    '/orders': anyOf('orders.view'),
    '/orders/:orderId': anyOf('orders.view'),
    '/inventory': anyOf('inventory.view'),
    '/suppliers': anyOf('suppliers.view'),
    '/purchase-orders': anyOf('purchases.view'),
    '/returns': anyOf('returns.view', 'orders.refund'),
    '/roles': anyOf('roles.view', 'users.manage_roles'),
    '/promotions': anyOf('promotions.view'),
    '/notifications': anyOf('notifications.view'),
    '/support': anyOf('support.tickets.view'),
    '/live-chat': anyOf('support.chat.view'),
    '/analytics': anyOf('reports.view_sales', 'reports.view_inventory', 'reports.view_customers', 'reports.view_financial'),
    '/audit': anyOf('system.view_logs'),
    '/content': anyOf('content.view'),
    '/educational-content': anyOf('content.view'),
    '/wallet': anyOf('wallet.view'),
    '/settings': anyOf('system.view_settings'),
};
