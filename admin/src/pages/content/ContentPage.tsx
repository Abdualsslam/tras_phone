import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import { contentApi, type Page, type Banner } from '@/api/content.api';
import { toast } from 'sonner';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
    Plus,
    MoreHorizontal,
    Pencil,
    Trash2,
    Loader2,
    FileText,
    Image,
    HelpCircle,
    Star,
    MessageSquare,
    CheckCircle,
    Eye,
} from 'lucide-react';
import { formatDate } from '@/lib/utils';

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function ContentPage() {
    const queryClient = useQueryClient();

    const [activeTab, setActiveTab] = useState('pages');
    const [isPageDialogOpen, setIsPageDialogOpen] = useState(false);
    const [isBannerDialogOpen, setIsBannerDialogOpen] = useState(false);
    const [selectedItem, setSelectedItem] = useState<any>(null);
    const [isEditing, setIsEditing] = useState(false);

    // ─────────────────────────────────────────
    // Queries
    // ─────────────────────────────────────────

    const { data: pages = [], isLoading: pagesLoading } = useQuery({
        queryKey: ['content-pages'],
        queryFn: () => contentApi.getPages(),
    });

    const { data: banners = [], isLoading: bannersLoading } = useQuery({
        queryKey: ['content-banners'],
        queryFn: () => contentApi.getBanners(),
    });

    const { data: faqs = [], isLoading: faqsLoading } = useQuery({
        queryKey: ['content-faqs'],
        queryFn: () => contentApi.getFaqs(),
    });

    const { data: testimonials = [], isLoading: testimonialsLoading } = useQuery({
        queryKey: ['content-testimonials'],
        queryFn: () => contentApi.getTestimonials(),
    });

    // ─────────────────────────────────────────
    // Mutations
    // ─────────────────────────────────────────

    const createPageMutation = useMutation({
        mutationFn: (data: any) => contentApi.createPage(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['content-pages'] });
            setIsPageDialogOpen(false);
            toast.success('تم إنشاء الصفحة بنجاح');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const updatePageMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: any }) => contentApi.updatePage(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['content-pages'] });
            setIsPageDialogOpen(false);
            setSelectedItem(null);
            toast.success('تم تحديث الصفحة بنجاح');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const deletePageMutation = useMutation({
        mutationFn: (id: string) => contentApi.deletePage(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['content-pages'] });
            toast.success('تم حذف الصفحة');
        },
    });

    const createBannerMutation = useMutation({
        mutationFn: (data: any) => contentApi.createBanner(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['content-banners'] });
            setIsBannerDialogOpen(false);
            toast.success('تم إنشاء البنر بنجاح');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const updateBannerMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: any }) => contentApi.updateBanner(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['content-banners'] });
            setIsBannerDialogOpen(false);
            setSelectedItem(null);
            toast.success('تم تحديث البنر بنجاح');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const deleteBannerMutation = useMutation({
        mutationFn: (id: string) => contentApi.deleteBanner(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['content-banners'] });
            toast.success('تم حذف البنر');
        },
    });

    const approveTestimonialMutation = useMutation({
        mutationFn: (id: string) => contentApi.approveTestimonial(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['content-testimonials'] });
            toast.success('تم الموافقة على الشهادة');
        },
    });

    const deleteTestimonialMutation = useMutation({
        mutationFn: (id: string) => contentApi.deleteTestimonial(id),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['content-testimonials'] });
            toast.success('تم حذف الشهادة');
        },
    });

    // ─────────────────────────────────────────
    // Forms
    // ─────────────────────────────────────────

    const pageForm = useForm({
        defaultValues: {
            title: '',
            titleAr: '',
            slug: '',
            content: '',
            contentAr: '',
            type: 'other' as const,
            isActive: true,
        },
    });

    const bannerForm = useForm({
        defaultValues: {
            title: '',
            titleAr: '',
            imageUrl: '',
            linkUrl: '',
            position: 'home',
            order: 0,
            isActive: true,
        },
    });

    // ─────────────────────────────────────────
    // Handlers
    // ─────────────────────────────────────────

    const handleAddPage = () => {
        setIsEditing(false);
        setSelectedItem(null);
        pageForm.reset({ title: '', titleAr: '', slug: '', content: '', contentAr: '', type: 'other', isActive: true });
        setIsPageDialogOpen(true);
    };

    const handleEditPage = (page: Page) => {
        setIsEditing(true);
        setSelectedItem(page);
        pageForm.reset({
            title: page.title,
            titleAr: page.titleAr || '',
            slug: page.slug,
            content: page.content,
            contentAr: page.contentAr || '',
            type: 'other' as const,
            isActive: page.isActive,
        });
        setIsPageDialogOpen(true);
    };

    const handleAddBanner = () => {
        setIsEditing(false);
        setSelectedItem(null);
        bannerForm.reset({ title: '', titleAr: '', imageUrl: '', linkUrl: '', position: 'home', order: 0, isActive: true });
        setIsBannerDialogOpen(true);
    };

    const handleEditBanner = (banner: Banner) => {
        setIsEditing(true);
        setSelectedItem(banner);
        bannerForm.reset({
            title: banner.title,
            titleAr: banner.titleAr || '',
            imageUrl: banner.imageUrl,
            linkUrl: banner.linkUrl || '',
            position: banner.position,
            order: banner.order,
            isActive: banner.isActive,
        });
        setIsBannerDialogOpen(true);
    };

    const onPageSubmit = (data: any) => {
        if (isEditing && selectedItem) {
            updatePageMutation.mutate({ id: selectedItem._id, data });
        } else {
            createPageMutation.mutate(data);
        }
    };

    const onBannerSubmit = (data: any) => {
        if (isEditing && selectedItem) {
            updateBannerMutation.mutate({ id: selectedItem._id, data });
        } else {
            createBannerMutation.mutate(data);
        }
    };

    // ─────────────────────────────────────────
    // Stats
    // ─────────────────────────────────────────

    const activePages = pages.filter(p => p.isActive).length;
    const activeBanners = banners.filter(b => b.isActive).length;
    const pendingTestimonials = testimonials.filter(t => !t.isApproved).length;

    // ─────────────────────────────────────────
    // Render
    // ─────────────────────────────────────────

    return (
        <div className="space-y-6">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold">إدارة المحتوى</h1>
                <p className="text-muted-foreground text-sm">إدارة الصفحات والبنرات والأسئلة الشائعة</p>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                                <FileText className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">الصفحات</p>
                                <p className="text-2xl font-bold">{activePages} / {pages.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                                <Image className="h-5 w-5 text-green-600 dark:text-green-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">البنرات</p>
                                <p className="text-2xl font-bold">{activeBanners} / {banners.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                                <HelpCircle className="h-5 w-5 text-purple-600 dark:text-purple-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">الأسئلة الشائعة</p>
                                <p className="text-2xl font-bold">{faqs.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-yellow-100 dark:bg-yellow-900/30 rounded-lg">
                                <MessageSquare className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">شهادات بانتظار الموافقة</p>
                                <p className="text-2xl font-bold">{pendingTestimonials}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Tabs */}
            <Tabs value={activeTab} onValueChange={setActiveTab}>
                <TabsList className="mb-4">
                    <TabsTrigger value="pages" className="flex items-center gap-2">
                        <FileText className="h-4 w-4" />
                        الصفحات
                    </TabsTrigger>
                    <TabsTrigger value="banners" className="flex items-center gap-2">
                        <Image className="h-4 w-4" />
                        البنرات
                    </TabsTrigger>
                    <TabsTrigger value="faqs" className="flex items-center gap-2">
                        <HelpCircle className="h-4 w-4" />
                        الأسئلة الشائعة
                    </TabsTrigger>
                    <TabsTrigger value="testimonials" className="flex items-center gap-2">
                        <Star className="h-4 w-4" />
                        الشهادات
                        {pendingTestimonials > 0 && (
                            <Badge variant="warning" className="mr-1">{pendingTestimonials}</Badge>
                        )}
                    </TabsTrigger>
                </TabsList>

                {/* Pages Tab */}
                <TabsContent value="pages">
                    <Card>
                        <CardHeader>
                            <div className="flex justify-between items-center">
                                <CardTitle className="flex items-center gap-2">
                                    <FileText className="h-5 w-5" />
                                    الصفحات الثابتة
                                </CardTitle>
                                <Button onClick={handleAddPage}>
                                    <Plus className="h-4 w-4 ml-2" />
                                    إضافة صفحة
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {pagesLoading ? (
                                <div className="flex justify-center items-center h-40">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                                </div>
                            ) : pages.length === 0 ? (
                                <div className="text-center py-12 text-muted-foreground">
                                    <FileText className="h-12 w-12 mx-auto mb-4 opacity-50" />
                                    <p>لا توجد صفحات</p>
                                </div>
                            ) : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>العنوان</TableHead>
                                            <TableHead>Slug</TableHead>
                                            <TableHead>النوع</TableHead>
                                            <TableHead>الحالة</TableHead>
                                            <TableHead>آخر تحديث</TableHead>
                                            <TableHead className="w-[50px]"></TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {pages.map((page) => (
                                            <TableRow key={page._id}>
                                                <TableCell>
                                                    <div>
                                                        <p className="font-medium">{page.title}</p>
                                                        {page.titleAr && (
                                                            <p className="text-sm text-muted-foreground">{page.titleAr}</p>
                                                        )}
                                                    </div>
                                                </TableCell>
                                                <TableCell className="font-mono text-sm">{page.slug}</TableCell>
                                                <TableCell>
                                                    <Badge variant="outline">
                                                        {page.type === 'header' ? 'Header' : page.type === 'footer' ? 'Footer' : 'أخرى'}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>
                                                    <Badge variant={page.isActive ? 'success' : 'secondary'}>
                                                        {page.isActive ? 'نشط' : 'غير نشط'}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell className="text-muted-foreground text-sm">
                                                    {formatDate(page.updatedAt)}
                                                </TableCell>
                                                <TableCell>
                                                    <DropdownMenu>
                                                        <DropdownMenuTrigger asChild>
                                                            <Button variant="ghost" size="icon">
                                                                <MoreHorizontal className="h-4 w-4" />
                                                            </Button>
                                                        </DropdownMenuTrigger>
                                                        <DropdownMenuContent align="end">
                                                            <DropdownMenuItem onClick={() => handleEditPage(page)}>
                                                                <Pencil className="h-4 w-4 ml-2" />
                                                                تعديل
                                                            </DropdownMenuItem>
                                                            <DropdownMenuItem
                                                                onClick={() => deletePageMutation.mutate(page._id)}
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
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Banners Tab */}
                <TabsContent value="banners">
                    <Card>
                        <CardHeader>
                            <div className="flex justify-between items-center">
                                <CardTitle className="flex items-center gap-2">
                                    <Image className="h-5 w-5" />
                                    البنرات والإعلانات
                                </CardTitle>
                                <Button onClick={handleAddBanner}>
                                    <Plus className="h-4 w-4 ml-2" />
                                    إضافة بنر
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {bannersLoading ? (
                                <div className="flex justify-center items-center h-40">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                                </div>
                            ) : banners.length === 0 ? (
                                <div className="text-center py-12 text-muted-foreground">
                                    <Image className="h-12 w-12 mx-auto mb-4 opacity-50" />
                                    <p>لا توجد بنرات</p>
                                </div>
                            ) : (
                                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                                    {banners.map((banner) => (
                                        <Card key={banner._id} className="overflow-hidden">
                                            <div className="aspect-video bg-muted relative">
                                                <img
                                                    src={banner.imageUrl}
                                                    alt={banner.title}
                                                    className="w-full h-full object-cover"
                                                    onError={(e) => {
                                                        (e.target as HTMLImageElement).src = '/placeholder.svg';
                                                    }}
                                                />
                                                <Badge
                                                    variant={banner.isActive ? 'success' : 'secondary'}
                                                    className="absolute top-2 right-2"
                                                >
                                                    {banner.isActive ? 'نشط' : 'غير نشط'}
                                                </Badge>
                                            </div>
                                            <CardContent className="p-4">
                                                <h3 className="font-medium mb-2">{banner.title}</h3>
                                                <div className="flex justify-between items-center text-sm text-muted-foreground">
                                                    <span><Eye className="h-3 w-3 inline ml-1" />{banner.impressions}</span>
                                                    <div className="flex gap-2">
                                                        <Button variant="ghost" size="sm" onClick={() => handleEditBanner(banner)}>
                                                            <Pencil className="h-4 w-4" />
                                                        </Button>
                                                        <Button
                                                            variant="ghost"
                                                            size="sm"
                                                            onClick={() => deleteBannerMutation.mutate(banner._id)}
                                                            className="text-red-600"
                                                        >
                                                            <Trash2 className="h-4 w-4" />
                                                        </Button>
                                                    </div>
                                                </div>
                                            </CardContent>
                                        </Card>
                                    ))}
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* FAQs Tab */}
                <TabsContent value="faqs">
                    <Card>
                        <CardHeader>
                            <div className="flex justify-between items-center">
                                <CardTitle className="flex items-center gap-2">
                                    <HelpCircle className="h-5 w-5" />
                                    الأسئلة الشائعة
                                </CardTitle>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {faqsLoading ? (
                                <div className="flex justify-center items-center h-40">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                                </div>
                            ) : faqs.length === 0 ? (
                                <div className="text-center py-12 text-muted-foreground">
                                    <HelpCircle className="h-12 w-12 mx-auto mb-4 opacity-50" />
                                    <p>لا توجد أسئلة شائعة</p>
                                </div>
                            ) : (
                                <div className="space-y-4">
                                    {faqs.map((faq) => (
                                        <Card key={faq._id}>
                                            <CardContent className="p-4">
                                                <div className="flex justify-between items-start">
                                                    <div className="flex-1">
                                                        <h4 className="font-medium mb-2">{faq.question}</h4>
                                                        <p className="text-sm text-muted-foreground line-clamp-2">{faq.answer}</p>
                                                    </div>
                                                    <div className="flex items-center gap-2">
                                                        <Badge variant={faq.isActive ? 'success' : 'secondary'}>
                                                            {faq.isActive ? 'نشط' : 'غير نشط'}
                                                        </Badge>
                                                        <span className="text-xs text-muted-foreground">
                                                            <Eye className="h-3 w-3 inline ml-1" />
                                                            {faq.views}
                                                        </span>
                                                    </div>
                                                </div>
                                            </CardContent>
                                        </Card>
                                    ))}
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Testimonials Tab */}
                <TabsContent value="testimonials">
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Star className="h-5 w-5" />
                                شهادات العملاء
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            {testimonialsLoading ? (
                                <div className="flex justify-center items-center h-40">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                                </div>
                            ) : testimonials.length === 0 ? (
                                <div className="text-center py-12 text-muted-foreground">
                                    <Star className="h-12 w-12 mx-auto mb-4 opacity-50" />
                                    <p>لا توجد شهادات</p>
                                </div>
                            ) : (
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    {testimonials.map((testimonial) => (
                                        <Card key={testimonial._id} className={!testimonial.isApproved ? 'border-yellow-500' : ''}>
                                            <CardContent className="p-4">
                                                <div className="flex items-start gap-4">
                                                    <div className="w-12 h-12 rounded-full bg-muted flex items-center justify-center">
                                                        {testimonial.customerImage ? (
                                                            <img
                                                                src={testimonial.customerImage}
                                                                alt={testimonial.customerName}
                                                                className="w-full h-full rounded-full object-cover"
                                                            />
                                                        ) : (
                                                            <span className="text-lg font-medium">
                                                                {testimonial.customerName.charAt(0)}
                                                            </span>
                                                        )}
                                                    </div>
                                                    <div className="flex-1">
                                                        <div className="flex items-center justify-between mb-2">
                                                            <div>
                                                                <p className="font-medium">{testimonial.customerName}</p>
                                                                {testimonial.customerTitle && (
                                                                    <p className="text-xs text-muted-foreground">{testimonial.customerTitle}</p>
                                                                )}
                                                            </div>
                                                            <div className="flex items-center gap-1">
                                                                {[...Array(5)].map((_, i) => (
                                                                    <Star
                                                                        key={i}
                                                                        className={`h-4 w-4 ${i < testimonial.rating ? 'text-yellow-500 fill-yellow-500' : 'text-gray-300'}`}
                                                                    />
                                                                ))}
                                                            </div>
                                                        </div>
                                                        <p className="text-sm text-muted-foreground mb-3">{testimonial.content}</p>
                                                        <div className="flex justify-between items-center">
                                                            <Badge variant={testimonial.isApproved ? 'success' : 'warning'}>
                                                                {testimonial.isApproved ? 'معتمد' : 'بانتظار الموافقة'}
                                                            </Badge>
                                                            <div className="flex gap-2">
                                                                {!testimonial.isApproved && (
                                                                    <Button
                                                                        variant="ghost"
                                                                        size="sm"
                                                                        onClick={() => approveTestimonialMutation.mutate(testimonial._id)}
                                                                    >
                                                                        <CheckCircle className="h-4 w-4 text-green-600" />
                                                                    </Button>
                                                                )}
                                                                <Button
                                                                    variant="ghost"
                                                                    size="sm"
                                                                    onClick={() => deleteTestimonialMutation.mutate(testimonial._id)}
                                                                    className="text-red-600"
                                                                >
                                                                    <Trash2 className="h-4 w-4" />
                                                                </Button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </CardContent>
                                        </Card>
                                    ))}
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>

            {/* Page Dialog */}
            <Dialog open={isPageDialogOpen} onOpenChange={setIsPageDialogOpen}>
                <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle>{isEditing ? 'تعديل الصفحة' : 'إضافة صفحة جديدة'}</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={pageForm.handleSubmit(onPageSubmit)} className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>العنوان (EN) *</Label>
                                <Input {...pageForm.register('title')} placeholder="Page Title" />
                            </div>
                            <div className="space-y-2">
                                <Label>العنوان (AR)</Label>
                                <Input {...pageForm.register('titleAr')} placeholder="عنوان الصفحة" />
                            </div>
                        </div>
                        <div className="space-y-2">
                            <Label>Slug *</Label>
                            <Input {...pageForm.register('slug')} placeholder="page-slug" className="font-mono" />
                        </div>
                        <div className="space-y-2">
                            <Label>المحتوى (EN)</Label>
                            <Textarea {...pageForm.register('content')} rows={5} placeholder="Page content..." />
                        </div>
                        <div className="space-y-2">
                            <Label>المحتوى (AR)</Label>
                            <Textarea {...pageForm.register('contentAr')} rows={5} placeholder="محتوى الصفحة..." />
                        </div>
                        <div className="flex items-center gap-2">
                            <Switch
                                id="pageActive"
                                checked={pageForm.watch('isActive')}
                                onCheckedChange={(checked: boolean) => pageForm.setValue('isActive', checked)}
                            />
                            <Label htmlFor="pageActive">صفحة نشطة</Label>
                        </div>
                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsPageDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={createPageMutation.isPending || updatePageMutation.isPending}>
                                {(createPageMutation.isPending || updatePageMutation.isPending) && (
                                    <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                                )}
                                {isEditing ? 'حفظ' : 'إنشاء'}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Banner Dialog */}
            <Dialog open={isBannerDialogOpen} onOpenChange={setIsBannerDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{isEditing ? 'تعديل البنر' : 'إضافة بنر جديد'}</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={bannerForm.handleSubmit(onBannerSubmit)} className="space-y-4">
                        <div className="space-y-2">
                            <Label>العنوان *</Label>
                            <Input {...bannerForm.register('title')} placeholder="عنوان البنر" />
                        </div>
                        <div className="space-y-2">
                            <Label>رابط الصورة *</Label>
                            <Input {...bannerForm.register('imageUrl')} placeholder="https://..." />
                        </div>
                        <div className="space-y-2">
                            <Label>رابط الهدف</Label>
                            <Input {...bannerForm.register('linkUrl')} placeholder="https://..." />
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>الموقع</Label>
                                <Input {...bannerForm.register('position')} placeholder="home" />
                            </div>
                            <div className="space-y-2">
                                <Label>الترتيب</Label>
                                <Input type="number" {...bannerForm.register('order', { valueAsNumber: true })} />
                            </div>
                        </div>
                        <div className="flex items-center gap-2">
                            <Switch
                                id="bannerActive"
                                checked={bannerForm.watch('isActive')}
                                onCheckedChange={(checked: boolean) => bannerForm.setValue('isActive', checked)}
                            />
                            <Label htmlFor="bannerActive">بنر نشط</Label>
                        </div>
                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsBannerDialogOpen(false)}>
                                إلغاء
                            </Button>
                            <Button type="submit" disabled={createBannerMutation.isPending || updateBannerMutation.isPending}>
                                {(createBannerMutation.isPending || updateBannerMutation.isPending) && (
                                    <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                                )}
                                {isEditing ? 'حفظ' : 'إنشاء'}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>
        </div>
    );
}

export default ContentPage;
