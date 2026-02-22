import { useState } from "react";
import { useTranslation } from "react-i18next";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { adminsApi, type UpdateAdminDto } from "@/api/admins.api";
import type { Admin } from "@/types";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
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
  Pencil,
  Trash2,
  Shield,
  Loader2,
  AlertCircle,
  Users,
} from "lucide-react";
import { getInitials, formatDate } from "@/lib/utils";

const createAdminSchema = z.object({
  phone: z.string().min(1, "رقم الهاتف مطلوب"),
  email: z
    .string()
    .email("البريد الإلكتروني غير صحيح")
    .optional()
    .or(z.literal("")),
  password: z.string().min(8, "كلمة المرور يجب أن تكون 8 أحرف على الأقل"),
  fullName: z.string().min(2, "الاسم يجب أن يكون على الأقل 2 أحرف"),
  fullNameAr: z.string().optional(),
  department: z.string().optional(),
  position: z.string().optional(),
  directPhone: z.string().optional(),
  extension: z.string().optional(),
  isSuperAdmin: z.boolean().optional(),
  canAccessMobile: z.boolean().optional(),
  canAccessWeb: z.boolean().optional(),
});

const updateAdminSchema = z.object({
  fullName: z.string().min(2, "الاسم يجب أن يكون على الأقل 2 أحرف"),
  fullNameAr: z.string().optional(),
  department: z.string().optional(),
  position: z.string().optional(),
  directPhone: z.string().optional(),
  extension: z.string().optional(),
  isSuperAdmin: z.boolean().optional(),
  canAccessMobile: z.boolean().optional(),
  canAccessWeb: z.boolean().optional(),
  employmentStatus: z
    .enum(["active", "on_leave", "suspended", "terminated"])
    .optional(),
});

type CreateFormData = z.infer<typeof createAdminSchema>;
type UpdateFormData = z.infer<typeof updateAdminSchema>;

const statusVariants: Record<string, "success" | "warning" | "danger"> = {
  active: "success",
  on_leave: "warning",
  suspended: "danger",
  terminated: "danger",
};

const statusLabels: Record<string, string> = {
  active: "نشط",
  on_leave: "في إجازة",
  suspended: "موقوف",
  terminated: "مفصول",
};

