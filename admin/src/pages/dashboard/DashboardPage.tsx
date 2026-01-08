import { useTranslation } from 'react-i18next';
import { useQuery } from '@tanstack/react-query';
import { useAuth } from '@/contexts/AuthContext';
import { analyticsApi } from '@/api/analytics.api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
    DollarSign,
    ShoppingCart,
    Users,
    Package,
    TrendingUp,
    TrendingDown,
    ArrowUpRight,
    Loader2,
} from 'lucide-react';
import { cn, formatCurrency, formatNumber } from '@/lib/utils';

const statusColors: Record<string, string> = {
    pending: 'bg-yellow-100 text-yellow-700',
    processing: 'bg-blue-100 text-blue-700',
    shipped: 'bg-purple-100 text-purple-700',
    delivered: 'bg-green-100 text-green-700',
    confirmed: 'bg-blue-100 text-blue-700',
    cancelled: 'bg-red-100 text-red-700',
};

const statusLabels: Record<string, string> = {
    pending: 'قيد الانتظار',
    confirmed: 'مؤكد',
    processing: 'قيد المعالجة',
    shipped: 'تم الشحن',
    delivered: 'تم التوصيل',
    cancelled: 'ملغي',
};

export function DashboardPage() {
    const { t, i18n } = useTranslation();
    const { user } = useAuth();
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    // Fetch dashboard stats from backend
    const { data: stats, isLoading } = useQuery({
        queryKey: ['dashboard'],
        queryFn: analyticsApi.getDashboard,
    });

    const statCards = [
        {
            titleKey: 'dashboard.totalRevenue',
            value: stats?.totalRevenue || 0,
            change: stats?.revenueChange || 0,
            icon: DollarSign,
            format: 'currency',
            color: 'bg-green-500',
        },
        {
            titleKey: 'dashboard.totalOrders',
            value: stats?.totalOrders || 0,
            change: stats?.ordersChange || 0,
            icon: ShoppingCart,
            format: 'number',
            color: 'bg-blue-500',
        },
        {
            titleKey: 'dashboard.totalCustomers',
            value: stats?.totalCustomers || 0,
            change: stats?.customersChange || 0,
            icon: Users,
            format: 'number',
            color: 'bg-purple-500',
        },
        {
            titleKey: 'dashboard.totalProducts',
            value: stats?.totalProducts || 0,
            change: stats?.productsChange || 0,
            icon: Package,
            format: 'number',
            color: 'bg-orange-500',
        },
    ];

    if (isLoading) {
        return (
            <div className="flex items-center justify-center h-[50vh]">
                <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
            </div>
        );
    }

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Welcome Message */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900">
                    {t('dashboard.welcome')}، {user?.name}! 👋
                </h1>
                <p className="text-gray-500 mt-1">إليك نظرة عامة على نشاط متجرك اليوم</p>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                {statCards.map((stat) => (
                    <Card key={stat.titleKey} className="relative overflow-hidden">
                        <CardContent className="p-6">
                            <div className="flex items-start justify-between">
                                <div>
                                    <p className="text-sm text-gray-500 mb-1">{t(stat.titleKey)}</p>
                                    <p className="text-2xl font-bold text-gray-900">
                                        {stat.format === 'currency'
                                            ? formatCurrency(stat.value, 'SAR', locale)
                                            : formatNumber(stat.value, locale)}
                                    </p>
                                </div>
                                <div className={cn('p-3 rounded-xl', stat.color)}>
                                    <stat.icon className="h-5 w-5 text-white" />
                                </div>
                            </div>

                            <div className="flex items-center gap-1 mt-4">
                                {stat.change >= 0 ? (
                                    <TrendingUp className="h-4 w-4 text-green-500" />
                                ) : (
                                    <TrendingDown className="h-4 w-4 text-red-500" />
                                )}
                                <span
                                    className={cn(
                                        'text-sm font-medium',
                                        stat.change >= 0 ? 'text-green-500' : 'text-red-500'
                                    )}
                                >
                                    {stat.change >= 0 ? '+' : ''}{stat.change}%
                                </span>
                                <span className="text-sm text-gray-400">مقارنة بالشهر الماضي</span>
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            {/* Recent Orders */}
            <Card>
                <CardHeader className="flex flex-row items-center justify-between">
                    <CardTitle>{t('dashboard.recentOrders')}</CardTitle>
                    <button className="text-sm text-primary-600 hover:underline flex items-center gap-1">
                        عرض الكل
                        <ArrowUpRight className="h-4 w-4" />
                    </button>
                </CardHeader>
                <CardContent>
                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="border-b border-gray-200">
                                    <th className="text-start py-3 px-4 text-sm font-medium text-gray-500">رقم الطلب</th>
                                    <th className="text-start py-3 px-4 text-sm font-medium text-gray-500">العميل</th>
                                    <th className="text-start py-3 px-4 text-sm font-medium text-gray-500">الإجمالي</th>
                                    <th className="text-start py-3 px-4 text-sm font-medium text-gray-500">الحالة</th>
                                </tr>
                            </thead>
                            <tbody>
                                {(stats?.recentOrders || []).slice(0, 5).map((order: any) => (
                                    <tr key={order._id} className="border-b border-gray-100 hover:bg-gray-50">
                                        <td className="py-3 px-4 text-sm font-medium text-gray-900">{order.orderNumber}</td>
                                        <td className="py-3 px-4 text-sm text-gray-600">{order.customer?.companyName || '-'}</td>
                                        <td className="py-3 px-4 text-sm text-gray-900 font-medium">
                                            {formatCurrency(order.total, 'SAR', locale)}
                                        </td>
                                        <td className="py-3 px-4">
                                            <span
                                                className={cn(
                                                    'px-2.5 py-1 rounded-full text-xs font-medium',
                                                    statusColors[order.status] || 'bg-gray-100 text-gray-700'
                                                )}
                                            >
                                                {statusLabels[order.status] || order.status}
                                            </span>
                                        </td>
                                    </tr>
                                ))}
                                {(!stats?.recentOrders || stats.recentOrders.length === 0) && (
                                    <tr>
                                        <td colSpan={4} className="py-8 text-center text-gray-500">
                                            لا توجد طلبات حديثة
                                        </td>
                                    </tr>
                                )}
                            </tbody>
                        </table>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}
