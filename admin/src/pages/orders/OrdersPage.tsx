import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  ordersApi,
  type OrderNote,
  type OrderShipment,
  type CreateShipmentDto,
} from "@/api/orders.api";
import type { Order } from "@/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
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
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Search,
  MoreHorizontal,
  Eye,
  Truck,
  CreditCard,
  ShoppingCart,
  Loader2,
  AlertCircle,
  Clock,
  CheckCircle,
  Package,
  MessageSquare,
  Send,
  Plus,
  RefreshCw,
} from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { formatCurrency, formatDate, formatNumber } from "@/lib/utils";

const orderStatusVariants: Record<
  string,
  "success" | "warning" | "danger" | "default"
> = {
  pending: "warning",
  confirmed: "default",
  processing: "default",
  shipped: "success",
  delivered: "success",
  cancelled: "danger",
  refunded: "danger",
};

const orderStatusLabels: Record<string, string> = {
  pending: "قيد الانتظار",
  confirmed: "مؤكد",
  processing: "قيد المعالجة",
  shipped: "تم الشحن",
  delivered: "تم التوصيل",
  cancelled: "ملغي",
  refunded: "مسترد",
};

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

export function OrdersPage() {
  const { t, i18n } = useTranslation();
  const queryClient = useQueryClient();
  const navigate = useNavigate();
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);
  const [isDetailsDialogOpen, setIsDetailsDialogOpen] = useState(false);
  const [isShipmentDialogOpen, setIsShipmentDialogOpen] = useState(false);
  const [isPaymentDialogOpen, setIsPaymentDialogOpen] = useState(false);
  const [isStatusDialogOpen, setIsStatusDialogOpen] = useState(false);
  const [noteContent, setNoteContent] = useState("");
  const [newStatus, setNewStatus] = useState("");
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

  // Fetch stats
  const { data: stats } = useQuery({
    queryKey: ["orders-stats"],
    queryFn: () => ordersApi.getStats(),
  });

  // Fetch orders
  const { data, isLoading, error } = useQuery({
    queryKey: ["orders", searchQuery, statusFilter],
    queryFn: () =>
      ordersApi.getAll({
        orderNumber: searchQuery || undefined,
        status: statusFilter || undefined,
        limit: 20,
      }),
  });

  // Fetch order notes when details dialog is open
  const { data: orderNotes = [] } = useQuery<OrderNote[]>({
    queryKey: ["order-notes", selectedOrder?._id],
    queryFn: () => ordersApi.getNotes(selectedOrder!._id),
    enabled: isDetailsDialogOpen && !!selectedOrder?._id,
  });

  // Fetch order shipments when details dialog is open
  const { data: orderShipments = [] } = useQuery<OrderShipment[]>({
    queryKey: ["order-shipments", selectedOrder?._id],
    queryFn: () => ordersApi.getShipments(selectedOrder!._id),
    enabled: isDetailsDialogOpen && !!selectedOrder?._id,
  });

  // Mutations
  const updateStatusMutation = useMutation({
    mutationFn: ({
      orderId,
      status,
      note,
    }: {
      orderId: string;
      status: string;
      note?: string;
    }) => ordersApi.updateStatus(orderId, { status, note }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      queryClient.invalidateQueries({ queryKey: ["orders-stats"] });
      setIsStatusDialogOpen(false);
    },
  });

  const addNoteMutation = useMutation({
    mutationFn: ({ orderId, content }: { orderId: string; content: string }) =>
      ordersApi.addNote(orderId, { content, type: "internal" }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["order-notes"] });
      setNoteContent("");
    },
  });

  const createShipmentMutation = useMutation({
    mutationFn: ({
      orderId,
      data,
    }: {
      orderId: string;
      data: CreateShipmentDto;
    }) => ordersApi.createShipment(orderId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["order-shipments"] });
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      setIsShipmentDialogOpen(false);
      setShipmentData({ trackingNumber: "", carrier: "" });
    },
  });

  const recordPaymentMutation = useMutation({
    mutationFn: ({
      orderId,
      data,
    }: {
      orderId: string;
      data: { amount: number; method?: string; reference?: string };
    }) => ordersApi.recordPayment(orderId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["orders"] });
      setIsPaymentDialogOpen(false);
      setPaymentData({ amount: "", method: "", reference: "" });
    },
  });

  const handleViewDetails = (order: Order) => {
    navigate(`/orders/${order._id}`);
  };

  const handleOpenShipment = (order: Order) => {
    setSelectedOrder(order);
    setIsShipmentDialogOpen(true);
  };

  const handleOpenPayment = (order: Order) => {
    setSelectedOrder(order);
    setPaymentData({ amount: String(order.total), method: "", reference: "" });
    setIsPaymentDialogOpen(true);
  };

  const handleOpenStatus = (order: Order) => {
    setSelectedOrder(order);
    setNewStatus(order.status);
    setIsStatusDialogOpen(true);
  };

  const handleAddNote = () => {
    if (!selectedOrder || !noteContent.trim()) return;
    addNoteMutation.mutate({
      orderId: selectedOrder._id,
      content: noteContent,
    });
  };

  const handleCreateShipment = () => {
    if (!selectedOrder) return;
    const items = selectedOrder.items.map((item) => ({
      productId:
        typeof item.product === "object" ? item.product._id : item.product,
      quantity: item.quantity,
    }));
    createShipmentMutation.mutate({
      orderId: selectedOrder._id,
      data: { ...shipmentData, items },
    });
  };

  const handleRecordPayment = () => {
    if (!selectedOrder || !paymentData.amount) return;
    recordPaymentMutation.mutate({
      orderId: selectedOrder._id,
      data: {
        amount: Number(paymentData.amount),
        method: paymentData.method || undefined,
        reference: paymentData.reference || undefined,
      },
    });
  };

  const handleUpdateStatus = () => {
    if (!selectedOrder || !newStatus) return;
    updateStatusMutation.mutate({
      orderId: selectedOrder._id,
      status: newStatus,
    });
  };

  const orders = data?.items || [];

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
            {t("orders.title")}
          </h1>
          <p className="text-gray-500 dark:text-gray-400 mt-1">
            متابعة وإدارة الطلبات
          </p>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                <ShoppingCart className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">إجمالي الطلبات</p>
                <p className="text-2xl font-bold">
                  {formatNumber(stats?.totalOrders || 0)}
                </p>
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
                <p className="text-2xl font-bold">
                  {stats?.pendingOrders || 0}
                </p>
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
                <p className="text-sm text-muted-foreground">تم الشحن</p>
                <p className="text-2xl font-bold">
                  {stats?.shippedOrders || 0}
                </p>
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
                <p className="text-sm text-muted-foreground">تم التوصيل</p>
                <p className="text-2xl font-bold">
                  {stats?.deliveredOrders || 0}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Search and Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input
                placeholder="البحث برقم الطلب أو اسم العميل..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="ps-10"
              />
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm min-w-[150px]"
            >
              <option value="">جميع الحالات</option>
              <option value="pending">قيد الانتظار</option>
              <option value="confirmed">مؤكد</option>
              <option value="processing">قيد المعالجة</option>
              <option value="shipped">تم الشحن</option>
              <option value="delivered">تم التوصيل</option>
              <option value="cancelled">ملغي</option>
            </select>
          </div>
        </CardContent>
      </Card>

      {/* Orders Table */}
      <Card>
        <CardHeader className="flex flex-row items-center gap-2 pb-4">
          <ShoppingCart className="h-5 w-5 text-gray-500" />
          <CardTitle className="text-lg">قائمة الطلبات</CardTitle>
          {data && (
            <Badge variant="secondary" className="ms-auto">
              {data.pagination?.total || orders.length} طلب
            </Badge>
          )}
        </CardHeader>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
            </div>
          ) : error ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-500">
              <AlertCircle className="h-12 w-12 mb-4 text-red-400" />
              <p>حدث خطأ في تحميل البيانات</p>
            </div>
          ) : orders.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-500">
              <ShoppingCart className="h-12 w-12 mb-4 text-gray-300" />
              <p>{t("common.noData")}</p>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>{t("orders.orderNumber")}</TableHead>
                  <TableHead>{t("orders.customer")}</TableHead>
                  <TableHead>{t("orders.total")}</TableHead>
                  <TableHead>حالة الطلب</TableHead>
                  <TableHead>حالة الدفع</TableHead>
                  <TableHead>{t("orders.date")}</TableHead>
                  <TableHead className="w-[50px]"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {orders.map((order) => (
                  <TableRow
                    key={order._id}
                    className="cursor-pointer hover:bg-gray-50 dark:hover:bg-slate-800"
                    onClick={() => navigate(`/orders/${order._id}`)}
                  >
                    <TableCell className="font-medium text-primary-600">
                      {order.orderNumber}
                    </TableCell>
                    <TableCell>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-gray-100">
                          {order.customer?.companyName || "-"}
                        </p>
                        <p className="text-xs text-gray-500">
                          {order.customer?.contactName || "-"}
                        </p>
                      </div>
                    </TableCell>
                    <TableCell className="font-medium">
                      {formatCurrency(order.total, "SAR", locale)}
                    </TableCell>
                    <TableCell>
                      <Badge variant={orderStatusVariants[order.status]}>
                        {orderStatusLabels[order.status]}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge
                        variant={paymentStatusVariants[order.paymentStatus]}
                      >
                        {paymentStatusLabels[order.paymentStatus]}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-gray-500 text-sm">
                      {formatDate(order.createdAt, locale)}
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={(e) => e.stopPropagation()}
                          >
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem
                            onClick={() => handleViewDetails(order)}
                          >
                            <Eye className="h-4 w-4" />
                            عرض التفاصيل
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => handleOpenStatus(order)}
                          >
                            <RefreshCw className="h-4 w-4" />
                            تحديث الحالة
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => handleOpenShipment(order)}
                          >
                            <Truck className="h-4 w-4" />
                            إنشاء شحنة
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => handleOpenPayment(order)}
                          >
                            <CreditCard className="h-4 w-4" />
                            تسجيل دفعة
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

      {/* Order Details Dialog */}
      <Dialog open={isDetailsDialogOpen} onOpenChange={setIsDetailsDialogOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>تفاصيل الطلب {selectedOrder?.orderNumber}</DialogTitle>
          </DialogHeader>
          {selectedOrder && (
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

              {/* Details Tab */}
              <TabsContent value="details" className="space-y-6 mt-4">
                {/* Order Info */}
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div>
                    <p className="text-sm text-gray-500 dark:text-gray-400">
                      العميل
                    </p>
                    <p className="font-medium text-gray-900 dark:text-gray-100">
                      {selectedOrder.customer?.companyName || "-"}
                    </p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500 dark:text-gray-400">
                      حالة الطلب
                    </p>
                    <Badge variant={orderStatusVariants[selectedOrder.status]}>
                      {orderStatusLabels[selectedOrder.status]}
                    </Badge>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500 dark:text-gray-400">
                      حالة الدفع
                    </p>
                    <Badge
                      variant={
                        paymentStatusVariants[selectedOrder.paymentStatus]
                      }
                    >
                      {paymentStatusLabels[selectedOrder.paymentStatus]}
                    </Badge>
                  </div>
                  <div>
                    <p className="text-sm text-gray-500 dark:text-gray-400">
                      التاريخ
                    </p>
                    <p className="font-medium text-gray-900 dark:text-gray-100">
                      {formatDate(selectedOrder.createdAt, locale)}
                    </p>
                  </div>
                </div>

                {/* Order Items */}
                <div>
                  <h4 className="font-medium text-gray-900 dark:text-gray-100 mb-3">
                    المنتجات
                  </h4>
                  <div className="border dark:border-slate-700 rounded-lg divide-y dark:divide-slate-700">
                    {selectedOrder.items.map((item, index) => (
                      <div
                        key={index}
                        className="p-3 flex items-center justify-between"
                      >
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 bg-gray-100 dark:bg-slate-800 rounded-lg" />
                          <div>
                            <p className="font-medium text-gray-900 dark:text-gray-100">
                              {item.productSnapshot?.name ||
                                (typeof item.product === "object"
                                  ? item.product?.name
                                  : "-")}
                            </p>
                            <p className="text-xs text-gray-500 dark:text-gray-400">
                              {item.productSnapshot?.sku ||
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

                {/* Order Summary */}
                <div className="bg-gray-50 dark:bg-slate-800 rounded-lg p-4">
                  <div className="flex justify-between mb-2">
                    <span className="text-gray-500 dark:text-gray-400">
                      المجموع الفرعي
                    </span>
                    <span className="text-gray-900 dark:text-gray-100">
                      {formatCurrency(selectedOrder.subtotal, "SAR", locale)}
                    </span>
                  </div>
                  {selectedOrder.discount > 0 && (
                    <div className="flex justify-between mb-2 text-green-600 dark:text-green-400">
                      <span>الخصم</span>
                      <span>
                        -{" "}
                        {formatCurrency(selectedOrder.discount, "SAR", locale)}
                      </span>
                    </div>
                  )}
                  <div className="flex justify-between mb-2">
                    <span className="text-gray-500 dark:text-gray-400">
                      الضريبة
                    </span>
                    <span className="text-gray-900 dark:text-gray-100">
                      {formatCurrency(selectedOrder.tax, "SAR", locale)}
                    </span>
                  </div>
                  <div className="flex justify-between font-bold text-lg border-t dark:border-slate-700 pt-2 mt-2">
                    <span className="text-gray-900 dark:text-gray-100">
                      الإجمالي
                    </span>
                    <span className="text-gray-900 dark:text-gray-100">
                      {formatCurrency(selectedOrder.total, "SAR", locale)}
                    </span>
                  </div>
                </div>
              </TabsContent>

              {/* Shipments Tab */}
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

              {/* Notes Tab */}
              <TabsContent value="notes" className="mt-4 space-y-4">
                {/* Add Note Form */}
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
                  </Button>
                </div>

                {/* Notes List */}
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
          )}
        </DialogContent>
      </Dialog>

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
      <Dialog open={isStatusDialogOpen} onOpenChange={setIsStatusDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <RefreshCw className="h-5 w-5" />
              تحديث حالة الطلب
            </DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>الحالة الجديدة</Label>
              <select
                value={newStatus}
                onChange={(e) => setNewStatus(e.target.value)}
                className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm"
              >
                <option value="pending">قيد الانتظار</option>
                <option value="confirmed">مؤكد</option>
                <option value="processing">قيد المعالجة</option>
                <option value="shipped">تم الشحن</option>
                <option value="delivered">تم التوصيل</option>
                <option value="cancelled">ملغي</option>
              </select>
            </div>
          </div>
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => setIsStatusDialogOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleUpdateStatus}
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
