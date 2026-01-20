import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { productsApi, type PriceLevel, type CreatePriceLevelDto, type UpdatePriceLevelDto } from '@/api/products.api';
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
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
  MoreHorizontal,
  Pencil,
  Trash2,
  DollarSign,
  Loader2,
  AlertCircle,
} from 'lucide-react';
import { Switch } from '@/components/ui/switch';

interface PriceLevelForm {
  name: string;
  nameAr: string;
  code: string;
  description: string;
  discountPercentage: number;
  minOrderAmount: number;
  color: string;
  displayOrder: number;
  isActive: boolean;
  isDefault: boolean;
}

const initialFormData: PriceLevelForm = {
  name: '',
  nameAr: '',
  code: '',
  description: '',
  discountPercentage: 0,
  minOrderAmount: 0,
  color: '#3B82F6',
  displayOrder: 0,
  isActive: true,
  isDefault: false,
};

export function PriceLevelsPage() {
  const queryClient = useQueryClient();
  const [searchQuery, setSearchQuery] = useState('');
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [selectedPriceLevel, setSelectedPriceLevel] = useState<PriceLevel | null>(null);
  const [formData, setFormData] = useState<PriceLevelForm>(initialFormData);
  const [editingPriceLevel, setEditingPriceLevel] = useState<PriceLevel | null>(null);

  // Fetch price levels
  const { data: priceLevels = [], isLoading, error } = useQuery({
    queryKey: ['price-levels-all'],
    queryFn: productsApi.getAllPriceLevels,
  });

  // Create mutation
  const createMutation = useMutation({
    mutationFn: (data: CreatePriceLevelDto) => productsApi.createPriceLevel(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['price-levels-all'] });
      queryClient.invalidateQueries({ queryKey: ['price-levels'] });
      setIsDialogOpen(false);
      setFormData(initialFormData);
      setEditingPriceLevel(null);
    },
  });

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdatePriceLevelDto }) =>
      productsApi.updatePriceLevel(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['price-levels-all'] });
      queryClient.invalidateQueries({ queryKey: ['price-levels'] });
      setIsDialogOpen(false);
      setFormData(initialFormData);
      setEditingPriceLevel(null);
    },
  });

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: (id: string) => productsApi.deletePriceLevel(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['price-levels-all'] });
      queryClient.invalidateQueries({ queryKey: ['price-levels'] });
      setIsDeleteDialogOpen(false);
      setSelectedPriceLevel(null);
    },
  });

  const handleFormChange = (
    field: keyof PriceLevelForm,
    value: string | number | boolean
  ) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handleOpenCreate = () => {
    setEditingPriceLevel(null);
    setFormData(initialFormData);
    setIsDialogOpen(true);
  };

  const handleOpenEdit = (priceLevel: PriceLevel) => {
    setEditingPriceLevel(priceLevel);
    setFormData({
      name: priceLevel.name || '',
      nameAr: priceLevel.nameAr || '',
      code: priceLevel.code || '',
      description: priceLevel.description || '',
      discountPercentage: priceLevel.discountPercentage || 0,
      minOrderAmount: priceLevel.minOrderAmount || 0,
      color: priceLevel.color || '#3B82F6',
      displayOrder: priceLevel.displayOrder || 0,
      isActive: priceLevel.isActive ?? true,
      isDefault: priceLevel.isDefault ?? false,
    });
    setIsDialogOpen(true);
  };

  const handleDelete = (priceLevel: PriceLevel) => {
    setSelectedPriceLevel(priceLevel);
    setIsDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = () => {
    if (selectedPriceLevel) {
      deleteMutation.mutate(selectedPriceLevel._id);
    }
  };

  const handleSubmit = () => {
    if (!formData.name || !formData.nameAr || !formData.code) {
      return;
    }

    if (editingPriceLevel) {
      const updateData: UpdatePriceLevelDto = {
        name: formData.name,
        nameAr: formData.nameAr,
        code: formData.code,
        ...(formData.description && { description: formData.description }),
        discountPercentage: formData.discountPercentage,
        ...(formData.minOrderAmount > 0 && { minOrderAmount: formData.minOrderAmount }),
        ...(formData.color && { color: formData.color }),
        displayOrder: formData.displayOrder,
        isActive: formData.isActive,
        isDefault: formData.isDefault,
      };
      updateMutation.mutate({ id: editingPriceLevel._id, data: updateData });
    } else {
      const createData: CreatePriceLevelDto = {
        name: formData.name,
        nameAr: formData.nameAr,
        code: formData.code,
        ...(formData.description && { description: formData.description }),
        discountPercentage: formData.discountPercentage,
        ...(formData.minOrderAmount > 0 && { minOrderAmount: formData.minOrderAmount }),
        ...(formData.color && { color: formData.color }),
        displayOrder: formData.displayOrder,
        isActive: formData.isActive,
        isDefault: formData.isDefault,
      };
      createMutation.mutate(createData);
    }
  };

  const filteredPriceLevels = priceLevels.filter(
    (level) =>
      level.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      level.nameAr?.toLowerCase().includes(searchQuery.toLowerCase()) ||
      level.code.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
            مستويات التسعير
          </h1>
          <p className="text-gray-500 dark:text-gray-400 mt-1">
            إدارة مستويات التسعير للعملاء
          </p>
        </div>
        <Button onClick={handleOpenCreate}>
          <Plus className="h-4 w-4" />
          إضافة مستوى جديد
        </Button>
      </div>

      {/* Search */}
      <Card>
        <CardContent className="p-4">
          <div className="relative max-w-md">
            <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
            <Input
              placeholder="البحث عن مستوى..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="ps-10"
            />
          </div>
        </CardContent>
      </Card>

      {/* Price Levels Table */}
      <Card>
        <CardHeader className="flex flex-row items-center gap-2 pb-4">
          <DollarSign className="h-5 w-5 text-gray-500 dark:text-gray-400" />
          <CardTitle className="text-lg">قائمة مستويات التسعير</CardTitle>
          {priceLevels && (
            <Badge variant="secondary" className="ms-auto">
              {priceLevels.length} مستوى
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
          ) : filteredPriceLevels.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-500 dark:text-gray-400">
              <DollarSign className="h-12 w-12 mb-4 text-gray-300 dark:text-gray-600" />
              <p>لا توجد مستويات تسعير</p>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>الاسم</TableHead>
                  <TableHead>الكود</TableHead>
                  <TableHead>نسبة الخصم</TableHead>
                  <TableHead>الحد الأدنى للطلب</TableHead>
                  <TableHead>ترتيب العرض</TableHead>
                  <TableHead>الحالة</TableHead>
                  <TableHead>افتراضي</TableHead>
                  <TableHead className="w-[50px]"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredPriceLevels.map((level) => (
                  <TableRow key={level._id}>
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-gray-100">
                          {level.nameAr || level.name}
                        </p>
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          {level.name}
                        </p>
                      </div>
                    </TableCell>
                    <TableCell className="font-mono text-sm text-gray-600 dark:text-gray-400">
                      {level.code}
                    </TableCell>
                    <TableCell>
                      {level.discountPercentage ? (
                        <Badge variant="secondary">
                          {level.discountPercentage}%
                        </Badge>
                      ) : (
                        <span className="text-gray-400">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      {level.minOrderAmount ? (
                        <span className="text-gray-600 dark:text-gray-400">
                          {level.minOrderAmount.toLocaleString()} ر.س
                        </span>
                      ) : (
                        <span className="text-gray-400">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <span className="text-gray-600 dark:text-gray-400">
                        {level.displayOrder || 0}
                      </span>
                    </TableCell>
                    <TableCell>
                      <Badge variant={level.isActive ? 'success' : 'default'}>
                        {level.isActive ? 'نشط' : 'غير نشط'}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {level.isDefault ? (
                        <Badge variant="success">افتراضي</Badge>
                      ) : (
                        <span className="text-gray-400">-</span>
                      )}
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem onClick={() => handleOpenEdit(level)}>
                            <Pencil className="h-4 w-4" />
                            تعديل
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            className="text-red-600"
                            onClick={() => handleDelete(level)}
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

      {/* Add/Edit Dialog */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {editingPriceLevel ? 'تعديل مستوى التسعير' : 'إضافة مستوى تسعير جديد'}
            </DialogTitle>
            <DialogDescription>
              {editingPriceLevel
                ? 'قم بتعديل بيانات مستوى التسعير'
                : 'أدخل بيانات مستوى التسعير الجديد'}
              {' '}(الحقول المميزة بـ * إلزامية)
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>
                  الاسم بالإنجليزية <span className="text-red-500">*</span>
                </Label>
                <Input
                  dir="ltr"
                  placeholder="Retail"
                  value={formData.name}
                  onChange={(e) => handleFormChange('name', e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label>
                  الاسم بالعربية <span className="text-red-500">*</span>
                </Label>
                <Input
                  placeholder="تجزئة"
                  value={formData.nameAr}
                  onChange={(e) => handleFormChange('nameAr', e.target.value)}
                />
              </div>
              <div className="space-y-2">
                <Label>
                  الكود <span className="text-red-500">*</span>
                </Label>
                <Input
                  dir="ltr"
                  placeholder="retail"
                  value={formData.code}
                  onChange={(e) => handleFormChange('code', e.target.value)}
                />
                <p className="text-xs text-gray-500">
                  يجب أن يكون الكود فريداً (مثل: retail, wholesale, vip)
                </p>
              </div>
              <div className="space-y-2">
                <Label>اللون</Label>
                <div className="flex items-center gap-2">
                  <Input
                    type="color"
                    value={formData.color}
                    onChange={(e) => handleFormChange('color', e.target.value)}
                    className="w-20 h-10"
                  />
                  <Input
                    dir="ltr"
                    placeholder="#3B82F6"
                    value={formData.color}
                    onChange={(e) => handleFormChange('color', e.target.value)}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <Label>نسبة الخصم (%)</Label>
                <Input
                  type="number"
                  dir="ltr"
                  placeholder="0"
                  min="0"
                  max="100"
                  value={formData.discountPercentage}
                  onChange={(e) =>
                    handleFormChange('discountPercentage', Number(e.target.value))
                  }
                />
              </div>
              <div className="space-y-2">
                <Label>الحد الأدنى للطلب (ر.س)</Label>
                <Input
                  type="number"
                  dir="ltr"
                  placeholder="0"
                  min="0"
                  value={formData.minOrderAmount}
                  onChange={(e) =>
                    handleFormChange('minOrderAmount', Number(e.target.value))
                  }
                />
              </div>
              <div className="space-y-2">
                <Label>ترتيب العرض</Label>
                <Input
                  type="number"
                  dir="ltr"
                  placeholder="0"
                  min="0"
                  value={formData.displayOrder}
                  onChange={(e) =>
                    handleFormChange('displayOrder', Number(e.target.value))
                  }
                />
              </div>
              <div className="space-y-2 md:col-span-2">
                <Label>الوصف</Label>
                <Input
                  placeholder="وصف مستوى التسعير..."
                  value={formData.description}
                  onChange={(e) => handleFormChange('description', e.target.value)}
                />
              </div>
            </div>

            <div className="flex items-center gap-6 pt-4 border-t">
              <div className="flex items-center gap-2">
                <Switch
                  checked={formData.isActive}
                  onCheckedChange={(checked) => handleFormChange('isActive', checked)}
                />
                <Label>نشط</Label>
              </div>
              <div className="flex items-center gap-2">
                <Switch
                  checked={formData.isDefault}
                  onCheckedChange={(checked) => handleFormChange('isDefault', checked)}
                />
                <Label>افتراضي للعملاء الجدد</Label>
              </div>
            </div>
          </div>

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setIsDialogOpen(false);
                setFormData(initialFormData);
                setEditingPriceLevel(null);
              }}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleSubmit}
              disabled={createMutation.isPending || updateMutation.isPending}
            >
              {(createMutation.isPending || updateMutation.isPending) && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              {editingPriceLevel ? 'تحديث' : 'إضافة'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>حذف مستوى التسعير</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من حذف مستوى التسعير "{selectedPriceLevel?.nameAr || selectedPriceLevel?.name}"؟
              <br />
              لا يمكن حذف مستوى مستخدم في عملاء أو منتجات.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setIsDeleteDialogOpen(false);
                setSelectedPriceLevel(null);
              }}
            >
              إلغاء
            </Button>
            <Button
              variant="destructive"
              onClick={handleDeleteConfirm}
              disabled={deleteMutation.isPending}
            >
              {deleteMutation.isPending && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              حذف
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
