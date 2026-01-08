import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productsApi, type CreateProductDto } from '@/api/products.api';
import { catalogApi, type CategoryTree, type QualityType } from '@/api/catalog.api';
import type { Product, Brand } from '@/types';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
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
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
} from '@/components/ui/dialog';
import {
    Plus,
    Search,
    MoreHorizontal,
    Pencil,
    Trash2,
    Eye,
    Package,
    Loader2,
    AlertCircle,
} from 'lucide-react';
import { formatCurrency } from '@/lib/utils';

const statusVariants: Record<string, 'success' | 'warning' | 'default' | 'danger'> = {
    active: 'success',
    published: 'success',
    draft: 'warning',
    inactive: 'default',
    out_of_stock: 'danger',
    discontinued: 'default',
    archived: 'default',
};

const statusLabels: Record<string, string> = {
    active: 'نشط',
    published: 'منشور',
    draft: 'مسودة',
    inactive: 'غير نشط',
    out_of_stock: 'نفذ المخزون',
    discontinued: 'متوقف',
    archived: 'مؤرشف',
};

interface AddProductForm {
    // Required
    sku: string;
    name: string;
    nameAr: string;
    slug: string;
    brandId: string;
    categoryId: string;
    qualityTypeId: string;
    basePrice: string;
    // Optional
    description: string;
    descriptionAr: string;
    shortDescription: string;
    shortDescriptionAr: string;
    compareAtPrice: string;
    costPrice: string;
    stockQuantity: string;
    lowStockThreshold: string;
    minOrderQuantity: string;
    maxOrderQuantity: string;
    status: string;
    isActive: boolean;
    isFeatured: boolean;
    weight: string;
    dimensions: string;
    color: string;
}

const initialFormData: AddProductForm = {
    sku: '',
    name: '',
    nameAr: '',
    slug: '',
    brandId: '',
    categoryId: '',
    qualityTypeId: '',
    basePrice: '',
    description: '',
    descriptionAr: '',
    shortDescription: '',
    shortDescriptionAr: '',
    compareAtPrice: '',
    costPrice: '',
    stockQuantity: '0',
    lowStockThreshold: '5',
    minOrderQuantity: '1',
    maxOrderQuantity: '',
    status: 'draft',
    isActive: true,
    isFeatured: false,
    weight: '',
    dimensions: '',
    color: '',
};

