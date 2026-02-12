import { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  ordersApi,
  type OrderNote,
  type OrderShipment,
  type CreateShipmentDto,
} from "@/api/orders.api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  Truck,
  CreditCard,
  Loader2,
  MessageSquare,
  Send,
  Plus,
  RefreshCw,
} from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { formatCurrency, formatDate } from "@/lib/utils";

// Single source of truth for order statuses (matches backend)
const ORDER_STATUS_KEYS = [
  "pending",
  "confirmed",
  "processing",
  "ready_for_pickup",
  "shipped",
  "out_for_delivery",
  "delivered",
  "completed",
  "cancelled",
  "refunded",
] as const;

const orderStatusVariants: Record<
  string,
  "success" | "warning" | "danger" | "default"
> = {
  pending: "warning",
  confirmed: "default",
  processing: "default",
  ready_for_pickup: "default",
  shipped: "success",
  out_for_delivery: "success",
  delivered: "success",
  completed: "success",
  cancelled: "danger",
  refunded: "danger",
};

const orderStatusLabels: Record<string, string> = {
  pending: "قيد الانتظار",
  confirmed: "مؤكد",
  processing: "قيد المعالجة",
  ready_for_pickup: "جاهز للاستلام",
  shipped: "تم الشحن",
  out_for_delivery: "خارج للتوصيل",
  delivered: "تم التوصيل",
  completed: "مكتمل",
  cancelled: "ملغي",
  refunded: "مسترد",
};

// Main flow for stepper (display order)
const ORDER_STATUS_FLOW: string[] = [
  "pending",
  "confirmed",
  "processing",
  "ready_for_pickup",
  "shipped",
  "out_for_delivery",
  "delivered",
  "completed",
];

const paymentStatusVariants: Record<string, "success" | "warning" | "danger"> =
  {
    paid: "success",
    pending: "warning",
    partially_paid: "warning",
    failed: "danger",
    refunded: "danger",
  };

const paymentStatusLabels: Record<string, string> = {
  paid: "مدفوع",
  pending: "غير مدفوع",
  partially_paid: "مدفوع جزئياً",
  failed: "فشل",
  refunded: "مسترد",
};

