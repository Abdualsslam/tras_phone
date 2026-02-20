import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm } from "react-hook-form";
import { authApi, type PasswordResetRequest } from "@/api/auth.api";
import { toast } from "sonner";
import { getErrorMessage } from "@/api/client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import {
  MoreHorizontal,
  Eye,
  Loader2,
  AlertCircle,
  CheckCircle,
  XCircle,
  Clock,
  Key,
  Copy,
  User,
} from "lucide-react";
import { formatDate } from "@/lib/utils";

// ══════════════════════════════════════════════════════════════
// Status Configuration
// ══════════════════════════════════════════════════════════════

const statusConfig: Record<
  string,
  {
    label: string;
    variant: "default" | "secondary" | "success" | "warning" | "danger";
    icon: React.ReactNode;
  }
> = {
  pending: {
    label: "قيد الانتظار",
    variant: "warning",
    icon: <Clock className="h-3 w-3" />,
  },
  completed: {
    label: "مكتمل",
    variant: "success",
    icon: <CheckCircle className="h-3 w-3" />,
  },
  rejected: {
    label: "مرفوض",
    variant: "danger",
    icon: <XCircle className="h-3 w-3" />,
  },
};

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function PasswordResetRequestsPage() {
  const queryClient = useQueryClient();

  const [statusFilter, setStatusFilter] = useState<string>("_all");
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false);
  const [isProcessDialogOpen, setIsProcessDialogOpen] = useState(false);
  const [isRejectDialogOpen, setIsRejectDialogOpen] = useState(false);
  const [selectedRequest, setSelectedRequest] =
    useState<PasswordResetRequest | null>(null);
  const [generatedPassword, setGeneratedPassword] = useState<string | null>(
    null
  );

  // ─────────────────────────────────────────
  // Queries
  // ─────────────────────────────────────────

  const {
    data: requestsData,
    isLoading,
    error,
  } = useQuery({
    queryKey: ["password-reset-requests", statusFilter],
    queryFn: () =>
      authApi.getPasswordResetRequests({
        status: statusFilter === "_all" ? undefined : statusFilter,
      }),
  });

  const requests = requestsData?.items || [];

  // ─────────────────────────────────────────
  // Mutations
  // ─────────────────────────────────────────

  const processMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: { adminNotes?: string } }) =>
      authApi.processPasswordResetRequest(id, data),
    onSuccess: (result) => {
      queryClient.invalidateQueries({ queryKey: ["password-reset-requests"] });
      setGeneratedPassword(result.temporaryPassword);
      toast.success(
        "تم معالجة الطلب بنجاح. يرجى نسخ كلمة المرور وإرسالها للعميل."
      );
    },
    onError: (error) =>
      toast.error(getErrorMessage(error, "حدث خطأ أثناء معالجة الطلب")),
  });

  const rejectMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: { rejectionReason: string; adminNotes?: string };
    }) => authApi.rejectPasswordResetRequest(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["password-reset-requests"] });
      setIsRejectDialogOpen(false);
      setSelectedRequest(null);
      toast.success("تم رفض الطلب بنجاح");
    },
    onError: (error) =>
      toast.error(getErrorMessage(error, "حدث خطأ أثناء رفض الطلب")),
  });

  // ─────────────────────────────────────────
  // Forms
  // ─────────────────────────────────────────

  const processForm = useForm({
    defaultValues: {
      adminNotes: "",
    },
  });

  const rejectForm = useForm({
    defaultValues: {
      rejectionReason: "",
      adminNotes: "",
    },
  });

  // ─────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────

  const handleView = (request: PasswordResetRequest) => {
    setSelectedRequest(request);
    setIsViewDialogOpen(true);
  };

  const handleProcess = (request: PasswordResetRequest) => {
    setSelectedRequest(request);
    setGeneratedPassword(null);
    processForm.reset({ adminNotes: "" });
    setIsProcessDialogOpen(true);
  };

  const handleReject = (request: PasswordResetRequest) => {
    setSelectedRequest(request);
    rejectForm.reset({ rejectionReason: "", adminNotes: "" });
    setIsRejectDialogOpen(true);
  };

  const onProcessSubmit = (data: { adminNotes: string }) => {
    if (selectedRequest) {
      processMutation.mutate({
        id: selectedRequest._id,
        data: {
          adminNotes: data.adminNotes || undefined,
        },
      });
    }
  };

  const onRejectSubmit = (data: {
    rejectionReason: string;
    adminNotes: string;
  }) => {
    if (selectedRequest) {
      rejectMutation.mutate({
        id: selectedRequest._id,
        data: {
          rejectionReason: data.rejectionReason,
          adminNotes: data.adminNotes || undefined,
        },
      });
    }
  };

  const copyPassword = () => {
    if (generatedPassword) {
      navigator.clipboard.writeText(generatedPassword);
      toast.success("تم نسخ كلمة المرور");
    }
  };

  // ─────────────────────────────────────────
  // Stats
  // ─────────────────────────────────────────

  const pendingRequests = requests.filter((r) => r.status === "pending").length;
  const completedRequests = requests.filter(
    (r) => r.status === "completed"
  ).length;
  const rejectedRequests = requests.filter(
    (r) => r.status === "rejected"
  ).length;

  // ─────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center h-[400px] text-muted-foreground">
        <AlertCircle className="h-12 w-12 mb-4 text-destructive" />
        <p>حدث خطأ أثناء تحميل الطلبات</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold">طلبات إعادة تعيين كلمة المرور</h1>
          <p className="text-muted-foreground text-sm">
            معالجة طلبات إعادة تعيين كلمة المرور من العملاء
          </p>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                <Key className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">إجمالي الطلبات</p>
                <p className="text-2xl font-bold">{requests.length}</p>
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
                <p className="text-sm text-muted-foreground">قيد الانتظار</p>
                <p className="text-2xl font-bold">{pendingRequests}</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                <CheckCircle className="h-5 w-5 text-green-600 dark:text-green-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">مكتملة</p>
                <p className="text-2xl font-bold">{completedRequests}</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-red-100 dark:bg-red-900/30 rounded-lg">
                <XCircle className="h-5 w-5 text-red-600 dark:text-red-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">مرفوضة</p>
                <p className="text-2xl font-bold">{rejectedRequests}</p>
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
              <Key className="h-5 w-5" />
              قائمة الطلبات
            </CardTitle>
            <div className="flex gap-2 w-full sm:w-auto">
              <Select
                value={statusFilter || undefined}
                onValueChange={setStatusFilter}
              >
                <SelectTrigger className="w-40">
                  <SelectValue placeholder="جميع الحالات" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="_all">جميع الحالات</SelectItem>
                  <SelectItem value="pending">قيد الانتظار</SelectItem>
                  <SelectItem value="completed">مكتملة</SelectItem>
                  <SelectItem value="rejected">مرفوضة</SelectItem>
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
          ) : requests.length === 0 ? (
            <div className="text-center py-12 text-muted-foreground">
              <Key className="h-12 w-12 mx-auto mb-4 opacity-50" />
              <p>لا يوجد طلبات</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>رقم الطلب</TableHead>
                    <TableHead>رقم الهاتف</TableHead>
                    <TableHead>العميل</TableHead>
                    <TableHead>الحالة</TableHead>
                    <TableHead>التاريخ</TableHead>
                    <TableHead>ملاحظات العميل</TableHead>
                    <TableHead className="w-[50px]"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {requests.map((request) => {
                    const status =
                      statusConfig[request.status] || statusConfig.pending;
                    return (
                      <TableRow key={request._id}>
                        <TableCell>
                          <Badge variant="outline" className="font-mono">
                            {request.requestNumber}
                          </Badge>
                        </TableCell>
                        <TableCell className="font-medium">
                          {request.phone}
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <User className="h-4 w-4 text-muted-foreground" />
                            <span>
                              {typeof request.customerId === "object"
                                ? request.customerId.phone
                                : request.phone}
                            </span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={status.variant}
                            className="flex items-center gap-1 w-fit"
                          >
                            {status.icon}
                            {status.label}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-muted-foreground">
                          {formatDate(request.createdAt)}
                        </TableCell>
                        <TableCell className="text-muted-foreground max-w-xs truncate">
                          {request.customerNotes || "-"}
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
                                onClick={() => handleView(request)}
                              >
                                <Eye className="h-4 w-4 ml-2" />
                                عرض التفاصيل
                              </DropdownMenuItem>
                              {request.status === "pending" && (
                                <>
                                  <DropdownMenuItem
                                    onClick={() => handleProcess(request)}
                                  >
                                    <CheckCircle className="h-4 w-4 ml-2" />
                                    معالجة
                                  </DropdownMenuItem>
                                  <DropdownMenuItem
                                    onClick={() => handleReject(request)}
                                    className="text-red-600"
                                  >
                                    <XCircle className="h-4 w-4 ml-2" />
                                    رفض
                                  </DropdownMenuItem>
                                </>
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

      {/* View Dialog */}
      <Dialog open={isViewDialogOpen} onOpenChange={setIsViewDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Badge variant="outline" className="font-mono">
                {selectedRequest?.requestNumber}
              </Badge>
              تفاصيل طلب إعادة تعيين كلمة المرور
            </DialogTitle>
          </DialogHeader>
          {selectedRequest && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <p className="text-muted-foreground">رقم الهاتف</p>
                  <p className="font-medium">{selectedRequest.phone}</p>
                </div>
                <div>
                  <p className="text-muted-foreground">الحالة</p>
                  <Badge
                    variant={
                      statusConfig[selectedRequest.status]?.variant || "default"
                    }
                  >
                    {statusConfig[selectedRequest.status]?.label ||
                      selectedRequest.status}
                  </Badge>
                </div>
                <div>
                  <p className="text-muted-foreground">تاريخ الطلب</p>
                  <p className="font-medium">
                    {formatDate(selectedRequest.createdAt)}
                  </p>
                </div>
                {selectedRequest.processedAt && (
                  <div>
                    <p className="text-muted-foreground">تاريخ المعالجة</p>
                    <p className="font-medium">
                      {formatDate(selectedRequest.processedAt)}
                    </p>
                  </div>
                )}
                {selectedRequest.processedBy &&
                  typeof selectedRequest.processedBy === "object" && (
                    <div>
                      <p className="text-muted-foreground">معالج بواسطة</p>
                      <p className="font-medium">
                        {selectedRequest.processedBy.fullName}
                      </p>
                    </div>
                  )}
                {selectedRequest.rejectionReason && (
                  <div className="col-span-2">
                    <p className="text-muted-foreground">سبب الرفض</p>
                    <p className="font-medium">
                      {selectedRequest.rejectionReason}
                    </p>
                  </div>
                )}
              </div>
              {selectedRequest.customerNotes && (
                <div>
                  <p className="text-muted-foreground mb-2">ملاحظات العميل</p>
                  <p className="text-sm bg-muted p-3 rounded-md">
                    {selectedRequest.customerNotes}
                  </p>
                </div>
              )}
              {selectedRequest.adminNotes && (
                <div>
                  <p className="text-muted-foreground mb-2">ملاحظات المشرف</p>
                  <p className="text-sm bg-muted p-3 rounded-md">
                    {selectedRequest.adminNotes}
                  </p>
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>

      {/* Process Dialog */}
      <Dialog open={isProcessDialogOpen} onOpenChange={setIsProcessDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>معالجة طلب إعادة تعيين كلمة المرور</DialogTitle>
            <DialogDescription>
              سيتم توليد كلمة مرور جديدة للعميل. يرجى نسخها وإرسالها للعميل
              يدوياً.
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={processForm.handleSubmit(onProcessSubmit)}
            className="space-y-4"
          >
            {!generatedPassword ? (
              <>
                <div>
                  <Label htmlFor="adminNotes">ملاحظات (اختياري)</Label>
                  <Textarea
                    id="adminNotes"
                    {...processForm.register("adminNotes")}
                    placeholder="ملاحظات حول معالجة الطلب..."
                    rows={3}
                  />
                </div>
                <DialogFooter>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => setIsProcessDialogOpen(false)}
                  >
                    إلغاء
                  </Button>
                  <Button type="submit" disabled={processMutation.isPending}>
                    {processMutation.isPending ? (
                      <>
                        <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                        جاري المعالجة...
                      </>
                    ) : (
                      "توليد كلمة المرور ومعالجة الطلب"
                    )}
                  </Button>
                </DialogFooter>
              </>
            ) : (
              <>
                <div className="space-y-2">
                  <Label>كلمة المرور المؤقتة</Label>
                  <div className="flex gap-2">
                    <Input
                      value={generatedPassword}
                      readOnly
                      className="font-mono"
                    />
                    <Button
                      type="button"
                      variant="outline"
                      size="icon"
                      onClick={copyPassword}
                    >
                      <Copy className="h-4 w-4" />
                    </Button>
                  </div>
                  <p className="text-xs text-muted-foreground">
                    يرجى نسخ كلمة المرور وإرسالها للعميل عبر واتساب أو إيميل أو
                    هاتف.
                  </p>
                </div>
                <DialogFooter>
                  <Button
                    type="button"
                    onClick={() => {
                      setIsProcessDialogOpen(false);
                      setGeneratedPassword(null);
                      setSelectedRequest(null);
                    }}
                  >
                    إغلاق
                  </Button>
                </DialogFooter>
              </>
            )}
          </form>
        </DialogContent>
      </Dialog>

      {/* Reject Dialog */}
      <Dialog open={isRejectDialogOpen} onOpenChange={setIsRejectDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>رفض طلب إعادة تعيين كلمة المرور</DialogTitle>
            <DialogDescription>يرجى إضافة سبب الرفض.</DialogDescription>
          </DialogHeader>
          <form
            onSubmit={rejectForm.handleSubmit(onRejectSubmit)}
            className="space-y-4"
          >
            <div>
              <Label htmlFor="rejectionReason">سبب الرفض *</Label>
              <Textarea
                id="rejectionReason"
                {...rejectForm.register("rejectionReason", {
                  required: "سبب الرفض مطلوب",
                })}
                placeholder="مثال: لم يتم التحقق من هوية العميل..."
                rows={3}
              />
              {rejectForm.formState.errors.rejectionReason && (
                <p className="text-xs text-destructive mt-1">
                  {rejectForm.formState.errors.rejectionReason.message}
                </p>
              )}
            </div>
            <div>
              <Label htmlFor="rejectAdminNotes">ملاحظات (اختياري)</Label>
              <Textarea
                id="rejectAdminNotes"
                {...rejectForm.register("adminNotes")}
                placeholder="ملاحظات إضافية..."
                rows={2}
              />
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsRejectDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                variant="destructive"
                disabled={rejectMutation.isPending}
              >
                {rejectMutation.isPending ? (
                  <>
                    <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                    جاري الحفظ...
                  </>
                ) : (
                  "رفض الطلب"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
