import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supportApi, type TicketCategory, type CannedResponse } from '@/api/support.api';
import type { Ticket } from '@/types';
import { useSocket } from '@/hooks/useSocket';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Switch } from '@/components/ui/switch';
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
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
import {
    HeadphonesIcon,
    Clock,
    CheckCircle,
    AlertCircle,
    User,
    Send,
    Loader2,
    Plus,
    FolderOpen,
    MessageSquare,
    MoreHorizontal,
    Pencil,
    Trash2,
    Copy,
} from 'lucide-react';
import { getInitials, formatDate } from '@/lib/utils';

const statusLabels: Record<string, string> = {
    open: 'مفتوح',
    in_progress: 'قيد المعالجة',
    resolved: 'محلول',
    closed: 'مغلق',
};

const statusVariants: Record<string, 'warning' | 'default' | 'success'> = {
    open: 'warning',
    in_progress: 'default',
    resolved: 'success',
    closed: 'success',
};

const priorityLabels: Record<string, string> = {
    low: 'منخفض',
    medium: 'متوسط',
    high: 'عالي',
    urgent: 'عاجل',
};

const priorityColors: Record<string, string> = {
    low: 'text-gray-500',
    medium: 'text-blue-500',
    high: 'text-orange-500',
    urgent: 'text-red-500',
};

