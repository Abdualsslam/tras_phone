import { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  ordersApi,
  type OrderNote,
  type OrderShipment,
  type CreateShipmentDto,
  type UpdateOrderItemsDto,
  type UpdateOrderItemDto,
} from "@/api/orders.api";
import { uploadsApi } from "@/api/uploads.api";
import { productsApi } from "@/api/products.api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import {
  ArrowLeft,
  Truck,
  CreditCard,
  CheckCircle2,
  Loader2,
  MessageSquare,
  Send,
  Plus,
  RefreshCw,
  XCircle,
  Upload,
  FileText,
  ExternalLink,
  Package,
  Trash2,
  Search,
  Save,
  AlertTriangle,
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
    partial: "warning",
    unpaid: "danger",
    pending: "warning",
    partially_paid: "warning",
    failed: "danger",
    refunded: "danger",
  };

const paymentStatusLabels: Record<string, string> = {
  paid: "مدفوع",
  partial: "مدفوع جزئياً",
  unpaid: "غير مدفوع",
  pending: "غير مدفوع",
  partially_paid: "مدفوع جزئياً",
  failed: "فشل",
  refunded: "مسترد",
};

const transferStatusLabels: Record<string, string> = {
  not_required: "غير مطلوب",
  awaiting_receipt: "بانتظار رفع الإيصال",
  receipt_uploaded: "إيصال مرفوع - بانتظار التحقق",
  verified: "تم التحقق",
  rejected: "مرفوض",
};

const transferStatusVariants: Record<string, "success" | "warning" | "danger" | "default"> = {
  not_required: "default",
  awaiting_receipt: "warning",
  receipt_uploaded: "warning",
  verified: "success",
  rejected: "danger",
};

