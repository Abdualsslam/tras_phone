import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm, useFieldArray } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { purchaseOrdersApi, suppliersApi, type PurchaseOrder } from '@/api/suppliers.api';
import { productsApi } from '@/api/products.api';
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
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import {
    Plus,
    MoreHorizontal,
    Eye,
    Loader2,
    AlertCircle,
    FileText,
    Trash2,
    CheckCircle,
    XCircle,
    Truck,
    Package,
    Clock,
} from 'lucide-react';
import { formatCurrency, formatDate } from '@/lib/utils';

// ══════════════════════════════════════════════════════════════
// Schema & Types
// ══════════════════════════════════════════════════════════════

const purchaseOrderSchema = z.object({
    supplierId: z.string().min(1, 'اختر المورد'),
    notes: z.string().optional(),
    expectedDeliveryDate: z.string().optional(),
    taxAmount: z.number().min(0).optional(),
    shippingCost: z.number().min(0).optional(),
    items: z.array(z.object({
        productId: z.string().min(1, 'اختر المنتج'),
        quantity: z.number().min(1, 'الكمية مطلوبة'),
        unitPrice: z.number().min(0, 'السعر مطلوب'),
    })).min(1, 'أضف منتج واحد على الأقل'),
});

type PurchaseOrderFormData = z.infer<typeof purchaseOrderSchema>;

