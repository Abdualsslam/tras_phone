import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { catalogApi, type CategoryTree } from '@/api/catalog.api';
import { uploadsApi, isValidFileSize, isValidImageType } from '@/api/uploads.api';
import { getErrorMessage } from '@/api/client';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
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
    FolderTree,
    MoreHorizontal,
    Pencil,
    Trash2,
    ChevronDown,
    ChevronRight,
    Loader2,
    AlertCircle,
    Upload,
    X,
} from 'lucide-react';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { cn } from '@/lib/utils';
import { toast } from 'sonner';

interface AddCategoryForm {
    name: string;
    nameAr: string;
    slug: string;
    parentId: string;
    image: string;
    isActive: boolean;
}

const initialFormData: AddCategoryForm = {
    name: '',
    nameAr: '',
    slug: '',
    parentId: '',
    image: '',
    isActive: true,
};

type CategoryOption = {
    _id: string;
    name: string;
    nameAr?: string;
    level: number;
};

function collectCategoryOptions(categories: CategoryTree[], level = 0): CategoryOption[] {
    const options: CategoryOption[] = [];

    for (const category of categories) {
        options.push({
            _id: category._id,
            name: category.name,
            nameAr: category.nameAr,
            level,
        });

        if (category.children?.length) {
            options.push(...collectCategoryOptions(category.children, level + 1));
        }
    }

    return options;
}

function collectDescendantIds(category: CategoryTree): Set<string> {
    const ids = new Set<string>();

    const walk = (node: CategoryTree) => {
        for (const child of node.children || []) {
            ids.add(child._id);
            walk(child);
        }
    };

    walk(category);
    return ids;
}

type CategoryRowProps = {
    category: CategoryTree;
    level?: number;
    onEdit: (category: CategoryTree) => void;
    onAddChild: (category: CategoryTree) => void;
    onDelete: (category: CategoryTree) => void;
};

function CategoryRow({ category, level = 0, onEdit, onAddChild, onDelete }: CategoryRowProps) {
    const [isExpanded, setIsExpanded] = useState(false);
    const hasChildren = category.children && category.children.length > 0;
    const previewImage = category.image || category.imageUrl || category.icon;

    return (
        <>
            <div
                className={cn(
                    'flex items-center gap-3 px-4 py-3 border-b border-gray-100 dark:border-slate-700 hover:bg-gray-50 dark:hover:bg-slate-800 transition-colors',
                    level > 0 && 'bg-gray-50/50 dark:bg-slate-800/50'
                )}
                style={{ paddingInlineStart: `${level * 32 + 16}px` }}
            >
                {hasChildren ? (
                    <button
                        onClick={() => setIsExpanded(!isExpanded)}
                        className="w-6 h-6 flex items-center justify-center rounded hover:bg-gray-200 dark:hover:bg-slate-700"
                    >
                        {isExpanded ? (
                            <ChevronDown className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                        ) : (
                            <ChevronRight className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                        )}
                    </button>
                ) : (
                    <div className="w-6" />
                )}

                <div className="w-10 h-10 bg-gray-100 dark:bg-slate-800 rounded-lg flex items-center justify-center overflow-hidden">
                    {previewImage ? (
                        <img src={previewImage} alt={category.name} className="w-full h-full object-cover" />
                    ) : (
                        <FolderTree className="h-5 w-5 text-gray-400" />
                    )}
                </div>

                <div className="flex-1">
                    <p className="font-medium text-gray-900 dark:text-gray-100">{category.nameAr || category.name}</p>
                    <p className="text-xs text-gray-500 dark:text-gray-400">{category.name}</p>
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
                        <DropdownMenuItem onClick={() => onEdit(category)}>
                            <Pencil className="h-4 w-4" />
                            تعديل
                        </DropdownMenuItem>
                        <DropdownMenuItem onClick={() => onAddChild(category)}>
                            <Plus className="h-4 w-4" />
                            إضافة فرعي
                        </DropdownMenuItem>
                        <DropdownMenuSeparator />
                        <DropdownMenuItem className="text-red-600" onClick={() => onDelete(category)}>
                            <Trash2 className="h-4 w-4" />
                            حذف
                        </DropdownMenuItem>
                    </DropdownMenuContent>
                </DropdownMenu>
            </div>

            {isExpanded && category.children?.map((child) => (
                <CategoryRow
                    key={child._id}
                    category={child}
                    level={level + 1}
                    onEdit={onEdit}
                    onAddChild={onAddChild}
                    onDelete={onDelete}
                />
            ))}
        </>
    );
}

