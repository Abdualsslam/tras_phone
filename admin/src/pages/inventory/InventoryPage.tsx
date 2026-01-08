import { useTranslation } from 'react-i18next';
import { useQuery } from '@tanstack/react-query';
import { inventoryApi } from '@/api/inventory.api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table';
import {
    Warehouse,
    Package,
    TrendingUp,
    TrendingDown,
    AlertTriangle,
    Loader2,
} from 'lucide-react';
import { cn, formatNumber } from '@/lib/utils';


export function InventoryPage() {
    const { t, i18n } = useTranslation();
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    // Fetch warehouses from backend
    const { data: warehouses, isLoading: warehousesLoading } = useQuery({
        queryKey: ['warehouses'],
        queryFn: inventoryApi.getWarehouses,
    });

    // Fetch stock alerts from backend
    const { data: alerts, isLoading: alertsLoading } = useQuery({
        queryKey: ['stock-alerts'],
        queryFn: () => inventoryApi.getAlerts(),
    });

    const isLoading = warehousesLoading || alertsLoading;

    const stats = {
        totalProducts: warehouses?.reduce((sum, w) => sum + (w.totalProducts || 0), 0) || 0,
        inStock: alerts?.filter((a) => a.status === 'resolved').length || 0,
        lowStock: alerts?.filter((a) => a.status === 'pending').length || 0,
        outOfStock: alerts?.filter((a) => a.currentStock === 0).length || 0,
    };

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">{t('sidebar.inventory')}</h1>
                    <p className="text-gray-500 mt-1">إدارة المخزون والمستودعات</p>
                </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-blue-100 rounded-xl">
                            <Package className="h-5 w-5 text-blue-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{formatNumber(stats.totalProducts, locale)}</p>
                            <p className="text-sm text-gray-500">إجمالي المنتجات</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-green-100 rounded-xl">
                            <TrendingUp className="h-5 w-5 text-green-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{formatNumber(stats.inStock, locale)}</p>
                            <p className="text-sm text-gray-500">متوفر</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-yellow-100 rounded-xl">
                            <AlertTriangle className="h-5 w-5 text-yellow-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{formatNumber(stats.lowStock, locale)}</p>
                            <p className="text-sm text-gray-500">مخزون منخفض</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-red-100 rounded-xl">
                            <TrendingDown className="h-5 w-5 text-red-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{formatNumber(stats.outOfStock, locale)}</p>
                            <p className="text-sm text-gray-500">نفذ</p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Warehouses */}
            {isLoading ? (
                <div className="flex items-center justify-center py-12">
                    <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                </div>
            ) : (
                <>
                    <div className="grid md:grid-cols-3 gap-4">
                        {warehouses?.map((warehouse) => (
                            <Card key={warehouse._id}>
                                <CardContent className="p-4">
                                    <div className="flex items-center gap-3 mb-3">
                                        <div className="p-2 bg-primary-100 rounded-lg">
                                            <Warehouse className="h-5 w-5 text-primary-600" />
                                        </div>
                                        <div>
                                            <p className="font-medium">{warehouse.name}</p>
                                            <p className="text-xs text-gray-500">{warehouse.address?.city || '-'}</p>
                                        </div>
                                        {warehouse.isDefault && (
                                            <Badge variant="default" className="ms-auto">الرئيسي</Badge>
                                        )}
                                    </div>
                                    <div className="grid grid-cols-2 gap-4 text-center">
                                        <div className="bg-gray-50 rounded-lg p-2">
                                            <p className="text-lg font-bold">{formatNumber(warehouse.totalProducts || 0, locale)}</p>
                                            <p className="text-xs text-gray-500">منتج</p>
                                        </div>
                                        <div className="bg-gray-50 rounded-lg p-2">
                                            <p className="text-lg font-bold">{formatNumber(warehouse.totalStock || 0, locale)}</p>
                                            <p className="text-xs text-gray-500">وحدة</p>
                                        </div>
                                    </div>
                                </CardContent>
                            </Card>
                        ))}
                    </div>

                    {/* Stock Alerts Table */}
                    <Card>
                        <CardHeader className="pb-4">
                            <CardTitle className="text-lg">تنبيهات المخزون</CardTitle>
                        </CardHeader>
                        <CardContent className="p-0">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>المنتج</TableHead>
                                        <TableHead>رمز المنتج</TableHead>
                                        <TableHead>المستودع</TableHead>
                                        <TableHead>الكمية</TableHead>
                                        <TableHead>الحد الأدنى</TableHead>
                                        <TableHead>الحالة</TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {alerts?.map((alert) => (
                                        <TableRow key={alert._id}>
                                            <TableCell className="font-medium">{alert.product?.name}</TableCell>
                                            <TableCell className="font-mono text-sm text-gray-500">{alert.product?.sku}</TableCell>
                                            <TableCell className="text-gray-600">{alert.warehouse?.name}</TableCell>
                                            <TableCell>
                                                <span
                                                    className={cn(
                                                        'font-medium',
                                                        alert.currentStock === 0
                                                            ? 'text-red-600'
                                                            : alert.currentStock < alert.minStockLevel
                                                                ? 'text-yellow-600'
                                                                : 'text-green-600'
                                                    )}
                                                >
                                                    {formatNumber(alert.currentStock, locale)}
                                                </span>
                                            </TableCell>
                                            <TableCell className="text-gray-500">{formatNumber(alert.minStockLevel, locale)}</TableCell>
                                            <TableCell>
                                                <Badge variant={alert.currentStock === 0 ? 'danger' : 'warning'}>
                                                    {alert.currentStock === 0 ? 'نفذ' : 'منخفض'}
                                                </Badge>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                    {(!alerts || alerts.length === 0) && (
                                        <TableRow>
                                            <TableCell colSpan={6} className="text-center py-8 text-gray-500">
                                                لا توجد تنبيهات مخزون
                                            </TableCell>
                                        </TableRow>
                                    )}
                                </TableBody>
                            </Table>
                        </CardContent>
                    </Card>
                </>
            )}
        </div>
    );
}