export function ProductsPage() {
    const { t, i18n } = useTranslation();
    const queryClient = useQueryClient();
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState('');
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
    const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
    const [formData, setFormData] = useState<AddProductForm>(initialFormData);
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    // Fetch products
    const { data, isLoading, error } = useQuery({
        queryKey: ['products', searchQuery, statusFilter],
        queryFn: () => productsApi.getAll({ search: searchQuery, status: statusFilter, limit: 20 }),
    });

    // Fetch categories for dropdown
    const { data: categories = [] } = useQuery<CategoryTree[]>({
        queryKey: ['categories-tree'],
        queryFn: catalogApi.getCategoryTree,
        enabled: isAddDialogOpen,
    });

    // Fetch brands for dropdown
    const { data: brands = [] } = useQuery<Brand[]>({
        queryKey: ['brands'],
        queryFn: () => catalogApi.getBrands(),
        enabled: isAddDialogOpen,
    });

    // Fetch quality types for dropdown
    const { data: qualityTypes = [] } = useQuery<QualityType[]>({
        queryKey: ['quality-types'],
        queryFn: catalogApi.getQualityTypes,
        enabled: isAddDialogOpen,
    });

    // Create mutation
    const createMutation = useMutation({
        mutationFn: (data: CreateProductDto) => productsApi.create(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['products'] });
            setIsAddDialogOpen(false);
            setFormData(initialFormData);
        },
    });

    // Delete mutation
    const deleteMutation = useMutation({
        mutationFn: (id: string) => productsApi.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['products'] });
            setIsDeleteDialogOpen(false);
            setSelectedProduct(null);
        },
    });

    const handleDelete = (product: Product) => {
        setSelectedProduct(product);
        setIsDeleteDialogOpen(true);
    };

    const onDeleteConfirm = () => {
        if (selectedProduct) {
            deleteMutation.mutate(selectedProduct._id);
        }
    };

    const handleFormChange = (field: keyof AddProductForm, value: string | boolean) => {
        setFormData(prev => ({ ...prev, [field]: value }));
        // Auto-generate slug from name
        if (field === 'name' && typeof value === 'string') {
            const slug = value.toLowerCase().replace(/\s+/g, '-').replace(/[^\w-]/g, '');
            setFormData(prev => ({ ...prev, slug }));
        }
    };

    const handleOpenAddDialog = () => {
        setFormData(initialFormData);
        setIsAddDialogOpen(true);
    };

    const handleSubmit = () => {
        // Validate required fields
        if (!formData.sku || !formData.name || !formData.nameAr || !formData.brandId || !formData.categoryId || !formData.qualityTypeId || !formData.basePrice) {
            return;
        }

        const productData: CreateProductDto = {
            sku: formData.sku,
            name: formData.name,
            nameAr: formData.nameAr,
            slug: formData.slug || formData.name.toLowerCase().replace(/\s+/g, '-'),
            brandId: formData.brandId,
            categoryId: formData.categoryId,
            qualityTypeId: formData.qualityTypeId,
            basePrice: Number(formData.basePrice),
            // Optional fields
            ...(formData.description && { description: formData.description }),
            ...(formData.descriptionAr && { descriptionAr: formData.descriptionAr }),
            ...(formData.shortDescription && { shortDescription: formData.shortDescription }),
            ...(formData.shortDescriptionAr && { shortDescriptionAr: formData.shortDescriptionAr }),
            ...(formData.compareAtPrice && { compareAtPrice: Number(formData.compareAtPrice) }),
            ...(formData.costPrice && { costPrice: Number(formData.costPrice) }),
            stockQuantity: Number(formData.stockQuantity) || 0,
            lowStockThreshold: Number(formData.lowStockThreshold) || 5,
            minOrderQuantity: Number(formData.minOrderQuantity) || 1,
            ...(formData.maxOrderQuantity && { maxOrderQuantity: Number(formData.maxOrderQuantity) }),
            status: formData.status as CreateProductDto['status'],
            isActive: formData.isActive,
            isFeatured: formData.isFeatured,
            ...(formData.weight && { weight: Number(formData.weight) }),
            ...(formData.dimensions && { dimensions: formData.dimensions }),
            ...(formData.color && { color: formData.color }),
        };

        createMutation.mutate(productData);
    };

    const products = data?.items || [];

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t('products.title')}</h1>
                    <p className="text-gray-500 dark:text-gray-400 mt-1">إدارة المنتجات والمخزون</p>
                </div>
                <Button onClick={handleOpenAddDialog}>
                    <Plus className="h-4 w-4" />
                    {t('products.addProduct')}
                </Button>
            </div>

            {/* Search and Filters */}
            <Card>
                <CardContent className="p-4">
                    <div className="flex flex-col sm:flex-row gap-4">
                        <div className="relative flex-1">
                            <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                            <Input
                                placeholder="البحث عن منتج..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="ps-10"
                            />
                        </div>
                        <select
                            value={statusFilter}
                            onChange={(e) => setStatusFilter(e.target.value)}
                            className="h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm min-w-[150px]"
                        >
                            <option value="">جميع الحالات</option>
                            <option value="active">نشط</option>
                            <option value="draft">مسودة</option>
                            <option value="inactive">غير نشط</option>
                        </select>
                    </div>
                </CardContent>
            </Card>

            {/* Products Table */}
            <Card>
                <CardHeader className="flex flex-row items-center gap-2 pb-4">
                    <Package className="h-5 w-5 text-gray-500 dark:text-gray-400" />
                    <CardTitle className="text-lg">قائمة المنتجات</CardTitle>
                    {data && (
                        <Badge variant="secondary" className="ms-auto">
                            {data.pagination?.total || products.length} منتج
                        </Badge>
                    )}
                </CardHeader>
                <CardContent className="p-0">
                    {isLoading ? (
                        <div className="flex items-center justify-center py-12">
                            <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                        </div>
                    ) : error ? (
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500 dark:text-gray-400">
                            <AlertCircle className="h-12 w-12 mb-4 text-red-400" />
                            <p>حدث خطأ في تحميل البيانات</p>
                        </div>
                    ) : products.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500 dark:text-gray-400">
                            <Package className="h-12 w-12 mb-4 text-gray-300 dark:text-gray-600" />
                            <p>{t('common.noData')}</p>
                        </div>
                    ) : (
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>المنتج</TableHead>
                                    <TableHead>{t('products.sku')}</TableHead>
                                    <TableHead>{t('products.category')}</TableHead>
                                    <TableHead>{t('products.price')}</TableHead>
                                    <TableHead>{t('products.stock')}</TableHead>
                                    <TableHead>{t('products.status')}</TableHead>
                                    <TableHead className="w-[50px]"></TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {products.map((product) => (
                                    <TableRow key={product._id}>
                                        <TableCell>
                                            <div className="flex items-center gap-3">
                                                <div className="w-12 h-12 rounded-lg bg-gray-100 dark:bg-slate-800 overflow-hidden">
                                                    {product.images?.[0] ? (
                                                        <img
                                                            src={product.images[0]}
                                                            alt={product.name}
                                                            className="w-full h-full object-cover"
                                                        />
                                                    ) : (
                                                        <div className="w-full h-full flex items-center justify-center">
                                                            <Package className="h-6 w-6 text-gray-300" />
                                                        </div>
                                                    )}
                                                </div>
                                                <div>
                                                    <p className="font-medium text-gray-900 dark:text-gray-100">{product.name}</p>
                                                    {product.brand && (
                                                        <p className="text-xs text-gray-500 dark:text-gray-400">{product.brand.name}</p>
                                                    )}
                                                </div>
                                            </div>
                                        </TableCell>
                                        <TableCell className="text-gray-600 dark:text-gray-400 font-mono text-sm">
                                            {product.sku}
                                        </TableCell>
                                        <TableCell className="text-gray-600 dark:text-gray-400">
                                            {product.category?.name || '-'}
                                        </TableCell>
                                        <TableCell className="font-medium text-gray-900 dark:text-gray-100">
                                            {formatCurrency(product.price || 0, 'SAR', locale)}
                                        </TableCell>
                                        <TableCell>
                                            <span
                                                className={
                                                    product.stock > 10
                                                        ? 'text-green-600'
                                                        : product.stock > 0
                                                            ? 'text-yellow-600'
                                                            : 'text-red-600'
                                                }
                                            >
                                                {product.stock}
                                            </span>
                                        </TableCell>
                                        <TableCell>
                                            <Badge variant={statusVariants[product.status]}>
                                                {statusLabels[product.status]}
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
                                                        <Eye className="h-4 w-4" />
                                                        عرض
                                                    </DropdownMenuItem>
                                                    <DropdownMenuItem>
                                                        <Pencil className="h-4 w-4" />
                                                        تعديل
                                                    </DropdownMenuItem>
                                                    <DropdownMenuSeparator />
                                                    <DropdownMenuItem
                                                        className="text-red-600"
                                                        onClick={() => handleDelete(product)}
                                                    >
                                                        <Trash2 className="h-4 w-4" />
                                                        حذف
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

            {/* Add Product Dialog */}
            <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
                <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>إضافة منتج جديد</DialogTitle>
                        <DialogDescription>أدخل بيانات المنتج الجديد (الحقول المميزة بـ * إلزامية)</DialogDescription>
                    </DialogHeader>

                    <div className="space-y-6 py-4">
                        {/* Basic Info Section */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">المعلومات الأساسية</h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>رمز المنتج (SKU) <span className="text-red-500">*</span></Label>
                                    <Input
                                        dir="ltr"
                                        placeholder="SKU001"
                                        value={formData.sku}
                                        onChange={(e) => handleFormChange('sku', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الرابط (Slug) <span className="text-red-500">*</span></Label>
                                    <Input
                                        dir="ltr"
                                        placeholder="product-slug"
                                        value={formData.slug}
                                        onChange={(e) => handleFormChange('slug', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الاسم بالإنجليزية <span className="text-red-500">*</span></Label>
                                    <Input
                                        dir="ltr"
                                        placeholder="Product Name"
                                        value={formData.name}
                                        onChange={(e) => handleFormChange('name', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الاسم بالعربية <span className="text-red-500">*</span></Label>
                                    <Input
                                        placeholder="اسم المنتج"
                                        value={formData.nameAr}
                                        onChange={(e) => handleFormChange('nameAr', e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Classification Section */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">التصنيف</h3>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div className="space-y-2">
                                    <Label>التصنيف <span className="text-red-500">*</span></Label>
                                    <select
                                        value={formData.categoryId}
                                        onChange={(e) => handleFormChange('categoryId', e.target.value)}
                                        className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                                    >
                                        <option value="">اختر التصنيف...</option>
                                        {categories.map((cat) => (
                                            <option key={cat._id} value={cat._id}>
                                                {cat.nameAr || cat.name}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                                <div className="space-y-2">
                                    <Label>العلامة التجارية <span className="text-red-500">*</span></Label>
                                    <select
                                        value={formData.brandId}
                                        onChange={(e) => handleFormChange('brandId', e.target.value)}
                                        className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                                    >
                                        <option value="">اختر العلامة...</option>
                                        {brands.map((brand) => (
                                            <option key={brand._id} value={brand._id}>
                                                {brand.nameAr || brand.name}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                                <div className="space-y-2">
                                    <Label>نوع الجودة <span className="text-red-500">*</span></Label>
                                    <select
                                        value={formData.qualityTypeId}
                                        onChange={(e) => handleFormChange('qualityTypeId', e.target.value)}
                                        className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                                    >
                                        <option value="">اختر الجودة...</option>
                                        {qualityTypes.map((qt) => (
                                            <option key={qt._id} value={qt._id}>
                                                {qt.nameAr || qt.name}
                                            </option>
                                        ))}
                                    </select>
                                </div>
                            </div>
                        </div>

                        {/* Pricing Section */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">التسعير</h3>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div className="space-y-2">
                                    <Label>السعر الأساسي <span className="text-red-500">*</span></Label>
                                    <Input
                                        type="number"
                                        dir="ltr"
                                        placeholder="0.00"
                                        value={formData.basePrice}
                                        onChange={(e) => handleFormChange('basePrice', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>السعر قبل الخصم</Label>
                                    <Input
                                        type="number"
                                        dir="ltr"
                                        placeholder="0.00"
                                        value={formData.compareAtPrice}
                                        onChange={(e) => handleFormChange('compareAtPrice', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>سعر التكلفة</Label>
                                    <Input
                                        type="number"
                                        dir="ltr"
                                        placeholder="0.00"
                                        value={formData.costPrice}
                                        onChange={(e) => handleFormChange('costPrice', e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Inventory Section */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">المخزون</h3>
                            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                                <div className="space-y-2">
                                    <Label>الكمية</Label>
                                    <Input
                                        type="number"
                                        dir="ltr"
                                        placeholder="0"
                                        value={formData.stockQuantity}
                                        onChange={(e) => handleFormChange('stockQuantity', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>حد التنبيه</Label>
                                    <Input
                                        type="number"
                                        dir="ltr"
                                        placeholder="5"
                                        value={formData.lowStockThreshold}
                                        onChange={(e) => handleFormChange('lowStockThreshold', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الحد الأدنى للطلب</Label>
                                    <Input
                                        type="number"
                                        dir="ltr"
                                        placeholder="1"
                                        value={formData.minOrderQuantity}
                                        onChange={(e) => handleFormChange('minOrderQuantity', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الحد الأقصى للطلب</Label>
                                    <Input
                                        type="number"
                                        dir="ltr"
                                        placeholder="بدون حد"
                                        value={formData.maxOrderQuantity}
                                        onChange={(e) => handleFormChange('maxOrderQuantity', e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Description Section */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">الوصف</h3>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>الوصف المختصر (إنجليزي)</Label>
                                    <Input
                                        dir="ltr"
                                        placeholder="Short description"
                                        value={formData.shortDescription}
                                        onChange={(e) => handleFormChange('shortDescription', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الوصف المختصر (عربي)</Label>
                                    <Input
                                        placeholder="وصف مختصر"
                                        value={formData.shortDescriptionAr}
                                        onChange={(e) => handleFormChange('shortDescriptionAr', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الوصف الكامل (إنجليزي)</Label>
                                    <textarea
                                        dir="ltr"
                                        placeholder="Full description"
                                        value={formData.description}
                                        onChange={(e) => handleFormChange('description', e.target.value)}
                                        className="w-full min-h-[80px] rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 py-2 text-sm resize-none"
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الوصف الكامل (عربي)</Label>
                                    <textarea
                                        placeholder="الوصف الكامل"
                                        value={formData.descriptionAr}
                                        onChange={(e) => handleFormChange('descriptionAr', e.target.value)}
                                        className="w-full min-h-[80px] rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 py-2 text-sm resize-none"
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Physical Properties Section */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">الخصائص</h3>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div className="space-y-2">
                                    <Label>الوزن (جرام)</Label>
                                    <Input
                                        type="number"
                                        dir="ltr"
                                        placeholder="0"
                                        value={formData.weight}
                                        onChange={(e) => handleFormChange('weight', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>الأبعاد (L×W×H سم)</Label>
                                    <Input
                                        dir="ltr"
                                        placeholder="10x5x1"
                                        value={formData.dimensions}
                                        onChange={(e) => handleFormChange('dimensions', e.target.value)}
                                    />
                                </div>
                                <div className="space-y-2">
                                    <Label>اللون</Label>
                                    <Input
                                        placeholder="أسود"
                                        value={formData.color}
                                        onChange={(e) => handleFormChange('color', e.target.value)}
                                    />
                                </div>
                            </div>
                        </div>

                        {/* Status Section */}
                        <div className="space-y-4">
                            <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">الحالة</h3>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div className="space-y-2">
                                    <Label>حالة المنتج</Label>
                                    <select
                                        value={formData.status}
                                        onChange={(e) => handleFormChange('status', e.target.value)}
                                        className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                                    >
                                        <option value="draft">مسودة</option>
                                        <option value="active">نشط</option>
                                        <option value="inactive">غير نشط</option>
                                    </select>
                                </div>
                                <div className="flex items-center gap-2 pt-6">
                                    <input
                                        type="checkbox"
                                        id="isActive"
                                        checked={formData.isActive}
                                        onChange={(e) => handleFormChange('isActive', e.target.checked)}
                                        className="w-4 h-4 rounded border-gray-300"
                                    />
                                    <Label htmlFor="isActive">منتج نشط</Label>
                                </div>
                                <div className="flex items-center gap-2 pt-6">
                                    <input
                                        type="checkbox"
                                        id="isFeatured"
                                        checked={formData.isFeatured}
                                        onChange={(e) => handleFormChange('isFeatured', e.target.checked)}
                                        className="w-4 h-4 rounded border-gray-300"
                                    />
                                    <Label htmlFor="isFeatured">منتج مميز</Label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsAddDialogOpen(false)}>
                            إلغاء
                        </Button>
                        <Button
                            onClick={handleSubmit}
                            disabled={createMutation.isPending || !formData.sku || !formData.name || !formData.nameAr || !formData.brandId || !formData.categoryId || !formData.qualityTypeId || !formData.basePrice}
                        >
                            {createMutation.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
                            إضافة المنتج
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Delete Confirmation Dialog */}
            <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>تأكيد الحذف</DialogTitle>
                        <DialogDescription>
                            هل أنت متأكد من حذف المنتج "{selectedProduct?.name}"؟ هذا الإجراء لا يمكن التراجع عنه.
                        </DialogDescription>
                    </DialogHeader>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>
                            {t('common.cancel')}
                        </Button>
                        <Button
                            variant="destructive"
                            onClick={onDeleteConfirm}
                            disabled={deleteMutation.isPending}
                        >
                            {deleteMutation.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
                            {t('common.delete')}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
