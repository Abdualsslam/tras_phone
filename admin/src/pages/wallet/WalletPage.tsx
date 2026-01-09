import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { walletApi } from '@/api/wallet.api';
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
} from 'lucide-react';
import { formatCurrency, formatDate } from '@/lib/utils';

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function WalletPage() {
    const queryClient = useQueryClient();

    const [selectedCustomerId, setSelectedCustomerId] = useState<string>('');
    const [isCreditDialogOpen, setIsCreditDialogOpen] = useState(false);
    const [isDebitDialogOpen, setIsDebitDialogOpen] = useState(false);
    const [isPointsDialogOpen, setIsPointsDialogOpen] = useState(false);

    // ─────────────────────────────────────────
    // Queries
    // ─────────────────────────────────────────

    const { data: tiers = [], isLoading: tiersLoading } = useQuery({
        queryKey: ['wallet-tiers'],
        queryFn: () => walletApi.getTiers(),
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

            {/* Customer Search */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <Search className="h-5 w-5" />
                        البحث عن عميل
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="flex gap-4">
                        <div className="flex-1">
                            <Input
                                placeholder="أدخل معرف العميل..."
                                value={selectedCustomerId}
                                onChange={(e) => setSelectedCustomerId(e.target.value)}
                            />
                        </div>
                        <Button onClick={() => { }} disabled={!selectedCustomerId}>
                            <Search className="h-4 w-4 ml-2" />
                            بحث
                        </Button>
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

            {/* Loyalty Tiers */}
            <Card>
                <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                        <Star className="h-5 w-5" />
                        مستويات الولاء
                    </CardTitle>
                </CardHeader>
                <CardContent>
                    {tiersLoading ? (
                        <div className="flex justify-center items-center h-40">
                            <Loader2 className="h-8 w-8 animate-spin text-primary" />
                        </div>
                    ) : tiers.length === 0 ? (
                        <div className="text-center py-12 text-muted-foreground">
                            <Star className="h-12 w-12 mx-auto mb-4 opacity-50" />
                            <p>لا توجد مستويات</p>
                        </div>
                    ) : (
                        <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-4">
                            {tiers.map((tier) => (
                                <Card key={tier._id} className="border-2">
                                    <CardContent className="p-4 text-center">
                                        <Star className="h-8 w-8 mx-auto mb-2 text-yellow-500" />
                                        <h3 className="font-bold text-lg">{tier.name}</h3>
                                        {tier.nameAr && (
                                            <p className="text-sm text-muted-foreground">{tier.nameAr}</p>
                                        )}
                                        <p className="text-sm mt-2">
                                            {tier.minPoints.toLocaleString()} - {tier.maxPoints ? tier.maxPoints.toLocaleString() : '∞'} نقطة
                                        </p>
                                        <Badge variant="outline" className="mt-2">
                                            مضاعف x{tier.multiplier}
                                        </Badge>
                                    </CardContent>
                                </Card>
                            ))}
                        </div>
                    )}
                </CardContent>
            </Card>

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
        </div>
    );
}

export default WalletPage;
