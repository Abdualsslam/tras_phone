import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productsApi } from '@/api/products.api';
import type { Product } from '@/types';
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

export function ProductsPage() {
    const { t, i18n } = useTranslation();
    const queryClient = useQueryClient();
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState('');
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    // Fetch products
    const { data, isLoading, error } = useQuery({
        queryKey: ['products', searchQuery, statusFilter],
        queryFn: () => productsApi.getAll({ search: searchQuery, status: statusFilter, limit: 20 }),
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

    const products = data?.items || [];

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">{t('products.title')}</h1>
                    <p className="text-gray-500 mt-1">إدارة المنتجات والمخزون</p>
                </div>
                <Button>
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
                            className="h-10 rounded-lg border border-gray-300 px-3 text-sm min-w-[150px]"
                        >
                            <option value="">جميع الحالات</option>
                            <option value="published">منشور</option>
                            <option value="draft">مسودة</option>
                            <option value="archived">مؤرشف</option>
                        </select>
                    </div>
                </CardContent>
            </Card>

            {/* Products Table */}
            <Card>
                <CardHeader className="flex flex-row items-center gap-2 pb-4">
                    <Package className="h-5 w-5 text-gray-500" />
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
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500">
                            <AlertCircle className="h-12 w-12 mb-4 text-red-400" />
                            <p>حدث خطأ في تحميل البيانات</p>
                        </div>
                    ) : products.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500">
                            <Package className="h-12 w-12 mb-4 text-gray-300" />
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
                                                <div className="w-12 h-12 rounded-lg bg-gray-100 overflow-hidden">
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
                                                    <p className="font-medium text-gray-900">{product.name}</p>
                                                    {product.brand && (
                                                        <p className="text-xs text-gray-500">{product.brand.name}</p>
                                                    )}
                                                </div>
                                            </div>
                                        </TableCell>
                                        <TableCell className="text-gray-600 font-mono text-sm">
                                            {product.sku}
                                        </TableCell>
                                        <TableCell className="text-gray-600">
                                            {product.category?.name || '-'}
                                        </TableCell>
                                        <TableCell className="font-medium">
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
