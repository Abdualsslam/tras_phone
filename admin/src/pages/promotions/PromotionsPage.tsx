import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { promotionsApi } from '@/api/promotions.api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
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

interface PromotionFormData {
    name: string;
    nameAr: string;
    code: string;
    description?: string;
    descriptionAr?: string;
    discountType: 'percentage' | 'fixed_amount' | 'buy_x_get_y' | 'free_shipping';
    discountValue?: number;
    maxDiscountAmount?: number;
    buyQuantity?: number;
    getQuantity?: number;
    getDiscountPercentage?: number;
    startDate: string;
    endDate: string;
    minOrderAmount?: number;
    minQuantity?: number;
    scope: 'all' | 'specific_products' | 'specific_categories' | 'specific_brands';
    productIds?: string[];
    categoryIds?: string[];
    brandIds?: string[];
    usageLimit?: number;
    usageLimitPerCustomer?: number;
    image?: string;
    badgeText?: string;
    badgeColor?: string;
    isActive: boolean;
    isAutoApply: boolean;
    priority: number;
    isStackable: boolean;
}

const initialPromotionForm: PromotionFormData = {
    name: '',
    nameAr: '',
    code: '',
    description: '',
    descriptionAr: '',
    discountType: 'percentage',
    discountValue: 0,
    maxDiscountAmount: undefined,
    buyQuantity: undefined,
    getQuantity: undefined,
    getDiscountPercentage: undefined,
    startDate: new Date().toISOString().split('T')[0],
    endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    minOrderAmount: undefined,
    minQuantity: undefined,
    scope: 'all',
    productIds: [],
    categoryIds: [],
    brandIds: [],
    usageLimit: undefined,
    usageLimitPerCustomer: undefined,
    image: '',
    badgeText: '',
    badgeColor: '#FF0000',
    isActive: true,
    isAutoApply: false,
    priority: 0,
    isStackable: false,
};

