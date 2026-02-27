import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm } from "react-hook-form";
import { walletApi, type LoyaltyTier } from "@/api/wallet.api";
import { customersApi } from "@/api/customers.api";
import { useAuth } from "@/contexts/AuthContext";
import { toast } from "sonner";
import { getErrorMessage } from "@/api/client";

import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Switch } from "@/components/ui/switch";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Loader2, Wallet, TrendingUp, Coins, Crown, Filter } from "lucide-react";
import { formatCurrency } from "@/lib/utils";

import { CustomerPickerCard } from "./components/CustomerPickerCard";
import { WalletContextBar } from "./components/WalletContextBar";
import { WalletTransactionsCard } from "./components/WalletTransactionsCard";
import {
  WalletOperationWizardDialog,
  type WalletOperationType,
} from "./components/WalletOperationWizardDialog";
import { LoyaltyTiersPanel } from "./components/LoyaltyTiersPanel";

type TierFormValues = Omit<LoyaltyTier, "_id" | "createdAt" | "updatedAt">;

type AuditFilterState = {
  type: "_all" | "credit" | "debit";
  transactionType: string;
  search: string;
  reference: string;
  startDate: string;
  endDate: string;
  onlySelectedCustomer: boolean;
};

const defaultAuditFilters: AuditFilterState = {
  type: "_all",
  transactionType: "_all",
  search: "",
  reference: "",
  startDate: "",
  endDate: "",
  onlySelectedCustomer: false,
};

