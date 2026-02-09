import { useTranslation } from "react-i18next";
import { useQuery } from "@tanstack/react-query";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { analyticsApi } from "@/api/analytics.api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  DollarSign,
  ShoppingCart,
  Users,
  Package,
  TrendingUp,
  TrendingDown,
  ArrowUpRight,
  Loader2,
  AlertTriangle,
} from "lucide-react";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { cn, formatCurrency, formatNumber, formatDate } from "@/lib/utils";

const statusColors: Record<string, string> = {
  pending: "bg-yellow-100 text-yellow-700",
  processing: "bg-blue-100 text-blue-700",
  shipped: "bg-purple-100 text-purple-700",
  delivered: "bg-green-100 text-green-700",
  confirmed: "bg-blue-100 text-blue-700",
  cancelled: "bg-red-100 text-red-700",
};

const statusLabels: Record<string, string> = {
  pending: "قيد الانتظار",
  confirmed: "مؤكد",
  processing: "قيد المعالجة",
  shipped: "تم الشحن",
  delivered: "تم التوصيل",
  cancelled: "ملغي",
};

export function DashboardPage() {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const { user } = useAuth();
  const locale = i18n.language === "ar" ? "ar-SA" : "en-US";

  // Fetch dashboard stats from backend
  const { data: stats, isLoading } = useQuery({
    queryKey: ["dashboard"],
    queryFn: analyticsApi.getDashboard,
  });

  const statCards = [
    {
      titleKey: "dashboard.totalRevenue",
      value: stats?.overview?.revenue?.thisMonth || 0,
      change: stats?.overview?.revenue?.change || 0,
      icon: DollarSign,
      format: "currency",
      color: "bg-green-500",
      showChangeAsPercentage: true,
    },
    {
      titleKey: "dashboard.totalOrders",
      value: stats?.overview?.orders?.thisMonth || 0,
      change: stats?.overview?.orders?.change || 0,
      icon: ShoppingCart,
      format: "number",
      color: "bg-blue-500",
      showChangeAsPercentage: true,
    },
    {
      titleKey: "dashboard.totalCustomers",
      value: stats?.overview?.customers?.total || 0,
      change: stats?.overview?.customers?.newThisMonth || 0,
      icon: Users,
      format: "number",
      color: "bg-purple-500",
      showChangeAsPercentage: false,
      subtitle: "جديد هذا الشهر",
    },
    {
      titleKey: "dashboard.totalProducts",
      value: stats?.overview?.products?.total || 0,
      change: stats?.overview?.products?.active || 0,
      icon: Package,
      format: "number",
      color: "bg-orange-500",
      showChangeAsPercentage: false,
      subtitle: "نشط",
    },
  ];

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-[50vh]">
        <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Welcome Message */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
          {t("dashboard.welcome")}، {user?.fullName}! 👋
        </h1>
        <p className="text-gray-500 dark:text-gray-400 mt-1">
          إليك نظرة عامة على نشاط متجرك اليوم
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map((stat) => (
          <Card key={stat.titleKey} className="relative overflow-hidden">
            <CardContent className="p-6">
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-sm text-gray-500 dark:text-gray-400 mb-1">
                    {t(stat.titleKey)}
                  </p>
                  <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                    {stat.format === "currency"
                      ? formatCurrency(stat.value, "SAR", locale)
                      : formatNumber(stat.value, locale)}
                  </p>
                </div>
                <div className={cn("p-3 rounded-xl", stat.color)}>
                  <stat.icon className="h-5 w-5 text-white" />
                </div>
              </div>

              <div className="flex items-center gap-1 mt-4">
                {stat.showChangeAsPercentage ? (
                  <>
                    {stat.change >= 0 ? (
                      <TrendingUp className="h-4 w-4 text-green-500" />
                    ) : (
                      <TrendingDown className="h-4 w-4 text-red-500" />
                    )}
                    <span
                      className={cn(
                        "text-sm font-medium",
                        stat.change >= 0 ? "text-green-500" : "text-red-500"
                      )}
                    >
                      {stat.change >= 0 ? "+" : ""}
                      {stat.change.toFixed(1)}%
                    </span>
                    <span className="text-sm text-gray-400 dark:text-gray-500">
                      مقارنة بالشهر الماضي
                    </span>
                  </>
                ) : (
                  <>
                    <span className="text-sm text-gray-400 dark:text-gray-500">
                      {stat.subtitle}:
                    </span>
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">
                      {formatNumber(stat.change, locale)}
                    </span>
                  </>
                )}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Sales Chart */}
      {(stats?.salesChart?.length ?? 0) > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>مخطط المبيعات</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="h-[240px]">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart
                  data={(stats?.salesChart || []).map((d: any) => ({
                    ...d,
                    dateLabel: formatDate(d.date, locale),
                    revenue: d.revenue ?? 0,
                    orders: d.orders ?? 0,
                  }))}
                  margin={{ top: 8, right: 8, left: 8, bottom: 8 }}
                >
                  <CartesianGrid
                    strokeDasharray="3 3"
                    className="stroke-gray-200 dark:stroke-slate-700"
                  />
                  <XAxis dataKey="dateLabel" tick={{ fontSize: 12 }} />
                  <YAxis
                    tick={{ fontSize: 12 }}
                    tickFormatter={(v) => formatNumber(v, locale)}
                  />
                  <Tooltip
                    formatter={(value: number | undefined) => [
                      formatNumber(value ?? 0, locale),
                      "",
                    ]}
                  />
                  <Bar
                    dataKey="revenue"
                    fill="#f97316"
                    name="الإيرادات"
                    radius={[4, 4, 0, 0]}
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Pending Actions */}
      {stats?.pendingActions &&
        (stats.pendingActions.total > 0 ||
          stats.pendingActions.lowStockCount > 0) && (
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <AlertTriangle className="h-5 w-5 text-amber-500" />
                إجراءات تحتاج انتباه
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex flex-wrap gap-4">
                {stats.pendingActions.pendingOrders > 0 && (
                  <Link
                    to="/orders"
                    className="flex items-center gap-2 rounded-lg border p-3 hover:bg-gray-50 dark:hover:bg-slate-800 min-w-[140px]"
                  >
                    <ShoppingCart className="h-5 w-5 text-amber-500" />
                    <div>
                      <p className="text-2xl font-bold">
                        {stats.pendingActions.pendingOrders}
                      </p>
                      <p className="text-xs text-gray-500">طلبات معلقة</p>
                    </div>
                  </Link>
                )}
                {stats.pendingActions.lowStockCount > 0 && (
                  <Link
                    to="/inventory"
                    className="flex items-center gap-2 rounded-lg border p-3 hover:bg-gray-50 dark:hover:bg-slate-800 min-w-[140px]"
                  >
                    <Package className="h-5 w-5 text-red-500" />
                    <div>
                      <p className="text-2xl font-bold">
                        {stats.pendingActions.lowStockCount}
                      </p>
                      <p className="text-xs text-gray-500">
                        منتجات منخفضة المخزون
                      </p>
                    </div>
                  </Link>
                )}
                {stats.pendingActions.pendingApprovals > 0 && (
                  <Link
                    to="/customers"
                    className="flex items-center gap-2 rounded-lg border p-3 hover:bg-gray-50 dark:hover:bg-slate-800 min-w-[140px]"
                  >
                    <Users className="h-5 w-5 text-blue-500" />
                    <div>
                      <p className="text-2xl font-bold">
                        {stats.pendingActions.pendingApprovals}
                      </p>
                      <p className="text-xs text-gray-500">
                        عميل بانتظار الموافقة
                      </p>
                    </div>
                  </Link>
                )}
              </div>
            </CardContent>
          </Card>
        )}

      {/* Top Products & Top Customers */}
      <div className="grid lg:grid-cols-2 gap-6">
        {/* Top Products */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>أفضل المنتجات</CardTitle>
            <Link
              to="/products"
              className="text-sm text-primary-600 hover:underline flex items-center gap-1"
            >
              عرض الكل
              <ArrowUpRight className="h-4 w-4" />
            </Link>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {(stats?.topProducts || [])
                .slice(0, 5)
                .map((product: any, index: number) => (
                  <div
                    key={product._id || index}
                    className="flex items-center justify-between"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center text-sm font-medium text-primary-700">
                        {index + 1}
                      </div>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-gray-100">
                          {product.name || product.nameAr}
                        </p>
                        <p className="text-xs text-gray-500">
                          {product.sku} • {product.stockQuantity ?? 0} وحدة
                        </p>
                      </div>
                    </div>
                    <p className="font-medium text-gray-900 dark:text-gray-100">
                      {formatCurrency(product.basePrice ?? 0, "SAR", locale)}
                    </p>
                  </div>
                ))}
              {(!stats?.topProducts || stats.topProducts.length === 0) && (
                <div className="py-8 text-center text-gray-500 dark:text-gray-400">
                  لا توجد بيانات
                </div>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Top Customers */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>أفضل العملاء</CardTitle>
            <Link
              to="/customers"
              className="text-sm text-primary-600 hover:underline flex items-center gap-1"
            >
              عرض الكل
              <ArrowUpRight className="h-4 w-4" />
            </Link>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {(stats?.topCustomers || [])
                .slice(0, 5)
                .map((customer: any, index: number) => (
                  <div
                    key={customer._id || index}
                    className="flex items-center justify-between"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center text-sm font-medium text-primary-700">
                        {index + 1}
                      </div>
                      <div>
                        <p className="font-medium text-gray-900 dark:text-gray-100">
                          {customer.shopName || customer.responsiblePersonName}
                        </p>
                        <p className="text-xs text-gray-500">
                          {customer.totalOrders ?? 0} طلب
                        </p>
                      </div>
                    </div>
                    <p className="font-medium text-gray-900 dark:text-gray-100">
                      {formatCurrency(customer.totalSpent ?? 0, "SAR", locale)}
                    </p>
                  </div>
                ))}
              {(!stats?.topCustomers || stats.topCustomers.length === 0) && (
                <div className="py-8 text-center text-gray-500 dark:text-gray-400">
                  لا توجد بيانات
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Low Stock */}
      {(stats?.lowStock?.length ?? 0) > 0 && (
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <CardTitle>منتجات منخفضة المخزون</CardTitle>
            <Link
              to="/inventory"
              className="text-sm text-primary-600 hover:underline flex items-center gap-1"
            >
              عرض الكل
              <ArrowUpRight className="h-4 w-4" />
            </Link>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="border-b border-gray-200 dark:border-slate-700">
                    <th className="text-start py-2 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                      المنتج
                    </th>
                    <th className="text-start py-2 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                      الكمية
                    </th>
                    <th className="text-start py-2 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                      الحد الأدنى
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {(stats?.lowStock || []).slice(0, 5).map((p: any) => (
                    <tr
                      key={p._id}
                      className="border-b border-gray-100 dark:border-slate-800"
                    >
                      <td className="py-2 px-4 text-sm font-medium">
                        {p.name || p.nameAr}
                      </td>
                      <td className="py-2 px-4 text-sm">
                        <span
                          className={cn(
                            p.stockQuantity <= 0
                              ? "text-red-600 font-medium"
                              : "text-amber-600"
                          )}
                        >
                          {p.stockQuantity ?? 0}
                        </span>
                      </td>
                      <td className="py-2 px-4 text-sm text-gray-500">
                        {p.lowStockThreshold ?? 0}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Recent Orders */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between">
          <CardTitle>{t("dashboard.recentOrders")}</CardTitle>
          <Link
            to="/orders"
            className="text-sm text-primary-600 hover:underline flex items-center gap-1"
          >
            عرض الكل
            <ArrowUpRight className="h-4 w-4" />
          </Link>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200 dark:border-slate-700">
                  <th className="text-start py-3 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                    رقم الطلب
                  </th>
                  <th className="text-start py-3 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                    العميل
                  </th>
                  <th className="text-start py-3 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                    الإجمالي
                  </th>
                  <th className="text-start py-3 px-4 text-sm font-medium text-gray-500 dark:text-gray-400">
                    الحالة
                  </th>
                </tr>
              </thead>
              <tbody>
                {(stats?.recentOrders || []).slice(0, 5).map((order: any) => (
                  <tr
                    key={order._id}
                    className="border-b border-gray-100 dark:border-slate-800 hover:bg-gray-50 dark:hover:bg-slate-800 cursor-pointer"
                    onClick={() => navigate(`/orders/${order._id}`)}
                  >
                    <td className="py-3 px-4 text-sm font-medium text-gray-900 dark:text-gray-100">
                      {order.orderNumber}
                    </td>
                    <td className="py-3 px-4 text-sm text-gray-600 dark:text-gray-400">
                      {order.customerId?.shopName ||
                        order.customer?.companyName ||
                        order.customerId?.responsiblePersonName ||
                        "-"}
                    </td>
                    <td className="py-3 px-4 text-sm text-gray-900 dark:text-gray-100 font-medium">
                      {formatCurrency(order.total, "SAR", locale)}
                    </td>
                    <td className="py-3 px-4">
                      <span
                        className={cn(
                          "px-2.5 py-1 rounded-full text-xs font-medium",
                          statusColors[order.status] ||
                            "bg-gray-100 text-gray-700"
                        )}
                      >
                        {statusLabels[order.status] || order.status}
                      </span>
                    </td>
                  </tr>
                ))}
                {(!stats?.recentOrders || stats.recentOrders.length === 0) && (
                  <tr>
                    <td
                      colSpan={4}
                      className="py-8 text-center text-gray-500 dark:text-gray-400"
                    >
                      لا توجد طلبات حديثة
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
