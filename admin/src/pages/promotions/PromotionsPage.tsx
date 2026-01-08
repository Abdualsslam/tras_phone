import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { promotionsApi } from '@/api/promotions.api';
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
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
    Plus,
    Search,
    Tags,
    MoreHorizontal,
    Pencil,
    Trash2,
    Copy,
    Percent,
    Gift,
    Loader2,
    AlertCircle,
} from 'lucide-react';
import { formatCurrency, formatDate } from '@/lib/utils';

export function PromotionsPage() {
    const { t, i18n } = useTranslation();
    const queryClient = useQueryClient();
    const [searchQuery, setSearchQuery] = useState('');
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    // Fetch coupons from backend
    const { data: coupons, isLoading, error } = useQuery({
        queryKey: ['coupons'],
        queryFn: promotionsApi.getAllCoupons,
    });

    // Delete mutation
    const deleteMutation = useMutation({
        mutationFn: (id: string) => promotionsApi.deleteCoupon(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['coupons'] });
        },
    });

    const filteredCoupons = (coupons || []).filter(
        (promo) =>
            promo.code.toLowerCase().includes(searchQuery.toLowerCase()) ||
            promo.description?.includes(searchQuery)
    );

    const copyCode = (code: string) => {
        navigator.clipboard.writeText(code);
    };

    const stats = {
        total: coupons?.length || 0,
        active: coupons?.filter((c) => c.isActive).length || 0,
        totalUsage: coupons?.reduce((sum, c) => sum + (c.usageCount || 0), 0) || 0,
        percentage: coupons?.filter((c) => c.type === 'percentage').length || 0,
    };

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">{t('sidebar.promotions')}</h1>
                    <p className="text-gray-500 mt-1">إدارة القسائم والعروض الترويجية</p>
                </div>
                <Button>
                    <Plus className="h-4 w-4" />
                    إضافة قسيمة
                </Button>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <Card>
                    <CardContent className="p-4 text-center">
                        <div className="mx-auto w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center mb-2">
                            <Tags className="h-6 w-6 text-primary-600" />
                        </div>
                        <p className="text-2xl font-bold">{stats.total}</p>
                        <p className="text-sm text-gray-500">إجمالي القسائم</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 text-center">
                        <div className="mx-auto w-12 h-12 bg-green-100 rounded-xl flex items-center justify-center mb-2">
                            <Gift className="h-6 w-6 text-green-600" />
                        </div>
                        <p className="text-2xl font-bold">{stats.active}</p>
                        <p className="text-sm text-gray-500">قسائم نشطة</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 text-center">
                        <div className="mx-auto w-12 h-12 bg-blue-100 rounded-xl flex items-center justify-center mb-2">
                            <Percent className="h-6 w-6 text-blue-600" />
                        </div>
                        <p className="text-2xl font-bold">{stats.totalUsage}</p>
                        <p className="text-sm text-gray-500">إجمالي الاستخدام</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 text-center">
                        <div className="mx-auto w-12 h-12 bg-purple-100 rounded-xl flex items-center justify-center mb-2">
                            <Tags className="h-6 w-6 text-purple-600" />
                        </div>
                        <p className="text-2xl font-bold">{stats.percentage}</p>
                        <p className="text-sm text-gray-500">خصم نسبة مئوية</p>
                    </CardContent>
                </Card>
            </div>

            {/* Search */}
            <Card>
                <CardContent className="p-4">
                    <div className="relative max-w-md">
                        <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <Input
                            placeholder="البحث بكود القسيمة..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="ps-10"
                        />
                    </div>
                </CardContent>
            </Card>

            {/* Coupons Table */}
            <Card>
                <CardHeader className="pb-4">
                    <CardTitle className="text-lg">قائمة القسائم</CardTitle>
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
                    ) : (
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>الكود</TableHead>
                                    <TableHead>الوصف</TableHead>
                                    <TableHead>الخصم</TableHead>
                                    <TableHead>الاستخدام</TableHead>
                                    <TableHead>الفترة</TableHead>
                                    <TableHead>الحالة</TableHead>
                                    <TableHead className="w-[50px]"></TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {filteredCoupons.map((coupon) => (
                                    <TableRow key={coupon._id}>
                                        <TableCell>
                                            <div className="flex items-center gap-2">
                                                <code className="bg-gray-100 px-2 py-1 rounded text-sm font-mono">
                                                    {coupon.code}
                                                </code>
                                                <Button
                                                    variant="ghost"
                                                    size="icon"
                                                    className="h-6 w-6"
                                                    onClick={() => copyCode(coupon.code)}
                                                >
                                                    <Copy className="h-3 w-3" />
                                                </Button>
                                            </div>
                                        </TableCell>
                                        <TableCell className="text-gray-600">{coupon.description || '-'}</TableCell>
                                        <TableCell className="font-medium">
                                            {coupon.type === 'percentage'
                                                ? `${coupon.value}%`
                                                : formatCurrency(coupon.value, 'SAR', locale)}
                                        </TableCell>
                                        <TableCell>
                                            <div className="flex items-center gap-2">
                                                <span className="text-gray-900">{coupon.usageCount}</span>
                                                {coupon.usageLimit && (
                                                    <>
                                                        <span className="text-gray-400">/</span>
                                                        <span className="text-gray-500">{coupon.usageLimit}</span>
                                                    </>
                                                )}
                                            </div>
                                        </TableCell>
                                        <TableCell className="text-sm text-gray-500">
                                            <div>
                                                {formatDate(coupon.startDate, locale)}
                                                <span className="mx-1">-</span>
                                                {formatDate(coupon.endDate, locale)}
                                            </div>
                                        </TableCell>
                                        <TableCell>
                                            <Badge variant={coupon.isActive ? 'success' : 'default'}>
                                                {coupon.isActive ? 'نشط' : 'غير نشط'}
                                            </Badge>
                                        </TableCell>
                                        <TableCell>
                                            <DropdownMenu>
                                                <DropdownMenuTrigger asChild>
                                                    <Button variant="ghost" size="icon">
                                                        <MoreHorizontal className="h-4 w-4" />
                                                    </Button>
                                                </DropdownMenuTrigger>
                                                <DropdownMenuContent align="end">
                                                    <DropdownMenuItem>
                                                        <Pencil className="h-4 w-4" />
                                                        تعديل
                                                    </DropdownMenuItem>
                                                    <DropdownMenuItem onClick={() => copyCode(coupon.code)}>
                                                        <Copy className="h-4 w-4" />
                                                        نسخ
                                                    </DropdownMenuItem>
                                                    <DropdownMenuSeparator />
                                                    <DropdownMenuItem
                                                        className="text-red-600"
                                                        onClick={() => deleteMutation.mutate(coupon._id)}
                                                    >
                                                        <Trash2 className="h-4 w-4" />
                                                        حذف
                                                    </DropdownMenuItem>
                                                </DropdownMenuContent>
                                            </DropdownMenu>
                                        </TableCell>
                                    </TableRow>
                                ))}
                                {filteredCoupons.length === 0 && (
                                    <TableRow>
                                        <TableCell colSpan={7} className="text-center py-8 text-gray-500">
                                            لا توجد قسائم
                                        </TableCell>
                                    </TableRow>
                                )}
                            </TableBody>
                        </Table>
                    )}
                </CardContent>
            </Card>
        </div>
    );
}
