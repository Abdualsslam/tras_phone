import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm } from "react-hook-form";
import { returnsApi, type Return, type ReturnItem } from "@/api/returns.api";
import { toast } from "sonner";
import { getErrorMessage } from "@/api/client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
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
import {
  MoreHorizontal,
  Eye,
  Loader2,
  AlertCircle,
  RotateCcw,
  CheckCircle,
  XCircle,
  Clock,
  DollarSign,
  Package,
  ClipboardCheck,
} from "lucide-react";
import { formatCurrency, formatDate } from "@/lib/utils";

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
  approved: {
    label: "موافق عليه",
    variant: "default",
    icon: <CheckCircle className="h-3 w-3" />,
  },
  rejected: {
    label: "مرفوض",
    variant: "danger",
    icon: <XCircle className="h-3 w-3" />,
  },
  processing: {
    label: "قيد المعالجة",
    variant: "default",
    icon: <Package className="h-3 w-3" />,
  },
  pickup_scheduled: {
    label: "تم جدولة الاستلام",
    variant: "default",
    icon: <Package className="h-3 w-3" />,
  },
  picked_up: {
    label: "تم الاستلام",
    variant: "default",
    icon: <Package className="h-3 w-3" />,
  },
  inspecting: {
    label: "قيد الفحص",
    variant: "default",
    icon: <ClipboardCheck className="h-3 w-3" />,
  },
  refunded: {
    label: "تم الاسترداد",
    variant: "success",
    icon: <DollarSign className="h-3 w-3" />,
  },
  completed: {
    label: "مكتمل",
    variant: "success",
    icon: <CheckCircle className="h-3 w-3" />,
  },
  cancelled: {
    label: "ملغي",
    variant: "danger",
    icon: <XCircle className="h-3 w-3" />,
  },
};

