import { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  customersApi,
  type City,
  type PriceLevel,
  type AvailableUser,
  type CreateCustomerDto,
} from "@/api/customers.api";
import type { Customer } from "@/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Plus,
  Search,
  MoreHorizontal,
  Eye,
  Edit,
  CheckCircle,
  XCircle,
  Loader2,
  AlertCircle,
  Building2,
  UserPlus,
  UserCog,
  Phone,
  Mail,
  MapPin,
  CreditCard,
  Wallet,
  Award,
  ShoppingBag,
  TrendingUp,
  FileText,
  Calendar,
  User,
} from "lucide-react";
import { formatDate } from "@/lib/utils";

// Simple toast helper (replace with actual toast library if available)
const toast = {
  success: (msg: string) => console.log("✅", msg),
  error: (msg: string) => console.error("❌", msg),
};

const statusVariants: Record<
  string,
  "success" | "warning" | "danger" | "default"
> = {
  approved: "success",
  pending: "warning",
  rejected: "danger",
  suspended: "danger",
};

const statusLabels: Record<string, string> = {
  approved: "معتمد",
  pending: "قيد الانتظار",
  rejected: "مرفوض",
  suspended: "موقوف",
};

type AddMode = "fromScratch" | "convertUser";

interface FormData {
  // User fields
  phone: string;
  email: string;
  password: string;
  userStatus: string;
  // Customer fields
  selectedUserId: string;
  responsiblePersonName: string;
  shopName: string;
  shopNameAr: string;
  businessType: string;
  cityId: string;
  priceLevelId: string;
  address: string;
  commercialLicenseNumber: string;
  taxNumber: string;
  nationalId: string;
  creditLimit: string;
  preferredPaymentMethod: string;
  preferredContactMethod: string;
  internalNotes: string;
  // Additional Customer fields
  walletBalance: string;
  loyaltyPoints: string;
  loyaltyTier: string;
  assignedSalesRepId: string;
  riskScore: string;
  isFlagged: boolean;
  flagReason: string;
}

const initialFormData: FormData = {
  phone: "",
  email: "",
  password: "",
  userStatus: "active",
  selectedUserId: "",
  responsiblePersonName: "",
  shopName: "",
  shopNameAr: "",
  businessType: "shop",
  cityId: "",
  priceLevelId: "",
  address: "",
  commercialLicenseNumber: "",
  taxNumber: "",
  nationalId: "",
  creditLimit: "",
  preferredPaymentMethod: "cod",
  preferredContactMethod: "whatsapp",
  internalNotes: "",
  walletBalance: "",
  loyaltyPoints: "",
  loyaltyTier: "bronze",
  assignedSalesRepId: "",
  riskScore: "50",
  isFlagged: false,
  flagReason: "",
};

