import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { suppliersApi, type Supplier, type CreateSupplierDto } from '@/api/suppliers.api';
import { toast } from 'sonner';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogFooter,
} from '@/components/ui/dialog';
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
import { Switch } from '@/components/ui/switch';
import {
    Plus,
    Search,
    MoreHorizontal,
    Pencil,
    Trash2,
    Loader2,
    AlertCircle,
    Building2,
    Phone,
    Mail,
    DollarSign,
    ShoppingCart,
    CreditCard,
    Package,
} from 'lucide-react';
import { formatCurrency } from '@/lib/utils';

// ══════════════════════════════════════════════════════════════
// Schema & Types
// ══════════════════════════════════════════════════════════════

const supplierSchema = z.object({
    name: z.string().min(2, 'اسم المورد مطلوب'),
    nameAr: z.string().optional(),
    code: z.string().optional(),
    contactPerson: z.string().optional(),
    email: z.string().email('البريد الإلكتروني غير صحيح').optional().or(z.literal('')),
    phone: z.string().optional(),
    street: z.string().optional(),
    city: z.string().optional(),
    country: z.string().optional(),
    postalCode: z.string().optional(),
    taxNumber: z.string().optional(),
    paymentTerms: z.string().optional(),
    notes: z.string().optional(),
    isActive: z.boolean().optional(),
});

