import { NavLink } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useTheme } from '@/contexts/ThemeContext';
import { cn } from '@/lib/utils';
import logo from '@/assets/logo.png';
import logoDark from '@/assets/logo_dark.png';
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
    Building2,
    FileText,
    RotateCcw,
    Shield,
    History,
    Layers,
    Wallet,
    Smartphone,
    MessageSquare,
    Key,
    BookOpen,
} from 'lucide-react';
import { Button } from '@/components/ui/button';

interface SidebarProps {
    collapsed: boolean;
    onToggle: () => void;
}

const menuItems = [
    { icon: LayoutDashboard, path: '/', labelKey: 'sidebar.dashboard' },
    { icon: Users, path: '/admins', labelKey: 'sidebar.admins' },
    { icon: Shield, path: '/roles', labelKey: 'sidebar.roles' },
    { icon: UserCheck, path: '/customers', labelKey: 'sidebar.customers' },
    { icon: Key, path: '/password-reset-requests', labelKey: 'sidebar.passwordResetRequests' },
    { icon: Package, path: '/products', labelKey: 'sidebar.products' },
    { icon: Layers, path: '/price-levels', labelKey: 'sidebar.priceLevels' },
    { icon: FolderTree, path: '/categories', labelKey: 'sidebar.categories' },
    { icon: Smartphone, path: '/catalog', labelKey: 'sidebar.catalog' },
    { icon: ShoppingCart, path: '/orders', labelKey: 'sidebar.orders' },
    { icon: RotateCcw, path: '/returns', labelKey: 'sidebar.returns' },
    { icon: Warehouse, path: '/inventory', labelKey: 'sidebar.inventory' },
    { icon: Building2, path: '/suppliers', labelKey: 'sidebar.suppliers' },
    { icon: FileText, path: '/purchase-orders', labelKey: 'sidebar.purchaseOrders' },
    { icon: Wallet, path: '/wallet', labelKey: 'sidebar.wallet' },
    { icon: Tags, path: '/promotions', labelKey: 'sidebar.promotions' },
    { icon: Layers, path: '/content', labelKey: 'sidebar.content' },
    { icon: BookOpen, path: '/educational-content', labelKey: 'sidebar.educationalContent' },
    { icon: Bell, path: '/notifications', labelKey: 'sidebar.notifications' },
    { icon: HeadphonesIcon, path: '/support', labelKey: 'sidebar.support' },
    { icon: MessageSquare, path: '/live-chat', labelKey: 'sidebar.liveChat' },
    { icon: BarChart3, path: '/analytics', labelKey: 'sidebar.analytics' },
    { icon: History, path: '/audit', labelKey: 'sidebar.audit' },
    { icon: Settings, path: '/settings', labelKey: 'sidebar.settings' },
];

export function Sidebar({ collapsed, onToggle }: SidebarProps) {
    const { t, i18n } = useTranslation();
    const { isDark } = useTheme();
    const isRTL = i18n.language === 'ar';
    const currentLogo = isDark ? logoDark : logo;

    return (
        <aside
            className={cn(
                'fixed top-0 h-screen bg-white dark:bg-slate-900 border-e border-gray-200 dark:border-slate-700 transition-all duration-300 z-40 flex flex-col',
                collapsed ? 'w-[72px]' : 'w-64',
                isRTL ? 'right-0' : 'left-0'
            )}
        >
            {/* Logo */}
            <div className="h-16 flex items-center justify-center border-b border-gray-200 dark:border-slate-700 px-4">
                {collapsed ? (
                    <img 
                        src={currentLogo} 
                        alt="TRAS Logo" 
                        className="h-10 w-10 object-contain"
                    />
                ) : (
                    <div className="flex items-center gap-3">
                        <img 
                            src={currentLogo} 
                            alt="TRAS Logo" 
                            className="h-10 w-auto object-contain max-w-[140px]"
                        />
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
                                        'hover:bg-gray-100 dark:hover:bg-slate-800',
                                        isActive
                                            ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-400 font-medium'
                                            : 'text-gray-600 dark:text-gray-400',
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
            <div className="p-3 border-t border-gray-200 dark:border-slate-700">
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
