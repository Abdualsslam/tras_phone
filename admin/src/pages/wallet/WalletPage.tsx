import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { walletApi, type LoyaltyTier } from '@/api/wallet.api';
import { customersApi } from '@/api/customers.api';
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
// Select is kept for potential future use
import {
    Loader2,
    Wallet,
    ArrowUpCircle,
    ArrowDownCircle,
    Gift,
    Star,
    Search,
    TrendingUp,
    Coins,
    Plus,
    Pencil,
    Trash2,
    Crown,
} from 'lucide-react';
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs';
import { Switch } from '@/components/ui/switch';
import { formatCurrency, formatDate } from '@/lib/utils';

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function WalletPage() {
    const queryClient = useQueryClient();

    const [selectedCustomerId, setSelectedCustomerId] = useState<string>('');
    const [customerSearch, setCustomerSearch] = useState('');
    const [isCreditDialogOpen, setIsCreditDialogOpen] = useState(false);
    const [isDebitDialogOpen, setIsDebitDialogOpen] = useState(false);
    const [isPointsDialogOpen, setIsPointsDialogOpen] = useState(false);
    const [activeTab, setActiveTab] = useState('customers');
    
    // Tiers management
    const [isCreateTierDialogOpen, setIsCreateTierDialogOpen] = useState(false);
    const [isEditTierDialogOpen, setIsEditTierDialogOpen] = useState(false);
    const [isDeleteTierDialogOpen, setIsDeleteTierDialogOpen] = useState(false);
    const [selectedTier, setSelectedTier] = useState<LoyaltyTier | null>(null);

    // ─────────────────────────────────────────
    // Queries
    // ─────────────────────────────────────────

    const { data: tiers = [], isLoading: tiersLoading, refetch: refetchTiers } = useQuery({
        queryKey: ['wallet-tiers-admin'],
        queryFn: () => walletApi.getAllTiers(),
    });

    const { data: customerSearchResult, isLoading: customersLoading } = useQuery({
        queryKey: ['wallet-customer-search', customerSearch],
        queryFn: () => customersApi.getAll({ page: 1, limit: 10, search: customerSearch.trim() }),
        enabled: customerSearch.trim().length >= 2,
    });

    const { data: customerBalance, isLoading: balanceLoading } = useQuery({
        queryKey: ['wallet-balance', selectedCustomerId],
        queryFn: () => walletApi.getCustomerBalance(selectedCustomerId),
        enabled: !!selectedCustomerId,
    });

    const { data: transactions = [], isLoading: transactionsLoading } = useQuery({
        queryKey: ['wallet-transactions', selectedCustomerId],
        queryFn: () => walletApi.getCustomerTransactions(selectedCustomerId),
        enabled: !!selectedCustomerId,
    });

    const customerOptions = customerSearchResult?.items || [];
    const selectedCustomer = customerOptions.find((item) => item._id === selectedCustomerId);

    // ─────────────────────────────────────────
    // Mutations
    // ─────────────────────────────────────────

    const creditMutation = useMutation({
        mutationFn: walletApi.creditWallet,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['wallet-balance', selectedCustomerId] });
            queryClient.invalidateQueries({ queryKey: ['wallet-transactions', selectedCustomerId] });
            setIsCreditDialogOpen(false);
            toast.success('تم إضافة الرصيد بنجاح');
            creditForm.reset();
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const debitMutation = useMutation({
        mutationFn: walletApi.debitWallet,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['wallet-balance', selectedCustomerId] });
            queryClient.invalidateQueries({ queryKey: ['wallet-transactions', selectedCustomerId] });
            setIsDebitDialogOpen(false);
            toast.success('تم خصم الرصيد بنجاح');
            debitForm.reset();
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const grantPointsMutation = useMutation({
        mutationFn: walletApi.grantPoints,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['wallet-balance', selectedCustomerId] });
            setIsPointsDialogOpen(false);
            toast.success('تم منح النقاط بنجاح');
            pointsForm.reset();
        },
        onError: () => toast.error('حدث خطأ'),
    });

    // Tiers mutations
    const createTierMutation = useMutation({
        mutationFn: walletApi.createTier,
        onSuccess: () => {
            refetchTiers();
            setIsCreateTierDialogOpen(false);
            toast.success('تم إنشاء المستوى بنجاح');
            tierForm.reset();
        },
        onError: (error: any) => {
            toast.error(error?.response?.data?.messageAr || 'حدث خطأ في إنشاء المستوى');
        },
    });

    const updateTierMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: Partial<LoyaltyTier> }) => walletApi.updateTier(id, data),
        onSuccess: () => {
            refetchTiers();
            setIsEditTierDialogOpen(false);
            setSelectedTier(null);
            toast.success('تم تحديث المستوى بنجاح');
            tierForm.reset();
        },
        onError: (error: any) => {
            toast.error(error?.response?.data?.messageAr || 'حدث خطأ في تحديث المستوى');
        },
    });

    const deleteTierMutation = useMutation({
        mutationFn: (id: string) => walletApi.deleteTier(id),
        onSuccess: () => {
            refetchTiers();
            setIsDeleteTierDialogOpen(false);
            setSelectedTier(null);
            toast.success('تم حذف المستوى بنجاح');
        },
        onError: (error: any) => {
            toast.error(error?.response?.data?.messageAr || 'حدث خطأ في حذف المستوى');
        },
    });

    // ─────────────────────────────────────────
    // Forms
    // ─────────────────────────────────────────

    const creditForm = useForm({
        defaultValues: {
            amount: 0,
            description: '',
            reference: '',
        },
    });

    const debitForm = useForm({
        defaultValues: {
            amount: 0,
            description: '',
            reference: '',
        },
    });

    const pointsForm = useForm({
        defaultValues: {
            points: 0,
            reason: '',
        },
    });

    const tierForm = useForm<Omit<LoyaltyTier, '_id' | 'createdAt' | 'updatedAt'>>({
        defaultValues: {
            name: '',
            nameAr: '',
            code: '',
            minPoints: 0,
            pointsMultiplier: 1,
            discountPercentage: 0,
            freeShipping: false,
            prioritySupport: false,
            earlyAccess: false,
            displayOrder: 0,
            isActive: true,
        },
    });

    // ─────────────────────────────────────────
    // Handlers
    // ─────────────────────────────────────────

    const handleOpenCredit = () => {
        if (!selectedCustomerId) {
            toast.error('يرجى اختيار عميل أولاً');
            return;
        }
        creditForm.reset({ amount: 0, description: '', reference: '' });
        setIsCreditDialogOpen(true);
    };

    const handleOpenDebit = () => {
        if (!selectedCustomerId) {
            toast.error('يرجى اختيار عميل أولاً');
            return;
        }
        debitForm.reset({ amount: 0, description: '', reference: '' });
        setIsDebitDialogOpen(true);
    };

    const handleOpenPoints = () => {
        if (!selectedCustomerId) {
            toast.error('يرجى اختيار عميل أولاً');
            return;
        }
        pointsForm.reset({ points: 0, reason: '' });
        setIsPointsDialogOpen(true);
    };

    const onCreditSubmit = (data: { amount: number; description: string; reference: string }) => {
        creditMutation.mutate({
            customerId: selectedCustomerId,
            amount: data.amount,
            description: data.description,
            reference: data.reference || undefined,
        });
    };

    const onDebitSubmit = (data: { amount: number; description: string; reference: string }) => {
        debitMutation.mutate({
            customerId: selectedCustomerId,
            amount: data.amount,
            description: data.description,
            reference: data.reference || undefined,
        });
    };

    const onPointsSubmit = (data: { points: number; reason: string }) => {
        grantPointsMutation.mutate({
            customerId: selectedCustomerId,
            points: data.points,
            reason: data.reason,
        });
    };

    // Tiers handlers
    const handleCreateTier = () => {
        tierForm.reset({
            name: '',
            nameAr: '',
            code: '',
            minPoints: 0,
            pointsMultiplier: 1,
            discountPercentage: 0,
            freeShipping: false,
            prioritySupport: false,
            earlyAccess: false,
            displayOrder: 0,
            isActive: true,
        });
        setIsCreateTierDialogOpen(true);
    };

    const handleEditTier = (tier: LoyaltyTier) => {
        setSelectedTier(tier);
        tierForm.reset({
            name: tier.name,
            nameAr: tier.nameAr,
            code: tier.code,
            minPoints: tier.minPoints,
            pointsMultiplier: tier.pointsMultiplier,
            discountPercentage: tier.discountPercentage,
            freeShipping: tier.freeShipping,
            prioritySupport: tier.prioritySupport,
            earlyAccess: tier.earlyAccess,
            displayOrder: tier.displayOrder,
            isActive: tier.isActive,
            description: tier.description,
            descriptionAr: tier.descriptionAr,
            color: tier.color,
            icon: tier.icon,
            badgeImage: tier.badgeImage,
            customBenefits: tier.customBenefits,
            minSpend: tier.minSpend,
            minOrders: tier.minOrders,
        });
        setIsEditTierDialogOpen(true);
    };

    const handleDeleteTier = (tier: LoyaltyTier) => {
        setSelectedTier(tier);
        setIsDeleteTierDialogOpen(true);
    };

    const onTierSubmit = (data: Omit<LoyaltyTier, '_id' | 'createdAt' | 'updatedAt'>) => {
        if (selectedTier) {
            updateTierMutation.mutate({ id: selectedTier._id, data });
        } else {
            createTierMutation.mutate(data);
        }
    };

    const onDeleteTierConfirm = () => {
        if (selectedTier) {
            deleteTierMutation.mutate(selectedTier._id);
        }
    };

    // ─────────────────────────────────────────
    // Render
    // ─────────────────────────────────────────

    return (
        <div className="space-y-6">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold">إدارة المحفظة والنقاط</h1>
                <p className="text-muted-foreground text-sm">إدارة أرصدة العملاء ونقاط الولاء</p>
            </div>

            {/* Tabs */}
            <Tabs value={activeTab} onValueChange={setActiveTab}>
                <TabsList>
                    <TabsTrigger value="customers" className="flex items-center gap-2">
                        <Wallet className="h-4 w-4" />
                        عملاء المحفظة
                    </TabsTrigger>
                    <TabsTrigger value="tiers" className="flex items-center gap-2">
                        <Crown className="h-4 w-4" />
                        مستويات الولاء
                    </TabsTrigger>
                </TabsList>

                {/* Customers Tab */}
                <TabsContent value="customers" className="space-y-6">

            {/* Customer Search */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <Search className="h-5 w-5" />
                        البحث عن عميل
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="space-y-3">
                        <div className="flex gap-4">
                            <div className="flex-1">
                                <Input
                                    placeholder="ابحث بالاسم أو رقم الجوال..."
                                    value={customerSearch}
                                    onChange={(e) => setCustomerSearch(e.target.value)}
                                />
                            </div>
                        </div>

                        {customerSearch.trim().length >= 2 && (
                            <div className="rounded-md border p-2 max-h-52 overflow-auto">
                                {customersLoading ? (
                                    <p className="text-sm text-muted-foreground px-2 py-1">جاري البحث...</p>
                                ) : customerOptions.length === 0 ? (
                                    <p className="text-sm text-muted-foreground px-2 py-1">لا يوجد عملاء مطابقون</p>
                                ) : (
                                    <div className="space-y-1">
                                        {customerOptions.map((customer) => (
                                            <button
                                                key={customer._id}
                                                type="button"
                                                className="w-full text-right px-3 py-2 rounded-md hover:bg-muted transition-colors"
                                                onClick={() => {
                                                    setSelectedCustomerId(customer._id);
                                                    setCustomerSearch(customer.contactName || customer.companyName || customer.phone);
                                                }}
                                            >
                                                <div className="text-sm font-medium">
                                                    {customer.contactName || customer.companyName || 'عميل'}
                                                </div>
                                                <div className="text-xs text-muted-foreground">
                                                    {customer.phone} • {customer._id}
                                                </div>
                                            </button>
                                        ))}
                                    </div>
                                )}
                            </div>
                        )}

                        <div className="flex gap-4">
                            <div className="flex-1">
                                <Input
                                    placeholder="أو أدخل معرف العميل مباشرة..."
                                    value={selectedCustomerId}
                                    onChange={(e) => setSelectedCustomerId(e.target.value)}
                                />
                            </div>
                            <Button onClick={() => {}} disabled={!selectedCustomerId}>
                                <Search className="h-4 w-4 ml-2" />
                                تحميل البيانات
                            </Button>
                        </div>

                        {selectedCustomerId && (
                            <div className="text-xs text-muted-foreground">
                                العميل المحدد: {selectedCustomer?.contactName || selectedCustomer?.companyName || selectedCustomerId}
                            </div>
                        )}
                    </div>
                </CardContent>
            </Card>

            {/* Customer Wallet Info */}
            {selectedCustomerId && (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <Card>
                        <CardContent className="pt-6">
                            <div className="flex items-center gap-3">
                                <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                                    <Wallet className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                                </div>
                                <div>
                                    <p className="text-sm text-muted-foreground">الرصيد</p>
                                    <p className="text-2xl font-bold">
                                        {balanceLoading ? '...' : formatCurrency(customerBalance?.balance || 0)}
                                    </p>
                                </div>
                            </div>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="pt-6">
                            <div className="flex items-center gap-3">
                                <div className="p-2 bg-yellow-100 dark:bg-yellow-900/30 rounded-lg">
                                    <Coins className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />
                                </div>
                                <div>
                                    <p className="text-sm text-muted-foreground">النقاط</p>
                                    <p className="text-2xl font-bold">
                                        {balanceLoading ? '...' : (customerBalance?.points || 0).toLocaleString()}
                                    </p>
                                </div>
                            </div>
                        </CardContent>
                    </Card>
                    <Card>
                        <CardContent className="pt-6">
                            <div className="flex items-center gap-3">
                                <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                                    <Star className="h-5 w-5 text-purple-600 dark:text-purple-400" />
                                </div>
                                <div>
                                    <p className="text-sm text-muted-foreground">المستوى</p>
                                    <p className="text-2xl font-bold">
                                        {balanceLoading ? '...' : (customerBalance?.tier || 'Bronze')}
                                    </p>
                                </div>
                            </div>
                        </CardContent>
                    </Card>
                </div>
            )}

            {/* Actions */}
            {selectedCustomerId && (
                <div className="flex gap-2">
                    <Button onClick={handleOpenCredit} className="bg-green-600 hover:bg-green-700">
                        <ArrowUpCircle className="h-4 w-4 ml-2" />
                        إضافة رصيد
                    </Button>
                    <Button onClick={handleOpenDebit} variant="destructive">
                        <ArrowDownCircle className="h-4 w-4 ml-2" />
                        خصم رصيد
                    </Button>
                    <Button onClick={handleOpenPoints} variant="outline">
                        <Gift className="h-4 w-4 ml-2" />
                        منح نقاط
                    </Button>
                </div>
            )}

            {/* Transactions */}
            {selectedCustomerId && (
                <Card>
                    <CardHeader>
                        <CardTitle className="flex items-center gap-2">
                            <TrendingUp className="h-5 w-5" />
                            سجل المعاملات
                        </CardTitle>
                    </CardHeader>
                    <CardContent>
                        {transactionsLoading ? (
                            <div className="flex justify-center items-center h-40">
                                <Loader2 className="h-8 w-8 animate-spin text-primary" />
                            </div>
                        ) : transactions.length === 0 ? (
                            <div className="text-center py-12 text-muted-foreground">
                                <Wallet className="h-12 w-12 mx-auto mb-4 opacity-50" />
                                <p>لا توجد معاملات</p>
                            </div>
                        ) : (
                            <Table>
                                <TableHeader>
                                    <TableRow>
                                        <TableHead>النوع</TableHead>
                                        <TableHead>المبلغ</TableHead>
                                        <TableHead>الرصيد السابق</TableHead>
                                        <TableHead>الرصيد الجديد</TableHead>
                                        <TableHead>الوصف</TableHead>
                                        <TableHead>التاريخ</TableHead>
                                    </TableRow>
                                </TableHeader>
                                <TableBody>
                                    {transactions.map((tx) => (
                                        <TableRow key={tx._id}>
                                            <TableCell>
                                                <Badge variant={tx.type === 'credit' ? 'success' : 'danger'}>
                                                    {tx.type === 'credit' ? (
                                                        <ArrowUpCircle className="h-3 w-3 ml-1" />
                                                    ) : (
                                                        <ArrowDownCircle className="h-3 w-3 ml-1" />
                                                    )}
                                                    {tx.type === 'credit' ? 'إضافة' : 'خصم'}
                                                </Badge>
                                            </TableCell>
                                            <TableCell className={tx.type === 'credit' ? 'text-green-600 font-medium' : 'text-red-600 font-medium'}>
                                                {tx.type === 'credit' ? '+' : '-'}{formatCurrency(tx.amount)}
                                            </TableCell>
                                            <TableCell className="text-muted-foreground">
                                                {formatCurrency(tx.balanceBefore)}
                                            </TableCell>
                                            <TableCell className="font-medium">
                                                {formatCurrency(tx.balanceAfter)}
                                            </TableCell>
                                            <TableCell className="text-sm">{tx.description}</TableCell>
                                            <TableCell className="text-muted-foreground text-sm">
                                                {formatDate(tx.createdAt)}
                                            </TableCell>
                                        </TableRow>
                                    ))}
                                </TableBody>
                            </Table>
                        )}
                    </CardContent>
                </Card>
            )}

                </TabsContent>

                {/* Tiers Management Tab */}
                <TabsContent value="tiers" className="space-y-6">
                    <Card>
                        <CardHeader>
                            <div className="flex items-center justify-between">
                                <CardTitle className="flex items-center gap-2">
                                    <Crown className="h-5 w-5" />
                                    إدارة مستويات الولاء
                                </CardTitle>
                                <Button onClick={handleCreateTier} className="bg-green-600 hover:bg-green-700">
                                    <Plus className="h-4 w-4 ml-2" />
                                    إضافة مستوى جديد
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {tiersLoading ? (
                                <div className="flex justify-center items-center h-40">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                                </div>
                            ) : tiers.length === 0 ? (
                                <div className="text-center py-12 text-muted-foreground">
                                    <Crown className="h-12 w-12 mx-auto mb-4 opacity-50" />
                                    <p>لا توجد مستويات</p>
                                </div>
                            ) : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>الاسم</TableHead>
                                            <TableHead>الكود</TableHead>
                                            <TableHead>الحد الأدنى</TableHead>
                                            <TableHead>المضاعف</TableHead>
                                            <TableHead>الخصم</TableHead>
                                            <TableHead>المزايا</TableHead>
                                            <TableHead>الحالة</TableHead>
                                            <TableHead>الإجراءات</TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {tiers.map((tier) => (
                                            <TableRow key={tier._id}>
                                                <TableCell>
                                                    <div>
                                                        <p className="font-medium">{tier.name}</p>
                                                        <p className="text-sm text-muted-foreground">{tier.nameAr}</p>
                                                    </div>
                                                </TableCell>
                                                <TableCell>
                                                    <Badge variant="outline">{tier.code}</Badge>
                                                </TableCell>
                                                <TableCell>{tier.minPoints.toLocaleString()} نقطة</TableCell>
                                                <TableCell>x{tier.pointsMultiplier}</TableCell>
                                                <TableCell>{tier.discountPercentage}%</TableCell>
                                                <TableCell>
                                                    <div className="flex flex-wrap gap-1">
                                                        {tier.freeShipping && (
                                                            <Badge variant="success" className="text-xs">شحن مجاني</Badge>
                                                        )}
                                                        {tier.prioritySupport && (
                                                            <Badge variant="success" className="text-xs">دعم أولوية</Badge>
                                                        )}
                                                        {tier.earlyAccess && (
                                                            <Badge variant="success" className="text-xs">وصول مبكر</Badge>
                                                        )}
                                                    </div>
                                                </TableCell>
                                                <TableCell>
                                                    <Badge variant={tier.isActive ? 'success' : 'danger'}>
                                                        {tier.isActive ? 'نشط' : 'غير نشط'}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>
                                                    <div className="flex gap-2">
                                                        <Button
                                                            variant="outline"
                                                            size="sm"
                                                            onClick={() => handleEditTier(tier)}
                                                        >
                                                            <Pencil className="h-4 w-4" />
                                                        </Button>
                                                        <Button
                                                            variant="destructive"
                                                            size="sm"
                                                            onClick={() => handleDeleteTier(tier)}
                                                        >
                                                            <Trash2 className="h-4 w-4" />
                                                        </Button>
                                                    </div>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>

            {/* Credit Dialog */}
            <Dialog open={isCreditDialogOpen} onOpenChange={setIsCreditDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>إضافة رصيد</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={creditForm.handleSubmit(onCreditSubmit)} className="space-y-4">
                        <div className="space-y-2">
                            <Label>المبلغ *</Label>
                            <Input
                                type="number"
                                step="0.01"
                                {...creditForm.register('amount', { valueAsNumber: true })}
                                placeholder="0.00"
                            />
                        </div>
                        <div className="space-y-2">
                            <Label>الوصف *</Label>
                            <Textarea {...creditForm.register('description')} placeholder="سبب إضافة الرصيد..." />
                        </div>
                        <div className="space-y-2">
                            <Label>المرجع</Label>
                            <Input {...creditForm.register('reference')} placeholder="رقم المرجع (اختياري)" />
                        </div>
                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsCreditDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={creditMutation.isPending} className="bg-green-600 hover:bg-green-700">
                                {creditMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                إضافة
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Debit Dialog */}
            <Dialog open={isDebitDialogOpen} onOpenChange={setIsDebitDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>خصم رصيد</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={debitForm.handleSubmit(onDebitSubmit)} className="space-y-4">
                        <div className="space-y-2">
                            <Label>المبلغ *</Label>
                            <Input
                                type="number"
                                step="0.01"
                                {...debitForm.register('amount', { valueAsNumber: true })}
                                placeholder="0.00"
                            />
                        </div>
                        <div className="space-y-2">
                            <Label>الوصف *</Label>
                            <Textarea {...debitForm.register('description')} placeholder="سبب خصم الرصيد..." />
                        </div>
                        <div className="space-y-2">
                            <Label>المرجع</Label>
                            <Input {...debitForm.register('reference')} placeholder="رقم المرجع (اختياري)" />
                        </div>
                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsDebitDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={debitMutation.isPending} variant="destructive">
                                {debitMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                خصم
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Points Dialog */}
            <Dialog open={isPointsDialogOpen} onOpenChange={setIsPointsDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>منح نقاط ولاء</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={pointsForm.handleSubmit(onPointsSubmit)} className="space-y-4">
                        <div className="space-y-2">
                            <Label>عدد النقاط *</Label>
                            <Input
                                type="number"
                                {...pointsForm.register('points', { valueAsNumber: true })}
                                placeholder="0"
                            />
                        </div>
                        <div className="space-y-2">
                            <Label>السبب *</Label>
                            <Textarea {...pointsForm.register('reason')} placeholder="سبب منح النقاط..." />
                        </div>
                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsPointsDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={grantPointsMutation.isPending}>
                                {grantPointsMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                منح
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Create/Edit Tier Dialog */}
            <Dialog open={isCreateTierDialogOpen || isEditTierDialogOpen} onOpenChange={(open) => {
                if (!open) {
                    setIsCreateTierDialogOpen(false);
                    setIsEditTierDialogOpen(false);
                    setSelectedTier(null);
                    tierForm.reset();
                }
            }}>
                <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>{selectedTier ? 'تعديل مستوى الولاء' : 'إضافة مستوى ولاء جديد'}</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={tierForm.handleSubmit(onTierSubmit)} className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>الاسم (إنجليزي) *</Label>
                                <Input {...tierForm.register('name', { required: true })} placeholder="Bronze" />
                            </div>
                            <div className="space-y-2">
                                <Label>الاسم (عربي) *</Label>
                                <Input {...tierForm.register('nameAr', { required: true })} placeholder="برونزي" />
                            </div>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>الكود *</Label>
                                <Input {...tierForm.register('code', { required: true })} placeholder="bronze" disabled={!!selectedTier} />
                            </div>
                            <div className="space-y-2">
                                <Label>الحد الأدنى من النقاط *</Label>
                                <Input
                                    type="number"
                                    {...tierForm.register('minPoints', { required: true, valueAsNumber: true, min: 0 })}
                                    placeholder="0"
                                />
                            </div>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>مضاعف النقاط *</Label>
                                <Input
                                    type="number"
                                    step="0.1"
                                    {...tierForm.register('pointsMultiplier', { required: true, valueAsNumber: true, min: 0.1 })}
                                    placeholder="1"
                                />
                            </div>
                            <div className="space-y-2">
                                <Label>نسبة الخصم (%)</Label>
                                <Input
                                    type="number"
                                    {...tierForm.register('discountPercentage', { valueAsNumber: true, min: 0, max: 100 })}
                                    placeholder="0"
                                />
                            </div>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>اللون (Hex)</Label>
                                <Input {...tierForm.register('color')} placeholder="#CD7F32" />
                            </div>
                            <div className="space-y-2">
                                <Label>ترتيب العرض</Label>
                                <Input
                                    type="number"
                                    {...tierForm.register('displayOrder', { valueAsNumber: true })}
                                    placeholder="0"
                                />
                            </div>
                        </div>
                        <div className="space-y-2">
                            <Label>الوصف (إنجليزي)</Label>
                            <Textarea {...tierForm.register('description')} placeholder="Tier description..." />
                        </div>
                        <div className="space-y-2">
                            <Label>الوصف (عربي)</Label>
                            <Textarea {...tierForm.register('descriptionAr')} placeholder="وصف المستوى..." />
                        </div>
                        <div className="space-y-4">
                            <Label className="text-base font-semibold">المزايا</Label>
                            <div className="space-y-3">
                                <div className="flex items-center justify-between">
                                    <Label htmlFor="freeShipping" className="cursor-pointer">شحن مجاني</Label>
                                    <Switch
                                        id="freeShipping"
                                        checked={tierForm.watch('freeShipping')}
                                        onCheckedChange={(checked) => tierForm.setValue('freeShipping', checked)}
                                    />
                                </div>
                                <div className="flex items-center justify-between">
                                    <Label htmlFor="prioritySupport" className="cursor-pointer">دعم أولوية</Label>
                                    <Switch
                                        id="prioritySupport"
                                        checked={tierForm.watch('prioritySupport')}
                                        onCheckedChange={(checked) => tierForm.setValue('prioritySupport', checked)}
                                    />
                                </div>
                                <div className="flex items-center justify-between">
                                    <Label htmlFor="earlyAccess" className="cursor-pointer">وصول مبكر</Label>
                                    <Switch
                                        id="earlyAccess"
                                        checked={tierForm.watch('earlyAccess')}
                                        onCheckedChange={(checked) => tierForm.setValue('earlyAccess', checked)}
                                    />
                                </div>
                            </div>
                        </div>
                        <div className="flex items-center space-x-2 space-x-reverse">
                            <Switch
                                id="isActive"
                                checked={tierForm.watch('isActive')}
                                onCheckedChange={(checked) => tierForm.setValue('isActive', checked)}
                            />
                            <Label htmlFor="isActive" className="cursor-pointer">نشط</Label>
                        </div>
                        <DialogFooter>
                            <Button
                                type="button"
                                variant="outline"
                                onClick={() => {
                                    setIsCreateTierDialogOpen(false);
                                    setIsEditTierDialogOpen(false);
                                    setSelectedTier(null);
                                    tierForm.reset();
                                }}
                            >
                                إلغاء
                            </Button>
                            <Button
                                type="submit"
                                disabled={createTierMutation.isPending || updateTierMutation.isPending}
                                className="bg-green-600 hover:bg-green-700"
                            >
                                {(createTierMutation.isPending || updateTierMutation.isPending) && (
                                    <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                                )}
                                {selectedTier ? 'تحديث' : 'إنشاء'}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Delete Tier Confirmation Dialog */}
            <Dialog open={isDeleteTierDialogOpen} onOpenChange={setIsDeleteTierDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>تأكيد الحذف</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4">
                        <p className="text-sm text-muted-foreground">
                            هل أنت متأكد من حذف المستوى <strong>{selectedTier?.name}</strong>؟
                            <br />
                            سيتم تعطيل المستوى بدلاً من حذفه نهائياً.
                        </p>
                    </div>
                    <DialogFooter>
                        <Button
                            type="button"
                            variant="outline"
                            onClick={() => {
                                setIsDeleteTierDialogOpen(false);
                                setSelectedTier(null);
                            }}
                        >
                            إلغاء
                        </Button>
                        <Button
                            type="button"
                            variant="destructive"
                            onClick={onDeleteTierConfirm}
                            disabled={deleteTierMutation.isPending}
                        >
                            {deleteTierMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                            حذف
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}

export default WalletPage;