export function CategoriesPage() {
    const { t } = useTranslation();
    const queryClient = useQueryClient();
    const [searchQuery, setSearchQuery] = useState('');
    const [isDialogOpen, setIsDialogOpen] = useState(false);
    const [editingCategory, setEditingCategory] = useState<CategoryTree | null>(null);
    const [formData, setFormData] = useState<AddCategoryForm>(initialFormData);
    const [isUploadingImage, setIsUploadingImage] = useState(false);
    const [uploadError, setUploadError] = useState<string | null>(null);

    // Fetch category tree from backend
    const { data: categories, isLoading, error } = useQuery({
        queryKey: ['categories-tree'],
        queryFn: catalogApi.getCategoryTree,
    });

    // Create mutation
    const createMutation = useMutation({
        mutationFn: (data: AddCategoryForm) => catalogApi.createCategory({
            name: data.name,
            nameAr: data.nameAr,
            slug: data.slug || data.name.toLowerCase().replace(/\s+/g, '-'),
            parentId: data.parentId || undefined,
            image: data.image || undefined,
            isActive: data.isActive,
        }),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['categories-tree'] });
            setIsDialogOpen(false);
            setEditingCategory(null);
            setFormData(initialFormData);
            toast.success('تم إضافة التصنيف بنجاح');
        },
        onError: (error) => toast.error(getErrorMessage(error, 'حدث خطأ أثناء إضافة التصنيف')),
    });

    const updateMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: AddCategoryForm }) =>
            catalogApi.updateCategory(id, {
                name: data.name,
                nameAr: data.nameAr,
                slug: data.slug || data.name.toLowerCase().replace(/\s+/g, '-'),
                parentId: data.parentId || undefined,
                image: data.image,
                isActive: data.isActive,
            }),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['categories-tree'] });
            setIsDialogOpen(false);
            setEditingCategory(null);
            setFormData(initialFormData);
            toast.success('تم تحديث التصنيف بنجاح');
        },
        onError: (error) => toast.error(getErrorMessage(error, 'حدث خطأ أثناء تحديث التصنيف')),
    });

    const deleteMutation = useMutation({
        mutationFn: catalogApi.deleteCategory,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['categories-tree'] });
            toast.success('تم حذف التصنيف بنجاح');
        },
        onError: (error) => toast.error(getErrorMessage(error, 'حدث خطأ أثناء حذف التصنيف')),
    });

    const handleFormChange = (field: keyof AddCategoryForm, value: string | boolean) => {
        setFormData(prev => ({ ...prev, [field]: value }));
    };

    const handleSubmit = () => {
        if (!formData.name) {
            return;
        }

        if (editingCategory) {
            updateMutation.mutate({ id: editingCategory._id, data: formData });
            return;
        }

        createMutation.mutate(formData);
    };

    const handleCloseDialog = () => {
        setIsDialogOpen(false);
        setEditingCategory(null);
        setFormData(initialFormData);
        setUploadError(null);
    };

    const handleOpenAddDialog = () => {
        setEditingCategory(null);
        setFormData(initialFormData);
        setUploadError(null);
        setIsDialogOpen(true);
    };

    const handleOpenAddChildDialog = (parent: CategoryTree) => {
        setEditingCategory(null);
        setFormData({
            ...initialFormData,
            parentId: parent._id,
        });
        setUploadError(null);
        setIsDialogOpen(true);
    };

    const handleOpenEditDialog = (category: CategoryTree) => {
        setEditingCategory(category);
        setFormData({
            name: category.name || '',
            nameAr: category.nameAr || '',
            slug: category.slug || '',
            parentId: category.parentId || '',
            image: category.image || category.imageUrl || category.icon || '',
            isActive: category.isActive,
        });
        setUploadError(null);
        setIsDialogOpen(true);
    };

    const handleDeleteCategory = (category: CategoryTree) => {
        const confirmed = window.confirm(`هل أنت متأكد من حذف التصنيف "${category.nameAr || category.name}"؟`);
        if (!confirmed) {
            return;
        }

        deleteMutation.mutate(category._id);
    };

    const filteredCategories = (categories || []).filter(
        (cat) =>
            cat.nameAr?.includes(searchQuery) ||
            cat.name.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const categoryOptions = collectCategoryOptions(categories || []);
    const blockedParentIds = editingCategory ? collectDescendantIds(editingCategory) : new Set<string>();
    if (editingCategory) {
        blockedParentIds.add(editingCategory._id);
    }

    const isSaving = createMutation.isPending || updateMutation.isPending;

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t('sidebar.categories')}</h1>
                    <p className="text-gray-500 dark:text-gray-400 mt-1">إدارة تصنيفات المنتجات</p>
                </div>
                <Button onClick={handleOpenAddDialog}>
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
                    <FolderTree className="h-5 w-5 text-gray-500 dark:text-gray-400" />
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
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500 dark:text-gray-400">
                            <AlertCircle className="h-12 w-12 mb-4 text-red-400" />
                            <p>حدث خطأ في تحميل البيانات</p>
                        </div>
                    ) : filteredCategories.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500 dark:text-gray-400">
                            <FolderTree className="h-12 w-12 mb-4 text-gray-300 dark:text-gray-600" />
                            <p>{t('common.noData')}</p>
                        </div>
                    ) : (
                        filteredCategories.map((category) => (
                            <CategoryRow
                                key={category._id}
                                category={category}
                                onEdit={handleOpenEditDialog}
                                onAddChild={handleOpenAddChildDialog}
                                onDelete={handleDeleteCategory}
                            />
                        ))
                    )}
                </CardContent>
            </Card>

            {/* Category Dialog */}
            <Dialog open={isDialogOpen} onOpenChange={(open) => (open ? setIsDialogOpen(true) : handleCloseDialog())}>
                <DialogContent className="max-w-md">
                    <DialogHeader>
                        <DialogTitle>{editingCategory ? 'تعديل التصنيف' : 'إضافة تصنيف جديد'}</DialogTitle>
                        <DialogDescription>
                            {editingCategory ? 'قم بتعديل بيانات التصنيف' : 'أدخل بيانات التصنيف الجديد'}
                        </DialogDescription>
                    </DialogHeader>

                    <div className="space-y-4 py-4">
                        <div className="space-y-2">
                            <Label>الاسم بالإنجليزية <span className="text-red-500">*</span></Label>
                            <Input
                                placeholder="Category Name"
                                value={formData.name}
                                onChange={(e) => handleFormChange('name', e.target.value)}
                            />
                        </div>

                        <div className="space-y-2">
                            <Label>صورة التصنيف</Label>
                            {formData.image ? (
                                <div className="relative w-32 h-32 rounded-lg border-2 border-gray-300 dark:border-slate-600 overflow-hidden bg-gray-50 dark:bg-slate-800">
                                    <img
                                        src={formData.image}
                                        alt="Category"
                                        className="w-full h-full object-contain"
                                    />
                                    <button
                                        type="button"
                                        onClick={() => setFormData((prev) => ({ ...prev, image: '' }))}
                                        className="absolute top-1 end-1 p-1 bg-red-500 text-white rounded-full hover:bg-red-600 transition-colors"
                                    >
                                        <X className="h-3 w-3" />
                                    </button>
                                </div>
                            ) : (
                                <label className="flex flex-col items-center justify-center w-32 h-32 rounded-lg border-2 border-dashed border-gray-300 dark:border-slate-600 hover:border-primary-500 dark:hover:border-primary-500 cursor-pointer transition-colors bg-gray-50 dark:bg-slate-800">
                                    <input
                                        type="file"
                                        accept="image/*"
                                        className="hidden"
                                        disabled={isUploadingImage}
                                        onChange={async (e) => {
                                            const file = e.target.files?.[0];
                                            if (!file) return;

                                            if (!isValidImageType(file)) {
                                                setUploadError('نوع الملف غير مدعوم. الأنواع المسموحة: JPEG, PNG, GIF, WebP');
                                                return;
                                            }
                                            if (!isValidFileSize(file)) {
                                                setUploadError('حجم الملف كبير جداً. الحد الأقصى 10MB');
                                                return;
                                            }

                                            setUploadError(null);
                                            setIsUploadingImage(true);
                                            try {
                                                const result = await uploadsApi.uploadSingle(file, 'categories');
                                                setFormData((prev) => ({ ...prev, image: result.url }));
                                            } catch (error) {
                                                setUploadError(getErrorMessage(error, 'فشل رفع الصورة'));
                                            } finally {
                                                setIsUploadingImage(false);
                                            }
                                        }}
                                    />
                                    {isUploadingImage ? (
                                        <Loader2 className="h-6 w-6 animate-spin text-primary-500" />
                                    ) : (
                                        <>
                                            <Upload className="h-6 w-6 text-gray-400 mb-2" />
                                            <span className="text-xs text-gray-500 dark:text-gray-400 text-center px-2">
                                                اضغط لرفع الصورة
                                            </span>
                                        </>
                                    )}
                                </label>
                            )}
                            {uploadError && (
                                <p className="text-xs text-red-500 mt-1">{uploadError}</p>
                            )}
                        </div>

                        <div className="space-y-2">
                            <Label>الاسم بالعربية</Label>
                            <Input
                                placeholder="اسم التصنيف"
                                value={formData.nameAr}
                                onChange={(e) => handleFormChange('nameAr', e.target.value)}
                            />
                        </div>

                        <div className="space-y-2">
                            <Label>الرابط (Slug)</Label>
                            <Input
                                dir="ltr"
                                placeholder="category-slug"
                                value={formData.slug}
                                onChange={(e) => handleFormChange('slug', e.target.value)}
                            />
                            <p className="text-xs text-gray-500 dark:text-gray-400">سيتم توليده تلقائياً إذا تُرك فارغاً</p>
                        </div>

                        <div className="space-y-2">
                            <Label>التصنيف الأب</Label>
                            <select
                                value={formData.parentId}
                                onChange={(e) => handleFormChange('parentId', e.target.value)}
                                className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                            >
                                <option value="">بدون (تصنيف رئيسي)</option>
                                {categoryOptions.map((cat) => (
                                    <option
                                        key={cat._id}
                                        value={cat._id}
                                        disabled={blockedParentIds.has(cat._id)}
                                    >
                                        {`${'— '.repeat(cat.level)}${cat.nameAr || cat.name}`}
                                    </option>
                                ))}
                            </select>
                        </div>

                        <div className="flex items-center gap-2">
                            <input
                                type="checkbox"
                                id="isActive"
                                checked={formData.isActive}
                                onChange={(e) => handleFormChange('isActive', e.target.checked)}
                                className="w-4 h-4 rounded border-gray-300"
                            />
                            <Label htmlFor="isActive">تصنيف نشط</Label>
                        </div>
                    </div>

                    <DialogFooter>
                        <Button variant="outline" onClick={handleCloseDialog}>
                            إلغاء
                        </Button>
                        <Button onClick={handleSubmit} disabled={isSaving || isUploadingImage || !formData.name}>
                            {isSaving && <Loader2 className="h-4 w-4 animate-spin" />}
                            {editingCategory ? 'حفظ التعديلات' : 'إضافة التصنيف'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}

