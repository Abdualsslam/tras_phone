import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery } from '@tanstack/react-query';
import { notificationsApi } from '@/api/notifications.api';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import {
    Bell,
    Send,
    MessageSquare,
    CheckCircle,
    Clock,
    FileText,
    Loader2,
} from 'lucide-react';

export function NotificationsPage() {
    const { t } = useTranslation();
    const [activeTab, setActiveTab] = useState<'sent' | 'templates'>('sent');

    // Fetch notifications
    const { data: notificationsData, isLoading: notificationsLoading } = useQuery({
        queryKey: ['notifications'],
        queryFn: () => notificationsApi.getNotifications({ limit: 20 }),
    });

    // Fetch templates
    const { data: templates, isLoading: templatesLoading } = useQuery({
        queryKey: ['notification-templates'],
        queryFn: notificationsApi.getTemplates,
        enabled: activeTab === 'templates',
    });

    const notifications = notificationsData?.items || [];
    const isLoading = activeTab === 'sent' ? notificationsLoading : templatesLoading;

    const stats = {
        totalSent: notificationsData?.pagination?.total || notifications.length,
        thisWeek: notifications.filter((n) => {
            const date = new Date(n.createdAt);
            const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
            return date > weekAgo;
        }).length,
        openRate: 68,
        templates: templates?.length || 0,
    };

    const templateCategories = [
        { id: '1', name: 'إشعارات الطلبات', count: templates?.filter((t) => t.type === 'order').length || 0, icon: FileText },
        { id: '2', name: 'الحملات الترويجية', count: templates?.filter((t) => t.type === 'promotion').length || 0, icon: Send },
        { id: '3', name: 'تنبيهات المخزون', count: templates?.filter((t) => t.type === 'stock').length || 0, icon: Bell },
        { id: '4', name: 'رسائل النظام', count: templates?.filter((t) => t.type === 'system').length || 0, icon: MessageSquare },
    ];

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">{t('sidebar.notifications')}</h1>
                    <p className="text-gray-500 mt-1">إدارة الإشعارات والحملات</p>
                </div>
                <Button>
                    <Send className="h-4 w-4" />
                    إرسال إشعار
                </Button>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-blue-100 rounded-xl">
                            <Send className="h-5 w-5 text-blue-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{stats.totalSent}</p>
                            <p className="text-sm text-gray-500">إجمالي المرسل</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-green-100 rounded-xl">
                            <Clock className="h-5 w-5 text-green-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{stats.thisWeek}</p>
                            <p className="text-sm text-gray-500">هذا الأسبوع</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-purple-100 rounded-xl">
                            <CheckCircle className="h-5 w-5 text-purple-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{stats.openRate}%</p>
                            <p className="text-sm text-gray-500">معدل الفتح</p>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="p-4 flex items-center gap-4">
                        <div className="p-3 bg-orange-100 rounded-xl">
                            <FileText className="h-5 w-5 text-orange-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{stats.templates}</p>
                            <p className="text-sm text-gray-500">قالب</p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Tabs */}
            <div className="flex gap-2 border-b">
                <button
                    onClick={() => setActiveTab('sent')}
                    className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${activeTab === 'sent'
                        ? 'border-primary-600 text-primary-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700'
                        }`}
                >
                    الإشعارات المرسلة
                </button>
                <button
                    onClick={() => setActiveTab('templates')}
                    className={`px-4 py-2 text-sm font-medium border-b-2 transition-colors ${activeTab === 'templates'
                        ? 'border-primary-600 text-primary-600'
                        : 'border-transparent text-gray-500 hover:text-gray-700'
                        }`}
                >
                    القوالب
                </button>
            </div>

            {/* Content */}
            {isLoading ? (
                <div className="flex items-center justify-center py-12">
                    <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                </div>
            ) : activeTab === 'sent' ? (
                <div className="space-y-4">
                    {notifications.map((notif) => (
                        <Card key={notif._id}>
                            <CardContent className="p-4 flex items-start gap-4">
                                <div className="p-3 bg-primary-100 rounded-xl">
                                    <Bell className="h-5 w-5 text-primary-600" />
                                </div>
                                <div className="flex-1">
                                    <div className="flex items-start justify-between">
                                        <div>
                                            <h3 className="font-medium text-gray-900">{notif.title}</h3>
                                            <p className="text-sm text-gray-500 mt-1">{notif.body}</p>
                                        </div>
                                        <Badge variant={notif.read ? 'default' : 'secondary'}>
                                            {notif.read ? 'مقروء' : 'جديد'}
                                        </Badge>
                                    </div>
                                    <div className="flex items-center gap-4 mt-3 text-sm text-gray-500">
                                        <span>{new Date(notif.createdAt).toLocaleDateString('ar-SA')}</span>
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                    {notifications.length === 0 && (
                        <div className="text-center py-12 text-gray-500">
                            لا توجد إشعارات
                        </div>
                    )}
                </div>
            ) : (
                <div className="grid md:grid-cols-2 gap-4">
                    {templateCategories.map((category) => (
                        <Card key={category.id} className="cursor-pointer hover:shadow-md transition-shadow">
                            <CardContent className="p-4 flex items-center gap-4">
                                <div className="p-3 bg-gray-100 rounded-xl">
                                    <category.icon className="h-5 w-5 text-gray-600" />
                                </div>
                                <div className="flex-1">
                                    <h3 className="font-medium text-gray-900">{category.name}</h3>
                                    <p className="text-sm text-gray-500">{category.count} قالب</p>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}
        </div>
    );
}