const conditionLabels: Record<string, string> = {
  unopened: "غير مفتوح",
  opened: "مفتوح",
  damaged: "تالف",
  defective: "معيب",
};

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function ReturnsPage() {
  const queryClient = useQueryClient();

  const [statusFilter, setStatusFilter] = useState<string>("_all");
  const [isViewDialogOpen, setIsViewDialogOpen] = useState(false);
  const [isInspectDialogOpen, setIsInspectDialogOpen] = useState(false);
  const [isRefundDialogOpen, setIsRefundDialogOpen] = useState(false);
  const [selectedReturn, setSelectedReturn] = useState<Return | null>(null);
  const [selectedItem, setSelectedItem] = useState<ReturnItem | null>(null);

  // ─────────────────────────────────────────
  // Queries
  // ─────────────────────────────────────────

  const {
    data: returnsData,
    isLoading,
    error,
  } = useQuery({
    queryKey: ["returns", statusFilter],
    queryFn: () =>
      returnsApi.getAll({
        status: statusFilter === "_all" ? undefined : statusFilter,
      }),
  });

  const returns = returnsData?.items || [];

  // Unused but kept for future use
  // const { data: reasons = [] } = useQuery({
  //     queryKey: ['return-reasons'],
  //     queryFn: () => returnsApi.getReasons(),
  // });

  // ─────────────────────────────────────────
  // Mutations
  // ─────────────────────────────────────────

  const updateStatusMutation = useMutation({
    mutationFn: ({
      id,
      status,
      adminNotes,
    }: {
      id: string;
      status: string;
      adminNotes?: string;
    }) => returnsApi.updateStatus(id, { status, adminNotes }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["returns"] });
      toast.success("تم تحديث حالة المرتجع");
    },
    onError: (error) =>
      toast.error(getErrorMessage(error, "حدث خطأ أثناء تحديث الحالة")),
  });

  const inspectMutation = useMutation({
    mutationFn: ({
      returnId,
      itemId,
      data,
    }: {
      returnId: string;
      itemId: string;
      data: { condition: string; inspectionNotes?: string; approved: boolean };
    }) => returnsApi.inspectItem(returnId, itemId, data as any),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["returns"] });
      setIsInspectDialogOpen(false);
      setSelectedItem(null);
      toast.success("تم حفظ نتيجة الفحص");
    },
    onError: (error) =>
      toast.error(getErrorMessage(error, "حدث خطأ أثناء حفظ الفحص")),
  });

  const refundMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: { refundMethod: string; amount: number; notes?: string };
    }) => returnsApi.processRefund(id, data as any),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["returns"] });
      setIsRefundDialogOpen(false);
      setSelectedReturn(null);
      toast.success("تم معالجة الاسترداد بنجاح");
    },
    onError: (error) =>
      toast.error(getErrorMessage(error, "حدث خطأ أثناء معالجة الاسترداد")),
  });

  // ─────────────────────────────────────────
  // Forms
  // ─────────────────────────────────────────

  const inspectForm = useForm({
    defaultValues: {
      condition: "unopened",
      inspectionNotes: "",
      approved: true,
    },
  });

  const refundForm = useForm({
    defaultValues: {
      refundAmount: 0,
      notes: "",
    },
  });

  // ─────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────

  const handleView = (ret: Return) => {
    setSelectedReturn(ret);
    setIsViewDialogOpen(true);
  };

  const handleInspect = (ret: Return, item: ReturnItem) => {
    setSelectedReturn(ret);
    setSelectedItem(item);
    inspectForm.reset({
      condition: item.condition || "unopened",
      inspectionNotes: item.inspectionNotes || "",
      approved: item.inspectionStatus !== "rejected",
    });
    setIsInspectDialogOpen(true);
  };

  const handleRefund = (ret: Return) => {
    setSelectedReturn(ret);
    refundForm.reset({
      refundAmount: ret.refundAmount || ret.subtotal,
      notes: "",
    });
    setIsRefundDialogOpen(true);
  };

  const handleStatusChange = (returnId: string, newStatus: string) => {
    updateStatusMutation.mutate({ id: returnId, status: newStatus });
  };

  const onInspectSubmit = (data: {
    condition: string;
    inspectionNotes: string;
    approved: boolean;
  }) => {
    if (selectedItem && selectedReturn) {
      inspectMutation.mutate({
        returnId: selectedReturn._id,
        itemId: selectedItem._id,
          data: {
          condition: data.condition,
          inspectionNotes: data.inspectionNotes || undefined,
          approved: data.approved,
        },
      });
    }
  };

  const onRefundSubmit = (data: { refundAmount: number; notes: string }) => {
    if (selectedReturn) {
      refundMutation.mutate({
        id: selectedReturn._id,
        data: {
          refundMethod: "wallet", // Default to wallet refund
          amount: data.refundAmount,
          notes: data.notes || undefined,
        },
      });
    }
  };

  // ─────────────────────────────────────────
  // Stats
  // ─────────────────────────────────────────

  const pendingReturns = returns.filter((r) => r.status === "pending").length;
  const processingReturns = returns.filter((r) =>
    ["approved", "pickup_scheduled", "picked_up", "inspecting", "processing"].includes(r.status)
  ).length;
  const totalRefunded = returns.reduce(
    (sum, r) => sum + (Number(r.refundAmount) || 0),
    0
  );

  // ─────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center h-[400px] text-muted-foreground">
        <AlertCircle className="h-12 w-12 mb-4 text-destructive" />
        <p>حدث خطأ أثناء تحميل المرتجعات</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-bold">إدارة المرتجعات</h1>
          <p className="text-muted-foreground text-sm">
            معالجة طلبات الإرجاع والاستردادات
          </p>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                <RotateCcw className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">
                  إجمالي المرتجعات
                </p>
                <p className="text-2xl font-bold">{returns.length}</p>
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
                <p className="text-2xl font-bold">{pendingReturns}</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                <Package className="h-5 w-5 text-purple-600 dark:text-purple-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">قيد المعالجة</p>
                <p className="text-2xl font-bold">{processingReturns}</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                <DollarSign className="h-5 w-5 text-green-600 dark:text-green-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">إجمالي المسترد</p>
                <p className="text-2xl font-bold">
                  {formatCurrency(totalRefunded)}
                </p>
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
              <RotateCcw className="h-5 w-5" />
              طلبات الإرجاع
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
                  <SelectItem value="approved">موافق عليه</SelectItem>
                  <SelectItem value="rejected">مرفوض</SelectItem>
                  <SelectItem value="pickup_scheduled">تم جدولة الاستلام</SelectItem>
                  <SelectItem value="picked_up">تم الاستلام</SelectItem>
                  <SelectItem value="inspecting">قيد الفحص</SelectItem>
                  <SelectItem value="completed">مكتمل</SelectItem>
                  <SelectItem value="cancelled">ملغي</SelectItem>
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
          ) : returns.length === 0 ? (
            <div className="text-center py-12 text-muted-foreground">
              <RotateCcw className="h-12 w-12 mx-auto mb-4 opacity-50" />
              <p>لا يوجد طلبات إرجاع</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>رقم المرتجع</TableHead>
                    <TableHead>رقم الطلب</TableHead>
                    <TableHead>العميل</TableHead>
                    <TableHead>الحالة</TableHead>
                    <TableHead>المنتجات</TableHead>
                    <TableHead>المبلغ</TableHead>
                    <TableHead>التاريخ</TableHead>
                    <TableHead className="w-[50px]"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {returns.map((ret) => {
                    const status =
                      statusConfig[ret.status] || statusConfig.pending;
                    return (
                      <TableRow key={ret._id}>
                        <TableCell>
                          <Badge variant="outline" className="font-mono">
                            {ret.returnNumber}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          {ret.orderNumbers && ret.orderNumbers.length > 1 ? (
                            <div className="flex flex-col gap-1">
                              {ret.orderNumbers.map((orderNumber, idx) => (
                                <Badge
                                  key={idx}
                                  variant="outline"
                                  className="font-mono text-xs"
                                >
                                  {orderNumber}
                                </Badge>
                              ))}
                            </div>
                          ) : (
                            <span className="font-mono text-sm">
                              {ret.orderNumber || ret.orderNumbers?.[0]}
                            </span>
                          )}
                        </TableCell>
                        <TableCell>
                          <p className="font-medium">{ret.customerName}</p>
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
                        <TableCell>{ret.items?.length || 0} منتج</TableCell>
                        <TableCell className="font-medium">
                          {formatCurrency(ret.subtotal)}
                        </TableCell>
                        <TableCell className="text-muted-foreground">
                          {formatDate(ret.createdAt)}
                        </TableCell>
                        <TableCell>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem onClick={() => handleView(ret)}>
                                <Eye className="h-4 w-4 ms-2" />
                                عرض التفاصيل
                              </DropdownMenuItem>
                              {ret.status === "pending" && (
                                <>
                                  <DropdownMenuItem
                                    onClick={() =>
                                      handleStatusChange(ret._id, "approved")
                                    }
                                  >
                                    <CheckCircle className="h-4 w-4 ms-2" />
                                    موافقة
                                  </DropdownMenuItem>
                                  <DropdownMenuItem
                                    onClick={() =>
                                      handleStatusChange(ret._id, "rejected")
                                    }
                                    className="text-red-600"
                                  >
                                    <XCircle className="h-4 w-4 ms-2" />
                                    رفض
                                  </DropdownMenuItem>
                                </>
                              )}
                              {ret.status === "approved" && (
                                <DropdownMenuItem
                                  onClick={() =>
                                    handleStatusChange(ret._id, "inspecting")
                                  }
                                >
                                  <Package className="h-4 w-4 ms-2" />
                                  بدء الفحص
                                </DropdownMenuItem>
                              )}
                              {ret.status === "inspecting" && (
                                <DropdownMenuItem
                                  onClick={() => handleRefund(ret)}
                                >
                                  <DollarSign className="h-4 w-4 ms-2" />
                                  معالجة الاسترداد
                                </DropdownMenuItem>
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
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Badge variant="outline" className="font-mono">
                {selectedReturn?.returnNumber}
              </Badge>
              تفاصيل طلب الإرجاع
            </DialogTitle>
          </DialogHeader>
          {selectedReturn && (
            <div className="space-y-4">
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                <div>
                  <p className="text-muted-foreground">رقم الطلب</p>
                  <p className="font-medium font-mono">
                    {selectedReturn.orderNumber}
                  </p>
                </div>
                <div>
                  <p className="text-muted-foreground">العميل</p>
                  <p className="font-medium">{selectedReturn.customerName}</p>
                </div>
                <div>
                  <p className="text-muted-foreground">الحالة</p>
                  <Badge
                    variant={
                      statusConfig[selectedReturn.status]?.variant || "default"
                    }
                  >
                    {statusConfig[selectedReturn.status]?.label ||
                      selectedReturn.status}
                  </Badge>
                </div>
                <div>
                  <p className="text-muted-foreground">التاريخ</p>
                  <p className="font-medium">
                    {formatDate(selectedReturn.createdAt)}
                  </p>
                </div>
              </div>

              <div className="border rounded-lg overflow-hidden">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>المنتج</TableHead>
                      <TableHead className="text-center">الكمية</TableHead>
                      <TableHead>السبب</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead>الفحص</TableHead>
                      <TableHead className="w-[80px]"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {selectedReturn.items?.map((item) => (
                      <TableRow key={item._id}>
                        <TableCell>
                          <div className="flex items-center gap-3">
                            {item.productImage && (
                              <img
                                src={item.productImage}
                                alt={item.productName}
                                className="w-10 h-10 object-cover rounded"
                              />
                            )}
                            <div>
                              <p className="font-medium">{item.productName}</p>
                              <p className="text-xs text-muted-foreground">
                                {item.sku}
                              </p>
                            </div>
                          </div>
                        </TableCell>
                        <TableCell className="text-center">
                          {item.quantity}
                        </TableCell>
                        <TableCell>{item.returnReason}</TableCell>
                        <TableCell>
                          {item.condition && (
                            <Badge variant="outline">
                              {conditionLabels[item.condition] ||
                                item.condition}
                            </Badge>
                          )}
                        </TableCell>
                        <TableCell>
                          {item.inspectionStatus === "approved" && (
                            <Badge variant="success">مقبول</Badge>
                          )}
                          {item.inspectionStatus === "rejected" && (
                            <Badge variant="danger">مرفوض</Badge>
                          )}
                          {item.inspectionStatus === "pending" && (
                            <Badge variant="warning">قيد الفحص</Badge>
                          )}
                        </TableCell>
                        <TableCell>
                          {["approved", "processing"].includes(
                            selectedReturn.status
                          ) && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() =>
                                handleInspect(selectedReturn, item)
                              }
                            >
                              <ClipboardCheck className="h-4 w-4" />
                            </Button>
                          )}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>

              <div className="flex justify-end">
                <div className="w-64 space-y-2 text-sm">
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">المجموع:</span>
                    <span className="font-medium">
                      {formatCurrency(selectedReturn.subtotal)}
                    </span>
                  </div>
                  {selectedReturn.refundAmount > 0 && (
                    <div className="flex justify-between pt-2 border-t">
                      <span className="text-muted-foreground">
                        المبلغ المسترد:
                      </span>
                      <span className="font-medium text-green-600">
                        {formatCurrency(selectedReturn.refundAmount)}
                      </span>
                    </div>
                  )}
                </div>
              </div>

              {selectedReturn.notes && (
                <div className="p-3 bg-muted rounded-lg">
                  <p className="text-sm text-muted-foreground">
                    ملاحظات العميل:
                  </p>
                  <p className="text-sm">{selectedReturn.notes}</p>
                </div>
              )}
              {selectedReturn.adminNotes && (
                <div className="p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                  <p className="text-sm text-muted-foreground">
                    ملاحظات الإدارة:
                  </p>
                  <p className="text-sm">{selectedReturn.adminNotes}</p>
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setIsViewDialogOpen(false)}
            >
              إغلاق
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Inspect Dialog */}
      <Dialog open={isInspectDialogOpen} onOpenChange={setIsInspectDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>فحص المنتج</DialogTitle>
          </DialogHeader>
          <form
            onSubmit={inspectForm.handleSubmit(onInspectSubmit)}
            className="space-y-4"
          >
            <div className="p-3 bg-muted rounded-lg">
              <p className="font-medium">{selectedItem?.productName}</p>
              <p className="text-sm text-muted-foreground">
                الكمية: {selectedItem?.quantity}
              </p>
            </div>

            <div className="space-y-2">
              <Label>حالة المنتج</Label>
              <Select
                value={inspectForm.watch("condition")}
                onValueChange={(value: string) =>
                  inspectForm.setValue("condition", value)
                }
              >
                <SelectTrigger>
                  <SelectValue placeholder="اختر الحالة" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="unopened">غير مفتوح</SelectItem>
                  <SelectItem value="opened">مفتوح</SelectItem>
                  <SelectItem value="damaged">تالف</SelectItem>
                  <SelectItem value="defective">معيب</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label>ملاحظات الفحص</Label>
              <Textarea
                {...inspectForm.register("inspectionNotes")}
                placeholder="ملاحظات حول حالة المنتج..."
              />
            </div>

            <div className="flex items-center gap-4">
              <Button
                type="button"
                variant={inspectForm.watch("approved") ? "default" : "outline"}
                onClick={() => inspectForm.setValue("approved", true)}
              >
                <CheckCircle className="h-4 w-4 ms-2" />
                قبول
              </Button>
              <Button
                type="button"
                variant={
                  !inspectForm.watch("approved") ? "destructive" : "outline"
                }
                onClick={() => inspectForm.setValue("approved", false)}
              >
                <XCircle className="h-4 w-4 ms-2" />
                رفض
              </Button>
            </div>

            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsInspectDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button type="submit" disabled={inspectMutation.isPending}>
                {inspectMutation.isPending && (
                  <Loader2 className="h-4 w-4 ms-2 animate-spin" />
                )}
                حفظ
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Refund Dialog */}
      <Dialog open={isRefundDialogOpen} onOpenChange={setIsRefundDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>معالجة الاسترداد</DialogTitle>
          </DialogHeader>
          <form
            onSubmit={refundForm.handleSubmit(onRefundSubmit)}
            className="space-y-4"
          >
            <div className="p-3 bg-muted rounded-lg">
              <p className="text-sm text-muted-foreground">
                رقم المرتجع: <strong>{selectedReturn?.returnNumber}</strong>
              </p>
              <p className="text-sm text-muted-foreground">
                إجمالي المنتجات:{" "}
                <strong>{formatCurrency(selectedReturn?.subtotal || 0)}</strong>
              </p>
            </div>

            <div className="p-3 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
              <p className="text-sm text-blue-700 dark:text-blue-300">
                💰 سيتم إضافة المبلغ تلقائياً إلى محفظة العميل
              </p>
            </div>

            <div className="space-y-2">
              <Label>مبلغ الاسترداد</Label>
              <Input
                type="number"
                step="0.01"
                {...refundForm.register("refundAmount", {
                  valueAsNumber: true,
                })}
              />
            </div>

            <div className="space-y-2">
              <Label>ملاحظات</Label>
              <Textarea
                {...refundForm.register("notes")}
                placeholder="ملاحظات إضافية..."
              />
            </div>

            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsRefundDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button type="submit" disabled={refundMutation.isPending}>
                {refundMutation.isPending && (
                  <Loader2 className="h-4 w-4 ms-2 animate-spin" />
                )}
                تأكيد الاسترداد
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export default ReturnsPage;
