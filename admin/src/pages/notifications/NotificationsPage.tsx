import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  notificationsApi,
  type NotificationTemplate,
  type NotificationCampaign,
} from "@/api/notifications.api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Switch } from "@/components/ui/switch";
import {
  Bell,
  Send,
  MessageSquare,
  Clock,
  FileText,
  Loader2,
  Plus,
  MoreHorizontal,
  Pencil,
  Rocket,
  Mail,
  Smartphone,
} from "lucide-react";
import { formatDate } from "@/lib/utils";

export function NotificationsPage() {
  const { t, i18n } = useTranslation();
  const queryClient = useQueryClient();
  const locale = i18n.language === "ar" ? "ar-SA" : "en-US";

  const [isTemplateDialogOpen, setIsTemplateDialogOpen] = useState(false);
  const [isCampaignDialogOpen, setIsCampaignDialogOpen] = useState(false);
  const [isSendDialogOpen, setIsSendDialogOpen] = useState(false);
  const [editingTemplate, setEditingTemplate] =
    useState<NotificationTemplate | null>(null);

  const [templateForm, setTemplateForm] = useState({
    name: "",
    nameAr: "",
    type: "system" as "order" | "promotion" | "system" | "stock",
    channel: "push" as "push" | "email" | "sms",
    titleTemplate: "",
    bodyTemplate: "",
    isActive: true,
  });

  const [campaignForm, setCampaignForm] = useState({
    title: "",
    body: "",
    type: "push" as "push" | "email" | "sms",
    targetAudience: "all" as "all" | "segment" | "specific",
  });

  const [sendForm, setSendForm] = useState({
    title: "",
    body: "",
    customerIds: "",
  });

  // Queries
  const { data: notificationsData, isLoading: notificationsLoading } = useQuery(
    {
      queryKey: ["notifications"],
      queryFn: () => notificationsApi.getNotifications({ limit: 20 }),
    }
  );

  const { data: templates = [], isLoading: templatesLoading } = useQuery<
    NotificationTemplate[]
  >({
    queryKey: ["notification-templates"],
    queryFn: notificationsApi.getTemplates,
  });

  const { data: campaigns = [], isLoading: campaignsLoading } = useQuery<
    NotificationCampaign[]
  >({
    queryKey: ["notification-campaigns"],
    queryFn: notificationsApi.getCampaigns,
  });

  // Mutations
  const createTemplateMutation = useMutation({
    mutationFn: notificationsApi.createTemplate,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notification-templates"] });
      setIsTemplateDialogOpen(false);
      resetTemplateForm();
    },
  });

  const updateTemplateMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: Partial<NotificationTemplate>;
    }) => notificationsApi.updateTemplate(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notification-templates"] });
      setIsTemplateDialogOpen(false);
      resetTemplateForm();
    },
  });

  const createCampaignMutation = useMutation({
    mutationFn: notificationsApi.createCampaign,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notification-campaigns"] });
      setIsCampaignDialogOpen(false);
      setCampaignForm({
        title: "",
        body: "",
        type: "push",
        targetAudience: "all",
      });
    },
  });

  const launchCampaignMutation = useMutation({
    mutationFn: notificationsApi.sendCampaign,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["notification-campaigns"] });
    },
  });

  const sendNotificationMutation = useMutation({
    mutationFn: notificationsApi.sendToCustomers,
    onSuccess: () => {
      setIsSendDialogOpen(false);
      setSendForm({ title: "", body: "", customerIds: "" });
    },
  });

  // Handlers
  const resetTemplateForm = () => {
    setEditingTemplate(null);
    setTemplateForm({
      name: "",
      nameAr: "",
      type: "system",
      channel: "push",
      titleTemplate: "",
      bodyTemplate: "",
      isActive: true,
    });
  };

  const handleOpenCreateTemplate = () => {
    resetTemplateForm();
    setIsTemplateDialogOpen(true);
  };

  const handleOpenEditTemplate = (template: NotificationTemplate) => {
    setEditingTemplate(template);
    setTemplateForm({
      name: template.name,
      nameAr: template.nameAr || "",
      type: template.type,
      channel: template.channel,
      titleTemplate: template.titleTemplate,
      bodyTemplate: template.bodyTemplate,
      isActive: template.isActive,
    });
    setIsTemplateDialogOpen(true);
  };

  const handleSubmitTemplate = () => {
    if (!templateForm.name || !templateForm.titleTemplate) return;
    if (editingTemplate) {
      updateTemplateMutation.mutate({
        id: editingTemplate._id,
        data: templateForm,
      });
    } else {
      createTemplateMutation.mutate(templateForm);
    }
  };

  const handleSubmitCampaign = () => {
    if (!campaignForm.title || !campaignForm.body) return;
    createCampaignMutation.mutate(campaignForm);
  };

  const handleSendNotification = () => {
    if (!sendForm.title || !sendForm.body || !sendForm.customerIds) return;
    const customerIds = sendForm.customerIds
      .split(",")
      .map((id) => id.trim())
      .filter(Boolean);
    sendNotificationMutation.mutate({ ...sendForm, customerIds });
  };

  const notifications = notificationsData?.items || [];

  const weekAgo = new Date();
  weekAgo.setDate(weekAgo.getDate() - 7);

  const stats = {
    totalSent: notificationsData?.pagination?.total || notifications.length,
    thisWeek: notifications.filter((n) => {
      const date = new Date(n.createdAt);
      return date > weekAgo;
    }).length,
    templates: templates.length,
    campaigns: campaigns.length,
  };

  const getChannelIcon = (channel: string) => {
    switch (channel) {
      case "push":
        return <Smartphone className="h-4 w-4" />;
      case "email":
        return <Mail className="h-4 w-4" />;
      case "sms":
        return <MessageSquare className="h-4 w-4" />;
      default:
        return <Bell className="h-4 w-4" />;
    }
  };

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
            {t("sidebar.notifications")}
          </h1>
          <p className="text-gray-500 dark:text-gray-400 mt-1">
            إدارة الإشعارات والحملات والقوالب
          </p>
        </div>
        <Button onClick={() => setIsSendDialogOpen(true)}>
          <Send className="h-4 w-4" />
          إرسال إشعار
        </Button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <div className="p-3 bg-blue-100 dark:bg-blue-900/30 rounded-xl">
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
            <div className="p-3 bg-green-100 dark:bg-green-900/30 rounded-xl">
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
            <div className="p-3 bg-purple-100 dark:bg-purple-900/30 rounded-xl">
              <FileText className="h-5 w-5 text-purple-600" />
            </div>
            <div>
              <p className="text-2xl font-bold">{stats.templates}</p>
              <p className="text-sm text-gray-500">قالب</p>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="p-4 flex items-center gap-4">
            <div className="p-3 bg-orange-100 dark:bg-orange-900/30 rounded-xl">
              <Rocket className="h-5 w-5 text-orange-600" />
            </div>
            <div>
              <p className="text-2xl font-bold">{stats.campaigns}</p>
              <p className="text-sm text-gray-500">حملة</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Tabs */}
      <Tabs defaultValue="notifications" className="w-full">
        <TabsList>
          <TabsTrigger value="notifications" className="gap-2">
            <Bell className="h-4 w-4" />
            الإشعارات
          </TabsTrigger>
          <TabsTrigger value="templates" className="gap-2">
            <FileText className="h-4 w-4" />
            القوالب
          </TabsTrigger>
          <TabsTrigger value="campaigns" className="gap-2">
            <Rocket className="h-4 w-4" />
            الحملات
          </TabsTrigger>
        </TabsList>

        {/* Notifications Tab */}
        <TabsContent value="notifications" className="mt-4 space-y-4">
          {notificationsLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
            </div>
          ) : notifications.length === 0 ? (
            <div className="text-center py-12 text-gray-500">
              <Bell className="h-12 w-12 mx-auto mb-2 text-gray-300" />
              <p>لا توجد إشعارات</p>
            </div>
          ) : (
            notifications.map((notif) => (
              <Card key={notif._id}>
                <CardContent className="p-4 flex items-start gap-4">
                  <div className="p-3 bg-primary-100 dark:bg-primary-900/30 rounded-xl">
                    <Bell className="h-5 w-5 text-primary-600" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-start justify-between">
                      <div>
                        <h3 className="font-medium text-gray-900 dark:text-gray-100">
                          {notif.title}
                        </h3>
                        <p className="text-sm text-gray-500 mt-1">
                          {notif.body}
                        </p>
                      </div>
                      <Badge variant={notif.read ? "default" : "secondary"}>
                        {notif.read ? "مقروء" : "جديد"}
                      </Badge>
                    </div>
                    <p className="text-sm text-gray-500 mt-2">
                      {formatDate(notif.createdAt, locale)}
                    </p>
                  </div>
                </CardContent>
              </Card>
            ))
          )}
        </TabsContent>

        {/* Templates Tab */}
        <TabsContent value="templates" className="mt-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle className="flex items-center gap-2">
                <FileText className="h-5 w-5" />
                قوالب الإشعارات
              </CardTitle>
              <Button onClick={handleOpenCreateTemplate}>
                <Plus className="h-4 w-4" />
                إضافة قالب
              </Button>
            </CardHeader>
            <CardContent className="p-0">
              {templatesLoading ? (
                <div className="flex items-center justify-center py-12">
                  <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>الاسم</TableHead>
                      <TableHead>النوع</TableHead>
                      <TableHead>القناة</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead className="w-12"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {templates.map((template) => (
                      <TableRow key={template._id}>
                        <TableCell>
                          <div>
                            <p className="font-medium">
                              {template.nameAr || template.name}
                            </p>
                            <p className="text-xs text-gray-500">
                              {template.name}
                            </p>
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant="outline">
                            {template.type === "order"
                              ? "طلبات"
                              : template.type === "promotion"
                              ? "ترويج"
                              : template.type === "stock"
                              ? "مخزون"
                              : "نظام"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            {getChannelIcon(template.channel)}
                            <span>
                              {template.channel === "push"
                                ? "Push"
                                : template.channel === "email"
                                ? "Email"
                                : "SMS"}
                            </span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={template.isActive ? "success" : "default"}
                          >
                            {template.isActive ? "نشط" : "غير نشط"}
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
                              <DropdownMenuItem
                                onClick={() => handleOpenEditTemplate(template)}
                              >
                                <Pencil className="h-4 w-4" />
                                تعديل
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
                        </TableCell>
                      </TableRow>
                    ))}
                    {templates.length === 0 && (
                      <TableRow>
                        <TableCell
                          colSpan={5}
                          className="text-center py-8 text-gray-500"
                        >
                          لا توجد قوالب
                        </TableCell>
                      </TableRow>
                    )}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Campaigns Tab */}
        <TabsContent value="campaigns" className="mt-4">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between">
              <CardTitle className="flex items-center gap-2">
                <Rocket className="h-5 w-5" />
                الحملات
              </CardTitle>
              <Button onClick={() => setIsCampaignDialogOpen(true)}>
                <Plus className="h-4 w-4" />
                إنشاء حملة
              </Button>
            </CardHeader>
            <CardContent className="p-0">
              {campaignsLoading ? (
                <div className="flex items-center justify-center py-12">
                  <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>العنوان</TableHead>
                      <TableHead>النوع</TableHead>
                      <TableHead>الجمهور</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead>الإحصائيات</TableHead>
                      <TableHead className="w-12"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {campaigns.map((campaign) => (
                      <TableRow key={campaign._id}>
                        <TableCell>
                          <div>
                            <p className="font-medium">{campaign.title}</p>
                            <p className="text-xs text-gray-500 truncate max-w-[200px]">
                              {campaign.body}
                            </p>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            {getChannelIcon(campaign.type)}
                            <span>{campaign.type}</span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant="outline">
                            {campaign.targetAudience === "all"
                              ? "الجميع"
                              : campaign.targetAudience === "segment"
                              ? "شريحة"
                              : "محدد"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={
                              campaign.status === "sent"
                                ? "success"
                                : campaign.status === "scheduled"
                                ? "warning"
                                : "default"
                            }
                          >
                            {campaign.status === "draft"
                              ? "مسودة"
                              : campaign.status === "scheduled"
                              ? "مجدول"
                              : campaign.status === "sent"
                              ? "مرسل"
                              : "فشل"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="text-xs">
                            <span className="text-green-600">
                              {campaign.stats?.sent || 0} مرسل
                            </span>
                            {campaign.stats?.opened > 0 && (
                              <span className="text-gray-500 ms-2">
                                {campaign.stats.opened} مفتوح
                              </span>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          {campaign.status === "draft" && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() =>
                                launchCampaignMutation.mutate(campaign._id)
                              }
                              disabled={launchCampaignMutation.isPending}
                            >
                              <Rocket className="h-4 w-4" />
                            </Button>
                          )}
                        </TableCell>
                      </TableRow>
                    ))}
                    {campaigns.length === 0 && (
                      <TableRow>
                        <TableCell
                          colSpan={6}
                          className="text-center py-8 text-gray-500"
                        >
                          لا توجد حملات
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

      {/* Template Dialog */}
      <Dialog
        open={isTemplateDialogOpen}
        onOpenChange={setIsTemplateDialogOpen}
      >
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>
              {editingTemplate ? "تعديل القالب" : "إضافة قالب جديد"}
            </DialogTitle>
            <DialogDescription>أدخل بيانات قالب الإشعار</DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>
                  الاسم (EN) <span className="text-red-500">*</span>
                </Label>
                <Input
                  value={templateForm.name}
                  onChange={(e) =>
                    setTemplateForm({ ...templateForm, name: e.target.value })
                  }
                />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  value={templateForm.nameAr}
                  onChange={(e) =>
                    setTemplateForm({ ...templateForm, nameAr: e.target.value })
                  }
                />
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>النوع</Label>
                <select
                  value={templateForm.type}
                  onChange={(e) =>
                    setTemplateForm({
                      ...templateForm,
                      type: e.target.value as
                        | "order"
                        | "promotion"
                        | "system"
                        | "stock",
                    })
                  }
                  className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm"
                >
                  <option value="order">طلبات</option>
                  <option value="promotion">ترويج</option>
                  <option value="stock">مخزون</option>
                  <option value="system">نظام</option>
                </select>
              </div>
              <div className="space-y-2">
                <Label>القناة</Label>
                <select
                  value={templateForm.channel}
                  onChange={(e) =>
                    setTemplateForm({
                      ...templateForm,
                      channel: e.target.value as "push" | "email" | "sms",
                    })
                  }
                  className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm"
                >
                  <option value="push">إشعار فوري</option>
                  <option value="email">بريد إلكتروني</option>
                  <option value="sms">رسالة نصية</option>
                </select>
              </div>
            </div>
            <div className="space-y-2">
              <Label>
                عنوان الإشعار <span className="text-red-500">*</span>
              </Label>
              <Input
                value={templateForm.titleTemplate}
                onChange={(e) =>
                  setTemplateForm({
                    ...templateForm,
                    titleTemplate: e.target.value,
                  })
                }
                placeholder="استخدم {{variable}} للمتغيرات"
              />
            </div>
            <div className="space-y-2">
              <Label>محتوى الإشعار</Label>
              <Textarea
                value={templateForm.bodyTemplate}
                onChange={(e) =>
                  setTemplateForm({
                    ...templateForm,
                    bodyTemplate: e.target.value,
                  })
                }
                placeholder="استخدم {{variable}} للمتغيرات"
              />
            </div>
            <div className="flex items-center gap-2">
              <Switch
                checked={templateForm.isActive}
                onCheckedChange={(checked) =>
                  setTemplateForm({ ...templateForm, isActive: checked })
                }
              />
              <Label>نشط</Label>
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setIsTemplateDialogOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleSubmitTemplate}
              disabled={
                !templateForm.name ||
                !templateForm.titleTemplate ||
                createTemplateMutation.isPending ||
                updateTemplateMutation.isPending
              }
            >
              {(createTemplateMutation.isPending ||
                updateTemplateMutation.isPending) && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              {editingTemplate ? "حفظ" : "إضافة"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Campaign Dialog */}
      <Dialog
        open={isCampaignDialogOpen}
        onOpenChange={setIsCampaignDialogOpen}
      >
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>إنشاء حملة جديدة</DialogTitle>
            <DialogDescription>أدخل بيانات الحملة</DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>
                العنوان <span className="text-red-500">*</span>
              </Label>
              <Input
                value={campaignForm.title}
                onChange={(e) =>
                  setCampaignForm({ ...campaignForm, title: e.target.value })
                }
              />
            </div>
            <div className="space-y-2">
              <Label>
                المحتوى <span className="text-red-500">*</span>
              </Label>
              <Textarea
                value={campaignForm.body}
                onChange={(e) =>
                  setCampaignForm({ ...campaignForm, body: e.target.value })
                }
              />
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>النوع</Label>
                <select
                  value={campaignForm.type}
                  onChange={(e) =>
                    setCampaignForm({
                      ...campaignForm,
                      type: e.target.value as "push" | "email" | "sms",
                    })
                  }
                  className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm"
                >
                  <option value="push">إشعار فوري</option>
                  <option value="email">بريد إلكتروني</option>
                  <option value="sms">رسالة نصية</option>
                </select>
              </div>
              <div className="space-y-2">
                <Label>الجمهور المستهدف</Label>
                <select
                  value={campaignForm.targetAudience}
                  onChange={(e) =>
                    setCampaignForm({
                      ...campaignForm,
                      targetAudience: e.target.value as
                        | "all"
                        | "segment"
                        | "specific",
                    })
                  }
                  className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm"
                >
                  <option value="all">جميع العملاء</option>
                  <option value="segment">شريحة محددة</option>
                  <option value="specific">عملاء محددين</option>
                </select>
              </div>
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setIsCampaignDialogOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleSubmitCampaign}
              disabled={
                !campaignForm.title ||
                !campaignForm.body ||
                createCampaignMutation.isPending
              }
            >
              {createCampaignMutation.isPending && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              إنشاء الحملة
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Send Notification Dialog */}
      <Dialog open={isSendDialogOpen} onOpenChange={setIsSendDialogOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Send className="h-5 w-5" />
              إرسال إشعار مخصص
            </DialogTitle>
            <DialogDescription>أرسل إشعار لعملاء محددين</DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>
                العنوان <span className="text-red-500">*</span>
              </Label>
              <Input
                value={sendForm.title}
                onChange={(e) =>
                  setSendForm({ ...sendForm, title: e.target.value })
                }
              />
            </div>
            <div className="space-y-2">
              <Label>
                المحتوى <span className="text-red-500">*</span>
              </Label>
              <Textarea
                value={sendForm.body}
                onChange={(e) =>
                  setSendForm({ ...sendForm, body: e.target.value })
                }
              />
            </div>
            <div className="space-y-2">
              <Label>
                معرفات العملاء <span className="text-red-500">*</span>
              </Label>
              <Textarea
                dir="ltr"
                value={sendForm.customerIds}
                onChange={(e) =>
                  setSendForm({ ...sendForm, customerIds: e.target.value })
                }
                placeholder="أدخل معرفات العملاء مفصولة بفواصل"
              />
            </div>
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setIsSendDialogOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleSendNotification}
              disabled={
                !sendForm.title ||
                !sendForm.body ||
                !sendForm.customerIds ||
                sendNotificationMutation.isPending
              }
            >
              {sendNotificationMutation.isPending && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              إرسال
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
