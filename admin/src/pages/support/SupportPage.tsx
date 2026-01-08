import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supportApi } from '@/api/support.api';
import type { Ticket } from '@/types';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import {
    HeadphonesIcon,
    Clock,
    CheckCircle,
    AlertCircle,
    User,
    Send,
    Loader2,
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
    const [selectedTicket, setSelectedTicket] = useState<Ticket | null>(null);
    const [replyContent, setReplyContent] = useState('');
    const locale = i18n.language === 'ar' ? 'ar-SA' : 'en-US';

    // Fetch tickets from backend
    const { data: ticketsData, isLoading } = useQuery({
        queryKey: ['tickets'],
        queryFn: () => supportApi.getAllTickets({ limit: 50 }),
    });

    // Fetch stats
    const { data: stats } = useQuery({
        queryKey: ['support-stats'],
        queryFn: supportApi.getStats,
    });

    // Reply mutation
    const replyMutation = useMutation({
        mutationFn: ({ ticketId, content }: { ticketId: string; content: string }) =>
            supportApi.replyToTicket(ticketId, { content }),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['tickets'] });
            setReplyContent('');
        },
    });

    const handleReply = () => {
        if (selectedTicket && replyContent.trim()) {
            replyMutation.mutate({ ticketId: selectedTicket._id, content: replyContent });
        }
    };

    const tickets = ticketsData?.items || [];

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
                        <div className="p-3 bg-yellow-100 rounded-xl">
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
                        <div className="p-3 bg-blue-100 rounded-xl">
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
                        <div className="p-3 bg-green-100 rounded-xl">
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
                        <div className="p-3 bg-purple-100 rounded-xl">
                            <HeadphonesIcon className="h-5 w-5 text-purple-600" />
                        </div>
                        <div>
                            <p className="text-2xl font-bold">{stats?.avgResponseTime || 0} د</p>
                            <p className="text-sm text-gray-500">متوسط الرد</p>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Tickets */}
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
                                <div className="divide-y">
                                    {tickets.map((ticket) => (
                                        <div
                                            key={ticket._id}
                                            onClick={() => setSelectedTicket(ticket)}
                                            className={`p-4 cursor-pointer hover:bg-gray-50 transition-colors ${selectedTicket?._id === ticket._id ? 'bg-primary-50' : ''
                                                }`}
                                        >
                                            <div className="flex items-start gap-3">
                                                <Avatar>
                                                    <AvatarFallback>{getInitials(ticket.customer?.companyName || 'عميل')}</AvatarFallback>
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
                                                    <p className="text-sm text-gray-900 mt-1 truncate">{ticket.subject}</p>
                                                    <div className="flex items-center gap-3 mt-2 text-xs text-gray-500">
                                                        <span>{ticket.customer?.companyName}</span>
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

                {/* Ticket Detail / Quick Reply */}
                <div>
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
                                    <div>
                                        <p className="text-sm text-gray-500">العميل</p>
                                        <p className="font-medium">{selectedTicket.customer?.companyName}</p>
                                    </div>
                                    <textarea
                                        placeholder="اكتب ردك هنا..."
                                        value={replyContent}
                                        onChange={(e) => setReplyContent(e.target.value)}
                                        className="w-full h-32 p-3 border border-gray-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-primary-500"
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
                </div>
            </div>
        </div>
    );
}
