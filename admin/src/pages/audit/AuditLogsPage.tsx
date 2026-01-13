import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { auditApi, type AuditLog, type LoginLog } from '@/api/audit.api';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
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
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
    Search,
    Loader2,
    Activity,
    History,
    ShieldAlert,
    LogIn,
    AlertTriangle,
    XCircle,
    CheckCircle,
    Clock,
    User,
    Monitor,
    Globe,
} from 'lucide-react';
import { formatDate } from '@/lib/utils';

// ══════════════════════════════════════════════════════════════
// Action/Resource Labels
// ══════════════════════════════════════════════════════════════

const actionLabels: Record<string, { label: string; variant: 'default' | 'secondary' | 'success' | 'warning' | 'danger' }> = {
    create: { label: 'إنشاء', variant: 'success' },
    update: { label: 'تحديث', variant: 'default' },
    delete: { label: 'حذف', variant: 'danger' },
    login: { label: 'تسجيل دخول', variant: 'default' },
    logout: { label: 'تسجيل خروج', variant: 'secondary' },
    approve: { label: 'موافقة', variant: 'success' },
    reject: { label: 'رفض', variant: 'danger' },
    export: { label: 'تصدير', variant: 'warning' },
};

const resourceLabels: Record<string, string> = {
    admin: 'مشرف',
    customer: 'عميل',
    product: 'منتج',
    order: 'طلب',
    category: 'فئة',
    promotion: 'عرض',
    coupon: 'كوبون',
    settings: 'إعدادات',
    supplier: 'مورد',
    return: 'مرتجع',
    role: 'دور',
};

