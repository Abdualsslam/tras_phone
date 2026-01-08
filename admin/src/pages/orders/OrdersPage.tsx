import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from '@tanstack/react-query';
import { ordersApi } from '@/api/orders.api';
import type { Order } from '@/types';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
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
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import {
    Search,
    MoreHorizontal,
    Eye,
    Truck,
    CreditCard,
    ShoppingCart,
    Loader2,
    AlertCircle,
} from 'lucide-react';
import { formatCurrency, formatDate } from '@/lib/utils';

const orderStatusVariants: Record<string, 'success' | 'warning' | 'danger' | 'default'> = {
    pending: 'warning',
    confirmed: 'default',
    processing: 'default',
    shipped: 'success',
    delivered: 'success',
    cancelled: 'danger',
    refunded: 'danger',
};

const orderStatusLabels: Record<string, string> = {
    pending: 'قيد الانتظار',
    confirmed: 'مؤكد',
    processing: 'قيد المعالجة',
    shipped: 'تم الشحن',
    delivered: 'تم التوصيل',
    cancelled: 'ملغي',
    refunded: 'مسترد',
};

const paymentStatusVariants: Record<string, 'success' | 'warning' | 'danger'> = {
    paid: 'success',
    pending: 'warning',
    partially_paid: 'warning',
    failed: 'danger',
    refunded: 'danger',
};

const paymentStatusLabels: Record<string, string> = {
    paid: 'مدفوع',
    pending: 'غير مدفوع',
    partially_paid: 'مدفوع جزئياً',
    failed: 'فشل',
    refunded: 'مسترد',
};