export function OrderDetailsPage() {
  const { orderId } = useParams<{ orderId: string }>();
  const navigate = useNavigate();
  const { i18n } = useTranslation();
  const queryClient = useQueryClient();
  const [isShipmentDialogOpen, setIsShipmentDialogOpen] = useState(false);
  const [isPaymentDialogOpen, setIsPaymentDialogOpen] = useState(false);
  const [isStatusDialogOpen, setIsStatusDialogOpen] = useState(false);
  const [noteContent, setNoteContent] = useState("");
  const [newStatus, setNewStatus] = useState("");
  const [statusDialogNote, setStatusDialogNote] = useState("");
  const [shipmentData, setShipmentData] = useState({
    trackingNumber: "",
    carrier: "",
  });
  const [paymentData, setPaymentData] = useState({
    amount: "",
    method: "",
    reference: "",
  });
  const locale = i18n.language === "ar" ? "ar-SA" : "en-US";

  const {
    data: order,
    isLoading,
    error,
  } = useQuery({
    queryKey: ["order", orderId],
    queryFn: () => ordersApi.getById(orderId!),
    enabled: !!orderId,
  });

  const { data: orderNotes = [] } = useQuery<OrderNote[]>({
    queryKey: ["order-notes", orderId],
    queryFn: () => ordersApi.getNotes(orderId!),
    enabled: !!orderId && !!order,
  });

  const { data: orderShipments = [] } = useQuery<OrderShipment[]>({
    queryKey: ["order-shipments", orderId],
    queryFn: () => ordersApi.getShipments(orderId!),
    enabled: !!orderId && !!order,
  });

  const updateStatusMutation = useMutation({
    mutationFn: ({
      orderId: id,
      status,
      note,
    }: {
      orderId: string;
      status: string;
      note?: string;
    }) => ordersApi.updateStatus(id, { status, note }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["order", orderId] });
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      setIsStatusDialogOpen(false);
    },
  });

  const addNoteMutation = useMutation({
    mutationFn: ({
      orderId: id,
      content,
    }: {
      orderId: string;
      content: string;
    }) => ordersApi.addNote(id, { content, type: "internal" }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["order-notes"] });
      setNoteContent("");
    },
  });

  const createShipmentMutation = useMutation({
    mutationFn: ({
      orderId: id,
      data,
    }: {
      orderId: string;
      data: CreateShipmentDto;
    }) => ordersApi.createShipment(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["order-shipments"] });
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      setIsShipmentDialogOpen(false);
      setShipmentData({ trackingNumber: "", carrier: "" });
    },
  });

  const recordPaymentMutation = useMutation({
    mutationFn: ({
      orderId: id,
      data,
    }: {
      orderId: string;
      data: { amount: number; method?: string; reference?: string };
    }) => ordersApi.recordPayment(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["order", orderId] });
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      setIsPaymentDialogOpen(false);
      setPaymentData({ amount: "", method: "", reference: "" });
    },
  });

  const handleAddNote = () => {
    if (!orderId || !noteContent.trim()) return;
    addNoteMutation.mutate({ orderId, content: noteContent });
  };

  const handleCreateShipment = () => {
    if (!order) return;
    const items = order.items.map((item) => ({
      productId:
        typeof item.product === "object" ? item.product._id : item.product,
      quantity: item.quantity,
    }));
    createShipmentMutation.mutate({
      orderId: order._id,
      data: { ...shipmentData, items },
    });
  };

  const handleRecordPayment = () => {
    if (!orderId || !paymentData.amount) return;
    recordPaymentMutation.mutate({
      orderId,
      data: {
        amount: Number(paymentData.amount),
        method: paymentData.method || undefined,
        reference: paymentData.reference || undefined,
      },
    });
  };

  const handleUpdateStatus = (overrideStatus?: string) => {
    const status = overrideStatus ?? newStatus;
    if (!orderId || !status) return;
    updateStatusMutation.mutate({
      orderId,
      status,
      note: statusDialogNote.trim() || undefined,
    });
  };

  const handleOpenStatusDialog = () => {
    if (order) {
      setNewStatus(order.status);
      setStatusDialogNote("");
      updateStatusMutation.reset();
      setIsStatusDialogOpen(true);
    }
  };

  const handleCloseStatusDialog = (open: boolean) => {
    if (!open) setStatusDialogNote("");
    setIsStatusDialogOpen(open);
  };

  if (isLoading || !order) {
    return (
      <div className="flex items-center justify-center h-[50vh]">
        <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center h-[50vh] text-gray-500">
        <p>لم يتم العثور على الطلب</p>
        <Button
          variant="outline"
          className="mt-4"
          onClick={() => navigate("/orders")}
        >
          <ArrowLeft className="h-4 w-4" />
          العودة للطلبات
        </Button>
      </div>
    );
  }

  const customerName =
    order.customer?.companyName ||
    (order as any).customerId?.shopName ||
    (order as any).customerId?.responsiblePersonName ||
    "-";

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => navigate("/orders")}
          >
            <ArrowLeft className="h-5 w-5" />
          </Button>
          <div>
            <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
              تفاصيل الطلب {order.orderNumber}
            </h1>
            <p className="text-gray-500 dark:text-gray-400 mt-1">
              {formatDate(order.createdAt, locale)}
            </p>
          </div>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={handleOpenStatusDialog}
          >
            <RefreshCw className="h-4 w-4" />
            تحديث الحالة
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => {
              setPaymentData({
                amount: String(order.total),
                method: "",
                reference: "",
              });
              setIsPaymentDialogOpen(true);
            }}
          >
            <CreditCard className="h-4 w-4" />
            تسجيل دفعة
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={() => setIsShipmentDialogOpen(true)}
          >
            <Truck className="h-4 w-4" />
            إنشاء شحنة
          </Button>
        </div>
      </div>

      {/* Order Details */}
      <Card>
        <CardHeader>
          <CardTitle>معلومات الطلب</CardTitle>
        </CardHeader>
        <CardContent>
          <Tabs defaultValue="details" className="w-full">
            <TabsList className="w-full">
              <TabsTrigger value="details" className="flex-1">
                التفاصيل
              </TabsTrigger>
              <TabsTrigger value="shipments" className="flex-1">
                الشحنات ({orderShipments.length})
              </TabsTrigger>
              <TabsTrigger value="notes" className="flex-1">
                الملاحظات ({orderNotes.length})
              </TabsTrigger>
            </TabsList>

            <TabsContent value="details" className="space-y-6 mt-4">
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div>
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    العميل
                  </p>
                  <p className="font-medium text-gray-900 dark:text-gray-100">
                    {customerName}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    حالة الطلب
                  </p>
                  <Badge
                    variant={
                      orderStatusVariants[order.status] ?? "default"
                    }
                  >
                    {orderStatusLabels[order.status] ?? order.status}
                  </Badge>
                </div>
                <div>
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    حالة الدفع
                  </p>
                  <Badge variant={paymentStatusVariants[order.paymentStatus]}>
                    {paymentStatusLabels[order.paymentStatus]}
                  </Badge>
                </div>
                <div>
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    الإجمالي
                  </p>
                  <p className="font-medium text-gray-900 dark:text-gray-100">
                    {formatCurrency(order.total, "SAR", locale)}
                  </p>
                </div>
              </div>

              <div>
                <h4 className="font-medium text-gray-900 dark:text-gray-100 mb-3">
                  المنتجات
                </h4>
                <div className="border dark:border-slate-700 rounded-lg divide-y dark:divide-slate-700">
                  {order.items.map((item, index) => (
                    <div
                      key={index}
                      className="p-3 flex items-center justify-between"
                    >
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gray-100 dark:bg-slate-800 rounded-lg" />
                        <div>
                          <p className="font-medium text-gray-900 dark:text-gray-100">
                            {(i18n.language === "ar"
                              ? (item as any).nameAr || (item as any).name
                              : (item as any).name || (item as any).nameAr) ||
                              item.productSnapshot?.name ||
                              (typeof item.product === "object"
                                ? item.product?.name
                                : "-")}
                          </p>
                          <p className="text-xs text-gray-500 dark:text-gray-400">
                            {(item as any).sku ||
                              item.productSnapshot?.sku ||
                              (typeof item.product === "object"
                                ? item.product?.sku
                                : "-")}
                          </p>
                        </div>
                      </div>
                      <div className="text-end">
                        <p className="font-medium text-gray-900 dark:text-gray-100">
                          {formatCurrency(
                            item.totalPrice ?? item.total ?? 0,
                            "SAR",
                            locale
                          )}
                        </p>
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          {item.quantity} ×{" "}
                          {formatCurrency(
                            item.unitPrice ??
                              item.productSnapshot?.price ??
                              item.price ??
                              0,
                            "SAR",
                            locale
                          )}
                        </p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div className="bg-gray-50 dark:bg-slate-800 rounded-lg p-4">
                <div className="flex justify-between mb-2">
                  <span className="text-gray-500 dark:text-gray-400">
                    المجموع الفرعي
                  </span>
                  <span className="text-gray-900 dark:text-gray-100">
                    {formatCurrency(order.subtotal, "SAR", locale)}
                  </span>
                </div>
                {order.discount > 0 && (
                  <div className="flex justify-between mb-2 text-green-600 dark:text-green-400">
                    <span>الخصم</span>
                    <span>
                      - {formatCurrency(order.discount, "SAR", locale)}
                    </span>
                  </div>
                )}
                <div className="flex justify-between mb-2">
                  <span className="text-gray-500 dark:text-gray-400">
                    الضريبة
                  </span>
                  <span className="text-gray-900 dark:text-gray-100">
                    {formatCurrency(
                      (order as { taxAmount?: number; tax?: number })
                        .taxAmount ??
                        order.tax ??
                        0,
                      "SAR",
                      locale
                    )}
                  </span>
                </div>
                <div className="flex justify-between font-bold text-lg border-t dark:border-slate-700 pt-2 mt-2">
                  <span className="text-gray-900 dark:text-gray-100">
                    الإجمالي
                  </span>
                  <span className="text-gray-900 dark:text-gray-100">
                    {formatCurrency(order.total, "SAR", locale)}
                  </span>
                </div>
              </div>
            </TabsContent>

            <TabsContent value="shipments" className="mt-4 space-y-4">
              {orderShipments.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <Truck className="h-12 w-12 mx-auto mb-2 text-gray-300" />
                  <p>لا توجد شحنات لهذا الطلب</p>
                  <Button
                    className="mt-4"
                    onClick={() => setIsShipmentDialogOpen(true)}
                  >
                    <Plus className="h-4 w-4" />
                    إنشاء شحنة
                  </Button>
                </div>
              ) : (
                <div className="space-y-3">
                  {orderShipments.map((shipment) => (
                    <Card key={shipment._id}>
                      <CardContent className="p-4">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-3">
                            <Truck className="h-5 w-5 text-gray-400" />
                            <div>
                              <p className="font-medium">
                                {shipment.carrier || "شحنة"}
                              </p>
                              {shipment.trackingNumber && (
                                <p className="text-sm text-gray-500">
                                  رقم التتبع: {shipment.trackingNumber}
                                </p>
                              )}
                            </div>
                          </div>
                          <Badge
                            variant={
                              shipment.status === "delivered"
                                ? "success"
                                : shipment.status === "shipped"
                                ? "default"
                                : "warning"
                            }
                          >
                            {shipment.status === "pending"
                              ? "قيد الانتظار"
                              : shipment.status === "shipped"
                              ? "تم الشحن"
                              : shipment.status === "delivered"
                              ? "تم التوصيل"
                              : shipment.status}
                          </Badge>
                        </div>
                        <div className="mt-2 text-xs text-gray-500">
                          {shipment.items.length} منتج |{" "}
                          {formatDate(shipment.createdAt, locale)}
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}
            </TabsContent>

            <TabsContent value="notes" className="mt-4 space-y-4">
              <div className="flex gap-2">
                <Textarea
                  placeholder="أضف ملاحظة داخلية..."
                  value={noteContent}
                  onChange={(e) => setNoteContent(e.target.value)}
                  className="flex-1"
                />
                <Button
                  onClick={handleAddNote}
                  disabled={!noteContent.trim() || addNoteMutation.isPending}
                >
                  {addNoteMutation.isPending ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <Send className="h-4 w-4" />
                  )}
                  إرسال
                </Button>
              </div>
              {orderNotes.length === 0 ? (
                <div className="text-center py-6 text-gray-500">
                  <MessageSquare className="h-12 w-12 mx-auto mb-2 text-gray-300" />
                  <p>لا توجد ملاحظات</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {orderNotes.map((note) => (
                    <Card key={note._id}>
                      <CardContent className="p-3">
                        <p className="text-gray-900 dark:text-gray-100">
                          {note.content}
                        </p>
                        <div className="flex items-center gap-2 mt-2 text-xs text-gray-500">
                          <span>{note.createdByName || "Admin"}</span>
                          <span>•</span>
                          <span>{formatDate(note.createdAt, locale)}</span>
                          {note.type === "internal" && (
                            <Badge variant="secondary">داخلي</Badge>
                          )}
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      {/* Create Shipment Dialog */}
      <Dialog
        open={isShipmentDialogOpen}
        onOpenChange={setIsShipmentDialogOpen}
      >
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Truck className="h-5 w-5" />
              إنشاء شحنة جديدة
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>شركة الشحن</Label>
              <Input
                placeholder="مثال: أرامكس، سمسا..."
                value={shipmentData.carrier}
                onChange={(e) =>
                  setShipmentData({ ...shipmentData, carrier: e.target.value })
                }
              />
            </div>
            <div className="space-y-2">
              <Label>رقم التتبع</Label>
              <Input
                dir="ltr"
                placeholder="Tracking Number"
                value={shipmentData.trackingNumber}
                onChange={(e) =>
                  setShipmentData({
                    ...shipmentData,
                    trackingNumber: e.target.value,
                  })
                }
              />
            </div>
          </div>
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => setIsShipmentDialogOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleCreateShipment}
              disabled={createShipmentMutation.isPending}
            >
              {createShipmentMutation.isPending && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              إنشاء الشحنة
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Record Payment Dialog */}
      <Dialog open={isPaymentDialogOpen} onOpenChange={setIsPaymentDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <CreditCard className="h-5 w-5" />
              تسجيل دفعة
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>
                المبلغ <span className="text-red-500">*</span>
              </Label>
              <Input
                type="number"
                dir="ltr"
                placeholder="0.00"
                value={paymentData.amount}
                onChange={(e) =>
                  setPaymentData({ ...paymentData, amount: e.target.value })
                }
              />
            </div>
            <div className="space-y-2">
              <Label>طريقة الدفع</Label>
              <select
                value={paymentData.method}
                onChange={(e) =>
                  setPaymentData({ ...paymentData, method: e.target.value })
                }
                className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm"
              >
                <option value="">اختر الطريقة...</option>
                <option value="bank_transfer">تحويل بنكي</option>
                <option value="cash">نقدي</option>
                <option value="card">بطاقة</option>
              </select>
            </div>
            <div className="space-y-2">
              <Label>المرجع / رقم الحوالة</Label>
              <Input
                dir="ltr"
                placeholder="Reference Number"
                value={paymentData.reference}
                onChange={(e) =>
                  setPaymentData({ ...paymentData, reference: e.target.value })
                }
              />
            </div>
          </div>
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => setIsPaymentDialogOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleRecordPayment}
              disabled={!paymentData.amount || recordPaymentMutation.isPending}
            >
              {recordPaymentMutation.isPending && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              تسجيل الدفعة
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Update Status Dialog */}
      <Dialog open={isStatusDialogOpen} onOpenChange={handleCloseStatusDialog}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <RefreshCw className="h-5 w-5" />
              تحديث حالة الطلب
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            {/* Current status */}
            <div className="rounded-lg bg-gray-50 dark:bg-slate-800 px-3 py-2">
              <p className="text-sm text-gray-500 dark:text-gray-400">
                الحالة الحالية
              </p>
              <p className="font-medium text-gray-900 dark:text-gray-100">
                {order
                  ? orderStatusLabels[order.status] ?? order.status
                  : ""}
              </p>
            </div>

            {/* Stepper: main flow */}
            <div className="space-y-2">
              <p className="text-sm text-gray-500 dark:text-gray-400">
                مسار الطلب
              </p>
              <div className="flex flex-wrap gap-1 overflow-x-auto pb-1">
                {ORDER_STATUS_FLOW.map((statusKey, idx) => {
                  const isCurrent =
                    order && order.status === statusKey;
                  return (
                    <div
                      key={statusKey}
                      className="flex items-center gap-1 shrink-0"
                    >
                      <span
                        className={`rounded px-2 py-1 text-xs font-medium ${
                          isCurrent
                            ? "bg-primary text-primary-foreground ring-2 ring-primary ring-offset-2 dark:ring-offset-slate-900"
                            : "bg-gray-200 dark:bg-slate-700 text-gray-600 dark:text-gray-300"
                        }`}
                      >
                        {orderStatusLabels[statusKey]}
                      </span>
                      {idx < ORDER_STATUS_FLOW.length - 1 && (
                        <span className="text-gray-300 dark:text-slate-600">
                          →
                        </span>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Quick actions */}
            <div className="space-y-2">
              <Label>اختصارات سريعة</Label>
              <div className="flex flex-wrap gap-2">
                {[
                  { status: "confirmed", label: "تأكيد الطلب" },
                  { status: "processing", label: "قيد المعالجة" },
                  { status: "shipped", label: "تم الشحن" },
                  { status: "delivered", label: "تم التوصيل" },
                  { status: "completed", label: "مكتمل" },
                  { status: "cancelled", label: "إلغاء" },
                ].map(({ status, label }) => (
                  <Button
                    key={status}
                    type="button"
                    variant="outline"
                    size="sm"
                    disabled={
                      updateStatusMutation.isPending ||
                      (order?.status === status)
                    }
                    onClick={() => handleUpdateStatus(status)}
                  >
                    {label}
                  </Button>
                ))}
              </div>
            </div>

            {/* Full dropdown */}
            <div className="space-y-2">
              <Label>أو اختر حالة أخرى</Label>
              <select
                value={newStatus}
                onChange={(e) => setNewStatus(e.target.value)}
                className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm"
              >
                {ORDER_STATUS_KEYS.map((key) => (
                  <option key={key} value={key}>
                    {orderStatusLabels[key]}
                  </option>
                ))}
              </select>
            </div>

            {/* Notes */}
            <div className="space-y-2">
              <Label>ملاحظة (اختياري)</Label>
              <Textarea
                placeholder="ملاحظة لتسجيل تغيير الحالة..."
                value={statusDialogNote}
                onChange={(e) => setStatusDialogNote(e.target.value)}
                className="min-h-[80px]"
              />
            </div>

            {/* API error */}
            {updateStatusMutation.isError && (
              <div className="rounded-lg bg-red-50 dark:bg-red-900/20 px-3 py-2 text-sm text-red-700 dark:text-red-300">
                {(updateStatusMutation.error as Error)?.message ??
                  "فشل تحديث الحالة"}
              </div>
            )}
          </div>
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => handleCloseStatusDialog(false)}
            >
              إلغاء
            </Button>
            <Button
              onClick={() => handleUpdateStatus()}
              disabled={updateStatusMutation.isPending}
            >
              {updateStatusMutation.isPending && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              تحديث الحالة
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