const statusConfig: Record<string, { label: string; variant: 'default' | 'secondary' | 'success' | 'warning' | 'danger'; icon: React.ReactNode }> = {
    draft: { label: 'مسودة', variant: 'secondary', icon: <FileText className="h-3 w-3" /> },
    pending: { label: 'قيد الانتظار', variant: 'warning', icon: <Clock className="h-3 w-3" /> },
    approved: { label: 'موافق عليه', variant: 'default', icon: <CheckCircle className="h-3 w-3" /> },
    ordered: { label: 'تم الطلب', variant: 'default', icon: <Package className="h-3 w-3" /> },
    partial: { label: 'استلام جزئي', variant: 'warning', icon: <Truck className="h-3 w-3" /> },
    received: { label: 'تم الاستلام', variant: 'success', icon: <CheckCircle className="h-3 w-3" /> },
    cancelled: { label: 'ملغي', variant: 'danger', icon: <XCircle className="h-3 w-3" /> },
};

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function PurchaseOrdersPage() {
    const queryClient = useQueryClient();

    const [statusFilter, setStatusFilter] = useState<string>('');
    const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
    const [isViewDialogOpen, setIsViewDialogOpen] = useState(false);
    const [isReceiveDialogOpen, setIsReceiveDialogOpen] = useState(false);
    const [selectedOrder, setSelectedOrder] = useState<PurchaseOrder | null>(null);
    const [receiveItems, setReceiveItems] = useState<{ itemId: string; receivedQuantity: number; damagedQuantity: number }[]>([]);

    // ─────────────────────────────────────────
    // Queries
    // ─────────────────────────────────────────

    const { data: ordersData, isLoading, error } = useQuery({
        queryKey: ['purchase-orders', statusFilter],
        queryFn: () => purchaseOrdersApi.getAll({ status: statusFilter || undefined }),
    });

    const orders = ordersData?.items || [];

    const { data: suppliers = [] } = useQuery({
        queryKey: ['suppliers'],
        queryFn: () => suppliersApi.getAll(),
    });

    const { data: productsData } = useQuery({
        queryKey: ['products-list'],
        queryFn: () => productsApi.getAll({ limit: 100 }),
    });

    const products = productsData?.items || [];

    // ─────────────────────────────────────────
    // Mutations
    // ─────────────────────────────────────────

    const createMutation = useMutation({
        mutationFn: (data: PurchaseOrderFormData) => purchaseOrdersApi.create({
            supplierId: data.supplierId,
            items: data.items,
            taxAmount: data.taxAmount,
            shippingCost: data.shippingCost,
            notes: data.notes,
            expectedDeliveryDate: data.expectedDeliveryDate,
        }),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['purchase-orders'] });
            setIsCreateDialogOpen(false);
            toast.success('تم إنشاء أمر الشراء بنجاح');
            form.reset();
        },
        onError: () => {
            toast.error('حدث خطأ أثناء إنشاء أمر الشراء');
        },
    });

    const updateStatusMutation = useMutation({
        mutationFn: ({ id, status }: { id: string; status: string }) =>
            purchaseOrdersApi.updateStatus(id, status),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['purchase-orders'] });
            toast.success('تم تحديث حالة الطلب');
        },
        onError: () => {
            toast.error('حدث خطأ أثناء تحديث الحالة');
        },
    });

    const receiveMutation = useMutation({
        mutationFn: ({ id, items }: { id: string; items: { itemId: string; receivedQuantity: number; damagedQuantity?: number }[] }) =>
            purchaseOrdersApi.receive(id, items),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['purchase-orders'] });
            setIsReceiveDialogOpen(false);
            setSelectedOrder(null);
            toast.success('تم تسجيل الاستلام بنجاح');
        },
        onError: () => {
            toast.error('حدث خطأ أثناء تسجيل الاستلام');
        },
    });

    // ─────────────────────────────────────────
    // Form
    // ─────────────────────────────────────────

    const form = useForm<PurchaseOrderFormData>({
        resolver: zodResolver(purchaseOrderSchema),
        defaultValues: {
            supplierId: '',
            notes: '',
            expectedDeliveryDate: '',
            taxAmount: 0,
            shippingCost: 0,
            items: [{ productId: '', quantity: 1, unitPrice: 0 }],
        },
    });

    const { fields, append, remove } = useFieldArray({
        control: form.control,
        name: 'items',
    });

    // ─────────────────────────────────────────
    // Handlers
    // ─────────────────────────────────────────

    const handleView = (order: PurchaseOrder) => {
        setSelectedOrder(order);
        setIsViewDialogOpen(true);
    };

    const handleReceive = (order: PurchaseOrder) => {
        setSelectedOrder(order);
        setReceiveItems(order.items.map(item => ({
            itemId: item._id,
            receivedQuantity: item.quantity - item.receivedQuantity,
            damagedQuantity: 0,
        })));
        setIsReceiveDialogOpen(true);
    };

    const handleStatusChange = (orderId: string, newStatus: string) => {
        updateStatusMutation.mutate({ id: orderId, status: newStatus });
    };

    const onSubmit = (data: PurchaseOrderFormData) => {
        createMutation.mutate(data);
    };

    const onReceiveSubmit = () => {
        if (selectedOrder) {
            receiveMutation.mutate({
                id: selectedOrder._id,
                items: receiveItems.filter(item => item.receivedQuantity > 0),
            });
        }
    };

    // Calculate totals for form
    const watchedItems = form.watch('items');
    const watchedTax = form.watch('taxAmount') || 0;
    const watchedShipping = form.watch('shippingCost') || 0;
    const subtotal = watchedItems.reduce((sum, item) => sum + (item.quantity * item.unitPrice), 0);
    const total = subtotal + watchedTax + watchedShipping;

    // ─────────────────────────────────────────
    // Stats
    // ─────────────────────────────────────────

    const pendingOrders = orders.filter(o => ['draft', 'pending', 'approved', 'ordered'].includes(o.status)).length;
    const totalValue = orders.reduce((sum, o) => sum + o.total, 0);

    // ─────────────────────────────────────────
    // Render
    // ─────────────────────────────────────────

    if (error) {
        return (
            <div className="flex flex-col items-center justify-center h-[400px] text-muted-foreground">
                <AlertCircle className="h-12 w-12 mb-4 text-destructive" />
                <p>حدث خطأ أثناء تحميل أوامر الشراء</p>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <h1 className="text-2xl font-bold">أوامر الشراء</h1>
                    <p className="text-muted-foreground text-sm">إدارة أوامر الشراء من الموردين</p>
                </div>
                <Button onClick={() => setIsCreateDialogOpen(true)}>
                    <Plus className="h-4 w-4 ml-2" />
                    أمر شراء جديد
                </Button>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                                <FileText className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">إجمالي الأوامر</p>
                                <p className="text-2xl font-bold">{orders.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-yellow-100 dark:bg-yellow-900/30 rounded-lg">
                                <Clock className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">أوامر معلقة</p>
                                <p className="text-2xl font-bold">{pendingOrders}</p>
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
                                <p className="text-sm text-muted-foreground">إجمالي القيمة</p>
                                <p className="text-2xl font-bold">{formatCurrency(totalValue)}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Filters & Table */}
            <Card>
                <CardHeader>
                    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                        <CardTitle className="flex items-center gap-2">
                            <FileText className="h-5 w-5" />
                            قائمة أوامر الشراء
                        </CardTitle>
                        <div className="flex gap-2 w-full sm:w-auto">
                            <Select value={statusFilter} onValueChange={setStatusFilter}>
                                <SelectTrigger className="w-40">
                                    <SelectValue placeholder="جميع الحالات" />
                                </SelectTrigger>
                                <SelectContent>
                                    <SelectItem value="">جميع الحالات</SelectItem>
                                    <SelectItem value="draft">مسودة</SelectItem>
                                    <SelectItem value="pending">قيد الانتظار</SelectItem>
                                    <SelectItem value="approved">موافق عليه</SelectItem>
                                    <SelectItem value="ordered">تم الطلب</SelectItem>
                                    <SelectItem value="partial">استلام جزئي</SelectItem>
                                    <SelectItem value="received">تم الاستلام</SelectItem>
                                    <SelectItem value="cancelled">ملغي</SelectItem>
                                </SelectContent>
                            </Select>
                        </div>
                    </div>
                </CardHeader>
                <CardContent>
                    {isLoading ? (
                        <div className="flex justify-center items-center h-40">
                            <Loader2 className="h-8 w-8 animate-spin text-primary" />
                        </div>
                    ) : orders.length === 0 ? (
                        <div className="text-center py-12 text-muted-foreground">
                            <FileText className="h-12 w-12 mx-auto mb-4 opacity-50" />
                            <p>لا يوجد أوامر شراء</p>
                        </div>
                    ) : (
                        <div className="overflow-x-auto">
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>رقم الأمر</TableHead>
                                        <TableHead>المورد</TableHead>
                                        <TableHead>الحالة</TableHead>
                                        <TableHead>المنتجات</TableHead>
                                        <TableHead>الإجمالي</TableHead>
                                        <TableHead>التاريخ</TableHead>
                                        <TableHead className="w-[50px]"></TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {orders.map((order) => {
                                        const status = statusConfig[order.status] || statusConfig.draft;
                                        return (
                                            <TableRow key={order._id}>
                                                <TableCell>
                                                    <Badge variant="outline" className="font-mono">
                                                        {order.orderNumber}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>
                                                    <p className="font-medium">{order.supplier?.name || '-'}</p>
                                                </TableCell>
                                                <TableCell>
                                                    <Badge variant={status.variant} className="flex items-center gap-1 w-fit">
                                                        {status.icon}
                                                        {status.label}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>{order.items?.length || 0} منتج</TableCell>
                                                <TableCell className="font-medium">
                                                    {formatCurrency(order.total)}
                                                </TableCell>
                                                <TableCell className="text-muted-foreground">
                                                    {formatDate(order.createdAt)}
                                                </TableCell>
                                                <TableCell>
                                                    <DropdownMenu>
                                                        <DropdownMenuTrigger asChild>
                                                            <Button variant="ghost" size="icon">
                                                                <MoreHorizontal className="h-4 w-4" />
                                                            </Button>
                                                        </DropdownMenuTrigger>
                                                        <DropdownMenuContent align="end">
                                                            <DropdownMenuItem onClick={() => handleView(order)}>
                                                                <Eye className="h-4 w-4 ml-2" />
                                                                عرض التفاصيل
                                                            </DropdownMenuItem>
                                                            {['draft', 'pending'].includes(order.status) && (
                                                                <DropdownMenuItem onClick={() => handleStatusChange(order._id, 'approved')}>
                                                                    <CheckCircle className="h-4 w-4 ml-2" />
                                                                    موافقة
                                                                </DropdownMenuItem>
                                                            )}
                                                            {order.status === 'approved' && (
                                                                <DropdownMenuItem onClick={() => handleStatusChange(order._id, 'ordered')}>
                                                                    <Package className="h-4 w-4 ml-2" />
                                                                    تأكيد الطلب
                                                                </DropdownMenuItem>
                                                            )}
                                                            {['ordered', 'partial'].includes(order.status) && (
                                                                <DropdownMenuItem onClick={() => handleReceive(order)}>
                                                                    <Truck className="h-4 w-4 ml-2" />
                                                                    استلام البضاعة
                                                                </DropdownMenuItem>
                                                            )}
                                                            <DropdownMenuSeparator />
                                                            {!['received', 'cancelled'].includes(order.status) && (
                                                                <DropdownMenuItem
                                                                    onClick={() => handleStatusChange(order._id, 'cancelled')}
                                                                    className="text-red-600"
                                                                >
                                                                    <XCircle className="h-4 w-4 ml-2" />
                                                                    إلغاء
                                                                </DropdownMenuItem>
                                                            )}
                                                        </DropdownMenuContent>
                                                    </DropdownMenu>
                                                </TableCell>
                                            </TableRow>
                                        );
                                    })}
                                </TableBody>
                            </Table>
                        </div>
                    )}
                </CardContent>
            </Card>

            {/* Create Dialog */}
            <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
                <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>إنشاء أمر شراء جديد</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>المورد *</Label>
                                <Select
                                    value={form.watch('supplierId')}
                                    onValueChange={(value) => form.setValue('supplierId', value)}
                                >
                                    <SelectTrigger>
                                        <SelectValue placeholder="اختر المورد" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        {suppliers.map((supplier) => (
                                            <SelectItem key={supplier._id} value={supplier._id}>
                                                {supplier.name}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                                {form.formState.errors.supplierId && (
                                    <p className="text-sm text-red-500">{form.formState.errors.supplierId.message}</p>
                                )}
                            </div>
                            <div className="space-y-2">
                                <Label>تاريخ التوصيل المتوقع</Label>
                                <Input
                                    type="date"
                                    {...form.register('expectedDeliveryDate')}
                                />
                            </div>
                        </div>

                        {/* Items */}
                        <div className="border rounded-lg p-4 space-y-4">
                            <div className="flex justify-between items-center">
                                <h4 className="font-medium">المنتجات</h4>
                                <Button
                                    type="button"
                                    variant="outline"
                                    size="sm"
                                    onClick={() => append({ productId: '', quantity: 1, unitPrice: 0 })}
                                >
                                    <Plus className="h-4 w-4 ml-1" />
                                    إضافة منتج
                                </Button>
                            </div>

                            {fields.map((field, index) => (
                                <div key={field.id} className="grid grid-cols-12 gap-2 items-end">
                                    <div className="col-span-5 space-y-1">
                                        <Label className="text-xs">المنتج</Label>
                                        <Select
                                            value={form.watch(`items.${index}.productId`)}
                                            onValueChange={(value) => form.setValue(`items.${index}.productId`, value)}
                                        >
                                            <SelectTrigger>
                                                <SelectValue placeholder="اختر المنتج" />
                                            </SelectTrigger>
                                            <SelectContent>
                                                {products.map((product: any) => (
                                                    <SelectItem key={product._id} value={product._id}>
                                                        {product.name}
                                                    </SelectItem>
                                                ))}
                                            </SelectContent>
                                        </Select>
                                    </div>
                                    <div className="col-span-2 space-y-1">
                                        <Label className="text-xs">الكمية</Label>
                                        <Input
                                            type="number"
                                            min="1"
                                            {...form.register(`items.${index}.quantity`, { valueAsNumber: true })}
                                        />
                                    </div>
                                    <div className="col-span-2 space-y-1">
                                        <Label className="text-xs">السعر</Label>
                                        <Input
                                            type="number"
                                            step="0.01"
                                            min="0"
                                            {...form.register(`items.${index}.unitPrice`, { valueAsNumber: true })}
                                        />
                                    </div>
                                    <div className="col-span-2 space-y-1">
                                        <Label className="text-xs">الإجمالي</Label>
                                        <div className="h-10 px-3 py-2 bg-muted rounded-md text-sm">
                                            {formatCurrency((watchedItems[index]?.quantity || 0) * (watchedItems[index]?.unitPrice || 0))}
                                        </div>
                                    </div>
                                    <div className="col-span-1">
                                        <Button
                                            type="button"
                                            variant="ghost"
                                            size="icon"
                                            onClick={() => remove(index)}
                                            disabled={fields.length === 1}
                                        >
                                            <Trash2 className="h-4 w-4 text-red-500" />
                                        </Button>
                                    </div>
                                </div>
                            ))}
                        </div>

                        {/* Summary */}
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>ملاحظات</Label>
                                <Textarea {...form.register('notes')} placeholder="ملاحظات إضافية..." />
                            </div>
                            <div className="space-y-3">
                                <div className="flex justify-between items-center">
                                    <span className="text-sm text-muted-foreground">المجموع الفرعي:</span>
                                    <span className="font-medium">{formatCurrency(subtotal)}</span>
                                </div>
                                <div className="flex items-center gap-2">
                                    <Label className="text-sm text-muted-foreground w-20">الضريبة:</Label>
                                    <Input
                                        type="number"
                                        step="0.01"
                                        className="flex-1"
                                        {...form.register('taxAmount', { valueAsNumber: true })}
                                    />
                                </div>
                                <div className="flex items-center gap-2">
                                    <Label className="text-sm text-muted-foreground w-20">الشحن:</Label>
                                    <Input
                                        type="number"
                                        step="0.01"
                                        className="flex-1"
                                        {...form.register('shippingCost', { valueAsNumber: true })}
                                    />
                                </div>
                                <div className="flex justify-between items-center pt-2 border-t">
                                    <span className="font-medium">الإجمالي:</span>
                                    <span className="text-lg font-bold text-primary">{formatCurrency(total)}</span>
                                </div>
                            </div>
                        </div>

                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsCreateDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={createMutation.isPending}>
                                {createMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                إنشاء أمر الشراء
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* View Dialog */}
            <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
                <DialogContent className="max-w-2xl">
                    <DialogHeader>
                        <DialogTitle className="flex items-center gap-2">
                            <Badge variant="outline" className="font-mono">
                                {selectedOrder?.orderNumber}
                            </Badge>
                            تفاصيل أمر الشراء
                        </DialogTitle>
                    </DialogHeader>
                    {selectedOrder && (
                        <div className="space-y-4">
                            <div className="grid grid-cols-2 gap-4 text-sm">
                                <div>
                                    <p className="text-muted-foreground">المورد</p>
                                    <p className="font-medium">{selectedOrder.supplier?.name}</p>
                                </div>
                                <div>
                                    <p className="text-muted-foreground">الحالة</p>
                                    <Badge variant={statusConfig[selectedOrder.status]?.variant || 'default'}>
                                        {statusConfig[selectedOrder.status]?.label || selectedOrder.status}
                                    </Badge>
                                </div>
                                <div>
                                    <p className="text-muted-foreground">تاريخ الإنشاء</p>
                                    <p className="font-medium">{formatDate(selectedOrder.createdAt)}</p>
                                </div>
                                <div>
                                    <p className="text-muted-foreground">منشئ الطلب</p>
                                    <p className="font-medium">{selectedOrder.createdBy?.name || '-'}</p>
                                </div>
                            </div>

                            <div className="border rounded-lg overflow-hidden">
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>المنتج</TableHead>
                                            <TableHead className="text-center">الكمية</TableHead>
                                            <TableHead className="text-center">المستلم</TableHead>
                                            <TableHead>السعر</TableHead>
                                            <TableHead>الإجمالي</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {selectedOrder.items?.map((item) => (
                                            <TableRow key={item._id}>
                                                <TableCell>
                                                    <p className="font-medium">{item.productName}</p>
                                                    <p className="text-xs text-muted-foreground">{item.sku}</p>
                                                </TableCell>
                                                <TableCell className="text-center">{item.quantity}</TableCell>
                                                <TableCell className="text-center">
                                                    <span className={item.receivedQuantity >= item.quantity ? 'text-green-600' : ''}>
                                                        {item.receivedQuantity}
                                                    </span>
                                                </TableCell>
                                                <TableCell>{formatCurrency(item.unitPrice)}</TableCell>
                                                <TableCell className="font-medium">{formatCurrency(item.total)}</TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            </div>

                            <div className="flex justify-end">
                                <div className="w-64 space-y-2 text-sm">
                                    <div className="flex justify-between">
                                        <span className="text-muted-foreground">المجموع الفرعي:</span>
                                        <span>{formatCurrency(selectedOrder.subtotal)}</span>
                                    </div>
                                    <div className="flex justify-between">
                                        <span className="text-muted-foreground">الضريبة:</span>
                                        <span>{formatCurrency(selectedOrder.taxAmount)}</span>
                                    </div>
                                    <div className="flex justify-between">
                                        <span className="text-muted-foreground">الشحن:</span>
                                        <span>{formatCurrency(selectedOrder.shippingCost)}</span>
                                    </div>
                                    <div className="flex justify-between pt-2 border-t font-medium">
                                        <span>الإجمالي:</span>
                                        <span className="text-primary">{formatCurrency(selectedOrder.total)}</span>
                                    </div>
                                </div>
                            </div>

                            {selectedOrder.notes && (
                                <div className="p-3 bg-muted rounded-lg">
                                    <p className="text-sm text-muted-foreground">ملاحظات:</p>
                                    <p className="text-sm">{selectedOrder.notes}</p>
                                </div>
                            )}
                        </div>
                    )}
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsViewDialogOpen(false)}>
                            إغلاق
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Receive Dialog */}
            <Dialog open={isReceiveDialogOpen} onOpenChange={setIsReceiveDialogOpen}>
                <DialogContent className="max-w-2xl">
                    <DialogHeader>
                        <DialogTitle>استلام البضاعة</DialogTitle>
                    </DialogHeader>
                    {selectedOrder && (
                        <div className="space-y-4">
                            <div className="border rounded-lg overflow-hidden">
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>المنتج</TableHead>
                                            <TableHead className="text-center">المطلوب</TableHead>
                                            <TableHead className="text-center">المستلم سابقاً</TableHead>
                                            <TableHead className="text-center">الكمية المستلمة</TableHead>
                                            <TableHead className="text-center">تالف</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {selectedOrder.items?.map((item, index) => (
                                            <TableRow key={item._id}>
                                                <TableCell>
                                                    <p className="font-medium">{item.productName}</p>
                                                </TableCell>
                                                <TableCell className="text-center">{item.quantity}</TableCell>
                                                <TableCell className="text-center">{item.receivedQuantity}</TableCell>
                                                <TableCell>
                                                    <Input
                                                        type="number"
                                                        min="0"
                                                        max={item.quantity - item.receivedQuantity}
                                                        value={receiveItems[index]?.receivedQuantity || 0}
                                                        onChange={(e) => {
                                                            const newItems = [...receiveItems];
                                                            newItems[index] = {
                                                                ...newItems[index],
                                                                receivedQuantity: parseInt(e.target.value) || 0,
                                                            };
                                                            setReceiveItems(newItems);
                                                        }}
                                                        className="w-20 text-center mx-auto"
                                                    />
                                                </TableCell>
                                                <TableCell>
                                                    <Input
                                                        type="number"
                                                        min="0"
                                                        value={receiveItems[index]?.damagedQuantity || 0}
                                                        onChange={(e) => {
                                                            const newItems = [...receiveItems];
                                                            newItems[index] = {
                                                                ...newItems[index],
                                                                damagedQuantity: parseInt(e.target.value) || 0,
                                                            };
                                                            setReceiveItems(newItems);
                                                        }}
                                                        className="w-20 text-center mx-auto"
                                                    />
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            </div>
                        </div>
                    )}
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsReceiveDialogOpen(false)}>
                            إلغاء
                        </Button>
                        <Button onClick={onReceiveSubmit} disabled={receiveMutation.isPending}>
                            {receiveMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                            تأكيد الاستلام
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}

export default PurchaseOrdersPage;
