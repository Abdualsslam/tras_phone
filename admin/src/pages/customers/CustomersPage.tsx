import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { customersApi } from '@/api/customers.api';
import type { Customer } from '@/types';
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
    Eye,
    CheckCircle,
    XCircle,
    Loader2,
    AlertCircle,
    Building2,
} from 'lucide-react';
import { formatDate } from '@/lib/utils';

const statusVariants: Record<string, 'success' | 'warning' | 'danger' | 'default'> = {
    approved: 'success',
    pending: 'warning',
    rejected: 'danger',
    suspended: 'danger',
};

const statusLabels: Record<string, string> = {
    approved: 'معتمد',
    pending: 'قيد الانتظار',
    rejected: 'مرفوض',
    suspended: 'موقوف',
};

export function CustomersPage() {
    const { t, i18n } = useTranslation();
    const queryClient = useQueryClient();
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState('');
    const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(null);
    const [isDetailsDialogOpen, setIsDetailsDialogOpen] = useState(false);
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    // Fetch customers
    const { data, isLoading, error } = useQuery({
        queryKey: ['customers', searchQuery, statusFilter],
        queryFn: () => customersApi.getAll({ search: searchQuery, status: statusFilter, limit: 20 }),
    });

    // Approve mutation
    const approveMutation = useMutation({
        mutationFn: (id: string) => customersApi.approve(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['customers'] });
        },
    });

    // Reject mutation
    const rejectMutation = useMutation({
        mutationFn: (id: string) => customersApi.reject(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['customers'] });
        },
    });

    const handleViewDetails = (customer: Customer) => {
        setSelectedCustomer(customer);
        setIsDetailsDialogOpen(true);
    };

    const customers = data?.items || [];

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">{t('customers.title')}</h1>
                    <p className="text-gray-500 mt-1">إدارة العملاء وطلبات التسجيل</p>
                </div>
                <Button>
                    <Plus className="h-4 w-4" />
                    {t('customers.addCustomer')}
                </Button>
            </div>

            {/* Search and Filters */}
            <Card>
                <CardContent className="p-4">
                    <div className="flex flex-col sm:flex-row gap-4">
                        <div className="relative flex-1">
                            <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                            <Input
                                placeholder="البحث عن عميل..."
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
                            <option value="pending">قيد الانتظار</option>
                            <option value="approved">معتمد</option>
                            <option value="rejected">مرفوض</option>
                            <option value="suspended">موقوف</option>
                        </select>
                    </div>
                </CardContent>
            </Card>

            {/* Table */}
            <Card>
                <CardHeader className="flex flex-row items-center gap-2 pb-4">
                    <Building2 className="h-5 w-5 text-gray-500" />
                    <CardTitle className="text-lg">قائمة العملاء</CardTitle>
                    {data && (
                        <Badge variant="secondary" className="ms-auto">
                            {data.pagination?.total || customers.length} عميل
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
                    ) : customers.length === 0 ? (
                        <div className="flex flex-col items-center justify-center py-12 text-gray-500">
                            <Building2 className="h-12 w-12 mb-4 text-gray-300" />
                            <p>{t('common.noData')}</p>
                        </div>
                    ) : (
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>{t('customers.companyName')}</TableHead>
                                    <TableHead>{t('customers.contactName')}</TableHead>
                                    <TableHead>{t('customers.phone')}</TableHead>
                                    <TableHead>{t('customers.status')}</TableHead>
                                    <TableHead>تاريخ التسجيل</TableHead>
                                    <TableHead className="w-[50px]"></TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {customers.map((customer) => (
                                    <TableRow key={customer._id}>
                                        <TableCell className="font-medium text-gray-900">
                                            {customer.companyName}
                                        </TableCell>
                                        <TableCell className="text-gray-600">{customer.contactName}</TableCell>
                                        <TableCell className="text-gray-600" dir="ltr">
                                            {customer.phone}
                                        </TableCell>
                                        <TableCell>
                                            <Badge variant={statusVariants[customer.status]}>
                                                {statusLabels[customer.status]}
                                            </Badge>
                                        </TableCell>
                                        <TableCell className="text-gray-500 text-sm">
                                            {formatDate(customer.createdAt, locale)}
                                        </TableCell>
                                        <TableCell>
                                            <DropdownMenu>
                                                <DropdownMenuTrigger asChild>
                                                    <Button variant="ghost" size="icon">
                                                        <MoreHorizontal className="h-4 w-4" />
                                                    </Button>
                                                </DropdownMenuTrigger>
                                                <DropdownMenuContent align="end">
                                                    <DropdownMenuItem onClick={() => handleViewDetails(customer)}>
                                                        <Eye className="h-4 w-4" />
                                                        عرض التفاصيل
                                                    </DropdownMenuItem>
                                                    {customer.status === 'pending' && (
                                                        <>
                                                            <DropdownMenuSeparator />
                                                            <DropdownMenuItem
                                                                className="text-green-600"
                                                                onClick={() => approveMutation.mutate(customer._id)}
                                                            >
                                                                <CheckCircle className="h-4 w-4" />
                                                                قبول
                                                            </DropdownMenuItem>
                                                            <DropdownMenuItem
                                                                className="text-red-600"
                                                                onClick={() => rejectMutation.mutate(customer._id)}
                                                            >
                                                                <XCircle className="h-4 w-4" />
                                                                رفض
                                                            </DropdownMenuItem>
                                                        </>
                                                    )}
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

            {/* Customer Details Dialog */}
            <Dialog open={isDetailsDialogOpen} onOpenChange={setIsDetailsDialogOpen}>
                <DialogContent className="max-w-lg">
                    <DialogHeader>
                        <DialogTitle>{t('customers.customerDetails')}</DialogTitle>
                        <DialogDescription>معلومات العميل الكاملة</DialogDescription>
                    </DialogHeader>
                    {selectedCustomer && (
                        <div className="space-y-4">
                            <div className="grid grid-cols-2 gap-4">
                                <div>
                                    <p className="text-sm text-gray-500">{t('customers.companyName')}</p>
                                    <p className="font-medium">{selectedCustomer.companyName}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-gray-500">{t('customers.contactName')}</p>
                                    <p className="font-medium">{selectedCustomer.contactName}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-gray-500">{t('customers.email')}</p>
                                    <p className="font-medium">{selectedCustomer.email}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-gray-500">{t('customers.phone')}</p>
                                    <p className="font-medium" dir="ltr">{selectedCustomer.phone}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-gray-500">{t('customers.status')}</p>
                                    <Badge variant={statusVariants[selectedCustomer.status]}>
                                        {statusLabels[selectedCustomer.status]}
                                    </Badge>
                                </div>
                                <div>
                                    <p className="text-sm text-gray-500">السجل التجاري</p>
                                    <p className="font-medium">{selectedCustomer.commercialRegister || '-'}</p>
                                </div>
                            </div>
                            {selectedCustomer.address && (
                                <div>
                                    <p className="text-sm text-gray-500 mb-1">العنوان</p>
                                    <p className="font-medium">
                                        {[
                                            selectedCustomer.address.street,
                                            selectedCustomer.address.city,
                                            selectedCustomer.address.state,
                                            selectedCustomer.address.country,
                                        ]
                                            .filter(Boolean)
                                            .join('، ') || '-'}
                                    </p>
                                </div>
                            )}
                        </div>
                    )}
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsDetailsDialogOpen(false)}>
                            إغلاق
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
