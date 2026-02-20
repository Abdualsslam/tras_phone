import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm } from "react-hook-form";
import {
  inventoryApi,
  type Warehouse,
  type InventoryCount,
  type StockTransfer,
  type StockReservation,
} from "@/api/inventory.api";
import { toast } from "sonner";
import { getErrorMessage } from "@/api/client";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
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
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Warehouse as WarehouseIcon,
  Package,
  AlertTriangle,
  ArrowLeftRight,
  Plus,
  Pencil,
  Loader2,
  TrendingDown,
  TrendingUp,
  CheckCircle,
  Clock,
  ClipboardList,
  Lock,
  Truck,
} from "lucide-react";
import { formatDate, formatNumber } from "@/lib/utils";

export function InventoryPage() {
  const queryClient = useQueryClient();

  const [activeTab, setActiveTab] = useState("overview");
  const [isWarehouseDialogOpen, setIsWarehouseDialogOpen] = useState(false);
  const [isTransferDialogOpen, setIsTransferDialogOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState<Warehouse | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [stockFilter, setStockFilter] = useState<string>("all");

  // Queries
  const { data: stats } = useQuery({
    queryKey: ["inventory-stats"],
    queryFn: () => inventoryApi.getStats(),
  });

  const { data: warehouses = [], isLoading: warehousesLoading } = useQuery({
    queryKey: ["inventory-warehouses"],
    queryFn: () => inventoryApi.getWarehouses(),
  });

  const { data: stock = [], isLoading: stockLoading } = useQuery({
    queryKey: ["inventory-stock", stockFilter],
    queryFn: () =>
      inventoryApi.getStock(
        stockFilter !== "all" ? { status: stockFilter } : undefined
      ),
  });

  const { data: alerts = [], isLoading: alertsLoading } = useQuery({
    queryKey: ["inventory-alerts"],
    queryFn: () => inventoryApi.getAlerts("pending"),
  });

  const { data: movements = [], isLoading: movementsLoading } = useQuery({
    queryKey: ["inventory-movements"],
    queryFn: () => inventoryApi.getMovements(),
  });

  const { data: counts = [], isLoading: countsLoading } = useQuery<
    InventoryCount[]
  >({
    queryKey: ["inventory-counts"],
    queryFn: () => inventoryApi.getInventoryCounts(),
  });

  const { data: transfers = [], isLoading: transfersLoading } = useQuery<
    StockTransfer[]
  >({
    queryKey: ["inventory-transfers"],
    queryFn: () => inventoryApi.getStockTransfers(),
  });

  const { data: reservations = [], isLoading: reservationsLoading } = useQuery<
    StockReservation[]
  >({
    queryKey: ["inventory-reservations"],
    queryFn: () => inventoryApi.getReservations(),
  });

  // Mutations
  const createWarehouseMutation = useMutation({
    mutationFn: (data: any) => inventoryApi.createWarehouse(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inventory-warehouses"] });
      queryClient.invalidateQueries({ queryKey: ["inventory-stats"] });
      setIsWarehouseDialogOpen(false);
      toast.success("تم إضافة المستودع");
    },
    onError: (error) =>
      toast.error(getErrorMessage(error, "حدث خطأ في إضافة المستودع")),
  });

  const updateWarehouseMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Warehouse> }) =>
      inventoryApi.updateWarehouse(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inventory-warehouses"] });
      setIsWarehouseDialogOpen(false);
      toast.success("تم تحديث المستودع");
    },
    onError: (error) =>
      toast.error(getErrorMessage(error, "حدث خطأ في تحديث المستودع")),
  });

  const transferStockMutation = useMutation({
    mutationFn: inventoryApi.transferStock,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inventory-stock"] });
      queryClient.invalidateQueries({ queryKey: ["inventory-movements"] });
      setIsTransferDialogOpen(false);
      toast.success("تم نقل المخزون");
    },
    onError: (error) =>
      toast.error(getErrorMessage(error, "حدث خطأ في نقل المخزون")),
  });

  const acknowledgeAlertMutation = useMutation({
    mutationFn: (id: string) => inventoryApi.acknowledgeAlert(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inventory-alerts"] });
      toast.success("تم تأكيد التنبيه");
    },
  });

  const resolveAlertMutation = useMutation({
    mutationFn: (id: string) => inventoryApi.resolveAlert(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inventory-alerts"] });
      queryClient.invalidateQueries({ queryKey: ["inventory-stats"] });
      toast.success("تم حل التنبيه");
    },
  });

  const approveTransferMutation = useMutation({
    mutationFn: (id: string) => inventoryApi.approveStockTransfer(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inventory-transfers"] });
      toast.success("تم اعتماد التحويل");
    },
  });

  const shipTransferMutation = useMutation({
    mutationFn: (id: string) => inventoryApi.shipStockTransfer(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inventory-transfers"] });
      toast.success("تم شحن التحويل");
    },
  });

  const releaseReservationMutation = useMutation({
    mutationFn: (id: string) => inventoryApi.releaseReservation(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inventory-reservations"] });
      toast.success("تم تحرير الحجز");
    },
  });

  const approveCountMutation = useMutation({
    mutationFn: (id: string) => inventoryApi.approveInventoryCount(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["inventory-counts"] });
      toast.success("تم اعتماد الجرد");
    },
  });

  // Forms
  const warehouseForm = useForm({
    defaultValues: {
      name: "",
      nameAr: "",
      code: "",
      address: { street: "", city: "", country: "" },
      isActive: true,
      isDefault: false,
    },
  });

  const transferForm = useForm({
    defaultValues: {
      productId: "",
      fromWarehouseId: "",
      toWarehouseId: "",
      quantity: 0,
      reason: "",
    },
  });

  // Handlers
  const handleAddWarehouse = () => {
    setIsEditing(false);
    setSelectedItem(null);
    warehouseForm.reset({
      name: "",
      nameAr: "",
      code: "",
      address: { street: "", city: "", country: "" },
      isActive: true,
      isDefault: false,
    });
    setIsWarehouseDialogOpen(true);
  };

  const handleEditWarehouse = (warehouse: Warehouse) => {
    setIsEditing(true);
    setSelectedItem(warehouse);
    warehouseForm.reset({
      name: warehouse.name,
      nameAr: warehouse.nameAr || "",
      code: warehouse.code,
      address: warehouse.address || { street: "", city: "", country: "" },
      isActive: warehouse.isActive,
      isDefault: warehouse.isDefault,
    });
    setIsWarehouseDialogOpen(true);
  };

  const onWarehouseSubmit = (data: any) => {
    if (isEditing && selectedItem) {
      updateWarehouseMutation.mutate({ id: selectedItem._id, data });
    } else {
      createWarehouseMutation.mutate(data);
    }
  };

  const onTransferSubmit = (data: any) => {
    transferStockMutation.mutate(data);
  };

  // Helpers
  const getStatusBadge = (status: string) => {
    switch (status) {
      case "in_stock":
        return <Badge variant="success">متوفر</Badge>;
      case "low_stock":
        return <Badge variant="warning">منخفض</Badge>;
      case "out_of_stock":
        return <Badge variant="danger">نفذ</Badge>;
      default:
        return <Badge variant="secondary">{status}</Badge>;
    }
  };

  const getMovementIcon = (type: string) => {
    switch (type) {
      case "in":
        return <TrendingUp className="h-4 w-4 text-green-600" />;
      case "out":
        return <TrendingDown className="h-4 w-4 text-red-600" />;
      case "transfer":
        return <ArrowLeftRight className="h-4 w-4 text-blue-600" />;
      default:
        return <Package className="h-4 w-4" />;
    }
  };

  const renderLoadingState = () => (
    <div className="flex justify-center items-center h-40">
      <Loader2 className="h-8 w-8 animate-spin text-primary" />
    </div>
  );

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">إدارة المخزون</h1>
        <p className="text-muted-foreground text-sm">
          مراقبة المستودعات والمخزون والتنبيهات
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                <WarehouseIcon className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">المستودعات</p>
                <p className="text-2xl font-bold">
                  {stats?.totalWarehouses || warehouses.length}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                <Package className="h-5 w-5 text-green-600 dark:text-green-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">إجمالي المخزون</p>
                <p className="text-2xl font-bold">
                  {formatNumber(stats?.totalStock || 0)}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-yellow-100 dark:bg-yellow-900/30 rounded-lg">
                <TrendingDown className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">منخفض المخزون</p>
                <p className="text-2xl font-bold">
                  {stats?.lowStockItems || 0}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-red-100 dark:bg-red-900/30 rounded-lg">
                <AlertTriangle className="h-5 w-5 text-red-600 dark:text-red-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">تنبيهات معلقة</p>
                <p className="text-2xl font-bold">
                  {stats?.pendingAlerts || alerts.length}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="mb-4">
          <TabsTrigger value="overview" className="flex items-center gap-2">
            <Package className="h-4 w-4" />
            المخزون
          </TabsTrigger>
          <TabsTrigger value="warehouses" className="flex items-center gap-2">
            <WarehouseIcon className="h-4 w-4" />
            المستودعات
          </TabsTrigger>
          <TabsTrigger value="alerts" className="flex items-center gap-2">
            <AlertTriangle className="h-4 w-4" />
            التنبيهات
            {alerts.length > 0 && (
              <Badge variant="danger" className="mr-1">
                {alerts.length}
              </Badge>
            )}
          </TabsTrigger>
          <TabsTrigger value="movements" className="flex items-center gap-2">
            <ArrowLeftRight className="h-4 w-4" />
            الحركات
          </TabsTrigger>
          <TabsTrigger value="counts" className="flex items-center gap-2">
            <ClipboardList className="h-4 w-4" />
            الجرد
          </TabsTrigger>
          <TabsTrigger value="transfers" className="flex items-center gap-2">
            <Truck className="h-4 w-4" />
            التحويلات
          </TabsTrigger>
          <TabsTrigger value="reservations" className="flex items-center gap-2">
            <Lock className="h-4 w-4" />
            الحجوزات
          </TabsTrigger>
        </TabsList>

        {/* Stock */}
        <TabsContent value="overview">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <Package className="h-5 w-5" />
                  المخزون الحالي
                </CardTitle>
                <div className="flex gap-2">
                  <Select value={stockFilter} onValueChange={setStockFilter}>
                    <SelectTrigger className="w-[150px]">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">الكل</SelectItem>
                      <SelectItem value="in_stock">متوفر</SelectItem>
                      <SelectItem value="low_stock">منخفض</SelectItem>
                      <SelectItem value="out_of_stock">نفذ</SelectItem>
                    </SelectContent>
                  </Select>
                  <Button onClick={() => setIsTransferDialogOpen(true)}>
                    <ArrowLeftRight className="h-4 w-4 ml-2" />
                    نقل مخزون
                  </Button>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              {stockLoading ? (
                renderLoadingState()
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>المنتج</TableHead>
                      <TableHead>SKU</TableHead>
                      <TableHead>المستودع</TableHead>
                      <TableHead>الكمية</TableHead>
                      <TableHead>المحجوز</TableHead>
                      <TableHead>المتاح</TableHead>
                      <TableHead>الحالة</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {stock.map((item) => (
                      <TableRow key={item._id}>
                        <TableCell className="font-medium">
                          {item.product.name}
                        </TableCell>
                        <TableCell className="font-mono text-sm">
                          {item.product.sku}
                        </TableCell>
                        <TableCell>{item.warehouse.name}</TableCell>
                        <TableCell>{formatNumber(item.quantity)}</TableCell>
                        <TableCell className="text-muted-foreground">
                          {formatNumber(item.reservedQuantity)}
                        </TableCell>
                        <TableCell className="font-medium">
                          {formatNumber(item.availableQuantity)}
                        </TableCell>
                        <TableCell>{getStatusBadge(item.status)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Warehouses */}
        <TabsContent value="warehouses">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <WarehouseIcon className="h-5 w-5" />
                  المستودعات
                </CardTitle>
                <Button onClick={handleAddWarehouse}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة مستودع
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {warehousesLoading ? (
                renderLoadingState()
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {warehouses.map((warehouse) => (
                    <Card key={warehouse._id} className="border-2">
                      <CardContent className="p-4">
                        <div className="flex justify-between items-start mb-3">
                          <div>
                            <h3 className="font-bold text-lg">
                              {warehouse.name}
                            </h3>
                            <p className="text-sm text-muted-foreground font-mono">
                              {warehouse.code}
                            </p>
                          </div>
                          <div className="flex gap-1">
                            {warehouse.isDefault && (
                              <Badge variant="outline">افتراضي</Badge>
                            )}
                            <Badge
                              variant={
                                warehouse.isActive ? "success" : "secondary"
                              }
                            >
                              {warehouse.isActive ? "نشط" : "غير نشط"}
                            </Badge>
                          </div>
                        </div>
                        {warehouse.address && (
                          <p className="text-sm text-muted-foreground mb-3">
                            {[warehouse.address.city, warehouse.address.country]
                              .filter(Boolean)
                              .join(", ")}
                          </p>
                        )}
                        <div className="flex justify-between items-center pt-3 border-t">
                          <div className="text-sm">
                            <span className="text-muted-foreground">
                              المخزون:{" "}
                            </span>
                            <span className="font-bold">
                              {formatNumber(warehouse.totalStock || 0)}
                            </span>
                          </div>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => handleEditWarehouse(warehouse)}
                          >
                            <Pencil className="h-4 w-4" />
                          </Button>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Alerts */}
        <TabsContent value="alerts">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <AlertTriangle className="h-5 w-5" />
                تنبيهات المخزون
              </CardTitle>
            </CardHeader>
            <CardContent>
              {alertsLoading ? (
                renderLoadingState()
              ) : alerts.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <CheckCircle className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد تنبيهات معلقة</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>المنتج</TableHead>
                      <TableHead>المستودع</TableHead>
                      <TableHead>المخزون الحالي</TableHead>
                      <TableHead>الحد الأدنى</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead>التاريخ</TableHead>
                      <TableHead></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {alerts.map((alert) => (
                      <TableRow key={alert._id}>
                        <TableCell>
                          <div>
                            <p className="font-medium">{alert.product.name}</p>
                            <p className="text-xs text-muted-foreground font-mono">
                              {alert.product.sku}
                            </p>
                          </div>
                        </TableCell>
                        <TableCell>{alert.warehouse.name}</TableCell>
                        <TableCell className="font-bold text-red-600">
                          {alert.currentStock}
                        </TableCell>
                        <TableCell>{alert.minStockLevel}</TableCell>
                        <TableCell>
                          <Badge
                            variant={
                              alert.status === "pending"
                                ? "warning"
                                : "secondary"
                            }
                          >
                            <Clock className="h-3 w-3 ml-1" />
                            {alert.status === "pending" ? "معلق" : alert.status}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-muted-foreground text-sm">
                          {formatDate(alert.createdAt)}
                        </TableCell>
                        <TableCell>
                          <div className="flex gap-1">
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() =>
                                acknowledgeAlertMutation.mutate(alert._id)
                              }
                            >
                              تأكيد
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() =>
                                resolveAlertMutation.mutate(alert._id)
                              }
                            >
                              حل
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Movements */}
        <TabsContent value="movements">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <ArrowLeftRight className="h-5 w-5" />
                سجل الحركات
              </CardTitle>
            </CardHeader>
            <CardContent>
              {movementsLoading ? (
                renderLoadingState()
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>النوع</TableHead>
                      <TableHead>المنتج</TableHead>
                      <TableHead>الكمية</TableHead>
                      <TableHead>من/إلى</TableHead>
                      <TableHead>السبب</TableHead>
                      <TableHead>التاريخ</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {movements.map((movement) => (
                      <TableRow key={movement._id}>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            {getMovementIcon(movement.type)}
                            <span>
                              {movement.type === "in"
                                ? "وارد"
                                : movement.type === "out"
                                  ? "صادر"
                                  : movement.type === "transfer"
                                    ? "نقل"
                                    : "تعديل"}
                            </span>
                          </div>
                        </TableCell>
                        <TableCell>
                          <div>
                            <p className="font-medium">
                              {movement.product.name}
                            </p>
                            <p className="text-xs text-muted-foreground font-mono">
                              {movement.product.sku}
                            </p>
                          </div>
                        </TableCell>
                        <TableCell
                          className={
                            movement.type === "in"
                              ? "text-green-600 font-medium"
                              : movement.type === "out"
                                ? "text-red-600 font-medium"
                                : "font-medium"
                          }
                        >
                          {movement.type === "in"
                            ? "+"
                            : movement.type === "out"
                              ? "-"
                              : ""}
                          {formatNumber(movement.quantity)}
                        </TableCell>
                        <TableCell className="text-sm">
                          {movement.type === "transfer"
                            ? `${movement.fromWarehouseName || ""} → ${movement.toWarehouseName || ""}`
                            : movement.toWarehouseName ||
                              movement.fromWarehouseName ||
                              "-"}
                        </TableCell>
                        <TableCell className="text-sm text-muted-foreground">
                          {movement.reason || "-"}
                        </TableCell>
                        <TableCell className="text-muted-foreground text-sm">
                          {formatDate(movement.createdAt)}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Inventory Counts */}
        <TabsContent value="counts">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <ClipboardList className="h-5 w-5" />
                عمليات الجرد
              </CardTitle>
            </CardHeader>
            <CardContent>
              {countsLoading ? (
                renderLoadingState()
              ) : counts.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <ClipboardList className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد عمليات جرد</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>المستودع</TableHead>
                      <TableHead>النوع</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead>عدد الأصناف</TableHead>
                      <TableHead>التاريخ</TableHead>
                      <TableHead></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {counts.map((count) => (
                      <TableRow key={count._id}>
                        <TableCell className="font-medium">
                          {count.warehouse?.name || "-"}
                        </TableCell>
                        <TableCell>
                          <Badge variant="outline">
                            {count.type === "full"
                              ? "كامل"
                              : count.type === "partial"
                                ? "جزئي"
                                : "دوري"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={
                              count.status === "approved"
                                ? "success"
                                : count.status === "completed"
                                  ? "default"
                                  : "warning"
                            }
                          >
                            {count.status === "draft"
                              ? "مسودة"
                              : count.status === "in_progress"
                                ? "قيد التنفيذ"
                                : count.status === "completed"
                                  ? "مكتمل"
                                  : "معتمد"}
                          </Badge>
                        </TableCell>
                        <TableCell>{count.items?.length || 0}</TableCell>
                        <TableCell className="text-muted-foreground text-sm">
                          {formatDate(count.createdAt)}
                        </TableCell>
                        <TableCell>
                          {count.status === "completed" && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() =>
                                approveCountMutation.mutate(count._id)
                              }
                            >
                              اعتماد
                            </Button>
                          )}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Stock Transfers */}
        <TabsContent value="transfers">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Truck className="h-5 w-5" />
                تحويلات المخزون
              </CardTitle>
            </CardHeader>
            <CardContent>
              {transfersLoading ? (
                renderLoadingState()
              ) : transfers.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <Truck className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد تحويلات</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>رقم التحويل</TableHead>
                      <TableHead>من</TableHead>
                      <TableHead>إلى</TableHead>
                      <TableHead>عدد الأصناف</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead>التاريخ</TableHead>
                      <TableHead></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {transfers.map((transfer) => (
                      <TableRow key={transfer._id}>
                        <TableCell className="font-mono text-sm">
                          {transfer.transferNumber}
                        </TableCell>
                        <TableCell>
                          {transfer.fromWarehouse?.name || "-"}
                        </TableCell>
                        <TableCell>
                          {transfer.toWarehouse?.name || "-"}
                        </TableCell>
                        <TableCell>{transfer.items?.length || 0}</TableCell>
                        <TableCell>
                          <Badge
                            variant={
                              transfer.status === "received"
                                ? "success"
                                : transfer.status === "shipped"
                                  ? "default"
                                  : "warning"
                            }
                          >
                            {transfer.status === "pending"
                              ? "معلق"
                              : transfer.status === "approved"
                                ? "معتمد"
                                : transfer.status === "shipped"
                                  ? "مشحون"
                                  : transfer.status === "received"
                                    ? "مستلم"
                                    : "ملغي"}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-muted-foreground text-sm">
                          {formatDate(transfer.createdAt)}
                        </TableCell>
                        <TableCell>
                          <div className="flex gap-1">
                            {transfer.status === "pending" && (
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() =>
                                  approveTransferMutation.mutate(transfer._id)
                                }
                              >
                                اعتماد
                              </Button>
                            )}
                            {transfer.status === "approved" && (
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() =>
                                  shipTransferMutation.mutate(transfer._id)
                                }
                              >
                                شحن
                              </Button>
                            )}
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Reservations */}
        <TabsContent value="reservations">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Lock className="h-5 w-5" />
                حجوزات المخزون
              </CardTitle>
            </CardHeader>
            <CardContent>
              {reservationsLoading ? (
                renderLoadingState()
              ) : reservations.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <Lock className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد حجوزات نشطة</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>المنتج</TableHead>
                      <TableHead>المستودع</TableHead>
                      <TableHead>الكمية</TableHead>
                      <TableHead>رقم الطلب</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead>تاريخ الانتهاء</TableHead>
                      <TableHead></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {reservations.map((reservation) => (
                      <TableRow key={reservation._id}>
                        <TableCell>
                          <div>
                            <p className="font-medium">
                              {reservation.product?.name || "-"}
                            </p>
                            <p className="text-xs text-muted-foreground font-mono">
                              {reservation.product?.sku}
                            </p>
                          </div>
                        </TableCell>
                        <TableCell>
                          {reservation.warehouse?.name || "-"}
                        </TableCell>
                        <TableCell className="font-medium">
                          {formatNumber(reservation.quantity)}
                        </TableCell>
                        <TableCell className="font-mono text-sm">
                          {reservation.orderNumber || "-"}
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={
                              reservation.status === "active"
                                ? "warning"
                                : reservation.status === "released"
                                  ? "success"
                                  : "danger"
                            }
                          >
                            {reservation.status === "active"
                              ? "نشط"
                              : reservation.status === "released"
                                ? "محرر"
                                : "منتهي"}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-muted-foreground text-sm">
                          {reservation.expiresAt
                            ? formatDate(reservation.expiresAt)
                            : "-"}
                        </TableCell>
                        <TableCell>
                          {reservation.status === "active" && (
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() =>
                                releaseReservationMutation.mutate(
                                  reservation._id
                                )
                              }
                            >
                              تحرير
                            </Button>
                          )}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Warehouse Dialog */}
      <Dialog
        open={isWarehouseDialogOpen}
        onOpenChange={setIsWarehouseDialogOpen}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل المستودع" : "إضافة مستودع جديد"}
            </DialogTitle>
          </DialogHeader>
          <form
            onSubmit={warehouseForm.handleSubmit(onWarehouseSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (EN) *</Label>
                <Input
                  {...warehouseForm.register("name")}
                  placeholder="Main Warehouse"
                />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  {...warehouseForm.register("nameAr")}
                  placeholder="المستودع الرئيسي"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>الكود *</Label>
              <Input
                {...warehouseForm.register("code")}
                placeholder="WH-001"
                className="font-mono"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>المدينة</Label>
                <Input
                  {...warehouseForm.register("address.city")}
                  placeholder="الرياض"
                />
              </div>
              <div className="space-y-2">
                <Label>الدولة</Label>
                <Input
                  {...warehouseForm.register("address.country")}
                  placeholder="السعودية"
                />
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <Switch
                  id="warehouseActive"
                  checked={warehouseForm.watch("isActive")}
                  onCheckedChange={(checked: boolean) =>
                    warehouseForm.setValue("isActive", checked)
                  }
                />
                <Label htmlFor="warehouseActive">نشط</Label>
              </div>
              <div className="flex items-center gap-2">
                <Switch
                  id="warehouseDefault"
                  checked={warehouseForm.watch("isDefault")}
                  onCheckedChange={(checked: boolean) =>
                    warehouseForm.setValue("isDefault", checked)
                  }
                />
                <Label htmlFor="warehouseDefault">افتراضي</Label>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsWarehouseDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createWarehouseMutation.isPending ||
                  updateWarehouseMutation.isPending
                }
              >
                {(createWarehouseMutation.isPending ||
                  updateWarehouseMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إضافة"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Transfer Dialog */}
      <Dialog
        open={isTransferDialogOpen}
        onOpenChange={setIsTransferDialogOpen}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>نقل مخزون</DialogTitle>
          </DialogHeader>
          <form
            onSubmit={transferForm.handleSubmit(onTransferSubmit)}
            className="space-y-4"
          >
            <div className="space-y-2">
              <Label>معرف المنتج *</Label>
              <Input
                {...transferForm.register("productId")}
                placeholder="معرف المنتج"
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>من المستودع *</Label>
                <Select
                  value={transferForm.watch("fromWarehouseId")}
                  onValueChange={(value) =>
                    transferForm.setValue("fromWarehouseId", value)
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="اختر المستودع" />
                  </SelectTrigger>
                  <SelectContent>
                    {warehouses.map((w) => (
                      <SelectItem key={w._id} value={w._id}>
                        {w.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>إلى المستودع *</Label>
                <Select
                  value={transferForm.watch("toWarehouseId")}
                  onValueChange={(value) =>
                    transferForm.setValue("toWarehouseId", value)
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="اختر المستودع" />
                  </SelectTrigger>
                  <SelectContent>
                    {warehouses.map((w) => (
                      <SelectItem key={w._id} value={w._id}>
                        {w.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="space-y-2">
              <Label>الكمية *</Label>
              <Input
                type="number"
                {...transferForm.register("quantity", { valueAsNumber: true })}
                placeholder="0"
              />
            </div>
            <div className="space-y-2">
              <Label>السبب</Label>
              <Input
                {...transferForm.register("reason")}
                placeholder="سبب النقل (اختياري)"
              />
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsTransferDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button type="submit" disabled={transferStockMutation.isPending}>
                {transferStockMutation.isPending && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                نقل
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export default InventoryPage;