type SupplierFormData = z.infer<typeof supplierSchema>;

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function SuppliersPage() {
    const queryClient = useQueryClient();

    const [searchQuery, setSearchQuery] = useState('');
    const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
    const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
    const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
    const [isPaymentDialogOpen, setIsPaymentDialogOpen] = useState(false);
    const [selectedSupplier, setSelectedSupplier] = useState<Supplier | null>(null);

    // ─────────────────────────────────────────
    // Queries & Mutations
    // ─────────────────────────────────────────

    const { data: suppliers = [], isLoading, error } = useQuery({
        queryKey: ['suppliers', searchQuery],
        queryFn: () => suppliersApi.getAll({ search: searchQuery || undefined }),
    });

    const createMutation = useMutation({
        mutationFn: (data: CreateSupplierDto) => suppliersApi.create(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['suppliers'] });
            setIsCreateDialogOpen(false);
            toast.success('تم إضافة المورد بنجاح');
            createForm.reset();
        },
        onError: () => {
            toast.error('حدث خطأ أثناء إضافة المورد');
        },
    });

    const updateMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: Partial<CreateSupplierDto> }) =>
            suppliersApi.update(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['suppliers'] });
            setIsEditDialogOpen(false);
            setSelectedSupplier(null);
            toast.success('تم تحديث المورد بنجاح');
        },
        onError: () => {
            toast.error('حدث خطأ أثناء تحديث المورد');
        },
    });

    const deleteMutation = useMutation({
        mutationFn: (id: string) => suppliersApi.delete(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['suppliers'] });
            setIsDeleteDialogOpen(false);
            setSelectedSupplier(null);
            toast.success('تم حذف المورد بنجاح');
        },
        onError: () => {
            toast.error('حدث خطأ أثناء حذف المورد');
        },
    });

    const paymentMutation = useMutation({
        mutationFn: ({ supplierId, data }: {
            supplierId: string;
            data: { amount: number; paymentMethod: string; reference?: string; notes?: string }
        }) => suppliersApi.createPayment(supplierId, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['suppliers'] });
            setIsPaymentDialogOpen(false);
            setSelectedSupplier(null);
            toast.success('تم تسجيل الدفعة بنجاح');
            paymentForm.reset();
        },
        onError: () => {
            toast.error('حدث خطأ أثناء تسجيل الدفعة');
        },
    });

    // ─────────────────────────────────────────
    // Forms
    // ─────────────────────────────────────────

    const createForm = useForm<SupplierFormData>({
        resolver: zodResolver(supplierSchema),
        defaultValues: {
            isActive: true,
        },
    });

    const editForm = useForm<SupplierFormData>({
        resolver: zodResolver(supplierSchema),
    });

    const paymentForm = useForm({
        defaultValues: {
            amount: 0,
            paymentMethod: 'bank_transfer',
            reference: '',
            notes: '',
        },
    });

    // ─────────────────────────────────────────
    // Handlers
    // ─────────────────────────────────────────

    const handleEdit = (supplier: Supplier) => {
        setSelectedSupplier(supplier);
        editForm.reset({
            name: supplier.name,
            nameAr: supplier.nameAr || '',
            code: supplier.code,
            contactPerson: supplier.contactPerson || '',
            email: supplier.email || '',
            phone: supplier.phone || '',
            street: supplier.address?.street || '',
            city: supplier.address?.city || '',
            country: supplier.address?.country || '',
            postalCode: supplier.address?.postalCode || '',
            taxNumber: supplier.taxNumber || '',
            paymentTerms: supplier.paymentTerms || '',
            notes: supplier.notes || '',
            isActive: supplier.isActive,
        });
        setIsEditDialogOpen(true);
    };

    const handleDelete = (supplier: Supplier) => {
        setSelectedSupplier(supplier);
        setIsDeleteDialogOpen(true);
    };

    const handlePayment = (supplier: Supplier) => {
        setSelectedSupplier(supplier);
        paymentForm.reset({
            amount: 0,
            paymentMethod: 'bank_transfer',
            reference: '',
            notes: '',
        });
        setIsPaymentDialogOpen(true);
    };

    const transformFormData = (data: SupplierFormData): CreateSupplierDto => ({
        name: data.name,
        nameAr: data.nameAr || undefined,
        code: data.code || undefined,
        contactPerson: data.contactPerson || undefined,
        email: data.email || undefined,
        phone: data.phone || undefined,
        address: {
            street: data.street || undefined,
            city: data.city || undefined,
            country: data.country || undefined,
            postalCode: data.postalCode || undefined,
        },
        taxNumber: data.taxNumber || undefined,
        paymentTerms: data.paymentTerms || undefined,
        notes: data.notes || undefined,
        isActive: data.isActive,
    });

    const onCreateSubmit = (data: SupplierFormData) => {
        createMutation.mutate(transformFormData(data));
    };

    const onEditSubmit = (data: SupplierFormData) => {
        if (selectedSupplier) {
            updateMutation.mutate({ id: selectedSupplier._id, data: transformFormData(data) });
        }
    };

    const onDeleteConfirm = () => {
        if (selectedSupplier) {
            deleteMutation.mutate(selectedSupplier._id);
        }
    };

    const onPaymentSubmit = (data: { amount: number; paymentMethod: string; reference: string; notes: string }) => {
        if (selectedSupplier) {
            paymentMutation.mutate({
                supplierId: selectedSupplier._id,
                data: {
                    amount: data.amount,
                    paymentMethod: data.paymentMethod,
                    reference: data.reference || undefined,
                    notes: data.notes || undefined,
                },
            });
        }
    };

    // ─────────────────────────────────────────
    // Stats
    // ─────────────────────────────────────────

    const activeSuppliers = suppliers.filter(s => s.isActive).length;
    const totalBalance = suppliers.reduce((sum, s) => sum + (s.balance || 0), 0);
    const totalPurchases = suppliers.reduce((sum, s) => sum + (s.totalPurchases || 0), 0);

    // ─────────────────────────────────────────
    // Render
    // ─────────────────────────────────────────

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center h-[400px] text-muted-foreground">
                <AlertCircle className="h-12 w-12 mb-4 text-destructive" />
                <p>حدث خطأ أثناء تحميل الموردين</p>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 className="text-2xl font-bold">إدارة الموردين</h1>
                    <p className="text-muted-foreground text-sm">إدارة الموردين والمشتريات</p>
                </div>
                <Button onClick={() => setIsCreateDialogOpen(true)}>
                    <Plus className="h-4 w-4 ml-2" />
                    إضافة مورد
                </Button>
            </div>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                                <Building2 className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">إجمالي الموردين</p>
                                <p className="text-2xl font-bold">{suppliers.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                                <Package className="h-5 w-5 text-green-600 dark:text-green-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">موردين نشطين</p>
                                <p className="text-2xl font-bold">{activeSuppliers}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-red-100 dark:bg-red-900/30 rounded-lg">
                                <CreditCard className="h-5 w-5 text-red-600 dark:text-red-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">إجمالي المستحقات</p>
                                <p className="text-2xl font-bold">{formatCurrency(totalBalance)}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                                <ShoppingCart className="h-5 w-5 text-purple-600 dark:text-purple-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">إجمالي المشتريات</p>
                                <p className="text-2xl font-bold">{formatCurrency(totalPurchases)}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Search & Table */}
            <Card>
                <CardHeader>
                    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                        <CardTitle className="flex items-center gap-2">
                            <Building2 className="h-5 w-5" />
                            قائمة الموردين
                        </CardTitle>
                        <div className="relative w-full sm:w-80">
                            <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                            <Input
                                placeholder="بحث عن مورد..."
                                value={searchQuery}
                                onChange={(e) => setSearchQuery(e.target.value)}
                                className="pr-10"
                            />
                        </div>
                    </div>
                </CardHeader>
                <CardContent>
                    {isLoading ? (
                        <div className="flex justify-center items-center h-40">
                            <Loader2 className="h-8 w-8 animate-spin text-primary" />
                        </div>
                    ) : suppliers.length === 0 ? (
                        <div className="text-center py-12 text-muted-foreground">
                            <Building2 className="h-12 w-12 mx-auto mb-4 opacity-50" />
                            <p>لا يوجد موردين</p>
                        </div>
                    ) : (
                        <div className="overflow-x-auto">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>المورد</TableHead>
                                        <TableHead>الكود</TableHead>
                                        <TableHead>معلومات التواصل</TableHead>
                                        <TableHead>الرصيد</TableHead>
                                        <TableHead>إجمالي المشتريات</TableHead>
                                        <TableHead>الحالة</TableHead>
                                        <TableHead className="w-[50px]"></TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {suppliers.map((supplier) => (
                                        <TableRow key={supplier._id}>
                                            <TableCell>
                                                <div>
                                                    <p className="font-medium">{supplier.name}</p>
                                                    {supplier.nameAr && (
                                                        <p className="text-sm text-muted-foreground">{supplier.nameAr}</p>
                                                    )}
                                                    {supplier.contactPerson && (
                                                        <p className="text-xs text-muted-foreground">
                                                            المسؤول: {supplier.contactPerson}
                                                        </p>
                                                    )}
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                <Badge variant="outline">{supplier.code}</Badge>
                                            </TableCell>
                                            <TableCell>
                                                <div className="space-y-1">
                                                    {supplier.phone && (
                                                        <div className="flex items-center gap-1 text-sm">
                                                            <Phone className="h-3 w-3" />
                                                            {supplier.phone}
                                                        </div>
                                                    )}
                                                    {supplier.email && (
                                                        <div className="flex items-center gap-1 text-sm text-muted-foreground">
                                                            <Mail className="h-3 w-3" />
                                                            {supplier.email}
                                                        </div>
                                                    )}
                                                </div>
                                            </TableCell>
                                            <TableCell>
                                                <span className={supplier.balance > 0 ? 'text-red-600 font-medium' : ''}>
                                                    {formatCurrency(supplier.balance || 0)}
                                                </span>
                                            </TableCell>
                                            <TableCell>{formatCurrency(supplier.totalPurchases || 0)}</TableCell>
                                            <TableCell>
                                                <Badge variant={supplier.isActive ? 'success' : 'secondary'}>
                                                    {supplier.isActive ? 'نشط' : 'غير نشط'}
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
                                                        <DropdownMenuItem onClick={() => handleEdit(supplier)}>
                                                            <Pencil className="h-4 w-4 ml-2" />
                                                            تعديل
                                                        </DropdownMenuItem>
                                                        <DropdownMenuItem onClick={() => handlePayment(supplier)}>
                                                            <DollarSign className="h-4 w-4 ml-2" />
                                                            تسجيل دفعة
                                                        </DropdownMenuItem>
                                                        <DropdownMenuItem
                                                            onClick={() => handleDelete(supplier)}
                                                            className="text-red-600"
                                                        >
                                                            <Trash2 className="h-4 w-4 ml-2" />
                                                            حذف
                                                        </DropdownMenuItem>
                                                    </DropdownMenuContent>
                                                </DropdownMenu>
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        </div>
                    )}
                </CardContent>
            </Card>

            {/* Create Dialog */}
            <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
                <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>إضافة مورد جديد</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={createForm.handleSubmit(onCreateSubmit)} className="space-y-4">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>اسم المورد *</Label>
                                <Input {...createForm.register('name')} placeholder="اسم المورد" />
                                {createForm.formState.errors.name && (
                                    <p className="text-sm text-red-500">{createForm.formState.errors.name.message}</p>
                                )}
                            </div>
                            <div className="space-y-2">
                                <Label>الاسم بالعربية</Label>
                                <Input {...createForm.register('nameAr')} placeholder="الاسم بالعربية" />
                            </div>
                            <div className="space-y-2">
                                <Label>الكود</Label>
                                <Input {...createForm.register('code')} placeholder="SUP-001" />
                            </div>
                            <div className="space-y-2">
                                <Label>المسؤول</Label>
                                <Input {...createForm.register('contactPerson')} placeholder="اسم المسؤول" />
                            </div>
                            <div className="space-y-2">
                                <Label>البريد الإلكتروني</Label>
                                <Input {...createForm.register('email')} type="email" placeholder="email@example.com" />
                            </div>
                            <div className="space-y-2">
                                <Label>الهاتف</Label>
                                <Input {...createForm.register('phone')} placeholder="+966..." />
                            </div>
                        </div>

                        <div className="border-t pt-4">
                            <h4 className="font-medium mb-3">العنوان</h4>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>الشارع</Label>
                                    <Input {...createForm.register('street')} placeholder="الشارع" />
                                </div>
                                <div className="space-y-2">
                                    <Label>المدينة</Label>
                                    <Input {...createForm.register('city')} placeholder="المدينة" />
                                </div>
                                <div className="space-y-2">
                                    <Label>الدولة</Label>
                                    <Input {...createForm.register('country')} placeholder="الدولة" />
                                </div>
                                <div className="space-y-2">
                                    <Label>الرمز البريدي</Label>
                                    <Input {...createForm.register('postalCode')} placeholder="الرمز البريدي" />
                                </div>
                            </div>
                        </div>

                        <div className="border-t pt-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>الرقم الضريبي</Label>
                                    <Input {...createForm.register('taxNumber')} placeholder="الرقم الضريبي" />
                                </div>
                                <div className="space-y-2">
                                    <Label>شروط الدفع</Label>
                                    <Input {...createForm.register('paymentTerms')} placeholder="مثال: Net 30" />
                                </div>
                            </div>
                        </div>

                        <div className="space-y-2">
                            <Label>ملاحظات</Label>
                            <Textarea {...createForm.register('notes')} placeholder="ملاحظات إضافية..." />
                        </div>

                        <div className="flex items-center gap-2">
                            <Switch
                                id="isActive"
                                checked={createForm.watch('isActive')}
                                onCheckedChange={(checked: boolean) => createForm.setValue('isActive', checked)}
                            />
                            <Label htmlFor="isActive">مورد نشط</Label>
                        </div>

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={createMutation.isPending}>
                                {createMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                إضافة
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Edit Dialog */}
            <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
                <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>تعديل المورد</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={editForm.handleSubmit(onEditSubmit)} className="space-y-4">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>اسم المورد *</Label>
                                <Input {...editForm.register('name')} placeholder="اسم المورد" />
                            </div>
                            <div className="space-y-2">
                                <Label>الاسم بالعربية</Label>
                                <Input {...editForm.register('nameAr')} placeholder="الاسم بالعربية" />
                            </div>
                            <div className="space-y-2">
                                <Label>الكود</Label>
                                <Input {...editForm.register('code')} placeholder="SUP-001" />
                            </div>
                            <div className="space-y-2">
                                <Label>المسؤول</Label>
                                <Input {...editForm.register('contactPerson')} placeholder="اسم المسؤول" />
                            </div>
                            <div className="space-y-2">
                                <Label>البريد الإلكتروني</Label>
                                <Input {...editForm.register('email')} type="email" placeholder="email@example.com" />
                            </div>
                            <div className="space-y-2">
                                <Label>الهاتف</Label>
                                <Input {...editForm.register('phone')} placeholder="+966..." />
                            </div>
                        </div>

                        <div className="border-t pt-4">
                            <h4 className="font-medium mb-3">العنوان</h4>
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>الشارع</Label>
                                    <Input {...editForm.register('street')} placeholder="الشارع" />
                                </div>
                                <div className="space-y-2">
                                    <Label>المدينة</Label>
                                    <Input {...editForm.register('city')} placeholder="المدينة" />
                                </div>
                                <div className="space-y-2">
                                    <Label>الدولة</Label>
                                    <Input {...editForm.register('country')} placeholder="الدولة" />
                                </div>
                                <div className="space-y-2">
                                    <Label>الرمز البريدي</Label>
                                    <Input {...editForm.register('postalCode')} placeholder="الرمز البريدي" />
                                </div>
                            </div>
                        </div>

                        <div className="border-t pt-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div className="space-y-2">
                                    <Label>الرقم الضريبي</Label>
                                    <Input {...editForm.register('taxNumber')} placeholder="الرقم الضريبي" />
                                </div>
                                <div className="space-y-2">
                                    <Label>شروط الدفع</Label>
                                    <Input {...editForm.register('paymentTerms')} placeholder="مثال: Net 30" />
                                </div>
                            </div>
                        </div>

                        <div className="space-y-2">
                            <Label>ملاحظات</Label>
                            <Textarea {...editForm.register('notes')} placeholder="ملاحظات إضافية..." />
                        </div>

                        <div className="flex items-center gap-2">
                            <Switch
                                id="editIsActive"
                                checked={editForm.watch('isActive')}
                                onCheckedChange={(checked: boolean) => editForm.setValue('isActive', checked)}
                            />
                            <Label htmlFor="editIsActive">مورد نشط</Label>
                        </div>

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsEditDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={updateMutation.isPending}>
                                {updateMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                حفظ التغييرات
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Delete Confirmation Dialog */}
            <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>تأكيد الحذف</DialogTitle>
                    </DialogHeader>
                    <p className="text-muted-foreground">
                        هل أنت متأكد من حذف المورد "{selectedSupplier?.name}"؟ هذا الإجراء لا يمكن التراجع عنه.
                    </p>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsDeleteDialogOpen(false)}>
                            إلغاء
                        </Button>
                        <Button variant="destructive" onClick={onDeleteConfirm} disabled={deleteMutation.isPending}>
                            {deleteMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                            حذف
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Payment Dialog */}
            <Dialog open={isPaymentDialogOpen} onOpenChange={setIsPaymentDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>تسجيل دفعة للمورد</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={paymentForm.handleSubmit(onPaymentSubmit)} className="space-y-4">
                        <div className="p-3 bg-muted rounded-lg">
                            <p className="text-sm text-muted-foreground">المورد: <strong>{selectedSupplier?.name}</strong></p>
                            <p className="text-sm text-muted-foreground">
                                الرصيد الحالي: <strong className="text-red-600">{formatCurrency(selectedSupplier?.balance || 0)}</strong>
                            </p>
                        </div>

                        <div className="space-y-2">
                            <Label>المبلغ *</Label>
                            <Input
                                type="number"
                                step="0.01"
                                {...paymentForm.register('amount', { valueAsNumber: true })}
                                placeholder="0.00"
                            />
                        </div>

                        <div className="space-y-2">
                            <Label>طريقة الدفع</Label>
                            <select
                                className="w-full rounded-md border bg-background px-3 py-2"
                                {...paymentForm.register('paymentMethod')}
                            >
                                <option value="bank_transfer">تحويل بنكي</option>
                                <option value="cash">نقداً</option>
                                <option value="check">شيك</option>
                                <option value="other">أخرى</option>
                            </select>
                        </div>

                        <div className="space-y-2">
                            <Label>رقم المرجع</Label>
                            <Input {...paymentForm.register('reference')} placeholder="رقم الحوالة أو الشيك" />
                        </div>

                        <div className="space-y-2">
                            <Label>ملاحظات</Label>
                            <Textarea {...paymentForm.register('notes')} placeholder="ملاحظات إضافية..." />
                        </div>

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsPaymentDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={paymentMutation.isPending}>
                                {paymentMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                تسجيل الدفعة
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>
        </div>
    );
}

export default SuppliersPage;
