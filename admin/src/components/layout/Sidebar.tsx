import { NavLink } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { cn } from '@/lib/utils';
import {
    LayoutDashboard,
    Users,
    UserCheck,
    Package,
    FolderTree,
    ShoppingCart,
    Warehouse,
    Tags,
    Bell,
    HeadphonesIcon,
    BarChart3,
    Settings,
    ChevronRight,
    ChevronLeft,
} from 'lucide-react';
import { Button } from '@/components/ui/button';

interface SidebarProps {
    collapsed: boolean;
    onToggle: () => void;
}

const menuItems = [
    { icon: LayoutDashboard, path: '/', labelKey: 'sidebar.dashboard' },
    { icon: Users, path: '/admins', labelKey: 'sidebar.admins' },
    { icon: UserCheck, path: '/customers', labelKey: 'sidebar.customers' },
    { icon: Package, path: '/products', labelKey: 'sidebar.products' },
    { icon: FolderTree, path: '/categories', labelKey: 'sidebar.categories' },
    { icon: ShoppingCart, path: '/orders', labelKey: 'sidebar.orders' },
    { icon: Warehouse, path: '/inventory', labelKey: 'sidebar.inventory' },
    { icon: Tags, path: '/promotions', labelKey: 'sidebar.promotions' },
    { icon: Bell, path: '/notifications', labelKey: 'sidebar.notifications' },
    { icon: HeadphonesIcon, path: '/support', labelKey: 'sidebar.support' },
    { icon: BarChart3, path: '/analytics', labelKey: 'sidebar.analytics' },
    { icon: Settings, path: '/settings', labelKey: 'sidebar.settings' },
];

export function Sidebar({ collapsed, onToggle }: SidebarProps) {
    const { t, i18n } = useTranslation();
    const isRTL = i18n.language === 'ar';

    return (
        <aside
            className={cn(
                'fixed top-0 h-screen bg-white border-e border-gray-200 transition-all duration-300 z-40 flex flex-col',
                collapsed ? 'w-[72px]' : 'w-64',
                isRTL ? 'right-0' : 'left-0'
            )}
        >
            {/* Logo */}
            <div className="h-16 flex items-center justify-center border-b border-gray-200 px-4">
                {collapsed ? (
                    <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-700 rounded-xl flex items-center justify-center">
                        <span className="text-white font-bold text-lg">T</span>
                    </div>
                ) : (
                    <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-primary-700 rounded-xl flex items-center justify-center">
                            <span className="text-white font-bold text-lg">T</span>
                        </div>
                        <span className="font-bold text-lg text-gray-900">TRAS Phone</span>
                    </div>
                )}
            </div>

            {/* Navigation */}
            <nav className="flex-1 overflow-y-auto py-4 px-3">
                <ul className="space-y-1">
                    {menuItems.map((item) => (
                        <li key={item.path}>
                            <NavLink
                                to={item.path}
                                className={({ isActive }) =>
                                    cn(
                                        'flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-200',
                                        'hover:bg-gray-100',
                                        isActive
                                            ? 'bg-primary-50 text-primary-700 font-medium'
                                            : 'text-gray-600',
                                        collapsed && 'justify-center'
                                    )
                                }
                            >
                                <item.icon className="w-5 h-5 shrink-0" />
                                {!collapsed && <span>{t(item.labelKey)}</span>}
                            </NavLink>
                        </li>
                    ))}
                </ul>
            </nav>

            {/* Toggle Button */}
            <div className="p-3 border-t border-gray-200">
                <Button
                    variant="ghost"
                    size="icon"
                    onClick={onToggle}
                    className="w-full"
                >
                    {isRTL ? (
                        collapsed ? <ChevronLeft className="h-5 w-5" /> : <ChevronRight className="h-5 w-5" />
                    ) : (
                        collapsed ? <ChevronRight className="h-5 w-5" /> : <ChevronLeft className="h-5 w-5" />
                    )}
                </Button>
            </div>
        </aside>
    );
}
