import { useTranslation } from 'react-i18next';
import { useQuery } from '@tanstack/react-query';
import { analyticsApi } from '@/api/analytics.api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
    TrendingUp,
    DollarSign,
    ShoppingCart,
    Users,
    Package,
    ArrowUpRight,
    ArrowDownRight,
    Loader2,
} from 'lucide-react';
import { formatCurrency, formatNumber } from '@/lib/utils';

export function AnalyticsPage() {
    const { t, i18n } = useTranslation();
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    // Calculate date range for last 30 days
    const endDate = new Date().toISOString().split('T')[0];
    const startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    // Fetch dashboard stats
    const { data: stats, isLoading: statsLoading } = useQuery({
        queryKey: ['dashboard'],
        queryFn: analyticsApi.getDashboard,
    });

    // Fetch top products
    const { data: topProducts, isLoading: productsLoading } = useQuery({
        queryKey: ['top-products', startDate, endDate],
        queryFn: () => analyticsApi.getTopProducts(startDate, endDate, 5),
    });

    // Fetch customer report
    const { data: customerReport, isLoading: customersLoading } = useQuery({
        queryKey: ['customer-report', startDate, endDate],
        queryFn: () => analyticsApi.getCustomerReport(startDate, endDate),
    });

    const overviewStats = [
        {
            label: 'إجمالي الإيرادات',
            value: stats?.totalRevenue || 0,
            change: stats?.revenueChange || 0,
            icon: DollarSign,
            format: 'currency',
        },
        {
            label: 'إجمالي الطلبات',
            value: stats?.totalOrders || 0,
            change: stats?.ordersChange || 0,
            icon: ShoppingCart,
            format: 'number',
        },
        {
            label: 'العملاء الجدد',
            value: stats?.totalCustomers || 0,
            change: stats?.customersChange || 0,
            icon: Users,
            format: 'number',
        },
        {
            label: 'المنتجات المباعة',
            value: stats?.totalProducts || 0,
            change: stats?.productsChange || 0,
            icon: Package,
            format: 'number',
        },
    ];

    const isLoading = statsLoading || productsLoading || customersLoading;

    if (isLoading) {
        return (
            <div className="flex items-center justify-center h-[50vh]">
                <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
            </div>
        );
    }

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900">{t('sidebar.analytics')}</h1>
                <p className="text-gray-500 mt-1">تحليلات وإحصائيات المتجر</p>
            </div>

            {/* Overview Stats */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                {overviewStats.map((stat, index) => (
                    <Card key={index}>
                        <CardContent className="p-4">
                            <div className="flex items-start justify-between">
                                <div>
                                    <p className="text-sm text-gray-500 mb-1">{stat.label}</p>
                                    <p className="text-2xl font-bold text-gray-900">
                                        {stat.format === 'currency'
                                            ? formatCurrency(stat.value, 'SAR', locale)
                                            : formatNumber(stat.value, locale)}
                                    </p>
                                </div>
                                <div className={`p-2 rounded-lg ${stat.change >= 0 ? 'bg-green-100' : 'bg-red-100'}`}>
                                    <stat.icon className={`h-5 w-5 ${stat.change >= 0 ? 'text-green-600' : 'text-red-600'}`} />
                                </div>
                            </div>
                            <div className="flex items-center gap-1 mt-3">
                                {stat.change >= 0 ? (
                                    <ArrowUpRight className="h-4 w-4 text-green-500" />
                                ) : (
                                    <ArrowDownRight className="h-4 w-4 text-red-500" />
                                )}
                                <span className={`text-sm font-medium ${stat.change >= 0 ? 'text-green-500' : 'text-red-500'}`}>
                                    {stat.change >= 0 ? '+' : ''}{stat.change}%
                                </span>
                                <span className="text-sm text-gray-400">من الشهر الماضي</span>
                            </div>
                        </CardContent>
                    </Card>
                ))}
            </div>

            <div className="grid lg:grid-cols-2 gap-6">
                {/* Top Customers */}
                <Card>
                    <CardHeader>
                        <CardTitle className="text-lg flex items-center gap-2">
                            <Users className="h-5 w-5 text-gray-500" />
                            أفضل العملاء
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {(customerReport?.topCustomers || []).slice(0, 5).map((customer: any, index: number) => (
                                <div key={customer._id || index} className="flex items-center justify-between">
                                    <div className="flex items-center gap-3">
                                        <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center text-sm font-medium text-primary-700">
                                            {index + 1}
                                        </div>
                                        <div>
                                            <p className="font-medium text-gray-900">{customer.companyName}</p>
                                            <p className="text-xs text-gray-500">{customer.ordersCount || 0} طلب</p>
                                        </div>
                                    </div>
                                    <p className="font-medium">{formatCurrency(customer.totalSpent || 0, 'SAR', locale)}</p>
                                </div>
                            ))}
                            {(!customerReport?.topCustomers || customerReport.topCustomers.length === 0) && (
                                <div className="py-8 text-center text-gray-500">لا توجد بيانات</div>
                            )}
                        </div>
                    </CardContent>
                </Card>

                {/* Top Products */}
                <Card>
                    <CardHeader>
                        <CardTitle className="text-lg flex items-center gap-2">
                            <TrendingUp className="h-5 w-5 text-gray-500" />
                            المنتجات الأكثر مبيعاً
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        <div className="space-y-4">
                            {(topProducts || []).map((product, index) => (
                                <div key={product._id} className="flex items-center justify-between">
                                    <div className="flex items-center gap-3">
                                        <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center text-sm font-medium text-primary-700">
                                            {index + 1}
                                        </div>
                                        <div>
                                            <p className="font-medium text-gray-900">{product.name}</p>
                                            <p className="text-xs text-gray-500">{product.sales} وحدة</p>
                                        </div>
                                    </div>
                                    <p className="font-medium">{formatCurrency(product.revenue, 'SAR', locale)}</p>
                                </div>
                            ))}
                            {(!topProducts || topProducts.length === 0) && (
                                <div className="py-8 text-center text-gray-500">لا توجد بيانات</div>
                            )}
                        </div>
                    </CardContent>
                </Card>
            </div>
        </div>
    );
}