export function AdminsPage() {
  const { t, i18n } = useTranslation();
  const queryClient = useQueryClient();
  const [searchQuery, setSearchQuery] = useState("");
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [selectedAdmin, setSelectedAdmin] = useState<Admin | null>(null);
  const locale = i18n.language === "ar" ? "ar-SA" : "en-US";

  // Fetch admins
  const { data, isLoading, error } = useQuery({
    queryKey: ["admins", searchQuery],
    queryFn: () => adminsApi.getAll({ search: searchQuery, limit: 20 }),
  });

  // Create mutation
  const createMutation = useMutation({
    mutationFn: (data: any) => adminsApi.createWithUser(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admins"] });
      setIsCreateDialogOpen(false);
      createForm.reset();
    },
  });

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateAdminDto }) =>
      adminsApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admins"] });
      setIsEditDialogOpen(false);
      setSelectedAdmin(null);
    },
  });

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminsApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admins"] });
      setIsDeleteDialogOpen(false);
      setSelectedAdmin(null);
    },
  });

  // Create form
  const createForm = useForm<CreateFormData>({
    resolver: zodResolver(createAdminSchema),
    defaultValues: {
      phone: "",
      email: "",
      password: "",
      fullName: "",
      fullNameAr: "",
      department: "",
      position: "",
      directPhone: "",
      extension: "",
      isSuperAdmin: false,
      canAccessMobile: false,
      canAccessWeb: true,
    },
  });

  // Edit form
  const editForm = useForm<UpdateFormData>({
    resolver: zodResolver(updateAdminSchema),
  });

  const handleEdit = (admin: Admin) => {
    setSelectedAdmin(admin);
    editForm.reset({
      fullName: admin.fullName,
      fullNameAr: admin.fullNameAr || "",
      department: admin.department || "",
      position: admin.position || "",
      directPhone: admin.userId.phone || "",
      extension: "",
      isSuperAdmin: admin.isSuperAdmin,
      canAccessMobile: admin.canAccessMobile,
      canAccessWeb: admin.canAccessWeb,
      employmentStatus: admin.employmentStatus,
    });
    setIsEditDialogOpen(true);
  };

  const handleDelete = (admin: Admin) => {
    setSelectedAdmin(admin);
    setIsDeleteDialogOpen(true);
  };

  const onCreateSubmit = (data: CreateFormData) => {
    // Transform data to match API expectations
    const submitData = {
      ...data,
      email: data.email || undefined, // Convert empty string to undefined
    };
    createMutation.mutate(submitData);
  };

  const onEditSubmit = (data: UpdateFormData) => {
    if (selectedAdmin) {
      updateMutation.mutate({ id: selectedAdmin._id, data });
    }
  };

  const onDeleteConfirm = () => {
    if (selectedAdmin) {
      deleteMutation.mutate(selectedAdmin._id);
    }
  };

  // Mock admins data for display when API is not available
  const admins = data?.items || [];

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
            {t("admins.title")}
          </h1>
          <p className="text-gray-500 dark:text-gray-400 mt-1">
            إدارة المشرفين وصلاحياتهم
          </p>
        </div>
        <Button onClick={() => setIsCreateDialogOpen(true)}>
          <Plus className="h-4 w-4" />
          {t("admins.addAdmin")}
        </Button>
      </div>

      {/* Search and Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input
                placeholder="البحث عن مشرف..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="ps-10"
              />
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Table */}
      <Card>
        <CardHeader className="flex flex-row items-center gap-2 pb-4">
          <Users className="h-5 w-5 text-gray-500" />
          <CardTitle className="text-lg">قائمة المشرفين</CardTitle>
          {data && (
            <Badge variant="secondary" className="ms-auto">
              {data.pagination?.total || admins.length} مشرف
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
          ) : admins.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-500">
              <Users className="h-12 w-12 mb-4 text-gray-300" />
              <p>{t("common.noData")}</p>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>المشرف</TableHead>
                  <TableHead>البريد الإلكتروني</TableHead>
                  <TableHead>القسم</TableHead>
                  <TableHead>الحالة</TableHead>
                  <TableHead>تاريخ الإنشاء</TableHead>
                  <TableHead className="w-[50px]"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {admins.map((admin) => (
                  <TableRow key={admin._id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <Avatar>
                          <AvatarFallback>
                            {getInitials(admin.fullName)}
                          </AvatarFallback>
                        </Avatar>
                        <div>
                          <p className="font-medium text-gray-900 dark:text-gray-100">
                            {admin.fullName}
                          </p>
                          <p className="text-xs text-gray-500">
                            {admin.position}
                          </p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="text-gray-600">
                      {admin.userId.email}
                    </TableCell>
                    <TableCell className="text-gray-600">
                      {admin.department || "-"}
                    </TableCell>
                    <TableCell>
                      <Badge variant={statusVariants[admin.employmentStatus]}>
                        {statusLabels[admin.employmentStatus]}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-gray-500 text-sm">
                      {formatDate(admin.hireDate, locale)}
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem onClick={() => handleEdit(admin)}>
                            <Pencil className="h-4 w-4" />
                            تعديل
                          </DropdownMenuItem>
                          <DropdownMenuItem>
                            <Shield className="h-4 w-4" />
                            الصلاحيات
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            className="text-red-600"
                            onClick={() => handleDelete(admin)}
                          >
                            <Trash2 className="h-4 w-4" />
                            حذف
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

      {/* Create Dialog */}
      <Dialog open={isCreateDialogOpen} onOpenChange={setIsCreateDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t("admins.addAdmin")}</DialogTitle>
            <DialogDescription>أضف مشرف جديد للنظام</DialogDescription>
          </DialogHeader>
          <form
            onSubmit={createForm.handleSubmit(onCreateSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>رقم الهاتف *</Label>
                <Input
                  {...createForm.register("phone")}
                  placeholder="+966501234567"
                  error={!!createForm.formState.errors.phone}
                />
                {createForm.formState.errors.phone && (
                  <p className="text-red-500 text-xs">
                    {createForm.formState.errors.phone.message}
                  </p>
                )}
              </div>
              <div className="space-y-2">
                <Label>البريد الإلكتروني</Label>
                <Input
                  type="email"
                  {...createForm.register("email")}
                  placeholder="admin@example.com"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>كلمة المرور *</Label>
              <Input
                type="password"
                {...createForm.register("password")}
                error={!!createForm.formState.errors.password}
              />
              {createForm.formState.errors.password && (
                <p className="text-red-500 text-xs">
                  {createForm.formState.errors.password.message}
                </p>
              )}
              <p className="text-xs text-gray-500">
                كلمة المرور يجب أن تكون 8 أحرف على الأقل
              </p>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم الكامل *</Label>
                <Input
                  {...createForm.register("fullName")}
                  error={!!createForm.formState.errors.fullName}
                />
                {createForm.formState.errors.fullName && (
                  <p className="text-red-500 text-xs">
                    {createForm.formState.errors.fullName.message}
                  </p>
                )}
              </div>
              <div className="space-y-2">
                <Label>الاسم بالعربية</Label>
                <Input {...createForm.register("fullNameAr")} />
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>القسم</Label>
                <Input {...createForm.register("department")} />
              </div>
              <div className="space-y-2">
                <Label>المنصب</Label>
                <Input {...createForm.register("position")} />
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>رقم الهاتف المباشر</Label>
                <Input {...createForm.register("directPhone")} />
              </div>
              <div className="space-y-2">
                <Label>الإضافة</Label>
                <Input {...createForm.register("extension")} />
              </div>
            </div>
            <div className="space-y-3">
              <Label>الصلاحيات</Label>
              <div className="space-y-2">
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    {...createForm.register("isSuperAdmin")}
                  />
                  <Label className="text-sm">مدير عام</Label>
                </div>
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    {...createForm.register("canAccessMobile")}
                    defaultChecked={false}
                  />
                  <Label className="text-sm">يمكن الوصول للتطبيق المحمول</Label>
                </div>
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    {...createForm.register("canAccessWeb")}
                    defaultChecked={true}
                  />
                  <Label className="text-sm">يمكن الوصول للوحة التحكم</Label>
                </div>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsCreateDialogOpen(false)}
              >
                {t("common.cancel")}
              </Button>
              <Button type="submit" disabled={createMutation.isPending}>
                {createMutation.isPending && (
                  <Loader2 className="h-4 w-4 animate-spin" />
                )}
                {t("common.save")}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Edit Dialog */}
      <Dialog open={isEditDialogOpen} onOpenChange={setIsEditDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{t("admins.editAdmin")}</DialogTitle>
            <DialogDescription>تعديل بيانات المشرف</DialogDescription>
          </DialogHeader>
          <form
            onSubmit={editForm.handleSubmit(onEditSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم الكامل *</Label>
                <Input
                  {...editForm.register("fullName")}
                  error={!!editForm.formState.errors.fullName}
                />
                {editForm.formState.errors.fullName && (
                  <p className="text-red-500 text-xs">
                    {editForm.formState.errors.fullName.message}
                  </p>
                )}
              </div>
              <div className="space-y-2">
                <Label>الاسم بالعربية</Label>
                <Input {...editForm.register("fullNameAr")} />
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>القسم</Label>
                <Input {...editForm.register("department")} />
              </div>
              <div className="space-y-2">
                <Label>المنصب</Label>
                <Input {...editForm.register("position")} />
              </div>
            </div>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>رقم الهاتف المباشر</Label>
                <Input {...editForm.register("directPhone")} />
              </div>
              <div className="space-y-2">
                <Label>الإضافة</Label>
                <Input {...editForm.register("extension")} />
              </div>
            </div>
            <div className="space-y-2">
              <Label>{t("admins.status")}</Label>
              <select
                {...editForm.register("employmentStatus")}
                className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
              >
                <option value="active">نشط</option>
                <option value="on_leave">في إجازة</option>
                <option value="suspended">موقوف</option>
                <option value="terminated">مفصول</option>
              </select>
            </div>
            <div className="space-y-3">
              <Label>الصلاحيات</Label>
              <div className="space-y-2">
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    {...editForm.register("isSuperAdmin")}
                  />
                  <Label className="text-sm">مدير عام</Label>
                </div>
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    {...editForm.register("canAccessMobile")}
                  />
                  <Label className="text-sm">يمكن الوصول للتطبيق المحمول</Label>
                </div>
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    {...editForm.register("canAccessWeb")}
                  />
                  <Label className="text-sm">يمكن الوصول للوحة التحكم</Label>
                </div>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsEditDialogOpen(false)}
              >
                {t("common.cancel")}
              </Button>
              <Button type="submit" disabled={updateMutation.isPending}>
                {updateMutation.isPending && (
                  <Loader2 className="h-4 w-4 animate-spin" />
                )}
                {t("common.save")}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>تأكيد الحذف</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من حذف المشرف "{selectedAdmin?.fullName}"؟ هذا
              الإجراء لا يمكن التراجع عنه.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => setIsDeleteDialogOpen(false)}
            >
              {t("common.cancel")}
            </Button>
            <Button
              type="button"
              variant="destructive"
              onClick={onDeleteConfirm}
              disabled={deleteMutation.isPending}
            >
              {deleteMutation.isPending && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              {t("common.delete")}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