export function OrdersPage() {
    const { t, i18n } = useTranslation();
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState('');
    const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
    const [isDetailsDialogOpen, setIsDetailsDialogOpen] = useState(false);
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    // Fetch orders
    const { data, isLoading, error } = useQuery({
        queryKey: ['orders', searchQuery, statusFilter],
        queryFn: () => ordersApi.getAll({
            orderNumber: searchQuery || undefined,
            status: statusFilter || undefined,
            limit: 20
        }),
    });

    const handleViewDetails = (order: Order) => {
        setSelectedOrder(order);
        setIsDetailsDialogOpen(true);
    };

    const orders = data?.items || [];

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">{t('orders.title')}</h1>
                    <p className="text-gray-500 mt-1">متابعة وإدارة الطلبات</p>
                </div>
            </div>

            {/* Search and Filters */}
            <Card>
                <CardContent className="p-4">
                    <div className="flex flex-col sm:flex-row gap-4">
                        <div className="relative flex-1">
                            <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                            <Input
                                placeholder="البحث برقم الطلب أو اسم العميل..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="ps-10"
                            />
                        </div>
                        <select
                            value={statusFilter}
                            onChange={(e) => setStatusFilter(e.target.value)}
                            className="h-10 rounded-lg border border-gray-300 px-3 text-sm min-w-[150px]"
                        >
                            <option value="">جميع الحالات</option>
                            <option value="pending">قيد الانتظار</option>
                            <option value="confirmed">مؤكد</option>
                            <option value="processing">قيد المعالجة</option>
                            <option value="shipped">تم الشحن</option>
                            <option value="delivered">تم التوصيل</option>
                            <option value="cancelled">ملغي</option>
                        </select>
                    </div>
                </CardContent>
            </Card>

            {/* Orders Table */}
            <Card>
                <CardHeader className="flex flex-row items-center gap-2 pb-4">
                    <ShoppingCart className="h-5 w-5 text-gray-500" />
                    <CardTitle className="text-lg">قائمة الطلبات</CardTitle>
                    {data && (
                        <Badge variant="secondary" className="ms-auto">
                            {data.pagination?.total || orders.length} طلب
                        </Badge>
                    )}
                </CardHeader>
                <CardContent className="p-0">
                    {isLoading ? (
                        <div className="flex items-center justify-center py-12">
                            <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                        </div>
                    ) : error ? (
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500">
                            <AlertCircle className="h-12 w-12 mb-4 text-red-400" />
                            <p>حدث خطأ في تحميل البيانات</p>
                        </div>
                    ) : orders.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500">
                            <ShoppingCart className="h-12 w-12 mb-4 text-gray-300" />
                            <p>{t('common.noData')}</p>
                        </div>
                    ) : (
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>{t('orders.orderNumber')}</TableHead>
                                    <TableHead>{t('orders.customer')}</TableHead>
                                    <TableHead>{t('orders.total')}</TableHead>
                                    <TableHead>حالة الطلب</TableHead>
                                    <TableHead>حالة الدفع</TableHead>
                                    <TableHead>{t('orders.date')}</TableHead>
                                    <TableHead className="w-[50px]"></TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {orders.map((order) => (
                                    <TableRow key={order._id}>
                                        <TableCell className="font-medium text-primary-600">
                                            {order.orderNumber}
                                        </TableCell>
                                        <TableCell>
                                            <div>
                                                <p className="font-medium text-gray-900">{order.customer.companyName}</p>
                                                <p className="text-xs text-gray-500">{order.customer.contactName}</p>
                                            </div>
                                        </TableCell>
                                        <TableCell className="font-medium">
                                            {formatCurrency(order.total, 'SAR', locale)}
                                        </TableCell>
                                        <TableCell>
                                            <Badge variant={orderStatusVariants[order.status]}>
                                                {orderStatusLabels[order.status]}
                                            </Badge>
                                        </TableCell>
                                        <TableCell>
                                            <Badge variant={paymentStatusVariants[order.paymentStatus]}>
                                                {paymentStatusLabels[order.paymentStatus]}
                                            </Badge>
                                        </TableCell>
                                        <TableCell className="text-gray-500 text-sm">
                                            {formatDate(order.createdAt, locale)}
                                        </TableCell>
                                        <TableCell>
                                            <DropdownMenu>
                                                <DropdownMenuTrigger asChild>
                                                    <Button variant="ghost" size="icon">
                                                        <MoreHorizontal className="h-4 w-4" />
                                                    </Button>
                                                </DropdownMenuTrigger>
                                                <DropdownMenuContent align="end">
                                                    <DropdownMenuItem onClick={() => handleViewDetails(order)}>
                                                        <Eye className="h-4 w-4" />
                                                        عرض التفاصيل
                                                    </DropdownMenuItem>
                                                    <DropdownMenuItem>
                                                        <Truck className="h-4 w-4" />
                                                        إنشاء شحنة
                                                    </DropdownMenuItem>
                                                    <DropdownMenuItem>
                                                        <CreditCard className="h-4 w-4" />
                                                        تسجيل دفعة
                                                    </DropdownMenuItem>
                                                </DropdownMenuContent>
                                            </DropdownMenu>
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    )}
                </CardContent>
            </Card>

            {/* Order Details Dialog */}
            <Dialog open={isDetailsDialogOpen} onOpenChange={setIsDetailsDialogOpen}>
                <DialogContent className="max-w-2xl">
                    <DialogHeader>
                        <DialogTitle>تفاصيل الطلب {selectedOrder?.orderNumber}</DialogTitle>
                    </DialogHeader>
                    {selectedOrder && (
                        <div className="space-y-6">
                            {/* Order Info */}
                            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                                <div>
                                    <p className="text-sm text-gray-500">العميل</p>
                                    <p className="font-medium">{selectedOrder.customer.companyName}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-gray-500">حالة الطلب</p>
                                    <Badge variant={orderStatusVariants[selectedOrder.status]}>
                                        {orderStatusLabels[selectedOrder.status]}
                                    </Badge>
                                </div>
                                <div>
                                    <p className="text-sm text-gray-500">حالة الدفع</p>
                                    <Badge variant={paymentStatusVariants[selectedOrder.paymentStatus]}>
                                        {paymentStatusLabels[selectedOrder.paymentStatus]}
                                    </Badge>
                                </div>
                                <div>
                                    <p className="text-sm text-gray-500">التاريخ</p>
                                    <p className="font-medium">{formatDate(selectedOrder.createdAt, locale)}</p>
                                </div>
                            </div>

                            {/* Order Items */}
                            <div>
                                <h4 className="font-medium mb-3">المنتجات</h4>
                                <div className="border rounded-lg divide-y">
                                    {selectedOrder.items.map((item, index) => (
                                        <div key={index} className="p-3 flex items-center justify-between">
                                            <div className="flex items-center gap-3">
                                                <div className="w-10 h-10 bg-gray-100 rounded-lg" />
                                                <div>
                                                    <p className="font-medium">{item.product.name}</p>
                                                    <p className="text-xs text-gray-500">{item.product.sku}</p>
                                                </div>
                                            </div>
                                            <div className="text-end">
                                                <p className="font-medium">{formatCurrency(item.total, 'SAR', locale)}</p>
                                                <p className="text-xs text-gray-500">{item.quantity} × {formatCurrency(item.price, 'SAR', locale)}</p>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            {/* Order Summary */}
                            <div className="bg-gray-50 rounded-lg p-4">
                                <div className="flex justify-between mb-2">
                                    <span className="text-gray-500">المجموع الفرعي</span>
                                    <span>{formatCurrency(selectedOrder.subtotal, 'SAR', locale)}</span>
                                </div>
                                {selectedOrder.discount > 0 && (
                                    <div className="flex justify-between mb-2 text-green-600">
                                        <span>الخصم</span>
                                        <span>- {formatCurrency(selectedOrder.discount, 'SAR', locale)}</span>
                                    </div>
                                )}
                                <div className="flex justify-between mb-2">
                                    <span className="text-gray-500">الضريبة</span>
                                    <span>{formatCurrency(selectedOrder.tax, 'SAR', locale)}</span>
                                </div>
                                <div className="flex justify-between font-bold text-lg border-t pt-2 mt-2">
                                    <span>الإجمالي</span>
                                    <span>{formatCurrency(selectedOrder.total, 'SAR', locale)}</span>
                                </div>
                            </div>
                        </div>
                    )}
                </DialogContent>
            </Dialog>
        </div>
    );
}