export function CustomersPage() {
  const { t, i18n } = useTranslation();
  const queryClient = useQueryClient();
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("_all");
  const [selectedCustomer, setSelectedCustomer] = useState<Customer | null>(
    null
  );
  const [isDetailsDialogOpen, setIsDetailsDialogOpen] = useState(false);
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [editingCustomer, setEditingCustomer] = useState<Customer | null>(null);
  const [addMode, setAddMode] = useState<AddMode | null>(null);
  const [formData, setFormData] = useState<FormData>(initialFormData);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const locale = i18n.language === "ar" ? "ar-SA" : "en-US";

  // Fetch customers
  const { data, isLoading, error } = useQuery({
    queryKey: ["customers", searchQuery, statusFilter],
    queryFn: () =>
      customersApi.getAll({
        search: searchQuery,
        status: statusFilter === "_all" ? undefined : statusFilter,
        limit: 20,
      }),
  });

  // Fetch unlinked users (always)
  const { data: unlinkedUsers = [] } = useQuery<AvailableUser[]>({
    queryKey: ["unlinkedUsers"],
    queryFn: () => customersApi.getAvailableUsers(),
  });

  // Fetch lookup data for dialog
  const { data: cities = [] } = useQuery<City[]>({
    queryKey: ["cities"],
    queryFn: () => customersApi.getCities(),
    enabled: isAddDialogOpen || isEditDialogOpen,
  });

  const { data: priceLevels = [] } = useQuery<PriceLevel[]>({
    queryKey: ["priceLevels"],
    queryFn: () => customersApi.getPriceLevels(),
    enabled: isAddDialogOpen || isEditDialogOpen,
  });

  const { data: availableUsers = [] } = useQuery<AvailableUser[]>({
    queryKey: ["availableUsers"],
    queryFn: () => customersApi.getAvailableUsers(),
    enabled: isAddDialogOpen && addMode === "convertUser",
  });

  // Set default price level when loaded
  useEffect(() => {
    if (priceLevels.length > 0 && !formData.priceLevelId) {
      const defaultLevel =
        priceLevels.find((p) => p.isDefault) || priceLevels[0];
      if (defaultLevel) {
        setFormData((prev) => ({ ...prev, priceLevelId: defaultLevel._id }));
      }
    }
  }, [priceLevels, formData.priceLevelId]);

  // Approve mutation
  const approveMutation = useMutation({
    mutationFn: (id: string) => customersApi.approve(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers"] });
      toast.success("تمت الموافقة على العميل");
    },
  });

  // Reject mutation
  const rejectMutation = useMutation({
    mutationFn: (id: string) => customersApi.reject(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers"] });
      toast.success("تم رفض العميل");
    },
  });

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: any }) =>
      customersApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["customers"] });
      toast.success("تم تحديث العميل بنجاح");
      setIsEditDialogOpen(false);
      setEditingCustomer(null);
      setFormData(initialFormData);
    },
    onError: (error: any) => {
      toast.error(
        error.response?.data?.messageAr ||
          error.response?.data?.message ||
          "حدث خطأ أثناء تحديث العميل"
      );
    },
  });

  const handleViewDetails = async (customer: Customer) => {
    try {
      // Fetch full customer details from API
      const fullCustomer = await customersApi.getById(customer._id);
      setSelectedCustomer(fullCustomer);
      setIsDetailsDialogOpen(true);
    } catch (error) {
      console.error("Error fetching customer details:", error);
      // Fallback to basic customer data
      setSelectedCustomer(customer);
      setIsDetailsDialogOpen(true);
    }
  };

  const handleOpenAddDialog = () => {
    setFormData(initialFormData);
    setAddMode(null);
    setIsAddDialogOpen(true);
  };

  const handleCloseAddDialog = () => {
    setIsAddDialogOpen(false);
    setAddMode(null);
    setFormData(initialFormData);
  };

  const handleOpenEditDialog = async (customer: Customer) => {
    try {
      const fullCustomer = await customersApi.getById(customer._id);
      setEditingCustomer(fullCustomer);

      // ملء formData ببيانات العميل الحالية
      const customerData = fullCustomer as any;
      setFormData({
        phone: customerData.phone || "",
        email: customerData.email || "",
        password: "",
        userStatus: customerData.userId?.status || "active",
        selectedUserId: "",
        responsiblePersonName:
          customerData.contactName || customerData.responsiblePersonName || "",
        shopName: customerData.companyName || customerData.shopName || "",
        shopNameAr: customerData.shopNameAr || "",
        businessType: customerData.businessType || "shop",
        cityId:
          typeof customerData.cityId === "object"
            ? customerData.cityId._id
            : customerData.cityId || "",
        priceLevelId:
          typeof customerData.priceLevelId === "object"
            ? customerData.priceLevelId._id
            : customerData.priceLevelId || "",
        address: customerData.address || "",
        commercialLicenseNumber:
          customerData.commercialRegister ||
          customerData.commercialLicenseNumber ||
          "",
        taxNumber: customerData.taxNumber || "",
        nationalId: customerData.nationalId || "",
        creditLimit: customerData.creditLimit?.toString() || "",
        preferredPaymentMethod: customerData.preferredPaymentMethod || "cod",
        preferredContactMethod:
          customerData.preferredContactMethod || "whatsapp",
        internalNotes: customerData.internalNotes || "",
        walletBalance: customerData.walletBalance?.toString() || "",
        loyaltyPoints: customerData.loyaltyPoints?.toString() || "",
        loyaltyTier: customerData.loyaltyTier || "bronze",
        assignedSalesRepId:
          typeof customerData.assignedSalesRepId === "object"
            ? customerData.assignedSalesRepId._id
            : customerData.assignedSalesRepId || "",
        riskScore: customerData.riskScore?.toString() || "50",
        isFlagged: customerData.isFlagged || false,
        flagReason: customerData.flagReason || "",
      });
      setIsEditDialogOpen(true);
    } catch (error) {
      console.error("Error fetching customer details:", error);
      toast.error("فشل تحميل بيانات العميل");
    }
  };

  const handleCloseEditDialog = () => {
    setIsEditDialogOpen(false);
    setEditingCustomer(null);
    setFormData(initialFormData);
  };

  const handleFormChange = (field: keyof FormData, value: string | boolean) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async () => {
    if (!addMode) return;

    // Validation
    if (
      !formData.responsiblePersonName ||
      !formData.shopName ||
      !formData.cityId ||
      !formData.priceLevelId
    ) {
      toast.error("يرجى ملء جميع الحقول المطلوبة");
      return;
    }

    if (addMode === "fromScratch" && (!formData.phone || !formData.password)) {
      toast.error("يرجى إدخال رقم الهاتف وكلمة المرور");
      return;
    }

    if (addMode === "convertUser" && !formData.selectedUserId) {
      toast.error("يرجى اختيار مستخدم");
      return;
    }

    setIsSubmitting(true);
    try {
      let userId = formData.selectedUserId;

      // Step 1: Create user if from scratch
      if (addMode === "fromScratch") {
        const result = await customersApi.registerUser({
          phone: formData.phone,
          email: formData.email || undefined,
          password: formData.password,
          userType: "customer",
        });
        userId = result.user._id;
      }

      // Step 2: Create customer
      const customerData: CreateCustomerDto = {
        userId,
        responsiblePersonName: formData.responsiblePersonName,
        shopName: formData.shopName,
        shopNameAr: formData.shopNameAr || undefined,
        businessType:
          formData.businessType as CreateCustomerDto["businessType"],
        cityId: formData.cityId,
        priceLevelId: formData.priceLevelId,
        address: formData.address || undefined,
        commercialLicenseNumber: formData.commercialLicenseNumber || undefined,
        taxNumber: formData.taxNumber || undefined,
        nationalId: formData.nationalId || undefined,
        creditLimit: formData.creditLimit
          ? Number(formData.creditLimit)
          : undefined,
        preferredPaymentMethod:
          formData.preferredPaymentMethod as CreateCustomerDto["preferredPaymentMethod"],
        preferredContactMethod:
          formData.preferredContactMethod as CreateCustomerDto["preferredContactMethod"],
        internalNotes: formData.internalNotes || undefined,
      };

      await customersApi.create(customerData);

      toast.success("تم إضافة العميل بنجاح");
      queryClient.invalidateQueries({ queryKey: ["customers"] });
      queryClient.invalidateQueries({ queryKey: ["availableUsers"] });
      handleCloseAddDialog();
    } catch (error: any) {
      console.error("Error creating customer:", error);
      toast.error(
        error.response?.data?.messageAr ||
          error.response?.data?.message ||
          "حدث خطأ أثناء إضافة العميل"
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleUpdateSubmit = async () => {
    if (!editingCustomer) return;

    // Validation
    if (
      !formData.responsiblePersonName ||
      !formData.shopName ||
      !formData.cityId ||
      !formData.priceLevelId
    ) {
      toast.error("يرجى ملء جميع الحقول المطلوبة");
      return;
    }

    const updateData: any = {
      // User fields
      phone: formData.phone || undefined,
      email: formData.email || undefined,
      userStatus: formData.userStatus || undefined,
      // Customer fields
      responsiblePersonName: formData.responsiblePersonName,
      shopName: formData.shopName,
      shopNameAr: formData.shopNameAr || undefined,
      businessType: formData.businessType,
      cityId: formData.cityId,
      priceLevelId: formData.priceLevelId,
      address: formData.address || undefined,
      commercialLicenseNumber: formData.commercialLicenseNumber || undefined,
      taxNumber: formData.taxNumber || undefined,
      nationalId: formData.nationalId || undefined,
      creditLimit: formData.creditLimit
        ? Number(formData.creditLimit)
        : undefined,
      preferredPaymentMethod: formData.preferredPaymentMethod,
      preferredContactMethod: formData.preferredContactMethod,
      internalNotes: formData.internalNotes || undefined,
      // Additional Customer fields
      walletBalance: formData.walletBalance
        ? Number(formData.walletBalance)
        : undefined,
      loyaltyPoints: formData.loyaltyPoints
        ? Number(formData.loyaltyPoints)
        : undefined,
      loyaltyTier: formData.loyaltyTier || undefined,
      assignedSalesRepId: formData.assignedSalesRepId || undefined,
      riskScore: formData.riskScore ? Number(formData.riskScore) : undefined,
      isFlagged: formData.isFlagged,
      flagReason: formData.flagReason || undefined,
    };

    // Remove undefined and empty string values (but keep false for isFlagged)
    Object.keys(updateData).forEach((key) => {
      if (key === "isFlagged") {
        // Keep isFlagged even if false
        return;
      }
      if (updateData[key] === undefined || updateData[key] === "") {
        delete updateData[key];
      }
    });

    updateMutation.mutate({ id: editingCustomer._id, data: updateData });
  };

  const customers = data?.items || [];

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
            {t("customers.title")}
          </h1>
          <p className="text-gray-500 dark:text-gray-400 mt-1">
            إدارة العملاء وطلبات التسجيل
          </p>
        </div>
        <Button onClick={handleOpenAddDialog}>
          <Plus className="h-4 w-4" />
          {t("customers.addCustomer")}
        </Button>
      </div>

      {/* Unlinked Users Alert */}
      {unlinkedUsers.length > 0 && (
        <Card className="border-amber-200 bg-amber-50 dark:bg-amber-950 dark:border-amber-800">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-amber-100 dark:bg-amber-900 rounded-full">
                  <AlertCircle className="h-5 w-5 text-amber-600 dark:text-amber-400" />
                </div>
                <div>
                  <p className="font-medium text-amber-800 dark:text-amber-200">
                    يوجد {unlinkedUsers.length} مستخدم بدون ملف عميل
                  </p>
                  <p className="text-sm text-amber-600 dark:text-amber-400">
                    هؤلاء المستخدمون سجلوا كعملاء لكن لم يكملوا بياناتهم
                  </p>
                </div>
              </div>
              <Button
                variant="outline"
                className="border-amber-300 text-amber-700 hover:bg-amber-100 dark:border-amber-700 dark:text-amber-300"
                onClick={() => {
                  setAddMode("convertUser");
                  setIsAddDialogOpen(true);
                }}
              >
                <UserCog className="h-4 w-4" />
                تحويل إلى عملاء
              </Button>
            </div>
            {/* List of unlinked users */}
            <div className="mt-4 flex flex-wrap gap-2">
              {unlinkedUsers.slice(0, 5).map((user) => (
                <Badge
                  key={user._id}
                  variant="outline"
                  className="bg-white dark:bg-gray-800 text-amber-700 dark:text-amber-300"
                >
                  <Phone className="h-3 w-3 ml-1" />
                  {user.phone}
                </Badge>
              ))}
              {unlinkedUsers.length > 5 && (
                <Badge variant="secondary" className="text-amber-600">
                  +{unlinkedUsers.length - 5} آخرين
                </Badge>
              )}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Search and Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="flex flex-col sm:flex-row gap-3 sm:gap-4 items-stretch sm:items-center">
            <div className="relative flex-1 min-w-0">
              <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400 pointer-events-none" />
              <Input
                placeholder="البحث عن عميل..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="ps-12 pe-4 h-12 sm:h-14 text-base w-full"
              />
            </div>
            <Select
              value={statusFilter || undefined}
              onValueChange={setStatusFilter}
            >
              <SelectTrigger className="h-9 sm:h-9 w-full sm:w-auto sm:min-w-[130px] shrink-0 text-sm">
                <SelectValue placeholder="جميع الحالات" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="_all">جميع الحالات</SelectItem>
                <SelectItem value="pending">قيد الانتظار</SelectItem>
                <SelectItem value="approved">معتمد</SelectItem>
                <SelectItem value="rejected">مرفوض</SelectItem>
                <SelectItem value="suspended">موقوف</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardContent>
      </Card>

      {/* Table */}
      <Card>
        <CardHeader className="flex flex-row items-center gap-2 pb-4">
          <Building2 className="h-5 w-5 text-gray-500" />
          <CardTitle className="text-lg">قائمة العملاء</CardTitle>
          {data && (
            <Badge variant="secondary" className="ms-auto">
              {data.pagination?.total || customers.length} عميل
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
          ) : customers.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-500">
              <Building2 className="h-12 w-12 mb-4 text-gray-300" />
              <p>{t("common.noData")}</p>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>{t("customers.companyName")}</TableHead>
                  <TableHead>{t("customers.contactName")}</TableHead>
                  <TableHead>{t("customers.phone")}</TableHead>
                  <TableHead>{t("customers.status")}</TableHead>
                  <TableHead>تاريخ التسجيل</TableHead>
                  <TableHead className="w-[50px]"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {customers.map((customer) => (
                  <TableRow key={customer._id}>
                    <TableCell className="font-medium text-gray-900 dark:text-gray-100">
                      {customer.companyName}
                    </TableCell>
                    <TableCell className="text-gray-600">
                      {customer.contactName}
                    </TableCell>
                    <TableCell className="text-gray-600" dir="ltr">
                      {customer.phone}
                    </TableCell>
                    <TableCell>
                      <Badge variant={statusVariants[customer.status]}>
                        {statusLabels[customer.status]}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-gray-500 text-sm">
                      {formatDate(customer.createdAt, locale)}
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
                            onClick={() => handleViewDetails(customer)}
                          >
                            <Eye className="h-4 w-4" />
                            عرض التفاصيل
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => handleOpenEditDialog(customer)}
                          >
                            <Edit className="h-4 w-4" />
                            تعديل
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          {customer.status === "pending" && (
                            <>
                              <DropdownMenuSeparator />
                              <DropdownMenuItem
                                className="text-green-600"
                                onClick={() =>
                                  approveMutation.mutate(customer._id)
                                }
                              >
                                <CheckCircle className="h-4 w-4" />
                                قبول
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                className="text-red-600"
                                onClick={() =>
                                  rejectMutation.mutate(customer._id)
                                }
                              >
                                <XCircle className="h-4 w-4" />
                                رفض
                              </DropdownMenuItem>
                            </>
                          )}
                          {customer.status === "rejected" && (
                            <>
                              <DropdownMenuSeparator />
                              <DropdownMenuItem
                                className="text-green-600"
                                onClick={() =>
                                  approveMutation.mutate(customer._id)
                                }
                              >
                                <CheckCircle className="h-4 w-4" />
                                قبول
                              </DropdownMenuItem>
                            </>
                          )}
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

      {/* Customer Details Dialog */}
      <Dialog open={isDetailsDialogOpen} onOpenChange={setIsDetailsDialogOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-xl">
              <Building2 className="h-5 w-5" />
              {t("customers.customerDetails")}
            </DialogTitle>
            <DialogDescription>
              معلومات العميل الكاملة والتفصيلية
            </DialogDescription>
          </DialogHeader>
          {selectedCustomer && (
            <div className="space-y-6">
              {/* Status & Quick Info */}
              <div className="flex flex-wrap items-center gap-3 p-4 bg-gray-50 dark:bg-gray-900 rounded-lg">
                <Badge
                  variant={statusVariants[selectedCustomer.status]}
                  className="text-sm px-3 py-1"
                >
                  {statusLabels[selectedCustomer.status]}
                </Badge>
                {selectedCustomer.tier && (
                  <Badge variant="secondary" className="text-sm px-3 py-1">
                    <Award className="h-3 w-3 ml-1" />
                    {selectedCustomer.tier}
                  </Badge>
                )}
              </div>

              {/* Main Info Grid */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Basic Information */}
                <Card>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-base flex items-center gap-2">
                      <User className="h-4 w-4" />
                      المعلومات الأساسية
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-1">
                      <p className="text-xs text-gray-500 dark:text-gray-400">
                        اسم الشركة / المحل
                      </p>
                      <p className="font-medium text-sm">
                        {selectedCustomer.companyName}
                      </p>
                    </div>
                    <div className="space-y-1">
                      <p className="text-xs text-gray-500 dark:text-gray-400">
                        اسم المسؤول
                      </p>
                      <p className="font-medium text-sm">
                        {selectedCustomer.contactName}
                      </p>
                    </div>
                    {(selectedCustomer as any).businessType && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          نوع العمل
                        </p>
                        <Badge variant="outline" className="text-xs">
                          {(selectedCustomer as any).businessType === "shop"
                            ? "محل"
                            : (selectedCustomer as any).businessType ===
                              "technician"
                            ? "فني"
                            : (selectedCustomer as any).businessType ===
                              "distributor"
                            ? "موزع"
                            : "أخرى"}
                        </Badge>
                      </div>
                    )}
                  </CardContent>
                </Card>

                {/* Contact Information */}
                <Card>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-base flex items-center gap-2">
                      <Phone className="h-4 w-4" />
                      معلومات التواصل
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-1">
                      <p className="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1">
                        <Phone className="h-3 w-3" />
                        رقم الهاتف
                      </p>
                      <p className="font-medium text-sm" dir="ltr">
                        {selectedCustomer.phone}
                      </p>
                    </div>
                    {selectedCustomer.email && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1">
                          <Mail className="h-3 w-3" />
                          البريد الإلكتروني
                        </p>
                        <p className="font-medium text-sm" dir="ltr">
                          {selectedCustomer.email}
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).address && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1">
                          <MapPin className="h-3 w-3" />
                          العنوان
                        </p>
                        <p className="font-medium text-sm">
                          {(selectedCustomer as any).address}
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).cityId && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          المدينة
                        </p>
                        <p className="font-medium text-sm">
                          {typeof (selectedCustomer as any).cityId === "object"
                            ? (selectedCustomer as any).cityId.nameAr ||
                              (selectedCustomer as any).cityId.name
                            : "-"}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>

                {/* Financial Information */}
                <Card>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-base flex items-center gap-2">
                      <CreditCard className="h-4 w-4" />
                      المعلومات المالية
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {(selectedCustomer as any).creditLimit !== undefined && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          حد الائتمان
                        </p>
                        <p className="font-medium text-sm">
                          {(
                            (selectedCustomer as any).creditLimit || 0
                          ).toLocaleString()}{" "}
                          ريال
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).creditUsed !== undefined && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          الائتمان المستخدم
                        </p>
                        <p className="font-medium text-sm">
                          {(
                            (selectedCustomer as any).creditUsed || 0
                          ).toLocaleString()}{" "}
                          ريال
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).availableCredit !==
                      undefined && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          الائتمان المتاح
                        </p>
                        <p className="font-semibold text-sm text-green-600 dark:text-green-400">
                          {(
                            (selectedCustomer as any).availableCredit || 0
                          ).toLocaleString()}{" "}
                          ريال
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).walletBalance !== undefined && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1">
                          <Wallet className="h-3 w-3" />
                          رصيد المحفظة
                        </p>
                        <p className="font-medium text-sm">
                          {(
                            (selectedCustomer as any).walletBalance || 0
                          ).toLocaleString()}{" "}
                          ريال
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).priceLevelId && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          مستوى السعر
                        </p>
                        <p className="font-medium text-sm">
                          {typeof (selectedCustomer as any).priceLevelId ===
                          "object"
                            ? `${
                                (selectedCustomer as any).priceLevelId.nameAr ||
                                (selectedCustomer as any).priceLevelId.name
                              } (${
                                (selectedCustomer as any).priceLevelId
                                  .discount || 0
                              }%)`
                            : "-"}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>

                {/* Statistics & Loyalty */}
                <Card>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-base flex items-center gap-2">
                      <TrendingUp className="h-4 w-4" />
                      الإحصائيات والنقاط
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {(selectedCustomer as any).totalOrders !== undefined && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1">
                          <ShoppingBag className="h-3 w-3" />
                          إجمالي الطلبات
                        </p>
                        <p className="font-medium text-sm">
                          {(selectedCustomer as any).totalOrders || 0}
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).totalSpent !== undefined && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          إجمالي المشتريات
                        </p>
                        <p className="font-medium text-sm">
                          {(
                            (selectedCustomer as any).totalSpent || 0
                          ).toLocaleString()}{" "}
                          ريال
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).averageOrderValue !==
                      undefined && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          متوسط قيمة الطلب
                        </p>
                        <p className="font-medium text-sm">
                          {(
                            (selectedCustomer as any).averageOrderValue || 0
                          ).toLocaleString()}{" "}
                          ريال
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).loyaltyPoints !== undefined && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400 flex items-center gap-1">
                          <Award className="h-3 w-3" />
                          نقاط الولاء
                        </p>
                        <p className="font-medium text-sm">
                          {(selectedCustomer as any).loyaltyPoints || 0}
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).loyaltyTier && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          مستوى الولاء
                        </p>
                        <Badge variant="outline" className="text-xs">
                          {(selectedCustomer as any).loyaltyTier}
                        </Badge>
                      </div>
                    )}
                  </CardContent>
                </Card>

                {/* Documents */}
                {(selectedCustomer.commercialRegister ||
                  (selectedCustomer as any).taxNumber ||
                  (selectedCustomer as any).nationalId) && (
                  <Card>
                    <CardHeader className="pb-3">
                      <CardTitle className="text-base flex items-center gap-2">
                        <FileText className="h-4 w-4" />
                        الوثائق
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      {selectedCustomer.commercialRegister && (
                        <div className="space-y-1">
                          <p className="text-xs text-gray-500 dark:text-gray-400">
                            السجل التجاري
                          </p>
                          <p className="font-medium text-sm" dir="ltr">
                            {selectedCustomer.commercialRegister}
                          </p>
                        </div>
                      )}
                      {(selectedCustomer as any).taxNumber && (
                        <div className="space-y-1">
                          <p className="text-xs text-gray-500 dark:text-gray-400">
                            الرقم الضريبي
                          </p>
                          <p className="font-medium text-sm" dir="ltr">
                            {(selectedCustomer as any).taxNumber}
                          </p>
                        </div>
                      )}
                      {(selectedCustomer as any).nationalId && (
                        <div className="space-y-1">
                          <p className="text-xs text-gray-500 dark:text-gray-400">
                            رقم الهوية
                          </p>
                          <p className="font-medium text-sm" dir="ltr">
                            {(selectedCustomer as any).nationalId}
                          </p>
                        </div>
                      )}
                    </CardContent>
                  </Card>
                )}

                {/* Dates & Notes */}
                <Card>
                  <CardHeader className="pb-3">
                    <CardTitle className="text-base flex items-center gap-2">
                      <Calendar className="h-4 w-4" />
                      التواريخ والملاحظات
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="space-y-1">
                      <p className="text-xs text-gray-500 dark:text-gray-400">
                        تاريخ التسجيل
                      </p>
                      <p className="font-medium text-sm">
                        {formatDate(selectedCustomer.createdAt, locale)}
                      </p>
                    </div>
                    {selectedCustomer.updatedAt && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          آخر تحديث
                        </p>
                        <p className="font-medium text-sm">
                          {formatDate(selectedCustomer.updatedAt, locale)}
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).approvedAt && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          تاريخ الموافقة
                        </p>
                        <p className="font-medium text-sm">
                          {formatDate(
                            (selectedCustomer as any).approvedAt,
                            locale
                          )}
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).lastOrderAt && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          آخر طلب
                        </p>
                        <p className="font-medium text-sm">
                          {formatDate(
                            (selectedCustomer as any).lastOrderAt,
                            locale
                          )}
                        </p>
                      </div>
                    )}
                    {(selectedCustomer as any).internalNotes && (
                      <div className="space-y-1">
                        <p className="text-xs text-gray-500 dark:text-gray-400">
                          ملاحظات داخلية
                        </p>
                        <p className="font-medium text-sm text-gray-700 dark:text-gray-300">
                          {(selectedCustomer as any).internalNotes}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </div>
            </div>
          )}
          <DialogFooter className="gap-2">
            {selectedCustomer && selectedCustomer.status === "pending" && (
              <>
                <Button
                  variant="outline"
                  className="text-green-600 border-green-600 hover:bg-green-50"
                  onClick={() => {
                    if (selectedCustomer) {
                      approveMutation.mutate(selectedCustomer._id);
                      setIsDetailsDialogOpen(false);
                    }
                  }}
                  disabled={approveMutation.isPending}
                >
                  {approveMutation.isPending ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <CheckCircle className="h-4 w-4" />
                  )}
                  قبول
                </Button>
                <Button
                  variant="outline"
                  className="text-red-600 border-red-600 hover:bg-red-50"
                  onClick={() => {
                    if (selectedCustomer) {
                      rejectMutation.mutate(selectedCustomer._id);
                      setIsDetailsDialogOpen(false);
                    }
                  }}
                  disabled={rejectMutation.isPending}
                >
                  {rejectMutation.isPending ? (
                    <Loader2 className="h-4 w-4 animate-spin" />
                  ) : (
                    <XCircle className="h-4 w-4" />
                  )}
                  رفض
                </Button>
              </>
            )}
            {selectedCustomer && selectedCustomer.status === "rejected" && (
              <Button
                variant="outline"
                className="text-green-600 border-green-600 hover:bg-green-50"
                onClick={() => {
                  if (selectedCustomer) {
                    approveMutation.mutate(selectedCustomer._id);
                    setIsDetailsDialogOpen(false);
                  }
                }}
                disabled={approveMutation.isPending}
              >
                {approveMutation.isPending ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <CheckCircle className="h-4 w-4" />
                )}
                قبول
              </Button>
            )}
            <Button
              variant="outline"
              onClick={() => setIsDetailsDialogOpen(false)}
            >
              إغلاق
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Add Customer Dialog */}
      <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>إضافة عميل جديد</DialogTitle>
            <DialogDescription>
              {!addMode
                ? "اختر طريقة إضافة العميل"
                : addMode === "fromScratch"
                ? "إنشاء حساب ومحل جديد"
                : "تحويل مستخدم موجود إلى عميل"}
            </DialogDescription>
          </DialogHeader>

          {/* Mode Selection */}
          {!addMode && (
            <div className="grid grid-cols-2 gap-4 py-4">
              <button
                onClick={() => setAddMode("fromScratch")}
                className="flex flex-col items-center gap-3 p-6 rounded-xl border-2 border-dashed border-gray-300 hover:border-primary-500 hover:bg-primary-50 transition-all"
              >
                <UserPlus className="h-10 w-10 text-primary-600" />
                <div className="text-center">
                  <p className="font-semibold text-gray-900">إضافة من الصفر</p>
                  <p className="text-sm text-gray-500">
                    إنشاء حساب مستخدم ومحل جديد
                  </p>
                </div>
              </button>
              <button
                onClick={() => setAddMode("convertUser")}
                className="flex flex-col items-center gap-3 p-6 rounded-xl border-2 border-dashed border-gray-300 hover:border-primary-500 hover:bg-primary-50 transition-all"
              >
                <UserCog className="h-10 w-10 text-primary-600" />
                <div className="text-center">
                  <p className="font-semibold text-gray-900">تحويل مستخدم</p>
                  <p className="text-sm text-gray-500">
                    ربط مستخدم موجود بمحل جديد
                  </p>
                </div>
              </button>
            </div>
          )}

          {/* Form */}
          {addMode && (
            <div className="space-y-6 py-4">
              {/* User Section - Only for fromScratch */}
              {addMode === "fromScratch" && (
                <div className="space-y-4">
                  <h3 className="font-semibold text-gray-900 border-b pb-2">
                    بيانات الحساب
                  </h3>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <Label>
                        رقم الهاتف <span className="text-red-500">*</span>
                      </Label>
                      <Input
                        dir="ltr"
                        placeholder="+966501234567"
                        value={formData.phone}
                        onChange={(e) =>
                          handleFormChange("phone", e.target.value)
                        }
                      />
                    </div>
                    <div className="space-y-2">
                      <Label>
                        البريد الإلكتروني{" "}
                        <span className="text-gray-400 text-xs">(اختياري)</span>
                      </Label>
                      <Input
                        type="email"
                        dir="ltr"
                        placeholder="email@example.com"
                        value={formData.email}
                        onChange={(e) =>
                          handleFormChange("email", e.target.value)
                        }
                      />
                    </div>
                    <div className="space-y-2 md:col-span-2">
                      <Label>
                        كلمة المرور <span className="text-red-500">*</span>
                      </Label>
                      <Input
                        type="password"
                        dir="ltr"
                        placeholder="كلمة مرور قوية"
                        value={formData.password}
                        onChange={(e) =>
                          handleFormChange("password", e.target.value)
                        }
                      />
                      <p className="text-xs text-gray-500">
                        يجب أن تحتوي على حرف كبير، حرف صغير، رقم، ورمز خاص
                      </p>
                    </div>
                  </div>
                </div>
              )}

              {/* User Selection - Only for convertUser */}
              {addMode === "convertUser" && (
                <div className="space-y-4">
                  <h3 className="font-semibold text-gray-900 border-b pb-2">
                    اختيار المستخدم
                  </h3>
                  <div className="space-y-2">
                    <Label>
                      المستخدم <span className="text-red-500">*</span>
                    </Label>
                    <select
                      value={formData.selectedUserId}
                      onChange={(e) =>
                        handleFormChange("selectedUserId", e.target.value)
                      }
                      className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
                    >
                      <option value="">اختر مستخدم...</option>
                      {availableUsers.map((user) => (
                        <option key={user._id} value={user._id}>
                          {user.phone} {user.email ? `(${user.email})` : ""}
                        </option>
                      ))}
                    </select>
                    {availableUsers.length === 0 && (
                      <p className="text-sm text-amber-600">
                        لا يوجد مستخدمين متاحين للتحويل
                      </p>
                    )}
                  </div>
                </div>
              )}

              {/* Shop Info Section */}
              <div className="space-y-4">
                <h3 className="font-semibold text-gray-900 border-b pb-2">
                  بيانات المحل
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>
                      اسم المسؤول <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      placeholder="أحمد محمد"
                      value={formData.responsiblePersonName}
                      onChange={(e) =>
                        handleFormChange(
                          "responsiblePersonName",
                          e.target.value
                        )
                      }
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>
                      اسم المحل (إنجليزي){" "}
                      <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      dir="ltr"
                      placeholder="Mobile Shop"
                      value={formData.shopName}
                      onChange={(e) =>
                        handleFormChange("shopName", e.target.value)
                      }
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>
                      اسم المحل (عربي){" "}
                      <span className="text-gray-400 text-xs">(اختياري)</span>
                    </Label>
                    <Input
                      placeholder="محل الجوالات"
                      value={formData.shopNameAr}
                      onChange={(e) =>
                        handleFormChange("shopNameAr", e.target.value)
                      }
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>
                      نوع العمل{" "}
                      <span className="text-gray-400 text-xs">(اختياري)</span>
                    </Label>
                    <Select
                      value={formData.businessType}
                      onValueChange={(value) =>
                        handleFormChange("businessType", value)
                      }
                    >
                      <SelectTrigger className="w-full">
                        <SelectValue placeholder="اختر نوع العمل..." />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="shop">محل</SelectItem>
                        <SelectItem value="technician">فني</SelectItem>
                        <SelectItem value="distributor">موزع</SelectItem>
                        <SelectItem value="other">أخرى</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label>
                      المدينة <span className="text-red-500">*</span>
                    </Label>
                    <Select
                      value={formData.cityId || undefined}
                      onValueChange={(value) =>
                        handleFormChange("cityId", value)
                      }
                    >
                      <SelectTrigger className="w-full">
                        <SelectValue placeholder="اختر المدينة..." />
                      </SelectTrigger>
                      <SelectContent>
                        {cities.map((city) => (
                          <SelectItem key={city._id} value={city._id}>
                            {city.nameAr || city.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label>
                      مستوى السعر <span className="text-red-500">*</span>
                    </Label>
                    <Select
                      value={formData.priceLevelId || undefined}
                      onValueChange={(value) =>
                        handleFormChange("priceLevelId", value)
                      }
                    >
                      <SelectTrigger className="w-full">
                        <SelectValue placeholder="اختر مستوى السعر..." />
                      </SelectTrigger>
                      <SelectContent>
                        {priceLevels.map((level) => (
                          <SelectItem key={level._id} value={level._id}>
                            {level.nameAr || level.name} (
                            {level.discountPercentage}%)
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2 md:col-span-2">
                    <Label>
                      العنوان{" "}
                      <span className="text-gray-400 text-xs">(اختياري)</span>
                    </Label>
                    <Input
                      placeholder="الرياض، حي الملز، شارع الستين"
                      value={formData.address}
                      onChange={(e) =>
                        handleFormChange("address", e.target.value)
                      }
                    />
                  </div>
                </div>
              </div>

              {/* Documents Section */}
              <div className="space-y-4">
                <h3 className="font-semibold text-gray-900 border-b pb-2">
                  الوثائق{" "}
                  <span className="text-gray-400 text-xs font-normal">
                    (اختياري)
                  </span>
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label>رقم السجل التجاري</Label>
                    <Input
                      dir="ltr"
                      placeholder="1234567890"
                      value={formData.commercialLicenseNumber}
                      onChange={(e) =>
                        handleFormChange(
                          "commercialLicenseNumber",
                          e.target.value
                        )
                      }
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>الرقم الضريبي</Label>
                    <Input
                      dir="ltr"
                      placeholder="300000000000003"
                      value={formData.taxNumber}
                      onChange={(e) =>
                        handleFormChange("taxNumber", e.target.value)
                      }
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>رقم الهوية</Label>
                    <Input
                      dir="ltr"
                      placeholder="1234567890"
                      value={formData.nationalId}
                      onChange={(e) =>
                        handleFormChange("nationalId", e.target.value)
                      }
                    />
                  </div>
                </div>
              </div>

              {/* Preferences Section */}
              <div className="space-y-4">
                <h3 className="font-semibold text-gray-900 border-b pb-2">
                  التفضيلات{" "}
                  <span className="text-gray-400 text-xs font-normal">
                    (اختياري)
                  </span>
                </h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label>حد الائتمان</Label>
                    <Input
                      type="number"
                      dir="ltr"
                      placeholder="0"
                      value={formData.creditLimit}
                      onChange={(e) =>
                        handleFormChange("creditLimit", e.target.value)
                      }
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>طريقة الدفع المفضلة</Label>
                    <select
                      value={formData.preferredPaymentMethod}
                      onChange={(e) =>
                        handleFormChange(
                          "preferredPaymentMethod",
                          e.target.value
                        )
                      }
                      className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
                    >
                      <option value="cod">الدفع عند الاستلام</option>
                      <option value="bank_transfer">تحويل بنكي</option>
                      <option value="wallet">المحفظة</option>
                    </select>
                  </div>
                  <div className="space-y-2">
                    <Label>طريقة التواصل المفضلة</Label>
                    <select
                      value={formData.preferredContactMethod}
                      onChange={(e) =>
                        handleFormChange(
                          "preferredContactMethod",
                          e.target.value
                        )
                      }
                      className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
                    >
                      <option value="whatsapp">واتساب</option>
                      <option value="phone">هاتف</option>
                      <option value="email">بريد إلكتروني</option>
                    </select>
                  </div>
                </div>
              </div>

              {/* Internal Notes */}
              <div className="space-y-2">
                <Label>
                  ملاحظات داخلية{" "}
                  <span className="text-gray-400 text-xs">(اختياري)</span>
                </Label>
                <textarea
                  placeholder="ملاحظات للإدارة فقط..."
                  value={formData.internalNotes}
                  onChange={(e) =>
                    handleFormChange("internalNotes", e.target.value)
                  }
                  className="w-full min-h-[80px] rounded-lg border border-gray-300 px-3 py-2 text-sm resize-none"
                />
              </div>
            </div>
          )}

          <DialogFooter className="gap-2">
            {addMode && (
              <Button variant="ghost" onClick={() => setAddMode(null)}>
                رجوع
              </Button>
            )}
            <Button variant="outline" onClick={handleCloseAddDialog}>
              إلغاء
            </Button>
            {addMode && (
              <Button onClick={handleSubmit} disabled={isSubmitting}>
                {isSubmitting && <Loader2 className="h-4 w-4 animate-spin" />}
                إضافة العميل
              </Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit Customer Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent className="max-w-3xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>تعديل بيانات العميل</DialogTitle>
            <DialogDescription>
              تعديل معلومات العميل:{" "}
              {editingCustomer?.companyName || editingCustomer?.contactName}
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-6 py-4">
            {/* User Information Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 border-b pb-2">
                بيانات المستخدم
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <Label>رقم الهاتف</Label>
                  <Input
                    dir="ltr"
                    placeholder="+966501234567"
                    value={formData.phone}
                    onChange={(e) => handleFormChange("phone", e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label>البريد الإلكتروني</Label>
                  <Input
                    type="email"
                    dir="ltr"
                    placeholder="email@example.com"
                    value={formData.email}
                    onChange={(e) => handleFormChange("email", e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label>حالة المستخدم</Label>
                  <Select
                    value={formData.userStatus}
                    onValueChange={(value) =>
                      handleFormChange("userStatus", value)
                    }
                  >
                    <SelectTrigger className="w-full">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="pending">قيد الانتظار</SelectItem>
                      <SelectItem value="active">نشط</SelectItem>
                      <SelectItem value="suspended">موقوف</SelectItem>
                      <SelectItem value="deleted">محذوف</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </div>

            {/* Shop Info Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 border-b pb-2">
                بيانات المحل
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>
                    اسم المسؤول <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    placeholder="أحمد محمد"
                    value={formData.responsiblePersonName}
                    onChange={(e) =>
                      handleFormChange("responsiblePersonName", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>
                    اسم المحل (إنجليزي) <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    dir="ltr"
                    placeholder="Mobile Shop"
                    value={formData.shopName}
                    onChange={(e) =>
                      handleFormChange("shopName", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>اسم المحل (عربي)</Label>
                  <Input
                    placeholder="محل الجوالات"
                    value={formData.shopNameAr}
                    onChange={(e) =>
                      handleFormChange("shopNameAr", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>نوع العمل</Label>
                  <Select
                    value={formData.businessType}
                    onValueChange={(value) =>
                      handleFormChange("businessType", value)
                    }
                  >
                    <SelectTrigger className="w-full">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="shop">محل</SelectItem>
                      <SelectItem value="technician">فني</SelectItem>
                      <SelectItem value="distributor">موزع</SelectItem>
                      <SelectItem value="other">أخرى</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>
                    المدينة <span className="text-red-500">*</span>
                  </Label>
                  <Select
                    value={formData.cityId || undefined}
                    onValueChange={(value) => handleFormChange("cityId", value)}
                  >
                    <SelectTrigger className="w-full">
                      <SelectValue placeholder="اختر المدينة..." />
                    </SelectTrigger>
                    <SelectContent>
                      {cities.map((city) => (
                        <SelectItem key={city._id} value={city._id}>
                          {city.nameAr || city.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>
                    مستوى السعر <span className="text-red-500">*</span>
                  </Label>
                  <Select
                    value={formData.priceLevelId || undefined}
                    onValueChange={(value) =>
                      handleFormChange("priceLevelId", value)
                    }
                  >
                    <SelectTrigger className="w-full">
                      <SelectValue placeholder="اختر مستوى السعر..." />
                    </SelectTrigger>
                    <SelectContent>
                      {priceLevels.map((level) => (
                        <SelectItem key={level._id} value={level._id}>
                          {level.nameAr || level.name} (
                          {level.discountPercentage}%)
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2 md:col-span-2">
                  <Label>العنوان</Label>
                  <Input
                    placeholder="الرياض، حي الملز، شارع الستين"
                    value={formData.address}
                    onChange={(e) =>
                      handleFormChange("address", e.target.value)
                    }
                  />
                </div>
              </div>
            </div>

            {/* Financial & Loyalty Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 border-b pb-2">
                المالية والولاء
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div className="space-y-2">
                  <Label>حد الائتمان</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="0"
                    value={formData.creditLimit}
                    onChange={(e) =>
                      handleFormChange("creditLimit", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>رصيد المحفظة</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="0"
                    value={formData.walletBalance}
                    onChange={(e) =>
                      handleFormChange("walletBalance", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>نقاط الولاء</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="0"
                    value={formData.loyaltyPoints}
                    onChange={(e) =>
                      handleFormChange("loyaltyPoints", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>مستوى الولاء</Label>
                  <Select
                    value={formData.loyaltyTier}
                    onValueChange={(value) =>
                      handleFormChange("loyaltyTier", value)
                    }
                  >
                    <SelectTrigger className="w-full">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="bronze">برونزي</SelectItem>
                      <SelectItem value="silver">فضي</SelectItem>
                      <SelectItem value="gold">ذهبي</SelectItem>
                      <SelectItem value="platinum">بلاتيني</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </div>

            {/* Documents Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 border-b pb-2">
                الوثائق
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <Label>رقم السجل التجاري</Label>
                  <Input
                    dir="ltr"
                    placeholder="1234567890"
                    value={formData.commercialLicenseNumber}
                    onChange={(e) =>
                      handleFormChange(
                        "commercialLicenseNumber",
                        e.target.value
                      )
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>الرقم الضريبي</Label>
                  <Input
                    dir="ltr"
                    placeholder="300000000000003"
                    value={formData.taxNumber}
                    onChange={(e) =>
                      handleFormChange("taxNumber", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>رقم الهوية</Label>
                  <Input
                    dir="ltr"
                    placeholder="1234567890"
                    value={formData.nationalId}
                    onChange={(e) =>
                      handleFormChange("nationalId", e.target.value)
                    }
                  />
                </div>
              </div>
            </div>

            {/* Preferences Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 border-b pb-2">
                التفضيلات
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>طريقة الدفع المفضلة</Label>
                  <select
                    value={formData.preferredPaymentMethod}
                    onChange={(e) =>
                      handleFormChange("preferredPaymentMethod", e.target.value)
                    }
                    className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
                  >
                    <option value="cod">الدفع عند الاستلام</option>
                    <option value="bank_transfer">تحويل بنكي</option>
                    <option value="wallet">المحفظة</option>
                  </select>
                </div>
                <div className="space-y-2">
                  <Label>طريقة التواصل المفضلة</Label>
                  <select
                    value={formData.preferredContactMethod}
                    onChange={(e) =>
                      handleFormChange("preferredContactMethod", e.target.value)
                    }
                    className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
                  >
                    <option value="whatsapp">واتساب</option>
                    <option value="phone">هاتف</option>
                    <option value="email">بريد إلكتروني</option>
                  </select>
                </div>
              </div>
            </div>

            {/* Risk & Flags Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 border-b pb-2">
                التقييم والتحذيرات
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <Label>درجة المخاطرة (0-100)</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    min="0"
                    max="100"
                    placeholder="50"
                    value={formData.riskScore}
                    onChange={(e) =>
                      handleFormChange("riskScore", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2 flex items-end">
                  <div className="flex items-center space-x-2 space-x-reverse">
                    <input
                      type="checkbox"
                      id="isFlagged"
                      checked={formData.isFlagged}
                      onChange={(e) =>
                        handleFormChange("isFlagged", e.target.checked)
                      }
                      className="h-4 w-4 rounded border-gray-300"
                    />
                    <Label htmlFor="isFlagged" className="cursor-pointer">
                      معلّم كتحذير
                    </Label>
                  </div>
                </div>
                {formData.isFlagged && (
                  <div className="space-y-2 md:col-span-3">
                    <Label>سبب التحذير</Label>
                    <Input
                      placeholder="سبب وضع علامة التحذير..."
                      value={formData.flagReason}
                      onChange={(e) =>
                        handleFormChange("flagReason", e.target.value)
                      }
                    />
                  </div>
                )}
              </div>
            </div>

            {/* Internal Notes */}
            <div className="space-y-2">
              <Label>ملاحظات داخلية</Label>
              <textarea
                placeholder="ملاحظات للإدارة فقط..."
                value={formData.internalNotes}
                onChange={(e) =>
                  handleFormChange("internalNotes", e.target.value)
                }
                className="w-full min-h-[80px] rounded-lg border border-gray-300 px-3 py-2 text-sm resize-none"
              />
            </div>
          </div>

          <DialogFooter className="gap-2">
            <Button variant="outline" onClick={handleCloseEditDialog}>
              إلغاء
            </Button>
            <Button
              onClick={handleUpdateSubmit}
              disabled={updateMutation.isPending}
            >
              {updateMutation.isPending && (
                <Loader2 className="h-4 w-4 animate-spin ml-2" />
              )}
              حفظ التعديلات
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