export function PromotionsPage() {
    const { t, i18n } = useTranslation();
    const queryClient = useQueryClient();
    const [searchQuery, setSearchQuery] = useState('');
    const activeTab: 'coupons' = 'coupons';
    const [isPromotionDialogOpen, setIsPromotionDialogOpen] = useState(false);
    const [promotionForm, setPromotionForm] = useState<PromotionFormData>(initialPromotionForm);
    const [isEditMode, setIsEditMode] = useState(false);
    const [selectedPromotionId, setSelectedPromotionId] = useState<string | null>(null);
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';
    const direction = i18n.dir() as 'rtl' | 'ltr';

    // Fetch promotions and coupons from backend
    const { data: promotions, isLoading: isLoadingPromotions } = useQuery({
        queryKey: ['promotions'],
        queryFn: promotionsApi.getAllPromotions,
        enabled: activeTab === 'promotions',
    });

    const { data: coupons, isLoading: isLoadingCoupons, error } = useQuery({
        queryKey: ['coupons'],
        queryFn: promotionsApi.getAllCoupons,
        enabled: activeTab === 'coupons',
    });

    // Create promotion mutation
    const createPromotionMutation = useMutation({
        mutationFn: (data: any) => promotionsApi.createPromotion(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['promotions'] });
            setIsPromotionDialogOpen(false);
            setPromotionForm(initialPromotionForm);
        },
    });

    // Update promotion mutation
    const updatePromotionMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: any }) => promotionsApi.updatePromotion(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['promotions'] });
            setIsPromotionDialogOpen(false);
            setPromotionForm(initialPromotionForm);
            setIsEditMode(false);
            setSelectedPromotionId(null);
        },
    });

    // Delete promotion mutation
    const deletePromotionMutation = useMutation({
        mutationFn: (id: string) => promotionsApi.deletePromotion(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['promotions'] });
        },
    });

    // Delete coupon mutation
    const deleteCouponMutation = useMutation({
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

    const filteredPromotions = (promotions || []).filter(
        (promo) =>
            promo.code?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            promo.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
            promo.nameAr?.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const copyCode = (code: string) => {
        navigator.clipboard.writeText(code);
    };

    const handleOpenPromotionDialog = () => {
        setIsEditMode(false);
        setSelectedPromotionId(null);
        setPromotionForm(initialPromotionForm);
        setIsPromotionDialogOpen(true);
    };

    const handleEditPromotion = (promotion: any) => {
        setIsEditMode(true);
        setSelectedPromotionId(promotion._id);
        setPromotionForm({
            name: promotion.name || '',
            nameAr: promotion.nameAr || '',
            code: promotion.code || '',
            description: promotion.description || '',
            descriptionAr: promotion.descriptionAr || '',
            discountType: promotion.discountType || 'percentage',
            discountValue: promotion.discountValue || 0,
            maxDiscountAmount: promotion.maxDiscountAmount,
            buyQuantity: promotion.buyQuantity,
            getQuantity: promotion.getQuantity,
            getDiscountPercentage: promotion.getDiscountPercentage,
            startDate: promotion.startDate ? new Date(promotion.startDate).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
            endDate: promotion.endDate ? new Date(promotion.endDate).toISOString().split('T')[0] : new Date().toISOString().split('T')[0],
            minOrderAmount: promotion.minOrderAmount,
            minQuantity: promotion.minQuantity,
            scope: promotion.scope || 'all',
            productIds: promotion.productIds || [],
            categoryIds: promotion.categoryIds || [],
            brandIds: promotion.brandIds || [],
            usageLimit: promotion.usageLimit,
            usageLimitPerCustomer: promotion.usageLimitPerCustomer,
            image: promotion.image || '',
            badgeText: promotion.badgeText || '',
            badgeColor: promotion.badgeColor || '#FF0000',
            isActive: promotion.isActive ?? true,
            isAutoApply: promotion.isAutoApply ?? false,
            priority: promotion.priority || 0,
            isStackable: promotion.isStackable ?? false,
        });
        setIsPromotionDialogOpen(true);
    };

    const handleSubmitPromotion = () => {
        const formData = {
            ...promotionForm,
            startDate: new Date(promotionForm.startDate).toISOString(),
            endDate: new Date(promotionForm.endDate).toISOString(),
        };

        if (isEditMode && selectedPromotionId) {
            updatePromotionMutation.mutate({ id: selectedPromotionId, data: formData });
        } else {
            createPromotionMutation.mutate(formData);
        }
    };

    const stats = {
        total: coupons?.length || 0,
        active: coupons?.filter((c) => c.isActive).length || 0,
        totalUsage: coupons?.reduce((sum, c) => sum + (c.usageCount || 0), 0) || 0,
        percentage: coupons?.filter((c) => c.type === 'percentage').length || 0,
    };

    return (
        <div className="space-y-6 animate-fade-in" dir={direction}>
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t('sidebar.coupons')}</h1>
                    <p className="text-gray-500 dark:text-gray-400 mt-1">إدارة القسائم</p>
                </div>
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

            <div className="space-y-4">
                <Card>
                    <CardHeader className="pb-4 text-start">
                        <CardTitle className="text-lg">قائمة القسائم</CardTitle>
                    </CardHeader>
                    <CardContent className="p-0">
                        {isLoadingCoupons ? (
                            <div className="flex items-center justify-center py-12">
                                <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                            </div>
                        ) : error ? (
                            <div className="flex flex-col items-center justify-center py-12 text-gray-500">
                                <AlertCircle className="h-12 w-12 mb-4 text-red-400" />
                                <p>حدث خطأ في تحميل البيانات</p>
                            </div>
                        ) : (
                            <Table dir={direction}>
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
                                                    <code className="bg-gray-100 dark:bg-slate-800 border border-gray-200 dark:border-slate-700 text-gray-900 dark:text-gray-100 px-2 py-1 rounded text-sm font-mono">
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
                                                            onClick={() => deleteCouponMutation.mutate(coupon._id)}
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

            {/* Create/Edit Promotion Dialog */}
            <Dialog open={isPromotionDialogOpen} onOpenChange={setIsPromotionDialogOpen}>
                <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>{isEditMode ? 'تعديل عرض' : 'إضافة عرض جديد'}</DialogTitle>
                        <DialogDescription>
                            {isEditMode ? 'قم بتعديل بيانات العرض' : 'أدخل بيانات العرض الجديد'} (الحقول المميزة بـ * إلزامية)
                        </DialogDescription>
                    </DialogHeader>

                    <div className="space-y-6 py-4">
                        {/* Basic Info */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                                المعلومات الأساسية
                            </h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>
                                        الاسم بالإنجليزية <span className="text-red-500">*</span>
                                    </Label>
                                    <Input
                                        value={promotionForm.name}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, name: e.target.value })}
                                        placeholder="عرض الصيف"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>
                                        الاسم بالعربية <span className="text-red-500">*</span>
                                    </Label>
                                    <Input
                                        value={promotionForm.nameAr}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, nameAr: e.target.value })}
                                        placeholder="عروض الصيف"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>
                                        الكود <span className="text-red-500">*</span>
                                    </Label>
                                    <Input
                                        value={promotionForm.code}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, code: e.target.value })}
                                        placeholder="SUMMER2024"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الوصف</Label>
                                    <Input
                                        value={promotionForm.description || ''}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, description: e.target.value })}
                                        placeholder="الوصف"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الوصف بالعربية</Label>
                                    <Input
                                        value={promotionForm.descriptionAr || ''}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, descriptionAr: e.target.value })}
                                        placeholder="الوصف بالعربية"
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Discount Type */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                                نوع الخصم
                            </h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>
                                        نوع الخصم <span className="text-red-500">*</span>
                                    </Label>
                                    <Select
                                        value={promotionForm.discountType}
                                        onValueChange={(value: any) => setPromotionForm({ ...promotionForm, discountType: value })}
                                    >
                                        <SelectTrigger>
                                            <SelectValue />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="percentage">نسبة مئوية</SelectItem>
                                            <SelectItem value="fixed_amount">مبلغ ثابت</SelectItem>
                                            <SelectItem value="buy_x_get_y">اشتر X واحصل على Y</SelectItem>
                                            <SelectItem value="free_shipping">شحن مجاني</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>
                                {promotionForm.discountType !== 'free_shipping' && (
                                    <div className="space-y-2">
                                        <Label>
                                            قيمة الخصم <span className="text-red-500">*</span>
                                        </Label>
                                        <Input
                                            type="number"
                                            value={promotionForm.discountValue || ''}
                                            onChange={(e) => setPromotionForm({ ...promotionForm, discountValue: parseFloat(e.target.value) || 0 })}
                                            placeholder={promotionForm.discountType === 'percentage' ? '20' : '50'}
                                        />
                                    </div>
                                )}
                                {promotionForm.discountType === 'percentage' && (
                                    <div className="space-y-2">
                                        <Label>الحد الأقصى للخصم (ريال)</Label>
                                        <Input
                                            type="number"
                                            value={promotionForm.maxDiscountAmount || ''}
                                            onChange={(e) => setPromotionForm({ ...promotionForm, maxDiscountAmount: parseFloat(e.target.value) || undefined })}
                                            placeholder="100"
                                        />
                                    </div>
                                )}
                                {promotionForm.discountType === 'buy_x_get_y' && (
                                    <>
                                        <div className="space-y-2">
                                            <Label>اشتر (X) <span className="text-red-500">*</span></Label>
                                            <Input
                                                type="number"
                                                value={promotionForm.buyQuantity || ''}
                                                onChange={(e) => setPromotionForm({ ...promotionForm, buyQuantity: parseInt(e.target.value) || undefined })}
                                                placeholder="2"
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <Label>احصل على (Y) <span className="text-red-500">*</span></Label>
                                            <Input
                                                type="number"
                                                value={promotionForm.getQuantity || ''}
                                                onChange={(e) => setPromotionForm({ ...promotionForm, getQuantity: parseInt(e.target.value) || undefined })}
                                                placeholder="1"
                                            />
                                        </div>
                                        <div className="space-y-2">
                                            <Label>نسبة الخصم على Y (%)</Label>
                                            <Input
                                                type="number"
                                                value={promotionForm.getDiscountPercentage || ''}
                                                onChange={(e) => setPromotionForm({ ...promotionForm, getDiscountPercentage: parseFloat(e.target.value) || undefined })}
                                                placeholder="100 (للمجاني)"
                                            />
                                        </div>
                                    </>
                                )}
                            </div>
                        </div>

                        {/* Validity */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                                الفترة الزمنية
                            </h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>
                                        تاريخ البداية <span className="text-red-500">*</span>
                                    </Label>
                                    <Input
                                        type="date"
                                        value={promotionForm.startDate}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, startDate: e.target.value })}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>
                                        تاريخ النهاية <span className="text-red-500">*</span>
                                    </Label>
                                    <Input
                                        type="date"
                                        value={promotionForm.endDate}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, endDate: e.target.value })}
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Conditions */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                                الشروط
                            </h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>الحد الأدنى لمبلغ الطلب (ريال)</Label>
                                    <Input
                                        type="number"
                                        value={promotionForm.minOrderAmount || ''}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, minOrderAmount: parseFloat(e.target.value) || undefined })}
                                        placeholder="500"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الحد الأدنى للكمية</Label>
                                    <Input
                                        type="number"
                                        value={promotionForm.minQuantity || ''}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, minQuantity: parseInt(e.target.value) || undefined })}
                                        placeholder="1"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>
                                        النطاق <span className="text-red-500">*</span>
                                    </Label>
                                    <Select
                                        value={promotionForm.scope}
                                        onValueChange={(value: any) => setPromotionForm({ ...promotionForm, scope: value })}
                                    >
                                        <SelectTrigger>
                                            <SelectValue />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="all">جميع المنتجات</SelectItem>
                                            <SelectItem value="specific_products">منتجات محددة</SelectItem>
                                            <SelectItem value="specific_categories">أقسام محددة</SelectItem>
                                            <SelectItem value="specific_brands">ماركات محددة</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>
                            </div>
                        </div>

                        {/* Usage Limits */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                                حدود الاستخدام
                            </h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>الحد الأقصى للاستخدام الإجمالي</Label>
                                    <Input
                                        type="number"
                                        value={promotionForm.usageLimit || ''}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, usageLimit: parseInt(e.target.value) || undefined })}
                                        placeholder="1000"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الحد الأقصى لكل عميل</Label>
                                    <Input
                                        type="number"
                                        value={promotionForm.usageLimitPerCustomer || ''}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, usageLimitPerCustomer: parseInt(e.target.value) || undefined })}
                                        placeholder="1"
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Settings */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                                الإعدادات
                            </h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>الأولوية</Label>
                                    <Input
                                        type="number"
                                        value={promotionForm.priority}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, priority: parseInt(e.target.value) || 0 })}
                                        placeholder="0"
                                    />
                                    <p className="text-xs text-gray-500">الأعلى أولاً</p>
                                </div>
                                <div className="space-y-2">
                                    <Label>نص الشارة</Label>
                                    <Input
                                        value={promotionForm.badgeText || ''}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, badgeText: e.target.value })}
                                        placeholder="خصم 20%"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>لون الشارة</Label>
                                    <Input
                                        type="color"
                                        value={promotionForm.badgeColor}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, badgeColor: e.target.value })}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>رابط الصورة</Label>
                                    <Input
                                        value={promotionForm.image || ''}
                                        onChange={(e) => setPromotionForm({ ...promotionForm, image: e.target.value })}
                                        placeholder="https://..."
                                    />
                                </div>
                            </div>
                            <div className="space-y-3">
                                <div className="flex items-center gap-2">
                                    <Switch
                                        id="isActive"
                                        checked={promotionForm.isActive}
                                        onCheckedChange={(checked) => setPromotionForm({ ...promotionForm, isActive: checked })}
                                    />
                                    <Label htmlFor="isActive">عرض نشط</Label>
                                </div>
                                <div className="flex items-center gap-2">
                                    <Switch
                                        id="isAutoApply"
                                        checked={promotionForm.isAutoApply}
                                        onCheckedChange={(checked) => setPromotionForm({ ...promotionForm, isAutoApply: checked })}
                                    />
                                    <Label htmlFor="isAutoApply">تطبيق تلقائي</Label>
                                </div>
                                <div className="flex items-center gap-2">
                                    <Switch
                                        id="isStackable"
                                        checked={promotionForm.isStackable}
                                        onCheckedChange={(checked) => setPromotionForm({ ...promotionForm, isStackable: checked })}
                                    />
                                    <Label htmlFor="isStackable">قابل للدمج مع عروض أخرى</Label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <DialogFooter>
                        <Button
                            variant="outline"
                            onClick={() => {
                                setIsPromotionDialogOpen(false);
                                setPromotionForm(initialPromotionForm);
                                setIsEditMode(false);
                                setSelectedPromotionId(null);
                            }}
                        >
                            إلغاء
                        </Button>
                        <Button
                            onClick={handleSubmitPromotion}
                            disabled={createPromotionMutation.isPending || updatePromotionMutation.isPending}
                        >
                            {(createPromotionMutation.isPending || updatePromotionMutation.isPending) && (
                                <Loader2 className="h-4 w-4 animate-spin me-2" />
                            )}
                            {isEditMode ? 'تحديث' : 'إنشاء'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