const loginStatusConfig: Record<string, { label: string; variant: 'default' | 'success' | 'warning' | 'danger'; icon: React.ReactNode }> = {
    success: { label: 'ناجح', variant: 'success', icon: <CheckCircle className="h-3 w-3" /> },
    failed: { label: 'فاشل', variant: 'danger', icon: <XCircle className="h-3 w-3" /> },
    suspicious: { label: 'مشبوه', variant: 'warning', icon: <AlertTriangle className="h-3 w-3" /> },
};

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function AuditLogsPage() {
    const [activeTab, setActiveTab] = useState('logs');
    const [searchQuery, setSearchQuery] = useState('');
    const [actionFilter, setActionFilter] = useState<string>('_all');
    const [resourceFilter, setResourceFilter] = useState<string>('_all');

    // ─────────────────────────────────────────
    // Queries
    // ─────────────────────────────────────────

    const { data: logsData, isLoading: logsLoading } = useQuery({
        queryKey: ['audit-logs', actionFilter, resourceFilter],
        queryFn: () => auditApi.getLogs({
            action: actionFilter === '_all' ? undefined : actionFilter,
            resource: resourceFilter === '_all' ? undefined : resourceFilter,
        }),
    });

    const { data: criticalLogs = [], isLoading: criticalLoading } = useQuery({
        queryKey: ['audit-critical'],
        queryFn: () => auditApi.getCriticalLogs(),
    });

    // Recent activities - not currently used but available for future
    useQuery({
        queryKey: ['audit-activities'],
        queryFn: () => auditApi.getRecentActivities(),
    });

    const { data: loginHistory = [], isLoading: loginsLoading } = useQuery({
        queryKey: ['audit-logins'],
        queryFn: () => auditApi.getLoginHistory(),
    });

    const { data: suspiciousLogins = [] } = useQuery({
        queryKey: ['audit-suspicious'],
        queryFn: () => auditApi.getSuspiciousLogins(),
    });

    const { data: failedLogins = [] } = useQuery({
        queryKey: ['audit-failed'],
        queryFn: () => auditApi.getFailedLogins(),
    });

    const { data: stats } = useQuery({
        queryKey: ['audit-stats'],
        queryFn: () => auditApi.getStats(),
    });

    const logs = logsData?.items || [];

    // ─────────────────────────────────────────
    // Filter logs
    // ─────────────────────────────────────────

    const filteredLogs = logs.filter(log => {
        if (!searchQuery) return true;
        const query = searchQuery.toLowerCase();
        return (
            log.action?.toLowerCase().includes(query) ||
            log.resource?.toLowerCase().includes(query) ||
            log.actorName?.toLowerCase().includes(query) ||
            log.ipAddress?.includes(query)
        );
    });

    // ─────────────────────────────────────────
    // Render Log Row
    // ─────────────────────────────────────────

    const renderLogRow = (log: AuditLog) => {
        const action = actionLabels[log.action] || { label: log.action, variant: 'secondary' as const };
        return (
            <TableRow key={log._id}>
                <TableCell>
                    <Badge variant={action.variant}>{action.label}</Badge>
                </TableCell>
                <TableCell>{resourceLabels[log.resource] || log.resource}</TableCell>
                <TableCell className="font-mono text-xs">{log.resourceId || '-'}</TableCell>
                <TableCell>
                    <div className="flex items-center gap-2">
                        <User className="h-3 w-3 text-muted-foreground" />
                        <span>{log.actorName || log.actorId || 'نظام'}</span>
                    </div>
                </TableCell>
                <TableCell>
                    <div className="flex items-center gap-2 text-xs text-muted-foreground">
                        <Globe className="h-3 w-3" />
                        {log.ipAddress || '-'}
                    </div>
                </TableCell>
                <TableCell className="text-muted-foreground text-sm">
                    {formatDate(log.createdAt)}
                </TableCell>
            </TableRow>
        );
    };

    // ─────────────────────────────────────────
    // Render Login Row
    // ─────────────────────────────────────────

    const renderLoginRow = (login: LoginLog) => {
        const status = loginStatusConfig[login.status] || loginStatusConfig.failed;
        return (
            <TableRow key={login._id}>
                <TableCell>
                    <div className="flex items-center gap-2">
                        <Badge variant={status.variant} className="flex items-center gap-1">
                            {status.icon}
                            {status.label}
                        </Badge>
                    </div>
                </TableCell>
                <TableCell>
                    <div>
                        <p className="font-medium">{login.userName || login.email}</p>
                        <p className="text-xs text-muted-foreground">{login.userType === 'admin' ? 'مشرف' : 'عميل'}</p>
                    </div>
                </TableCell>
                <TableCell>
                    <div className="flex items-center gap-2 text-sm">
                        <Globe className="h-3 w-3 text-muted-foreground" />
                        {login.ipAddress}
                    </div>
                </TableCell>
                <TableCell>
                    {login.deviceInfo && (
                        <div className="flex items-center gap-2 text-xs text-muted-foreground">
                            <Monitor className="h-3 w-3" />
                            <span className="truncate max-w-[150px]">{login.deviceInfo}</span>
                        </div>
                    )}
                </TableCell>
                <TableCell>
                    {login.failureReason && (
                        <span className="text-xs text-red-500">{login.failureReason}</span>
                    )}
                </TableCell>
                <TableCell className="text-muted-foreground text-sm">
                    {formatDate(login.createdAt)}
                </TableCell>
            </TableRow>
        );
    };

    // ─────────────────────────────────────────
    // Render
    // ─────────────────────────────────────────

    return (
        <div className="space-y-6">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold">سجل المراجعة</h1>
                <p className="text-muted-foreground text-sm">مراقبة أنشطة النظام وتسجيلات الدخول</p>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                                <Activity className="h-5 w-5 text-blue-600 dark:text-blue-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">إجمالي السجلات</p>
                                <p className="text-2xl font-bold">{stats?.totalLogs || logs.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                                <Clock className="h-5 w-5 text-green-600 dark:text-green-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">سجلات اليوم</p>
                                <p className="text-2xl font-bold">{stats?.todayLogs || 0}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-red-100 dark:bg-red-900/30 rounded-lg">
                                <ShieldAlert className="h-5 w-5 text-red-600 dark:text-red-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">سجلات حرجة</p>
                                <p className="text-2xl font-bold">{stats?.criticalLogs || criticalLogs.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
                <Card>
                    <CardContent className="pt-6">
                        <div className="flex items-center gap-3">
                            <div className="p-2 bg-yellow-100 dark:bg-yellow-900/30 rounded-lg">
                                <AlertTriangle className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />
                            </div>
                            <div>
                                <p className="text-sm text-muted-foreground">تسجيلات مشبوهة</p>
                                <p className="text-2xl font-bold">{suspiciousLogins.length}</p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Tabs */}
            <Tabs value={activeTab} onValueChange={setActiveTab}>
                <TabsList className="mb-4">
                    <TabsTrigger value="logs" className="flex items-center gap-2">
                        <History className="h-4 w-4" />
                        سجلات الأنشطة
                    </TabsTrigger>
                    <TabsTrigger value="logins" className="flex items-center gap-2">
                        <LogIn className="h-4 w-4" />
                        تسجيلات الدخول
                    </TabsTrigger>
                    <TabsTrigger value="critical" className="flex items-center gap-2">
                        <ShieldAlert className="h-4 w-4" />
                        حرج
                        {criticalLogs.length > 0 && (
                            <Badge variant="danger" className="mr-1">{criticalLogs.length}</Badge>
                        )}
                    </TabsTrigger>
                    <TabsTrigger value="suspicious" className="flex items-center gap-2">
                        <AlertTriangle className="h-4 w-4" />
                        مشبوه
                        {suspiciousLogins.length > 0 && (
                            <Badge variant="warning" className="mr-1">{suspiciousLogins.length}</Badge>
                        )}
                    </TabsTrigger>
                </TabsList>

                {/* Activity Logs Tab */}
                <TabsContent value="logs">
                    <Card>
                        <CardHeader>
                            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                                <CardTitle className="flex items-center gap-2">
                                    <History className="h-5 w-5" />
                                    سجلات الأنشطة
                                </CardTitle>
                                <div className="flex flex-wrap gap-2">
                                    <div className="relative w-60">
                                        <Search className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                                        <Input
                                            placeholder="بحث..."
                                            value={searchQuery}
                                            onChange={(e) => setSearchQuery(e.target.value)}
                                            className="pr-10"
                                        />
                                    </div>
                                    <Select value={actionFilter} onValueChange={setActionFilter}>
                                        <SelectTrigger className="w-32">
                                            <SelectValue placeholder="الإجراء" />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="_all">الكل</SelectItem>
                                            <SelectItem value="create">إنشاء</SelectItem>
                                            <SelectItem value="update">تحديث</SelectItem>
                                            <SelectItem value="delete">حذف</SelectItem>
                                        </SelectContent>
                                    </Select>
                                    <Select value={resourceFilter} onValueChange={setResourceFilter}>
                                        <SelectTrigger className="w-32">
                                            <SelectValue placeholder="المورد" />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="_all">الكل</SelectItem>
                                            <SelectItem value="admin">مشرف</SelectItem>
                                            <SelectItem value="product">منتج</SelectItem>
                                            <SelectItem value="order">طلب</SelectItem>
                                            <SelectItem value="customer">عميل</SelectItem>
                                        </SelectContent>
                                    </Select>
                                </div>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {logsLoading ? (
                                <div className="flex justify-center items-center h-40">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                                </div>
                            ) : filteredLogs.length === 0 ? (
                                <div className="text-center py-12 text-muted-foreground">
                                    <Activity className="h-12 w-12 mx-auto mb-4 opacity-50" />
                                    <p>لا توجد سجلات</p>
                                </div>
                            ) : (
                                <div className="overflow-x-auto">
                                    <Table>
                                        <TableHeader>
                                            <TableRow>
                                                <TableHead>الإجراء</TableHead>
                                                <TableHead>المورد</TableHead>
                                                <TableHead>المعرف</TableHead>
                                                <TableHead>المستخدم</TableHead>
                                                <TableHead>IP</TableHead>
                                                <TableHead>التاريخ</TableHead>
                                            </TableRow>
                                        </TableHeader>
                                        <TableBody>
                                            {filteredLogs.map(renderLogRow)}
                                        </TableBody>
                                    </Table>
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Logins Tab */}
                <TabsContent value="logins">
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <LogIn className="h-5 w-5" />
                                تسجيلات الدخول
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            {loginsLoading ? (
                                <div className="flex justify-center items-center h-40">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                                </div>
                            ) : loginHistory.length === 0 ? (
                                <div className="text-center py-12 text-muted-foreground">
                                    <LogIn className="h-12 w-12 mx-auto mb-4 opacity-50" />
                                    <p>لا توجد تسجيلات دخول</p>
                                </div>
                            ) : (
                                <div className="overflow-x-auto">
                                    <Table>
                                        <TableHeader>
                                            <TableRow>
                                                <TableHead>الحالة</TableHead>
                                                <TableHead>المستخدم</TableHead>
                                                <TableHead>IP</TableHead>
                                                <TableHead>الجهاز</TableHead>
                                                <TableHead>السبب</TableHead>
                                                <TableHead>التاريخ</TableHead>
                                            </TableRow>
                                        </TableHeader>
                                        <TableBody>
                                            {loginHistory.map(renderLoginRow)}
                                        </TableBody>
                                    </Table>
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Critical Tab */}
                <TabsContent value="critical">
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2 text-red-600">
                                <ShieldAlert className="h-5 w-5" />
                                السجلات الحرجة
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            {criticalLoading ? (
                                <div className="flex justify-center items-center h-40">
                                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                                </div>
                            ) : criticalLogs.length === 0 ? (
                                <div className="text-center py-12 text-muted-foreground">
                                    <CheckCircle className="h-12 w-12 mx-auto mb-4 text-green-500" />
                                    <p>لا توجد سجلات حرجة</p>
                                </div>
                            ) : (
                                <div className="overflow-x-auto">
                                    <Table>
                                        <TableHeader>
                                            <TableRow>
                                                <TableHead>الإجراء</TableHead>
                                                <TableHead>المورد</TableHead>
                                                <TableHead>المعرف</TableHead>
                                                <TableHead>المستخدم</TableHead>
                                                <TableHead>IP</TableHead>
                                                <TableHead>التاريخ</TableHead>
                                            </TableRow>
                                        </TableHeader>
                                        <TableBody>
                                            {criticalLogs.map(renderLogRow)}
                                        </TableBody>
                                    </Table>
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Suspicious Tab */}
                <TabsContent value="suspicious">
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2 text-yellow-600">
                                <AlertTriangle className="h-5 w-5" />
                                تسجيلات مشبوهة ومحاولات فاشلة
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            {suspiciousLogins.length === 0 && failedLogins.length === 0 ? (
                                <div className="text-center py-12 text-muted-foreground">
                                    <CheckCircle className="h-12 w-12 mx-auto mb-4 text-green-500" />
                                    <p>لا توجد تسجيلات مشبوهة</p>
                                </div>
                            ) : (
                                <div className="overflow-x-auto">
                                    <Table>
                                        <TableHeader>
                                            <TableRow>
                                                <TableHead>الحالة</TableHead>
                                                <TableHead>المستخدم</TableHead>
                                                <TableHead>IP</TableHead>
                                                <TableHead>الجهاز</TableHead>
                                                <TableHead>السبب</TableHead>
                                                <TableHead>التاريخ</TableHead>
                                            </TableRow>
                                        </TableHeader>
                                        <TableBody>
                                            {[...suspiciousLogins, ...failedLogins].map(renderLoginRow)}
                                        </TableBody>
                                    </Table>
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>
        </div>
    );
}

export default AuditLogsPage;