export function WalletPage() {
  const queryClient = useQueryClient();
  const { permissions } = useAuth();

  const hasPermission = (permission: string) =>
    permissions.includes("*") || permissions.includes(permission);
  const canAddCredit = hasPermission("wallet.add_credit");
  const canDeduct = hasPermission("wallet.deduct");
  const canAdjustPoints = hasPermission("loyalty.adjust_points");
  const canViewTransactions = hasPermission("wallet.view_transactions");
  const canManageTiers = hasPermission("loyalty.manage_tiers");

  const [activeTab, setActiveTab] = useState("operations");
  const [selectedCustomerId, setSelectedCustomerId] = useState<string>("");
  const [selectedCustomerName, setSelectedCustomerName] = useState<string>("");
  const [customerSearch, setCustomerSearch] = useState("");

  const [isOperationDialogOpen, setIsOperationDialogOpen] = useState(false);
  const [defaultOperationType, setDefaultOperationType] = useState<WalletOperationType>("credit");

  const [auditDraftFilters, setAuditDraftFilters] = useState<AuditFilterState>(defaultAuditFilters);
  const [auditFilters, setAuditFilters] = useState<AuditFilterState>(defaultAuditFilters);
  const [auditPage, setAuditPage] = useState(1);
  const [auditLimit, setAuditLimit] = useState(20);

  const [isCreateTierDialogOpen, setIsCreateTierDialogOpen] = useState(false);
  const [isEditTierDialogOpen, setIsEditTierDialogOpen] = useState(false);
  const [isDeleteTierDialogOpen, setIsDeleteTierDialogOpen] = useState(false);
  const [selectedTier, setSelectedTier] = useState<LoyaltyTier | null>(null);

  const {
    data: tiers = [],
    isLoading: tiersLoading,
    refetch: refetchTiers,
  } = useQuery({
    queryKey: ["wallet-tiers-admin"],
    queryFn: () => walletApi.getAllTiers(),
    enabled: canManageTiers,
  });

  const { data: customerSearchResult, isLoading: customersLoading } = useQuery({
    queryKey: ["wallet-customer-search", customerSearch],
    queryFn: () =>
      customersApi.getAll({
        page: 1,
        limit: 10,
        search: customerSearch.trim(),
      }),
    enabled: customerSearch.trim().length >= 2,
  });

  const {
    data: walletStats,
    isLoading: statsLoading,
    isError: statsError,
    error: statsErrorData,
  } = useQuery({
    queryKey: ["wallet-admin-stats"],
    queryFn: () => walletApi.getWalletStats(),
  });

  const {
    data: adminTransactionsData,
    isLoading: adminTransactionsLoading,
    isError: adminTransactionsError,
    error: adminTransactionsErrorData,
  } = useQuery({
    queryKey: [
      "wallet-admin-transactions",
      auditPage,
      auditLimit,
      auditFilters.type,
      auditFilters.transactionType,
      auditFilters.search,
      auditFilters.reference,
      auditFilters.startDate,
      auditFilters.endDate,
      auditFilters.onlySelectedCustomer,
      selectedCustomerId,
    ],
    queryFn: () =>
      walletApi.getAllTransactions({
        page: auditPage,
        limit: auditLimit,
        type: auditFilters.type === "_all" ? undefined : auditFilters.type,
        transactionType:
          auditFilters.transactionType === "_all" ? undefined : auditFilters.transactionType,
        search: auditFilters.search.trim() || undefined,
        reference: auditFilters.reference.trim() || undefined,
        startDate: auditFilters.startDate || undefined,
        endDate: auditFilters.endDate || undefined,
        customerId: auditFilters.onlySelectedCustomer ? selectedCustomerId || undefined : undefined,
      }),
    enabled: canViewTransactions,
  });

  const auditTransactions = adminTransactionsData?.items || [];
  const auditPagination = adminTransactionsData?.pagination;

  const {
    data: customerBalance,
    isLoading: balanceLoading,
    isError: customerBalanceError,
    error: customerBalanceErrorData,
  } = useQuery({
    queryKey: ["wallet-balance", selectedCustomerId],
    queryFn: () => walletApi.getCustomerBalance(selectedCustomerId),
    enabled: !!selectedCustomerId,
  });

  const {
    data: transactions = [],
    isLoading: transactionsLoading,
    isError: transactionsError,
    error: transactionsErrorData,
  } = useQuery({
    queryKey: ["wallet-transactions", selectedCustomerId],
    queryFn: () => walletApi.getCustomerTransactions(selectedCustomerId),
    enabled: !!selectedCustomerId && canViewTransactions,
  });

  const customerOptions = customerSearchResult?.items || [];

  const formatOperationSuccessMessage = (
    baseMessage: string,
    transaction?: { transactionNumber?: string; referenceNumber?: string; reference?: string },
  ) => {
    const txNumber = transaction?.transactionNumber;
    const reference = transaction?.referenceNumber || transaction?.reference;
    const suffixParts = [txNumber ? `رقم العملية: ${txNumber}` : null, reference ? `المرجع: ${reference}` : null]
      .filter(Boolean)
      .join(" | ");

    return suffixParts ? `${baseMessage} - ${suffixParts}` : baseMessage;
  };

  const focusAuditForWalletOperation = (
    type: "credit" | "debit",
    transaction?: { transactionNumber?: string; referenceNumber?: string; reference?: string },
  ) => {
    const nextFilters: AuditFilterState = {
      ...defaultAuditFilters,
      type,
      search: transaction?.transactionNumber || "",
      reference: transaction?.referenceNumber || transaction?.reference || "",
      onlySelectedCustomer: !!selectedCustomerId,
    };

    setActiveTab("audit");
    setAuditPage(1);
    setAuditFilters(nextFilters);
    setAuditDraftFilters(nextFilters);
  };

  const invalidateWalletQueries = () => {
    queryClient.invalidateQueries({ queryKey: ["wallet-balance", selectedCustomerId] });
    queryClient.invalidateQueries({ queryKey: ["wallet-transactions", selectedCustomerId] });
    queryClient.invalidateQueries({ queryKey: ["wallet-admin-stats"] });
    queryClient.invalidateQueries({ queryKey: ["wallet-admin-transactions"] });
  };

  const creditMutation = useMutation({
    mutationFn: walletApi.creditWallet,
    onSuccess: (transaction) => {
      invalidateWalletQueries();
      setIsOperationDialogOpen(false);
      focusAuditForWalletOperation("credit", transaction);
      toast.success(formatOperationSuccessMessage("تم إضافة الرصيد بنجاح", transaction));
    },
    onError: (error) => toast.error(getErrorMessage(error, "حدث خطأ في إضافة الرصيد")),
  });

  const debitMutation = useMutation({
    mutationFn: walletApi.debitWallet,
    onSuccess: (transaction) => {
      invalidateWalletQueries();
      setIsOperationDialogOpen(false);
      focusAuditForWalletOperation("debit", transaction);
      toast.success(formatOperationSuccessMessage("تم خصم الرصيد بنجاح", transaction));
    },
    onError: (error) => toast.error(getErrorMessage(error, "حدث خطأ في خصم الرصيد")),
  });

  const grantPointsMutation = useMutation({
    mutationFn: walletApi.grantPoints,
    onSuccess: (transaction) => {
      invalidateWalletQueries();
      setIsOperationDialogOpen(false);
      const message = formatOperationSuccessMessage("تم منح النقاط بنجاح", {
        transactionNumber: transaction?.transactionNumber,
      });
      toast.success(message);
    },
    onError: (error) => toast.error(getErrorMessage(error, "حدث خطأ في منح النقاط")),
  });

  const createTierMutation = useMutation({
    mutationFn: walletApi.createTier,
    onSuccess: () => {
      refetchTiers();
      setIsCreateTierDialogOpen(false);
      toast.success("تم إنشاء المستوى بنجاح");
      tierForm.reset();
    },
    onError: (error) => toast.error(getErrorMessage(error, "حدث خطأ في إنشاء المستوى")),
  });

  const updateTierMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<LoyaltyTier> }) =>
      walletApi.updateTier(id, data),
    onSuccess: () => {
      refetchTiers();
      setIsEditTierDialogOpen(false);
      setSelectedTier(null);
      toast.success("تم تحديث المستوى بنجاح");
      tierForm.reset();
    },
    onError: (error) => toast.error(getErrorMessage(error, "حدث خطأ في تحديث المستوى")),
  });

  const deleteTierMutation = useMutation({
    mutationFn: (id: string) => walletApi.deleteTier(id),
    onSuccess: () => {
      refetchTiers();
      setIsDeleteTierDialogOpen(false);
      setSelectedTier(null);
      toast.success("تم حذف المستوى بنجاح");
    },
    onError: (error) => toast.error(getErrorMessage(error, "حدث خطأ في حذف المستوى")),
  });

  const tierForm = useForm<TierFormValues>({
    defaultValues: {
      name: "",
      nameAr: "",
      code: "",
      minPoints: 0,
      pointsMultiplier: 1,
      discountPercentage: 0,
      freeShipping: false,
      prioritySupport: false,
      earlyAccess: false,
      displayOrder: 0,
      isActive: true,
    },
  });

  const handleSelectCustomer = (customer: {
    _id: string;
    contactName?: string;
    companyName?: string;
    phone?: string;
  }) => {
    setSelectedCustomerId(customer._id);
    const name = customer.contactName || customer.companyName || customer.phone || "عميل";
    setCustomerSearch(name);
    setSelectedCustomerName(name);
  };

  const handleClearSelection = () => {
    setSelectedCustomerId("");
    setSelectedCustomerName("");

    if (auditDraftFilters.onlySelectedCustomer || auditFilters.onlySelectedCustomer) {
      const nextFilters = {
        ...defaultAuditFilters,
        type: auditFilters.type,
      };
      setAuditDraftFilters(nextFilters);
      setAuditFilters(nextFilters);
      setAuditPage(1);
    }
  };

  const applyAuditFilters = () => {
    const normalized: AuditFilterState = {
      ...auditDraftFilters,
      search: auditDraftFilters.search.trim(),
      reference: auditDraftFilters.reference.trim(),
      onlySelectedCustomer: auditDraftFilters.onlySelectedCustomer && !!selectedCustomerId,
    };

    setAuditPage(1);
    setAuditFilters(normalized);
  };

  const resetAuditFilters = () => {
    setAuditPage(1);
    setAuditDraftFilters(defaultAuditFilters);
    setAuditFilters(defaultAuditFilters);
  };

  const openOperationWizard = (type: WalletOperationType) => {
    if (!selectedCustomerId) {
      toast.error("يرجى اختيار عميل أولاً");
      return;
    }

    if (type === "credit" && !canAddCredit) {
      toast.error("ليس لديك صلاحية إضافة رصيد");
      return;
    }

    if (type === "debit" && !canDeduct) {
      toast.error("ليس لديك صلاحية خصم الرصيد");
      return;
    }

    if (type === "points" && !canAdjustPoints) {
      toast.error("ليس لديك صلاحية تعديل النقاط");
      return;
    }

    setDefaultOperationType(type);
    setIsOperationDialogOpen(true);
  };

  const handleOperationSubmit = (
    operationType: WalletOperationType,
    data: {
      amount?: number;
      points?: number;
      description?: string;
      reason?: string;
      reference?: string;
    },
  ) => {
    if (!selectedCustomerId) {
      toast.error("يرجى اختيار عميل أولاً");
      return;
    }

    if (operationType === "points") {
      grantPointsMutation.mutate({
        customerId: selectedCustomerId,
        points: Number(data.points || 0),
        reason: (data.reason || "").trim(),
      });
      return;
    }

    const payload = {
      customerId: selectedCustomerId,
      amount: Number(data.amount || 0),
      description: (data.description || "").trim(),
      reference: data.reference,
    };

    if (operationType === "credit") {
      creditMutation.mutate(payload);
      return;
    }

    debitMutation.mutate(payload);
  };

  const handleCreateTier = () => {
    tierForm.reset({
      name: "",
      nameAr: "",
      code: "",
      minPoints: 0,
      pointsMultiplier: 1,
      discountPercentage: 0,
      freeShipping: false,
      prioritySupport: false,
      earlyAccess: false,
      displayOrder: 0,
      isActive: true,
    });
    setIsCreateTierDialogOpen(true);
  };

  const handleEditTier = (tier: LoyaltyTier) => {
    setSelectedTier(tier);
    tierForm.reset({
      name: tier.name,
      nameAr: tier.nameAr,
      code: tier.code,
      minPoints: tier.minPoints,
      pointsMultiplier: tier.pointsMultiplier,
      discountPercentage: tier.discountPercentage,
      freeShipping: tier.freeShipping,
      prioritySupport: tier.prioritySupport,
      earlyAccess: tier.earlyAccess,
      displayOrder: tier.displayOrder,
      isActive: tier.isActive,
      description: tier.description,
      descriptionAr: tier.descriptionAr,
      color: tier.color,
      icon: tier.icon,
      badgeImage: tier.badgeImage,
      customBenefits: tier.customBenefits,
      minSpend: tier.minSpend,
      minOrders: tier.minOrders,
    });
    setIsEditTierDialogOpen(true);
  };

  const handleDeleteTier = (tier: LoyaltyTier) => {
    setSelectedTier(tier);
    setIsDeleteTierDialogOpen(true);
  };

  const onTierSubmit = (data: TierFormValues) => {
    if (selectedTier) {
      updateTierMutation.mutate({ id: selectedTier._id, data });
    } else {
      createTierMutation.mutate(data);
    }
  };

  const onDeleteTierConfirm = () => {
    if (selectedTier) {
      deleteTierMutation.mutate(selectedTier._id);
    }
  };

  const isOperationSubmitting =
    creditMutation.isPending || debitMutation.isPending || grantPointsMutation.isPending;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold">إدارة المحفظة والنقاط</h1>
        <p className="text-muted-foreground text-sm">
          تدفق موحد لتنفيذ العمليات المالية مع سجل واضح قابل للمراجعة
        </p>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="operations" className="flex items-center gap-2">
            <Wallet className="h-4 w-4" />
            العمليات
          </TabsTrigger>
          <TabsTrigger value="audit" className="flex items-center gap-2">
            <TrendingUp className="h-4 w-4" />
            السجل والتدقيق
          </TabsTrigger>
          {canManageTiers && (
            <TabsTrigger value="tiers" className="flex items-center gap-2">
              <Crown className="h-4 w-4" />
              مستويات الولاء
            </TabsTrigger>
          )}
        </TabsList>

        <div className="mt-4">
          <WalletContextBar
            selectedCustomerId={selectedCustomerId}
            selectedCustomerName={selectedCustomerName}
            balanceLoading={balanceLoading}
            balance={customerBalance?.balance}
            points={customerBalance?.points}
            tier={customerBalance?.tier}
          />
        </div>

        <TabsContent value="operations" className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
            <Card>
              <CardContent className="pt-6">
                <p className="text-sm text-muted-foreground">إجمالي أرصدة المحافظ</p>
                <p className="text-2xl font-bold mt-1">
                  {statsLoading ? "..." : formatCurrency(walletStats?.totalBalance || 0)}
                </p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <p className="text-sm text-muted-foreground">المحافظ النشطة</p>
                <p className="text-2xl font-bold mt-1">
                  {statsLoading ? "..." : (walletStats?.activeWallets || 0).toLocaleString()}
                </p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <p className="text-sm text-muted-foreground">إجمالي الإضافات</p>
                <p className="text-2xl font-bold mt-1 text-green-600">
                  {statsLoading ? "..." : formatCurrency(walletStats?.totalCredits || 0)}
                </p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <p className="text-sm text-muted-foreground">إجمالي الخصومات</p>
                <p className="text-2xl font-bold mt-1 text-red-600">
                  {statsLoading ? "..." : formatCurrency(walletStats?.totalDebits || 0)}
                </p>
              </CardContent>
            </Card>
          </div>

          {statsError && (
            <Card className="border-red-200 bg-red-50/40 dark:border-red-800 dark:bg-red-900/10">
              <CardContent className="pt-6 text-sm text-red-700 dark:text-red-300">
                تعذر تحميل إحصائيات المحفظة: {getErrorMessage(statsErrorData, "حدث خطأ غير متوقع")}
              </CardContent>
            </Card>
          )}

          <CustomerPickerCard
            customerSearch={customerSearch}
            onSearchChange={setCustomerSearch}
            customersLoading={customersLoading}
            customerOptions={customerOptions}
            selectedCustomerId={selectedCustomerId}
            selectedCustomerName={selectedCustomerName}
            onSelectCustomer={handleSelectCustomer}
            onClearSelection={handleClearSelection}
          />

          <Card>
            <CardContent className="pt-6 space-y-4">
              <div className="flex items-center justify-between gap-3">
                <div>
                  <h3 className="font-semibold">تنفيذ عملية مالية</h3>
                  <p className="text-sm text-muted-foreground">
                    اختر العميل ثم نفذ العملية عبر معالج خطوة بخطوة.
                  </p>
                </div>
                <Coins className="h-5 w-5 text-muted-foreground" />
              </div>

              {!selectedCustomerId && (
                <p className="text-sm text-muted-foreground">
                  لا يمكن تنفيذ أي عملية قبل اختيار العميل.
                </p>
              )}

              <div className="flex flex-wrap gap-2">
                {canAddCredit && (
                  <Button
                    onClick={() => openOperationWizard("credit")}
                    disabled={!selectedCustomerId}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    إضافة رصيد
                  </Button>
                )}
                {canDeduct && (
                  <Button
                    onClick={() => openOperationWizard("debit")}
                    disabled={!selectedCustomerId}
                    variant="destructive"
                  >
                    خصم رصيد
                  </Button>
                )}
                {canAdjustPoints && (
                  <Button
                    onClick={() => openOperationWizard("points")}
                    disabled={!selectedCustomerId}
                    variant="outline"
                  >
                    منح نقاط
                  </Button>
                )}
              </div>

              {!canAddCredit && !canDeduct && !canAdjustPoints && (
                <p className="text-sm text-muted-foreground">
                  لا تملك صلاحيات تنفيذ عمليات مالية على المحفظة.
                </p>
              )}
            </CardContent>
          </Card>

          {selectedCustomerId && customerBalanceError && (
            <Card className="border-red-200 bg-red-50/40 dark:border-red-800 dark:bg-red-900/10">
              <CardContent className="pt-6 text-sm text-red-700 dark:text-red-300">
                تعذر تحميل بيانات العميل: {getErrorMessage(customerBalanceErrorData, "تأكد من اختيار عميل صحيح")}
              </CardContent>
            </Card>
          )}
        </TabsContent>

        <TabsContent value="audit" className="space-y-6">
          <Card>
            <CardContent className="pt-6 space-y-4">
              <div className="flex items-center gap-2">
                <Filter className="h-4 w-4 text-muted-foreground" />
                <h3 className="font-medium">فلاتر سجل المعاملات</h3>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-3">
                <div className="space-y-2">
                  <Label>نوع الحركة</Label>
                  <Select
                    value={auditDraftFilters.type}
                    onValueChange={(value) =>
                      setAuditDraftFilters((prev) => ({
                        ...prev,
                        type: value as AuditFilterState["type"],
                      }))
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="الكل" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="_all">الكل</SelectItem>
                      <SelectItem value="credit">إضافة</SelectItem>
                      <SelectItem value="debit">خصم</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label>تصنيف العملية</Label>
                  <Select
                    value={auditDraftFilters.transactionType}
                    onValueChange={(value) =>
                      setAuditDraftFilters((prev) => ({ ...prev, transactionType: value }))
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="الكل" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="_all">الكل</SelectItem>
                      <SelectItem value="admin_credit">admin_credit</SelectItem>
                      <SelectItem value="admin_debit">admin_debit</SelectItem>
                      <SelectItem value="order_payment">order_payment</SelectItem>
                      <SelectItem value="order_refund">order_refund</SelectItem>
                      <SelectItem value="wallet_topup">wallet_topup</SelectItem>
                      <SelectItem value="wallet_withdrawal">wallet_withdrawal</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label>بحث عام</Label>
                  <Input
                    placeholder="رقم عملية/عميل/وصف"
                    value={auditDraftFilters.search}
                    onChange={(e) =>
                      setAuditDraftFilters((prev) => ({ ...prev, search: e.target.value }))
                    }
                  />
                </div>

                <div className="space-y-2">
                  <Label>المرجع</Label>
                  <Input
                    placeholder="رقم المرجع"
                    value={auditDraftFilters.reference}
                    onChange={(e) =>
                      setAuditDraftFilters((prev) => ({ ...prev, reference: e.target.value }))
                    }
                  />
                </div>

                <div className="space-y-2">
                  <Label>من تاريخ</Label>
                  <Input
                    type="date"
                    value={auditDraftFilters.startDate}
                    onChange={(e) =>
                      setAuditDraftFilters((prev) => ({ ...prev, startDate: e.target.value }))
                    }
                  />
                </div>

                <div className="space-y-2">
                  <Label>إلى تاريخ</Label>
                  <Input
                    type="date"
                    value={auditDraftFilters.endDate}
                    onChange={(e) =>
                      setAuditDraftFilters((prev) => ({ ...prev, endDate: e.target.value }))
                    }
                  />
                </div>

                <div className="space-y-2">
                  <Label>نطاق العميل</Label>
                  <div className="flex items-center gap-2 h-10 rounded-md border px-3">
                    <input
                      type="checkbox"
                      checked={auditDraftFilters.onlySelectedCustomer}
                      disabled={!selectedCustomerId}
                      onChange={(e) =>
                        setAuditDraftFilters((prev) => ({
                          ...prev,
                          onlySelectedCustomer: e.target.checked,
                        }))
                      }
                    />
                    <span className="text-sm text-muted-foreground">
                      {selectedCustomerId
                        ? `العميل المحدد فقط (${selectedCustomerName || selectedCustomerId})`
                        : "اختر عميلًا أولاً لتفعيل هذا الخيار"}
                    </span>
                  </div>
                </div>
              </div>

              <div className="flex flex-wrap gap-2">
                <Button onClick={applyAuditFilters}>تطبيق الفلاتر</Button>
                <Button variant="outline" onClick={resetAuditFilters}>
                  إعادة ضبط
                </Button>
              </div>
            </CardContent>
          </Card>

          <WalletTransactionsCard
            title="سجل معاملات المحافظ"
            canViewTransactions={canViewTransactions}
            transactions={auditTransactions}
            loading={adminTransactionsLoading}
            errorMessage={
              adminTransactionsError
                ? `تعذر تحميل المعاملات العامة: ${getErrorMessage(adminTransactionsErrorData, "حدث خطأ غير متوقع")}`
                : undefined
            }
            showCustomer
            footer={
              canViewTransactions &&
              auditPagination && (
                <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                  <p className="text-xs text-muted-foreground">
                    صفحة {auditPagination.page} من {auditPagination.totalPages} - إجمالي السجلات: {auditPagination.total.toLocaleString()}
                  </p>
                  <div className="flex items-center gap-2">
                    <Select
                      value={String(auditLimit)}
                      onValueChange={(value) => {
                        setAuditLimit(Number(value));
                        setAuditPage(1);
                      }}
                    >
                      <SelectTrigger className="w-[120px]">
                        <SelectValue placeholder="الحجم" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="10">10 / صفحة</SelectItem>
                        <SelectItem value="20">20 / صفحة</SelectItem>
                        <SelectItem value="50">50 / صفحة</SelectItem>
                        <SelectItem value="100">100 / صفحة</SelectItem>
                      </SelectContent>
                    </Select>

                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setAuditPage((prev) => Math.max(1, prev - 1))}
                      disabled={!auditPagination.hasPreviousPage}
                    >
                      السابق
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setAuditPage((prev) => prev + 1)}
                      disabled={!auditPagination.hasNextPage}
                    >
                      التالي
                    </Button>
                  </div>
                </div>
              )
            }
          />

          {selectedCustomerId ? (
            <WalletTransactionsCard
              title="سجل معاملات العميل المحدد"
              canViewTransactions={canViewTransactions}
              transactions={transactions}
              loading={transactionsLoading}
              errorMessage={
                transactionsError
                  ? `تعذر تحميل معاملات العميل: ${getErrorMessage(transactionsErrorData, "حدث خطأ غير متوقع")}`
                  : undefined
              }
            />
          ) : (
            <Card>
              <CardContent className="pt-6 text-sm text-muted-foreground">
                اختر عميلًا من تبويب "العمليات" لعرض سجل معاملاته التفصيلي.
              </CardContent>
            </Card>
          )}
        </TabsContent>

        {canManageTiers && (
          <TabsContent value="tiers" className="space-y-6">
            <LoyaltyTiersPanel
              tiers={tiers}
              loading={tiersLoading}
              canManageTiers={canManageTiers}
              onCreateTier={handleCreateTier}
              onEditTier={handleEditTier}
              onDeleteTier={handleDeleteTier}
            />
          </TabsContent>
        )}
      </Tabs>

      <WalletOperationWizardDialog
        open={isOperationDialogOpen}
        onOpenChange={setIsOperationDialogOpen}
        selectedCustomerId={selectedCustomerId}
        selectedCustomerName={selectedCustomerName}
        walletBalance={customerBalance?.balance || 0}
        canAddCredit={canAddCredit}
        canDeduct={canDeduct}
        canAdjustPoints={canAdjustPoints}
        isSubmitting={isOperationSubmitting}
        defaultOperation={defaultOperationType}
        onSubmit={handleOperationSubmit}
      />

      <Dialog
        open={isCreateTierDialogOpen || isEditTierDialogOpen}
        onOpenChange={(open) => {
          if (!open) {
            setIsCreateTierDialogOpen(false);
            setIsEditTierDialogOpen(false);
            setSelectedTier(null);
            tierForm.reset();
          }
        }}
      >
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{selectedTier ? "تعديل مستوى الولاء" : "إضافة مستوى ولاء جديد"}</DialogTitle>
          </DialogHeader>
          <form onSubmit={tierForm.handleSubmit(onTierSubmit)} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (إنجليزي) *</Label>
                <Input {...tierForm.register("name", { required: true })} placeholder="Bronze" />
              </div>
              <div className="space-y-2">
                <Label>الاسم (عربي) *</Label>
                <Input {...tierForm.register("nameAr", { required: true })} placeholder="برونزي" />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الكود *</Label>
                <Input
                  {...tierForm.register("code", { required: true })}
                  placeholder="bronze-tier"
                  disabled={!!selectedTier}
                />
              </div>
              <div className="space-y-2">
                <Label>الحد الأدنى من النقاط *</Label>
                <Input
                  type="number"
                  {...tierForm.register("minPoints", {
                    required: true,
                    valueAsNumber: true,
                    min: 0,
                  })}
                  placeholder="0"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>مضاعف النقاط *</Label>
                <Input
                  type="number"
                  step="0.1"
                  {...tierForm.register("pointsMultiplier", {
                    required: true,
                    valueAsNumber: true,
                    min: 0.1,
                  })}
                  placeholder="1"
                />
              </div>
              <div className="space-y-2">
                <Label>نسبة الخصم (%)</Label>
                <Input
                  type="number"
                  {...tierForm.register("discountPercentage", {
                    valueAsNumber: true,
                    min: 0,
                    max: 100,
                  })}
                  placeholder="0"
                />
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>اللون (Hex)</Label>
                <Input {...tierForm.register("color")} placeholder="#CD7F32" />
              </div>
              <div className="space-y-2">
                <Label>ترتيب العرض</Label>
                <Input type="number" {...tierForm.register("displayOrder", { valueAsNumber: true })} placeholder="0" />
              </div>
            </div>

            <div className="space-y-2">
              <Label>الوصف (إنجليزي)</Label>
              <Textarea {...tierForm.register("description")} placeholder="Tier description..." />
            </div>
            <div className="space-y-2">
              <Label>الوصف (عربي)</Label>
              <Textarea {...tierForm.register("descriptionAr")} placeholder="وصف المستوى..." />
            </div>

            <div className="space-y-4">
              <Label className="text-base font-semibold">المزايا</Label>
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <Label htmlFor="freeShipping" className="cursor-pointer">
                    شحن مجاني
                  </Label>
                  <Switch
                    id="freeShipping"
                    checked={tierForm.watch("freeShipping")}
                    onCheckedChange={(checked) => tierForm.setValue("freeShipping", checked)}
                  />
                </div>
                <div className="flex items-center justify-between">
                  <Label htmlFor="prioritySupport" className="cursor-pointer">
                    دعم أولوية
                  </Label>
                  <Switch
                    id="prioritySupport"
                    checked={tierForm.watch("prioritySupport")}
                    onCheckedChange={(checked) => tierForm.setValue("prioritySupport", checked)}
                  />
                </div>
                <div className="flex items-center justify-between">
                  <Label htmlFor="earlyAccess" className="cursor-pointer">
                    وصول مبكر
                  </Label>
                  <Switch
                    id="earlyAccess"
                    checked={tierForm.watch("earlyAccess")}
                    onCheckedChange={(checked) => tierForm.setValue("earlyAccess", checked)}
                  />
                </div>
              </div>
            </div>

            <div className="flex items-center space-x-2 space-x-reverse">
              <Switch
                id="isActive"
                checked={tierForm.watch("isActive")}
                onCheckedChange={(checked) => tierForm.setValue("isActive", checked)}
              />
              <Label htmlFor="isActive" className="cursor-pointer">
                نشط
              </Label>
            </div>

            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  setIsCreateTierDialogOpen(false);
                  setIsEditTierDialogOpen(false);
                  setSelectedTier(null);
                  tierForm.reset();
                }}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={createTierMutation.isPending || updateTierMutation.isPending}
                className="bg-green-600 hover:bg-green-700"
              >
                {(createTierMutation.isPending || updateTierMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ms-2 animate-spin" />
                )}
                {selectedTier ? "تحديث" : "إنشاء"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      <Dialog open={isDeleteTierDialogOpen} onOpenChange={setIsDeleteTierDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>تأكيد الحذف</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <p className="text-sm text-muted-foreground">
              هل أنت متأكد من حذف المستوى <strong>{selectedTier?.name}</strong>؟
              <br />
              سيتم تعطيل المستوى بدلاً من حذفه نهائياً.
            </p>
          </div>
          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => {
                setIsDeleteTierDialogOpen(false);
                setSelectedTier(null);
              }}
            >
              إلغاء
            </Button>
            <Button
              type="button"
              variant="destructive"
              onClick={onDeleteTierConfirm}
              disabled={deleteTierMutation.isPending}
            >
              {deleteTierMutation.isPending && <Loader2 className="h-4 w-4 ms-2 animate-spin" />}
              حذف
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export default WalletPage;