export function OrderDetailsPage() {
  const { orderId } = useParams<{ orderId: string }>();
  const navigate = useNavigate();
  const { i18n } = useTranslation();
  const queryClient = useQueryClient();
  const [isShipmentDialogOpen, setIsShipmentDialogOpen] = useState(false);
  const [isPaymentDialogOpen, setIsPaymentDialogOpen] = useState(false);
  const [isStatusDialogOpen, setIsStatusDialogOpen] = useState(false);
  const [isEditItemsDialogOpen, setIsEditItemsDialogOpen] = useState(false);
  const [noteContent, setNoteContent] = useState("");
  const [newStatus, setNewStatus] = useState("");
  const [statusDialogNote, setStatusDialogNote] = useState("");
  const [verificationNotes, setVerificationNotes] = useState("");
  const [rejectionReason, setRejectionReason] = useState("");
  const [editReason, setEditReason] = useState("");
  const [editItems, setEditItems] = useState<UpdateOrderItemDto[]>([]);
  const [searchProductId, setSearchProductId] = useState("");
  const [searchResults, setSearchResults] = useState<any[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  const [shipmentData, setShipmentData] = useState({
    trackingNumber: "",
    carrier: "",
  });
  const [shippingLabelFile, setShippingLabelFile] = useState<File | null>(null);
  const [isUploadingLabel, setIsUploadingLabel] = useState(false);
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
      shippingLabelUrl,
    }: {
      orderId: string;
      status: string;
      note?: string;
      shippingLabelUrl?: string;
    }) => ordersApi.updateStatus(id, { status, note, shippingLabelUrl }),
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
      data: { amount: number; paymentMethod?: string; gatewayReference?: string };
    }) => ordersApi.recordPayment(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["order", orderId] });
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      setIsPaymentDialogOpen(false);
      setPaymentData({ amount: "", method: "", reference: "" });
    },
  });

  const verifyPaymentMutation = useMutation({
    mutationFn: ({
      orderId: id,
      data,
    }: {
      orderId: string;
      data: { verified: boolean; rejectionReason?: string; notes?: string };
    }) => ordersApi.verifyPayment(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["order", orderId] });
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      queryClient.invalidateQueries({
        queryKey: ["pending-transfer-verification-orders"],
      });
      setVerificationNotes("");
      setRejectionReason("");
    },
  });

  const updateItemsMutation = useMutation({
    mutationFn: ({
      orderId: id,
      data,
    }: {
      orderId: string;
      data: UpdateOrderItemsDto;
    }) => ordersApi.updateOrderItems(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["order", orderId] });
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      setIsEditItemsDialogOpen(false);
      setEditReason("");
      setSearchProductId("");
      setSearchResults([]);
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
        paymentMethod: paymentData.method || undefined,
        gatewayReference: paymentData.reference || undefined,
      },
    });
  };

  const handleVerifyTransfer = (verified: boolean) => {
    if (!orderId) return;

    if (!verified && !rejectionReason.trim()) {
      return;
    }

    verifyPaymentMutation.mutate({
      orderId,
      data: {
        verified,
        rejectionReason: verified ? undefined : rejectionReason.trim(),
        notes: verificationNotes.trim() || undefined,
      },
    });
  };

  const handleUpdateStatus = async (overrideStatus?: string) => {
    const status = overrideStatus ?? newStatus;
    if (!orderId || !status) return;

    if (status === "shipped" && !shippingLabelFile) {
      return;
    }

    let shippingLabelUrl: string | undefined;
    if (status === "shipped" && shippingLabelFile) {
      setIsUploadingLabel(true);
      try {
        const uploaded = await uploadsApi.uploadSingle(shippingLabelFile, "shipping-labels");
        shippingLabelUrl = uploaded.url;
      } catch (error) {
        setIsUploadingLabel(false);
        return;
      }
      setIsUploadingLabel(false);
    }

    updateStatusMutation.mutate({
      orderId,
      status,
      note: statusDialogNote.trim() || undefined,
      shippingLabelUrl,
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

  const handleOpenEditItemsDialog = () => {
    if (order) {
      setEditItems(
        order.items.map((item: any) => ({
          orderItemId: item._id,
          productId:
            typeof item.product === "object" ? item.product._id : item.product,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
        }))
      );
      setEditReason("");
      updateItemsMutation.reset();
      setIsEditItemsDialogOpen(true);
    }
  };

  const handleSearchProducts = async () => {
    if (!searchProductId.trim()) return;
    setIsSearching(true);
    try {
      const result = await productsApi.getAll({ search: searchProductId, limit: 10 });
      setSearchResults(result.items || []);
    } catch (error) {
      console.error("Search failed:", error);
    }
    setIsSearching(false);
  };

  const handleAddProductToEdit = (product: any) => {
    const exists = editItems.find((item) => item.productId === product._id);
    if (exists) return;
    setEditItems([
      ...editItems,
      { productId: product._id, quantity: 1, unitPrice: product.price },
    ]);
    setSearchResults([]);
    setSearchProductId("");
  };

  const handleRemoveItemFromEdit = (index: number) => {
    setEditItems(editItems.filter((_, i) => i !== index));
  };

  const handleUpdateItemQuantity = (index: number, quantity: number) => {
    const newItems = [...editItems];
    newItems[index] = { ...newItems[index], quantity };
    setEditItems(newItems);
  };

  const handleUpdateItemPrice = (index: number, unitPrice: number) => {
    const newItems = [...editItems];
    newItems[index] = { ...newItems[index], unitPrice };
    setEditItems(newItems);
  };

  const calculateNewTotal = () => {
    const subtotal = editItems.reduce(
      (sum, item) => sum + (item.unitPrice || 0) * item.quantity,
      0
    );
    const taxAmount = (order as any).taxAmount || 0;
    const shippingCost = (order as any).shippingCost || 0;
    const discount = (order as any).discount || 0;
    const couponDiscount = (order as any).couponDiscount || 0;
    return subtotal - discount - couponDiscount + taxAmount + shippingCost;
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
  const rawTransferStatus = (order as any).transferStatus as string | undefined;
  const transferReceiptImage = (order as any).transferReceiptImage as string | undefined;
  const transferReference = (order as any).transferReference as string | undefined;
  const transferDate = (order as any).transferDate as string | undefined;
  const transferVerifiedAt = (order as any).transferVerifiedAt as string | undefined;
  const transferRejectionReason = (order as any).rejectionReason as string | undefined;
  const isTransferVerified =
    rawTransferStatus === "verified" || Boolean(transferVerifiedAt);
  const transferStatus =
    rawTransferStatus ||
    (transferReceiptImage
      ? isTransferVerified
        ? "verified"
        : "receipt_uploaded"
      : "not_required");
  const paidAmount = Number((order as any).paidAmount || 0);
  const remainingAmount = Math.max(0, Number(order.total || 0) - paidAmount);
  const isBankTransferOrder = (order as any).paymentMethod === "bank_transfer";
  const canReviewTransfer =
    isBankTransferOrder && Boolean(transferReceiptImage) && !isTransferVerified;
  const shippingLabelUrl = (order as any).shippingLabelUrl as string | undefined;

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
            onClick={handleOpenEditItemsDialog}
          >
            <Package className="h-4 w-4" />
            تعديل المنتجات
          </Button>
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
                amount: String(Math.max(0, Number(order.total || 0) - Number((order as any).paidAmount || 0))),
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
                  <Badge
                    variant={paymentStatusVariants[order.paymentStatus] ?? "warning"}
                  >
                    {paymentStatusLabels[order.paymentStatus] ?? order.paymentStatus}
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

              {isBankTransferOrder && (
                <Card className="border-dashed">
                  <CardHeader>
                    <CardTitle className="text-base">التحويل البنكي والتحقق</CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                      <div>
                        <p className="text-xs text-gray-500 dark:text-gray-400">حالة التحويل</p>
                        <Badge variant={transferStatusVariants[transferStatus] ?? "default"}>
                          {transferStatusLabels[transferStatus] ?? transferStatus}
                        </Badge>
                      </div>
                      <div>
                        <p className="text-xs text-gray-500 dark:text-gray-400">المبلغ المدفوع</p>
                        <p className="font-medium">{formatCurrency(paidAmount, "SAR", locale)}</p>
                      </div>
                      <div>
                        <p className="text-xs text-gray-500 dark:text-gray-400">المتبقي للتحصيل</p>
                        <p className="font-medium">{formatCurrency(remainingAmount, "SAR", locale)}</p>
                      </div>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-sm">
                      <div>
                        <p className="text-xs text-gray-500 dark:text-gray-400">مرجع التحويل</p>
                        <p className="font-medium">{transferReference || "-"}</p>
                      </div>
                      <div>
                        <p className="text-xs text-gray-500 dark:text-gray-400">تاريخ التحويل</p>
                        <p className="font-medium">
                          {transferDate ? formatDate(transferDate, locale) : "-"}
                        </p>
                      </div>
                    </div>

                    {transferReceiptImage ? (
                      <a
                        href={transferReceiptImage}
                        target="_blank"
                        rel="noreferrer"
                        className="inline-flex text-sm text-primary hover:underline"
                      >
                        فتح الإيصال المرفوع
                      </a>
                    ) : (
                      <p className="text-sm text-gray-500 dark:text-gray-400">
                        لا يوجد إيصال مرفوع حتى الآن.
                      </p>
                    )}

                    {transferRejectionReason && (
                      <div className="rounded-lg bg-red-50 dark:bg-red-900/20 px-3 py-2 text-sm text-red-700 dark:text-red-300">
                        سبب الرفض: {transferRejectionReason}
                      </div>
                    )}

                    {canReviewTransfer && (
                      <div className="space-y-3 rounded-lg border p-3">
                        <p className="text-sm font-medium">إجراء التحقق</p>
                        <div className="space-y-2">
                          <Label>ملاحظات (اختياري)</Label>
                          <Textarea
                            value={verificationNotes}
                            onChange={(e) => setVerificationNotes(e.target.value)}
                            placeholder="ملاحظات التحقق..."
                            className="min-h-[80px]"
                          />
                        </div>
                        <div className="space-y-2">
                          <Label>سبب الرفض (إلزامي عند الرفض)</Label>
                          <Input
                            value={rejectionReason}
                            onChange={(e) => setRejectionReason(e.target.value)}
                            placeholder="مثال: الإيصال غير واضح"
                          />
                        </div>
                        <div className="flex flex-wrap gap-2">
                          <Button
                            onClick={() => handleVerifyTransfer(true)}
                            disabled={verifyPaymentMutation.isPending}
                          >
                            {verifyPaymentMutation.isPending ? (
                              <Loader2 className="h-4 w-4 animate-spin" />
                            ) : (
                              <CheckCircle2 className="h-4 w-4" />
                            )}
                            اعتماد الدفع
                          </Button>
                          <Button
                            variant="destructive"
                            onClick={() => handleVerifyTransfer(false)}
                            disabled={verifyPaymentMutation.isPending || !rejectionReason.trim()}
                          >
                            {verifyPaymentMutation.isPending ? (
                              <Loader2 className="h-4 w-4 animate-spin" />
                            ) : (
                              <XCircle className="h-4 w-4" />
                            )}
                            رفض الإيصال
                          </Button>
                        </div>
                        {verifyPaymentMutation.isError && (
                          <div className="rounded-lg bg-red-50 dark:bg-red-900/20 px-3 py-2 text-sm text-red-700 dark:text-red-300">
                            {(verifyPaymentMutation.error as Error)?.message ??
                              "فشل تحديث حالة التحقق"}
                          </div>
                        )}
                      </div>
                    )}
                  </CardContent>
                </Card>
              )}

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

              {/* Shipping Label */}
              {shippingLabelUrl && (
                <Card className="border-dashed">
                  <CardHeader>
                    <CardTitle className="text-base flex items-center gap-2">
                      <FileText className="h-4 w-4" />
                      بوليصة الشحن
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <a
                      href={shippingLabelUrl}
                      target="_blank"
                      rel="noreferrer"
                      className="inline-flex items-center gap-2 text-primary hover:underline"
                    >
                      <ExternalLink className="h-4 w-4" />
                      عرض البوليصة
                    </a>
                  </CardContent>
                </Card>
              )}
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
                placeholder="رقم التتبع"
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
                <option value="cash_on_delivery">الدفع عند الاستلام</option>
                <option value="credit_card">بطاقة ائتمان</option>
                <option value="mada">مدى</option>
                <option value="apple_pay">آبل باي</option>
                <option value="stc_pay">إس تي سي باي</option>
                <option value="wallet">محفظة</option>
                <option value="credit">آجل</option>
              </select>
            </div>
            <div className="space-y-2">
              <Label>المرجع / رقم الحوالة</Label>
              <Input
                dir="ltr"
                placeholder="رقم المرجع"
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
                {/* Shipped button - requires shipping label */}
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  disabled={
                    updateStatusMutation.isPending ||
                    isUploadingLabel ||
                    (order?.status === "shipped")
                  }
                  onClick={() => {
                    setNewStatus("shipped");
                  }}
                  className="border-amber-300 text-amber-700 hover:bg-amber-50 dark:border-amber-700 dark:text-amber-300 dark:hover:bg-amber-900/20"
                >
                  <Upload className="h-4 w-4 me-1" />
                  تم الشحن
                </Button>
              </div>
            </div>

            {/* Full dropdown */}
            <div className="space-y-2">
              <Label>أو اختر حالة أخرى</Label>
              <select
                value={newStatus}
                onChange={(e) => {
                  setNewStatus(e.target.value);
                  if (e.target.value !== "shipped") {
                    setShippingLabelFile(null);
                  }
                }}
                className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm"
              >
                {ORDER_STATUS_KEYS.map((key) => (
                  <option key={key} value={key}>
                    {orderStatusLabels[key]}
                  </option>
                ))}
              </select>
            </div>

            {/* Shipping Label Upload - Required when status is shipped */}
            {(newStatus === "shipped" || (order?.status !== "shipped" && newStatus === "shipped")) && (
              <div className="space-y-2 rounded-lg border border-amber-200 dark:border-amber-800 bg-amber-50 dark:bg-amber-900/20 p-3">
                <Label className="flex items-center gap-2 text-amber-700 dark:text-amber-300">
                  <FileText className="h-4 w-4" />
                  بوليصة الشحن <span className="text-red-500">*</span>
                </Label>
                <p className="text-xs text-amber-600 dark:text-amber-400">
                  يرجى رفع صورة أو ملف PDF لبوليصة الشحن
                </p>
                <div className="flex items-center gap-2">
                  <Input
                    type="file"
                    accept="image/*,.pdf"
                    onChange={(e) => {
                      const file = e.target.files?.[0];
                      if (file) {
                        setShippingLabelFile(file);
                      }
                    }}
                    className="cursor-pointer"
                  />
                </div>
                {shippingLabelFile && (
                  <div className="flex items-center gap-2 rounded bg-green-50 dark:bg-green-900/20 px-3 py-2 text-sm text-green-700 dark:text-green-300">
                    <CheckCircle2 className="h-4 w-4" />
                    <span className="truncate">{shippingLabelFile.name}</span>
                    <button
                      onClick={() => setShippingLabelFile(null)}
                      className="me-auto text-red-500 hover:text-red-700"
                    >
                      <XCircle className="h-4 w-4" />
                    </button>
                  </div>
                )}
              </div>
            )}

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
              disabled={
                updateStatusMutation.isPending ||
                isUploadingLabel ||
                (newStatus === "shipped" && !shippingLabelFile)
              }
            >
              {(updateStatusMutation.isPending || isUploadingLabel) && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              {isUploadingLabel ? "جاري رفع البوليصة..." : "تحديث الحالة"}
            </Button>
          </div>
        </DialogContent>
      </Dialog>

      {/* Edit Order Items Dialog */}
      <Dialog open={isEditItemsDialogOpen} onOpenChange={setIsEditItemsDialogOpen}>
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Package className="h-5 w-5" />
              تعديل منتجات الطلب
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            {/* Current Order Info */}
            <div className="rounded-lg bg-gray-50 dark:bg-slate-800 px-3 py-2">
              <div className="flex justify-between items-center">
                <div>
                  <p className="text-sm text-gray-500 dark:text-gray-400">الإجمالي الحالي</p>
                  <p className="font-bold text-lg">{formatCurrency(order.total, "SAR", locale)}</p>
                </div>
                <div className="text-start">
                  <p className="text-sm text-gray-500 dark:text-gray-400">الإجمالي الجديد</p>
                  <p className={`font-bold text-lg ${calculateNewTotal() < order.total ? "text-green-600" : calculateNewTotal() > order.total ? "text-red-600" : ""}`}>
                    {formatCurrency(calculateNewTotal(), "SAR", locale)}
                  </p>
                </div>
              </div>
              {calculateNewTotal() !== order.total && (
                <div className={`mt-2 text-sm ${calculateNewTotal() < order.total ? "text-green-600" : "text-red-600"}`}>
                  {calculateNewTotal() < order.total ? (
                    <span>💰 مبلغ مسترد: {formatCurrency(order.total - calculateNewTotal(), "SAR", locale)}</span>
                  ) : (
                    <span>⚠️ مبلغ إضافي مطلوب: {formatCurrency(calculateNewTotal() - order.total, "SAR", locale)}</span>
                  )}
                </div>
              )}
            </div>

            {/* Search Products */}
            <div className="space-y-2">
              <Label>إضافة منتج جديد</Label>
              <div className="flex gap-2">
                <Input
                  placeholder="ابحث عن منتج (اسم أو SKU)..."
                  value={searchProductId}
                  onChange={(e) => setSearchProductId(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && handleSearchProducts()}
                  className="flex-1"
                />
                <Button onClick={handleSearchProducts} disabled={isSearching}>
                  {isSearching ? <Loader2 className="h-4 w-4 animate-spin" /> : <Search className="h-4 w-4" />}
                </Button>
              </div>
              {searchResults.length > 0 && (
                <div className="border rounded-lg max-h-48 overflow-y-auto">
                  {searchResults.map((product) => (
                    <div
                      key={product._id}
                      className="p-2 hover:bg-gray-50 dark:hover:bg-slate-700 cursor-pointer flex justify-between items-center border-b last:border-b-0"
                      onClick={() => handleAddProductToEdit(product)}
                    >
                      <div>
                        <p className="font-medium">{product.name}</p>
                        <p className="text-xs text-gray-500">{product.sku} | {formatCurrency(product.price, "SAR", locale)}</p>
                      </div>
                      <Plus className="h-4 w-4 text-primary" />
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Edit Items List */}
            <div className="space-y-2">
              <Label>المنتجات ({editItems.length})</Label>
              <div className="border rounded-lg divide-y">
                {editItems.length === 0 ? (
                  <p className="p-4 text-center text-gray-500">لا توجد منتجات</p>
                ) : (
                  editItems.map((item, index) => {
                    const originalItem = order?.items.find(
                      (oi: any) =>
                        (typeof oi.product === "object" ? oi.product._id : oi.product) === item.productId
                    );
                    return (
                      <div key={index} className="p-3 flex items-center gap-3">
                        <div className="flex-1">
                          <p className="font-medium text-gray-900 dark:text-gray-100">
                            {originalItem
                              ? (i18n.language === "ar"
                                  ? (originalItem as any).nameAr || (originalItem as any).name
                                  : (originalItem as any).name || (originalItem as any).nameAr)
                              : `منتج جديد (${item.productId.slice(-6)})`}
                          </p>
                          <p className="text-xs text-gray-500">
                            {(originalItem as any)?.sku || item.productId.slice(-8)}
                          </p>
                        </div>
                        <div className="flex items-center gap-2">
                          <div className="flex items-center gap-1">
                            <Label className="text-xs">الكمية:</Label>
                            <Input
                              type="number"
                              min="1"
                              value={item.quantity}
                              onChange={(e) => handleUpdateItemQuantity(index, parseInt(e.target.value) || 1)}
                              className="w-20 h-8"
                            />
                          </div>
                          <div className="flex items-center gap-1">
                            <Label className="text-xs">السعر:</Label>
                            <Input
                              type="number"
                              min="0"
                              step="0.01"
                              value={item.unitPrice || 0}
                              onChange={(e) => handleUpdateItemPrice(index, parseFloat(e.target.value) || 0)}
                              className="w-24 h-8"
                            />
                          </div>
                          <Button
                            variant="ghost"
                            size="icon"
                            className="text-red-500 hover:text-red-700 hover:bg-red-50"
                            onClick={() => handleRemoveItemFromEdit(index)}
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                        <div className="w-24 text-start">
                          <p className="font-medium">
                            {formatCurrency((item.unitPrice || 0) * item.quantity, "SAR", locale)}
                          </p>
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            </div>

            {/* Reason */}
            <div className="space-y-2">
              <Label>سبب التعديل (اختياري)</Label>
              <Input
                placeholder="مثال: العميل طلب تغيير الكمية..."
                value={editReason}
                onChange={(e) => setEditReason(e.target.value)}
              />
            </div>

            {/* Warning */}
            {calculateNewTotal() < order.total && (
              <div className="rounded-lg bg-green-50 dark:bg-green-900/20 px-3 py-2 flex items-start gap-2">
                <AlertTriangle className="h-5 w-5 text-green-600 mt-0.5" />
                <div className="text-sm text-green-700 dark:text-green-300">
                  <p className="font-medium">سيتم إرجاع المبلغ الفارق للمحفظة</p>
                  <p>مبلغ {formatCurrency(order.total - calculateNewTotal(), "SAR", locale)} سيُضاف لمحفظة العميل</p>
                </div>
              </div>
            )}

            {calculateNewTotal() > order.total && (
              <div className="rounded-lg bg-amber-50 dark:bg-amber-900/20 px-3 py-2 flex items-start gap-2">
                <AlertTriangle className="h-5 w-5 text-amber-600 mt-0.5" />
                <div className="text-sm text-amber-700 dark:text-amber-300">
                  <p className="font-medium">زيادة في المبلغ</p>
                  <p>سيتم تسجيل المبلغ الإضافي {formatCurrency(calculateNewTotal() - order.total, "SAR", locale)} كمبلغ متبقي للدفع</p>
                </div>
              </div>
            )}

            {/* Error */}
            {updateItemsMutation.isError && (
              <div className="rounded-lg bg-red-50 dark:bg-red-900/20 px-3 py-2 text-sm text-red-700 dark:text-red-300">
                {(updateItemsMutation.error as Error)?.message ?? "فشل تحديث المنتجات"}
              </div>
            )}
          </div>
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => setIsEditItemsDialogOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              onClick={() => {
                if (orderId) {
                  updateItemsMutation.mutate({
                    orderId,
                    data: { items: editItems, reason: editReason || undefined },
                  });
                }
              }}
              disabled={editItems.length === 0 || updateItemsMutation.isPending}
            >
              {updateItemsMutation.isPending ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Save className="h-4 w-4" />
              )}
              حفظ التعديلات
            </Button>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