export function SupportPage() {
    const { t, i18n } = useTranslation();
    const queryClient = useQueryClient();
    const { joinTicket, leaveTicket, on } = useSocket();
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    const [selectedTicket, setSelectedTicket] = useState<Ticket | null>(null);
    const [replyContent, setReplyContent] = useState('');
    const [isCategoryDialogOpen, setIsCategoryDialogOpen] = useState(false);
    const [isCannedDialogOpen, setIsCannedDialogOpen] = useState(false);
    const [editingCategory, setEditingCategory] = useState<TicketCategory | null>(null);
    const [editingCanned, setEditingCanned] = useState<CannedResponse | null>(null);

    const [categoryForm, setCategoryForm] = useState({
        name: '',
        nameAr: '',
        description: '',
        isActive: true,
        order: 0,
    });

    const [cannedForm, setCannedForm] = useState({
        title: '',
        content: '',
        isActive: true,
    });

    // Join/leave ticket room for real-time updates
    useEffect(() => {
        if (!selectedTicket?._id) return;
        joinTicket(selectedTicket._id);
        return () => leaveTicket(selectedTicket._id);
    }, [selectedTicket?._id, joinTicket, leaveTicket]);

    // WebSocket: real-time ticket events
    useEffect(() => {
        const unsubCreated = on('ticket:created', () => {
            queryClient.invalidateQueries({ queryKey: ['tickets'] });
            queryClient.invalidateQueries({ queryKey: ['support-stats'] });
        });
        const unsubCreatedAdmin = on('ticket:created:admin', () => {
            queryClient.invalidateQueries({ queryKey: ['tickets'] });
            queryClient.invalidateQueries({ queryKey: ['support-stats'] });
        });
        const unsubUpdated = on('ticket:updated', () => {
            queryClient.invalidateQueries({ queryKey: ['tickets'] });
            queryClient.invalidateQueries({ queryKey: ['support-stats'] });
        });
        const unsubMessage = on('ticket:message', () => {
            queryClient.invalidateQueries({ queryKey: ['tickets'] });
        });
        const unsubAssigned = on('ticket:assigned', () => {
            queryClient.invalidateQueries({ queryKey: ['tickets'] });
            queryClient.invalidateQueries({ queryKey: ['support-stats'] });
        });
        return () => {
            unsubCreated();
            unsubCreatedAdmin();
            unsubUpdated();
            unsubMessage();
            unsubAssigned();
        };
    }, [selectedTicket?._id, on, queryClient]);

    // Queries
    const { data: ticketsData, isLoading } = useQuery({
        queryKey: ['tickets'],
        queryFn: () => supportApi.getAllTickets({ limit: 50 }),
    });

    const { data: stats } = useQuery({
        queryKey: ['support-stats'],
        queryFn: supportApi.getStats,
    });

    const { data: categoriesData, isLoading: categoriesLoading } = useQuery<TicketCategory[] | unknown>({
        queryKey: ['ticket-categories'],
        queryFn: supportApi.getCategories,
    });
    const categories = Array.isArray(categoriesData) ? categoriesData : [];

    const { data: cannedResponsesData, isLoading: cannedLoading } = useQuery<CannedResponse[] | unknown>({
        queryKey: ['canned-responses'],
        queryFn: supportApi.getCannedResponses,
    });
    const cannedResponses = Array.isArray(cannedResponsesData) ? cannedResponsesData : [];

    // Mutations
    const replyMutation = useMutation({
        mutationFn: ({ ticketId, content }: { ticketId: string; content: string }) =>
            supportApi.replyToTicket(ticketId, { content }),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['tickets'] });
            setReplyContent('');
        },
    });

    const createCategoryMutation = useMutation({
        mutationFn: (data: any) => supportApi.createCategory(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['ticket-categories'] });
            setIsCategoryDialogOpen(false);
            resetCategoryForm();
        },
    });

    const updateCategoryMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: any }) => supportApi.updateCategory(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['ticket-categories'] });
            setIsCategoryDialogOpen(false);
            resetCategoryForm();
        },
    });

    const deleteCategoryMutation = useMutation({
        mutationFn: supportApi.deleteCategory,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['ticket-categories'] });
        },
    });

    const createCannedMutation = useMutation({
        mutationFn: (data: any) => supportApi.createCannedResponse(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['canned-responses'] });
            setIsCannedDialogOpen(false);
            resetCannedForm();
        },
    });

    const updateCannedMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: any }) => supportApi.updateCannedResponse(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['canned-responses'] });
            setIsCannedDialogOpen(false);
            resetCannedForm();
        },
    });

    const deleteCannedMutation = useMutation({
        mutationFn: supportApi.deleteCannedResponse,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['canned-responses'] });
        },
    });

    // Handlers
    const handleReply = () => {
        if (selectedTicket && replyContent.trim()) {
            replyMutation.mutate({ ticketId: selectedTicket._id, content: replyContent });
        }
    };

    const resetCategoryForm = () => {
        setEditingCategory(null);
        setCategoryForm({ name: '', nameAr: '', description: '', isActive: true, order: 0 });
    };

    const resetCannedForm = () => {
        setEditingCanned(null);
        setCannedForm({ title: '', content: '', isActive: true });
    };

    const handleOpenCategoryCreate = () => {
        resetCategoryForm();
        setIsCategoryDialogOpen(true);
    };

    const handleOpenCategoryEdit = (category: TicketCategory) => {
        setEditingCategory(category);
        setCategoryForm({
            name: category.name,
            nameAr: category.nameAr || '',
            description: category.description || '',
            isActive: category.isActive,
            order: category.order,
        });
        setIsCategoryDialogOpen(true);
    };

    const handleSubmitCategory = () => {
        if (!categoryForm.name) return;
        if (editingCategory) {
            updateCategoryMutation.mutate({ id: editingCategory._id, data: categoryForm });
        } else {
            createCategoryMutation.mutate(categoryForm);
        }
    };

    const handleOpenCannedCreate = () => {
        resetCannedForm();
        setIsCannedDialogOpen(true);
    };

    const handleOpenCannedEdit = (canned: CannedResponse) => {
        setEditingCanned(canned);
        setCannedForm({
            title: canned.title,
            content: canned.content,
            isActive: canned.isActive,
        });
        setIsCannedDialogOpen(true);
    };

    const handleSubmitCanned = () => {
        if (!cannedForm.title || !cannedForm.content) return;
        if (editingCanned) {
            updateCannedMutation.mutate({ id: editingCanned._id, data: cannedForm });
        } else {
            createCannedMutation.mutate(cannedForm);
        }
    };

    const handleUseCannedResponse = (canned: CannedResponse) => {
        setReplyContent(canned.content);
    };

    const tickets = Array.isArray(ticketsData?.items) ? ticketsData.items : (Array.isArray((ticketsData as any)?.tickets) ? (ticketsData as any).tickets : []);

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t('sidebar.support')}</h1>
                    <p className="text-gray-500 dark:text-gray-400 mt-1">إدارة تذاكر الدعم الفني</p>
                </div>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-yellow-100 dark:bg-yellow-900/30 rounded-xl">
                            <AlertCircle className="h-5 w-5 text-yellow-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{stats?.open || 0}</p>
                            <p className="text-sm text-gray-500">مفتوح</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-blue-100 dark:bg-blue-900/30 rounded-xl">
                            <Clock className="h-5 w-5 text-blue-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{stats?.inProgress || 0}</p>
                            <p className="text-sm text-gray-500">قيد المعالجة</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-green-100 dark:bg-green-900/30 rounded-xl">
                            <CheckCircle className="h-5 w-5 text-green-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{stats?.resolved || 0}</p>
                            <p className="text-sm text-gray-500">محلول</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-purple-100 dark:bg-purple-900/30 rounded-xl">
                            <HeadphonesIcon className="h-5 w-5 text-purple-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{stats?.avgResponseTime || 0} د</p>
                            <p className="text-sm text-gray-500">متوسط الرد</p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Tabs */}
            <Tabs defaultValue="tickets" className="w-full">
                <TabsList>
                    <TabsTrigger value="tickets" className="gap-2">
                        <HeadphonesIcon className="h-4 w-4" />
                        التذاكر
                    </TabsTrigger>
                    <TabsTrigger value="categories" className="gap-2">
                        <FolderOpen className="h-4 w-4" />
                        الفئات
                    </TabsTrigger>
                    <TabsTrigger value="canned" className="gap-2">
                        <MessageSquare className="h-4 w-4" />
                        الردود الجاهزة
                    </TabsTrigger>
                </TabsList>

                {/* Tickets Tab */}
                <TabsContent value="tickets" className="mt-4">
                    <div className="grid lg:grid-cols-3 gap-6">
                        {/* Tickets List */}
                        <div className="lg:col-span-2 space-y-4">
                            <Card>
                                <CardHeader className="pb-4">
                                    <CardTitle className="text-lg">التذاكر</CardTitle>
                                </CardHeader>
                                <CardContent className="p-0">
                                    {isLoading ? (
                                        <div className="flex items-center justify-center py-12">
                                            <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                                        </div>
                                    ) : (
                                        <div className="divide-y dark:divide-slate-700">
                                            {tickets.map((ticket: Ticket) => (
                                                <div
                                                    key={ticket._id}
                                                    onClick={() => setSelectedTicket(ticket)}
                                                    className={`p-4 cursor-pointer hover:bg-gray-50 dark:hover:bg-slate-800 transition-colors ${selectedTicket?._id === ticket._id ? 'bg-primary-50 dark:bg-primary-900/20' : ''}`}
                                                >
                                                    <div className="flex items-start gap-3">
                                                        <Avatar>
                                                            <AvatarFallback>{getInitials((ticket.customer as any)?.companyName ?? (ticket.customer as any)?.name ?? 'عميل')}</AvatarFallback>
                                                        </Avatar>
                                                        <div className="flex-1 min-w-0">
                                                            <div className="flex items-center gap-2">
                                                                <span className="font-medium text-gray-900 dark:text-gray-100">{ticket.ticketNumber}</span>
                                                                <Badge variant={statusVariants[ticket.status]}>
                                                                    {statusLabels[ticket.status]}
                                                                </Badge>
                                                                <span className={`text-xs ${priorityColors[ticket.priority]}`}>
                                                                    ● {priorityLabels[ticket.priority]}
                                                                </span>
                                                            </div>
                                                            <p className="text-sm text-gray-900 dark:text-gray-100 mt-1 truncate">{ticket.subject}</p>
                                                            <div className="flex items-center gap-3 mt-2 text-xs text-gray-500">
                                                                <span>{(ticket.customer as any)?.companyName ?? (ticket.customer as any)?.name ?? '-'}</span>
                                                                <span>{formatDate(ticket.createdAt, locale)}</span>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            ))}
                                            {tickets.length === 0 && (
                                                <div className="py-12 text-center text-gray-500">
                                                    لا توجد تذاكر
                                                </div>
                                            )}
                                        </div>
                                    )}
                                </CardContent>
                            </Card>
                        </div>

                        {/* Quick Reply */}
                        <div className="space-y-4">
                            <Card>
                                <CardHeader className="pb-4">
                                    <CardTitle className="text-lg">رد سريع</CardTitle>
                                </CardHeader>
                                <CardContent>
                                    {selectedTicket ? (
                                        <div className="space-y-4">
                                            <div>
                                                <p className="text-sm text-gray-500">التذكرة</p>
                                                <p className="font-medium">{selectedTicket.ticketNumber}</p>
                                            </div>
                                            <div>
                                                <p className="text-sm text-gray-500">الموضوع</p>
                                                <p className="font-medium">{selectedTicket.subject}</p>
                                            </div>
                                            <Textarea
                                                placeholder="اكتب ردك هنا..."
                                                value={replyContent}
                                                onChange={(e) => setReplyContent(e.target.value)}
                                                className="h-32"
                                            />
                                            <Button
                                                className="w-full"
                                                onClick={handleReply}
                                                disabled={!replyContent.trim() || replyMutation.isPending}
                                            >
                                                {replyMutation.isPending ? (
                                                    <Loader2 className="h-4 w-4 animate-spin" />
                                                ) : (
                                                    <Send className="h-4 w-4" />
                                                )}
                                                إرسال الرد
                                            </Button>
                                        </div>
                                    ) : (
                                        <div className="text-center py-8 text-gray-500">
                                            <User className="h-12 w-12 mx-auto mb-2 text-gray-300" />
                                            <p>اختر تذكرة للرد عليها</p>
                                        </div>
                                    )}
                                </CardContent>
                            </Card>

                            {/* Quick Canned Responses */}
                            {selectedTicket && cannedResponses.length > 0 && (
                                <Card>
                                    <CardHeader className="pb-2">
                                        <CardTitle className="text-sm">ردود جاهزة</CardTitle>
                                    </CardHeader>
                                    <CardContent className="space-y-2">
                                        {cannedResponses.slice(0, 5).map((canned) => (
                                            <Button
                                                key={canned._id}
                                                variant="outline"
                                                size="sm"
                                                className="w-full justify-start text-start h-auto py-2"
                                                onClick={() => handleUseCannedResponse(canned)}
                                            >
                                                <Copy className="h-3 w-3 shrink-0" />
                                                <span className="truncate">{canned.title}</span>
                                            </Button>
                                        ))}
                                    </CardContent>
                                </Card>
                            )}
                        </div>
                    </div>
                </TabsContent>

                {/* Categories Tab */}
                <TabsContent value="categories" className="mt-4">
                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between">
                            <CardTitle className="flex items-center gap-2">
                                <FolderOpen className="h-5 w-5" />
                                فئات التذاكر
                            </CardTitle>
                            <Button onClick={handleOpenCategoryCreate}>
                                <Plus className="h-4 w-4" />
                                إضافة فئة
                            </Button>
                        </CardHeader>
                        <CardContent className="p-0">
                            {categoriesLoading ? (
                                <div className="flex items-center justify-center py-12">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                                </div>
                            ) : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>الاسم</TableHead>
                                            <TableHead>الوصف</TableHead>
                                            <TableHead>الترتيب</TableHead>
                                            <TableHead>الحالة</TableHead>
                                            <TableHead className="w-12"></TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {categories.map((category) => (
                                            <TableRow key={category._id}>
                                                <TableCell>
                                                    <div>
                                                        <p className="font-medium">{category.nameAr || category.name}</p>
                                                        <p className="text-xs text-gray-500">{category.name}</p>
                                                    </div>
                                                </TableCell>
                                                <TableCell className="text-gray-500 text-sm">{category.description || '-'}</TableCell>
                                                <TableCell>{category.order}</TableCell>
                                                <TableCell>
                                                    <Badge variant={category.isActive ? 'success' : 'default'}>
                                                        {category.isActive ? 'نشط' : 'غير نشط'}
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
                                                            <DropdownMenuItem onClick={() => handleOpenCategoryEdit(category)}>
                                                                <Pencil className="h-4 w-4" />
                                                                تعديل
                                                            </DropdownMenuItem>
                                                            <DropdownMenuItem
                                                                className="text-red-600"
                                                                onClick={() => deleteCategoryMutation.mutate(category._id)}
                                                            >
                                                                <Trash2 className="h-4 w-4" />
                                                                حذف
                                                            </DropdownMenuItem>
                                                        </DropdownMenuContent>
                                                    </DropdownMenu>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                        {categories.length === 0 && (
                                            <TableRow>
                                                <TableCell colSpan={5} className="text-center py-8 text-gray-500">
                                                    لا توجد فئات
                                                </TableCell>
                                            </TableRow>
                                        )}
                                    </TableBody>
                                </Table>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Canned Responses Tab */}
                <TabsContent value="canned" className="mt-4">
                    <Card>
                        <CardHeader className="flex flex-row items-center justify-between">
                            <CardTitle className="flex items-center gap-2">
                                <MessageSquare className="h-5 w-5" />
                                الردود الجاهزة
                            </CardTitle>
                            <Button onClick={handleOpenCannedCreate}>
                                <Plus className="h-4 w-4" />
                                إضافة رد جاهز
                            </Button>
                        </CardHeader>
                        <CardContent className="p-0">
                            {cannedLoading ? (
                                <div className="flex items-center justify-center py-12">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                                </div>
                            ) : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>العنوان</TableHead>
                                            <TableHead>المحتوى</TableHead>
                                            <TableHead>الاستخدام</TableHead>
                                            <TableHead>الحالة</TableHead>
                                            <TableHead className="w-12"></TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {cannedResponses.map((canned) => (
                                            <TableRow key={canned._id}>
                                                <TableCell className="font-medium">{canned.title}</TableCell>
                                                <TableCell className="text-gray-500 text-sm max-w-[300px] truncate">{canned.content}</TableCell>
                                                <TableCell>
                                                    <Badge variant="secondary">{canned.usageCount || 0} مرة</Badge>
                                                </TableCell>
                                                <TableCell>
                                                    <Badge variant={canned.isActive ? 'success' : 'default'}>
                                                        {canned.isActive ? 'نشط' : 'غير نشط'}
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
                                                            <DropdownMenuItem onClick={() => handleOpenCannedEdit(canned)}>
                                                                <Pencil className="h-4 w-4" />
                                                                تعديل
                                                            </DropdownMenuItem>
                                                            <DropdownMenuItem
                                                                className="text-red-600"
                                                                onClick={() => deleteCannedMutation.mutate(canned._id)}
                                                            >
                                                                <Trash2 className="h-4 w-4" />
                                                                حذف
                                                            </DropdownMenuItem>
                                                        </DropdownMenuContent>
                                                    </DropdownMenu>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                        {cannedResponses.length === 0 && (
                                            <TableRow>
                                                <TableCell colSpan={5} className="text-center py-8 text-gray-500">
                                                    لا توجد ردود جاهزة
                                                </TableCell>
                                            </TableRow>
                                        )}
                                    </TableBody>
                                </Table>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>

            {/* Category Dialog */}
            <Dialog open={isCategoryDialogOpen} onOpenChange={setIsCategoryDialogOpen}>
                <DialogContent className="max-w-md">
                    <DialogHeader>
                        <DialogTitle>{editingCategory ? 'تعديل الفئة' : 'إضافة فئة جديدة'}</DialogTitle>
                        <DialogDescription>أدخل بيانات الفئة</DialogDescription>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="space-y-2">
                            <Label>الاسم (EN) <span className="text-red-500">*</span></Label>
                            <Input
                                dir="ltr"
                                value={categoryForm.name}
                                onChange={(e) => setCategoryForm({ ...categoryForm, name: e.target.value })}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label>الاسم (AR)</Label>
                            <Input
                                value={categoryForm.nameAr}
                                onChange={(e) => setCategoryForm({ ...categoryForm, nameAr: e.target.value })}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label>الوصف</Label>
                            <Textarea
                                value={categoryForm.description}
                                onChange={(e) => setCategoryForm({ ...categoryForm, description: e.target.value })}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label>الترتيب</Label>
                            <Input
                                type="number"
                                value={categoryForm.order}
                                onChange={(e) => setCategoryForm({ ...categoryForm, order: parseInt(e.target.value) || 0 })}
                            />
                        </div>
                        <div className="flex items-center gap-2">
                            <Switch
                                checked={categoryForm.isActive}
                                onCheckedChange={(checked) => setCategoryForm({ ...categoryForm, isActive: checked })}
                            />
                            <Label>نشط</Label>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsCategoryDialogOpen(false)}>إلغاء</Button>
                        <Button
                            onClick={handleSubmitCategory}
                            disabled={!categoryForm.name || createCategoryMutation.isPending || updateCategoryMutation.isPending}
                        >
                            {(createCategoryMutation.isPending || updateCategoryMutation.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}
                            {editingCategory ? 'حفظ' : 'إضافة'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>

            {/* Canned Response Dialog */}
            <Dialog open={isCannedDialogOpen} onOpenChange={setIsCannedDialogOpen}>
                <DialogContent className="max-w-md">
                    <DialogHeader>
                        <DialogTitle>{editingCanned ? 'تعديل الرد' : 'إضافة رد جاهز'}</DialogTitle>
                        <DialogDescription>أدخل بيانات الرد الجاهز</DialogDescription>
                    </DialogHeader>
                    <div className="space-y-4 py-4">
                        <div className="space-y-2">
                            <Label>العنوان <span className="text-red-500">*</span></Label>
                            <Input
                                value={cannedForm.title}
                                onChange={(e) => setCannedForm({ ...cannedForm, title: e.target.value })}
                            />
                        </div>
                        <div className="space-y-2">
                            <Label>المحتوى <span className="text-red-500">*</span></Label>
                            <Textarea
                                value={cannedForm.content}
                                onChange={(e) => setCannedForm({ ...cannedForm, content: e.target.value })}
                                className="h-32"
                            />
                        </div>
                        <div className="flex items-center gap-2">
                            <Switch
                                checked={cannedForm.isActive}
                                onCheckedChange={(checked) => setCannedForm({ ...cannedForm, isActive: checked })}
                            />
                            <Label>نشط</Label>
                        </div>
                    </div>
                    <DialogFooter>
                        <Button variant="outline" onClick={() => setIsCannedDialogOpen(false)}>إلغاء</Button>
                        <Button
                            onClick={handleSubmitCanned}
                            disabled={!cannedForm.title || !cannedForm.content || createCannedMutation.isPending || updateCannedMutation.isPending}
                        >
                            {(createCannedMutation.isPending || updateCannedMutation.isPending) && <Loader2 className="h-4 w-4 animate-spin" />}
                            {editingCanned ? 'حفظ' : 'إضافة'}
                        </Button>
                    </DialogFooter>
                </DialogContent>
            </Dialog>
        </div>
    );
}
