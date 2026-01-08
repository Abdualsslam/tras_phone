import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from '@tanstack/react-query';
import { catalogApi, type CategoryTree } from '@/api/catalog.api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
    Plus,
    Search,
    FolderTree,
    MoreHorizontal,
    Pencil,
    Trash2,
    ChevronDown,
    ChevronRight,
    Loader2,
    AlertCircle,
} from 'lucide-react';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { cn } from '@/lib/utils';

function CategoryRow({ category, level = 0 }: { category: CategoryTree; level?: number }) {
    const [isExpanded, setIsExpanded] = useState(false);
    const hasChildren = category.children && category.children.length > 0;

    return (
        <>
            <div
                className={cn(
                    'flex items-center gap-3 px-4 py-3 border-b border-gray-100 hover:bg-gray-50 transition-colors',
                    level > 0 && 'bg-gray-50/50'
                )}
                style={{ paddingInlineStart: `${level * 32 + 16}px` }}
            >
                {hasChildren ? (
                    <button
                        onClick={() => setIsExpanded(!isExpanded)}
                        className="w-6 h-6 flex items-center justify-center rounded hover:bg-gray-200"
                    >
                        {isExpanded ? (
                            <ChevronDown className="h-4 w-4 text-gray-500" />
                        ) : (
                            <ChevronRight className="h-4 w-4 text-gray-500" />
                        )}
                    </button>
                ) : (
                    <div className="w-6" />
                )}

                <div className="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center overflow-hidden">
                    {category.image ? (
                        <img src={category.image} alt={category.name} className="w-full h-full object-cover" />
                    ) : (
                        <FolderTree className="h-5 w-5 text-gray-400" />
                    )}
                </div>

                <div className="flex-1">
                    <p className="font-medium text-gray-900">{category.nameAr || category.name}</p>
                    <p className="text-xs text-gray-500">{category.name}</p>
                </div>

                <Badge variant="secondary">{category.productsCount || 0} منتج</Badge>

                <Badge variant={category.isActive ? 'success' : 'default'}>
                    {category.isActive ? 'نشط' : 'غير نشط'}
                </Badge>

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
                        <DropdownMenuItem>
                            <Plus className="h-4 w-4" />
                            إضافة فرعي
                        </DropdownMenuItem>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem className="text-red-600">
                            <Trash2 className="h-4 w-4" />
                            حذف
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
            </div>

            {isExpanded && category.children?.map((child) => (
                <CategoryRow key={child._id} category={child} level={level + 1} />
            ))}
        </>
    );
}

export function CategoriesPage() {
    const { t } = useTranslation();
    const [searchQuery, setSearchQuery] = useState('');

    // Fetch category tree from backend
    const { data: categories, isLoading, error } = useQuery({
        queryKey: ['categories-tree'],
        queryFn: catalogApi.getCategoryTree,
    });

    const filteredCategories = (categories || []).filter(
        (cat) =>
            cat.nameAr?.includes(searchQuery) ||
            cat.name.toLowerCase().includes(searchQuery.toLowerCase())
    );

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">{t('sidebar.categories')}</h1>
                    <p className="text-gray-500 mt-1">إدارة تصنيفات المنتجات</p>
                </div>
                <Button>
                    <Plus className="h-4 w-4" />
                    إضافة تصنيف
                </Button>
            </div>

            {/* Search */}
            <Card>
                <CardContent className="p-4">
                    <div className="relative max-w-md">
                        <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                        <Input
                            placeholder="البحث عن تصنيف..."
                            value={searchQuery}
                            onChange={(e) => setSearchQuery(e.target.value)}
                            className="ps-10"
                        />
                    </div>
                </CardContent>
            </Card>

            {/* Categories Tree */}
            <Card>
                <CardHeader className="flex flex-row items-center gap-2 pb-4">
                    <FolderTree className="h-5 w-5 text-gray-500" />
                    <CardTitle className="text-lg">شجرة التصنيفات</CardTitle>
                    {categories && (
                        <Badge variant="secondary" className="ms-auto">
                            {categories.length} تصنيف رئيسي
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
                    ) : filteredCategories.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500">
                            <FolderTree className="h-12 w-12 mb-4 text-gray-300" />
                            <p>{t('common.noData')}</p>
                        </div>
                    ) : (
                        filteredCategories.map((category) => (
                            <CategoryRow key={category._id} category={category} />
                        ))
                    )}
                </CardContent>
            </Card>
        </div>
    );
}
