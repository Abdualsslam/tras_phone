import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  catalogApi,
  type BrandWithDevices,
  type Device,
  type QualityType,
} from "@/api/catalog.api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
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
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Plus,
  Search,
  MoreHorizontal,
  Pencil,
  Trash2,
  Loader2,
  Star,
  Smartphone,
  Tag,
  Building2,
  CheckCircle,
  XCircle,
} from "lucide-react";
import { Switch } from "@/components/ui/switch";

// ══════════════════════════════════════════════════════════════
// Brands Tab Component
// ══════════════════════════════════════════════════════════════

function BrandsTab() {
  const queryClient = useQueryClient();
  const [searchQuery, setSearchQuery] = useState("");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingBrand, setEditingBrand] = useState<BrandWithDevices | null>(
    null
  );
  const [formData, setFormData] = useState({
    name: "",
    nameAr: "",
    slug: "",
    logo: "",
    isFeatured: false,
    isActive: true,
  });

  const { data: brands, isLoading } = useQuery({
    queryKey: ["brands"],
    queryFn: () => catalogApi.getBrands(),
  });

  const createMutation = useMutation({
    mutationFn: catalogApi.createBrand,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["brands"] });
      handleCloseDialog();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: Partial<{
        name: string;
        nameAr?: string;
        slug?: string;
        logo?: string;
        isFeatured?: boolean;
        isActive?: boolean;
      }>;
    }) => catalogApi.updateBrand(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["brands"] });
      handleCloseDialog();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: catalogApi.deleteBrand,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["brands"] });
    },
  });

  const handleOpenCreate = () => {
    setEditingBrand(null);
    setFormData({
      name: "",
      nameAr: "",
      slug: "",
      logo: "",
      isFeatured: false,
      isActive: true,
    });
    setIsDialogOpen(true);
  };

  const handleOpenEdit = (brand: BrandWithDevices) => {
    setEditingBrand(brand);
    setFormData({
      name: brand.name,
      nameAr: brand.nameAr || "",
      slug: brand.slug,
      logo: brand.logo || "",
      isFeatured: brand.isFeatured || false,
      isActive: brand.isActive,
    });
    setIsDialogOpen(true);
  };

  const handleCloseDialog = () => {
    setIsDialogOpen(false);
    setEditingBrand(null);
  };

  const handleSubmit = () => {
    if (!formData.name) return;

    if (editingBrand) {
      updateMutation.mutate({ id: editingBrand._id, data: formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const filteredBrands = (brands || []).filter(
    (b) =>
      b.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      b.nameAr?.includes(searchQuery)
  );

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-4">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
          <Input
            placeholder="البحث عن علامة تجارية..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="ps-10"
          />
        </div>
        <Button onClick={handleOpenCreate}>
          <Plus className="h-4 w-4" />
          إضافة علامة تجارية
        </Button>
      </div>

      <Card>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>العلامة التجارية</TableHead>
                  <TableHead>الرابط</TableHead>
                  <TableHead>الأجهزة</TableHead>
                  <TableHead>المنتجات</TableHead>
                  <TableHead>مميزة</TableHead>
                  <TableHead>الحالة</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredBrands.map((brand) => (
                  <TableRow key={brand._id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gray-100 dark:bg-slate-800 rounded-lg flex items-center justify-center overflow-hidden">
                          {brand.logo ? (
                            <img
                              src={brand.logo}
                              alt={brand.name}
                              className="w-full h-full object-contain p-1"
                            />
                          ) : (
                            <Building2 className="h-5 w-5 text-gray-400" />
                          )}
                        </div>
                        <div>
                          <p className="font-medium">
                            {brand.nameAr || brand.name}
                          </p>
                          <p className="text-xs text-gray-500">{brand.name}</p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="text-gray-500 font-mono text-sm">
                      {brand.slug}
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary">
                        {brand.devicesCount || 0}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary">
                        {brand.productsCount || 0}
                      </Badge>
                    </TableCell>
                    <TableCell>
                      {brand.isFeatured ? (
                        <Star className="h-4 w-4 text-yellow-500 fill-yellow-500" />
                      ) : (
                        <Star className="h-4 w-4 text-gray-300" />
                      )}
                    </TableCell>
                    <TableCell>
                      <Badge variant={brand.isActive ? "success" : "default"}>
                        {brand.isActive ? "نشط" : "غير نشط"}
                      </Badge>
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
                            onClick={() => handleOpenEdit(brand)}
                          >
                            <Pencil className="h-4 w-4" />
                            تعديل
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            className="text-red-600"
                            onClick={() => deleteMutation.mutate(brand._id)}
                          >
                            <Trash2 className="h-4 w-4" />
                            حذف
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
                {filteredBrands.length === 0 && (
                  <TableRow>
                    <TableCell
                      colSpan={7}
                      className="text-center py-8 text-gray-500"
                    >
                      لا توجد علامات تجارية
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Brand Dialog */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>
              {editingBrand ? "تعديل العلامة التجارية" : "إضافة علامة تجارية"}
            </DialogTitle>
            <DialogDescription>أدخل بيانات العلامة التجارية</DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>
                الاسم بالإنجليزية <span className="text-red-500">*</span>
              </Label>
              <Input
                dir="ltr"
                placeholder="Brand Name"
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>الاسم بالعربية</Label>
              <Input
                placeholder="اسم العلامة"
                value={formData.nameAr}
                onChange={(e) =>
                  setFormData({ ...formData, nameAr: e.target.value })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>الرابط (Slug)</Label>
              <Input
                dir="ltr"
                placeholder="brand-slug"
                value={formData.slug}
                onChange={(e) =>
                  setFormData({ ...formData, slug: e.target.value })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>رابط الشعار</Label>
              <Input
                dir="ltr"
                placeholder="https://..."
                value={formData.logo}
                onChange={(e) =>
                  setFormData({ ...formData, logo: e.target.value })
                }
              />
            </div>

            <div className="flex items-center justify-between">
              <Label>علامة مميزة</Label>
              <Switch
                checked={formData.isFeatured}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, isFeatured: checked })
                }
              />
            </div>

            <div className="flex items-center justify-between">
              <Label>نشط</Label>
              <Switch
                checked={formData.isActive}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, isActive: checked })
                }
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={handleCloseDialog}>
              إلغاء
            </Button>
            <Button
              onClick={handleSubmit}
              disabled={
                !formData.name ||
                createMutation.isPending ||
                updateMutation.isPending
              }
            >
              {(createMutation.isPending || updateMutation.isPending) && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              {editingBrand ? "حفظ التعديلات" : "إضافة"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// Devices Tab Component
// ══════════════════════════════════════════════════════════════

function DevicesTab() {
  const queryClient = useQueryClient();
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedBrandId, setSelectedBrandId] = useState<string>("");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingDevice, setEditingDevice] = useState<Device | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    nameAr: "",
    slug: "",
    brandId: "",
    image: "",
    releaseYear: new Date().getFullYear(),
    isPopular: false,
    isActive: true,
  });

  const { data: brands } = useQuery({
    queryKey: ["brands"],
    queryFn: () => catalogApi.getBrands(),
  });

  const { data: devices, isLoading } = useQuery({
    queryKey: ["devices", selectedBrandId],
    queryFn: () =>
      selectedBrandId
        ? catalogApi.getDevicesByBrand(selectedBrandId)
        : catalogApi.getDevices({ limit: 100 }),
  });

  const createMutation = useMutation({
    mutationFn: catalogApi.createDevice,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["devices"] });
      handleCloseDialog();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: Partial<{
        name: string;
        nameAr?: string;
        slug?: string;
        brandId: string;
        image?: string;
        releaseYear?: number;
        isPopular?: boolean;
        isActive?: boolean;
      }>;
    }) => catalogApi.updateDevice(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["devices"] });
      handleCloseDialog();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: catalogApi.deleteDevice,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["devices"] });
    },
  });

  const handleOpenCreate = () => {
    setEditingDevice(null);
    setFormData({
      name: "",
      nameAr: "",
      slug: "",
      brandId: selectedBrandId || "",
      image: "",
      releaseYear: new Date().getFullYear(),
      isPopular: false,
      isActive: true,
    });
    setIsDialogOpen(true);
  };

  const handleOpenEdit = (device: Device) => {
    setEditingDevice(device);
    setFormData({
      name: device.name,
      nameAr: device.nameAr || "",
      slug: device.slug,
      brandId: device.brandId,
      image: device.image || "",
      releaseYear: device.releaseYear || new Date().getFullYear(),
      isPopular: device.isPopular,
      isActive: device.isActive,
    });
    setIsDialogOpen(true);
  };

  const handleCloseDialog = () => {
    setIsDialogOpen(false);
    setEditingDevice(null);
  };

  const handleSubmit = () => {
    if (!formData.name || !formData.brandId) return;

    if (editingDevice) {
      updateMutation.mutate({ id: editingDevice._id, data: formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  const filteredDevices = (devices || []).filter(
    (d) =>
      d.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      d.nameAr?.includes(searchQuery)
  );

  return (
    <div className="space-y-4">
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div className="flex flex-1 items-center gap-4 w-full sm:w-auto">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
            <Input
              placeholder="البحث عن جهاز..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="ps-10"
            />
          </div>
          <select
            value={selectedBrandId}
            onChange={(e) => setSelectedBrandId(e.target.value)}
            className="h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm min-w-[150px]"
          >
            <option value="">كل العلامات</option>
            {brands?.map((brand) => (
              <option key={brand._id} value={brand._id}>
                {brand.nameAr || brand.name}
              </option>
            ))}
          </select>
        </div>
        <Button onClick={handleOpenCreate}>
          <Plus className="h-4 w-4" />
          إضافة جهاز
        </Button>
      </div>

      <Card>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>الجهاز</TableHead>
                  <TableHead>العلامة التجارية</TableHead>
                  <TableHead>سنة الإصدار</TableHead>
                  <TableHead>شائع</TableHead>
                  <TableHead>الحالة</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredDevices.map((device) => (
                  <TableRow key={device._id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gray-100 dark:bg-slate-800 rounded-lg flex items-center justify-center overflow-hidden">
                          {device.image ? (
                            <img
                              src={device.image}
                              alt={device.name}
                              className="w-full h-full object-contain p-1"
                            />
                          ) : (
                            <Smartphone className="h-5 w-5 text-gray-400" />
                          )}
                        </div>
                        <div>
                          <p className="font-medium">
                            {device.nameAr || device.name}
                          </p>
                          <p className="text-xs text-gray-500">{device.name}</p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">
                        {device.brand?.name || "-"}
                      </Badge>
                    </TableCell>
                    <TableCell>{device.releaseYear || "-"}</TableCell>
                    <TableCell>
                      {device.isPopular ? (
                        <CheckCircle className="h-4 w-4 text-green-500" />
                      ) : (
                        <XCircle className="h-4 w-4 text-gray-300" />
                      )}
                    </TableCell>
                    <TableCell>
                      <Badge variant={device.isActive ? "success" : "default"}>
                        {device.isActive ? "نشط" : "غير نشط"}
                      </Badge>
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
                            onClick={() => handleOpenEdit(device)}
                          >
                            <Pencil className="h-4 w-4" />
                            تعديل
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            className="text-red-600"
                            onClick={() => deleteMutation.mutate(device._id)}
                          >
                            <Trash2 className="h-4 w-4" />
                            حذف
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
                {filteredDevices.length === 0 && (
                  <TableRow>
                    <TableCell
                      colSpan={6}
                      className="text-center py-8 text-gray-500"
                    >
                      لا توجد أجهزة
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Device Dialog */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>
              {editingDevice ? "تعديل الجهاز" : "إضافة جهاز"}
            </DialogTitle>
            <DialogDescription>أدخل بيانات الجهاز</DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>
                العلامة التجارية <span className="text-red-500">*</span>
              </Label>
              <select
                value={formData.brandId}
                onChange={(e) =>
                  setFormData({ ...formData, brandId: e.target.value })
                }
                className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 px-3 text-sm"
              >
                <option value="">اختر العلامة</option>
                {brands?.map((brand) => (
                  <option key={brand._id} value={brand._id}>
                    {brand.nameAr || brand.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="space-y-2">
              <Label>
                الاسم بالإنجليزية <span className="text-red-500">*</span>
              </Label>
              <Input
                dir="ltr"
                placeholder="iPhone 15 Pro"
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>الاسم بالعربية</Label>
              <Input
                placeholder="آيفون 15 برو"
                value={formData.nameAr}
                onChange={(e) =>
                  setFormData({ ...formData, nameAr: e.target.value })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>الرابط (Slug)</Label>
              <Input
                dir="ltr"
                placeholder="iphone-15-pro"
                value={formData.slug}
                onChange={(e) =>
                  setFormData({ ...formData, slug: e.target.value })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>سنة الإصدار</Label>
              <Input
                type="number"
                min="2000"
                max="2030"
                value={formData.releaseYear}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    releaseYear: parseInt(e.target.value),
                  })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>رابط الصورة</Label>
              <Input
                dir="ltr"
                placeholder="https://..."
                value={formData.image}
                onChange={(e) =>
                  setFormData({ ...formData, image: e.target.value })
                }
              />
            </div>

            <div className="flex items-center justify-between">
              <Label>جهاز شائع</Label>
              <Switch
                checked={formData.isPopular}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, isPopular: checked })
                }
              />
            </div>

            <div className="flex items-center justify-between">
              <Label>نشط</Label>
              <Switch
                checked={formData.isActive}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, isActive: checked })
                }
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={handleCloseDialog}>
              إلغاء
            </Button>
            <Button
              onClick={handleSubmit}
              disabled={
                !formData.name ||
                !formData.brandId ||
                createMutation.isPending ||
                updateMutation.isPending
              }
            >
              {(createMutation.isPending || updateMutation.isPending) && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              {editingDevice ? "حفظ التعديلات" : "إضافة"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// Quality Types Tab Component
// ══════════════════════════════════════════════════════════════

function QualityTypesTab() {
  const queryClient = useQueryClient();
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingType, setEditingType] = useState<QualityType | null>(null);
  const [formData, setFormData] = useState({
    name: "",
    nameAr: "",
    code: "",
    displayOrder: 0,
    isActive: true,
  });

  const { data: qualityTypes, isLoading } = useQuery({
    queryKey: ["quality-types"],
    queryFn: catalogApi.getQualityTypes,
  });

  const createMutation = useMutation({
    mutationFn: catalogApi.createQualityType,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["quality-types"] });
      handleCloseDialog();
    },
  });

  const updateMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: Partial<{
        name: string;
        nameAr?: string;
        code: string;
        displayOrder?: number;
        isActive?: boolean;
      }>;
    }) => catalogApi.updateQualityType(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["quality-types"] });
      handleCloseDialog();
    },
  });

  const deleteMutation = useMutation({
    mutationFn: catalogApi.deleteQualityType,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["quality-types"] });
    },
  });

  const handleOpenCreate = () => {
    setEditingType(null);
    setFormData({
      name: "",
      nameAr: "",
      code: "",
      displayOrder: 0,
      isActive: true,
    });
    setIsDialogOpen(true);
  };

  const handleOpenEdit = (type: QualityType) => {
    setEditingType(type);
    setFormData({
      name: type.name,
      nameAr: type.nameAr || "",
      code: type.code,
      displayOrder: type.displayOrder,
      isActive: type.isActive,
    });
    setIsDialogOpen(true);
  };

  const handleCloseDialog = () => {
    setIsDialogOpen(false);
    setEditingType(null);
  };

  const handleSubmit = () => {
    if (!formData.name || !formData.code) return;

    if (editingType) {
      updateMutation.mutate({ id: editingType._id, data: formData });
    } else {
      createMutation.mutate(formData);
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-end">
        <Button onClick={handleOpenCreate}>
          <Plus className="h-4 w-4" />
          إضافة نوع جودة
        </Button>
      </div>

      <Card>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>النوع</TableHead>
                  <TableHead>الكود</TableHead>
                  <TableHead>الترتيب</TableHead>
                  <TableHead>الحالة</TableHead>
                  <TableHead className="w-12"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {(qualityTypes || []).map((type) => (
                  <TableRow key={type._id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 bg-gradient-to-br from-primary-100 to-primary-200 dark:from-primary-900 dark:to-primary-800 rounded-lg flex items-center justify-center">
                          <Tag className="h-5 w-5 text-primary-600 dark:text-primary-400" />
                        </div>
                        <div>
                          <p className="font-medium">
                            {type.nameAr || type.name}
                          </p>
                          <p className="text-xs text-gray-500">{type.name}</p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline" className="font-mono">
                        {type.code}
                      </Badge>
                    </TableCell>
                    <TableCell>{type.displayOrder}</TableCell>
                    <TableCell>
                      <Badge variant={type.isActive ? "success" : "default"}>
                        {type.isActive ? "نشط" : "غير نشط"}
                      </Badge>
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
                            onClick={() => handleOpenEdit(type)}
                          >
                            <Pencil className="h-4 w-4" />
                            تعديل
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            className="text-red-600"
                            onClick={() => deleteMutation.mutate(type._id)}
                          >
                            <Trash2 className="h-4 w-4" />
                            حذف
                          </DropdownMenuItem>
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))}
                {(!qualityTypes || qualityTypes.length === 0) && (
                  <TableRow>
                    <TableCell
                      colSpan={5}
                      className="text-center py-8 text-gray-500"
                    >
                      لا توجد أنواع جودة
                    </TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Quality Type Dialog */}
      <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>
              {editingType ? "تعديل نوع الجودة" : "إضافة نوع جودة"}
            </DialogTitle>
            <DialogDescription>أدخل بيانات نوع الجودة</DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-4">
            <div className="space-y-2">
              <Label>
                الاسم بالإنجليزية <span className="text-red-500">*</span>
              </Label>
              <Input
                dir="ltr"
                placeholder="New"
                value={formData.name}
                onChange={(e) =>
                  setFormData({ ...formData, name: e.target.value })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>الاسم بالعربية</Label>
              <Input
                placeholder="جديد"
                value={formData.nameAr}
                onChange={(e) =>
                  setFormData({ ...formData, nameAr: e.target.value })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>
                الكود <span className="text-red-500">*</span>
              </Label>
              <Input
                dir="ltr"
                placeholder="NEW"
                value={formData.code}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    code: e.target.value.toUpperCase(),
                  })
                }
              />
            </div>

            <div className="space-y-2">
              <Label>الترتيب</Label>
              <Input
                type="number"
                min="0"
                value={formData.displayOrder}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    displayOrder: parseInt(e.target.value) || 0,
                  })
                }
              />
            </div>

            <div className="flex items-center justify-between">
              <Label>نشط</Label>
              <Switch
                checked={formData.isActive}
                onCheckedChange={(checked) =>
                  setFormData({ ...formData, isActive: checked })
                }
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={handleCloseDialog}>
              إلغاء
            </Button>
            <Button
              onClick={handleSubmit}
              disabled={
                !formData.name ||
                !formData.code ||
                createMutation.isPending ||
                updateMutation.isPending
              }
            >
              {(createMutation.isPending || updateMutation.isPending) && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              {editingType ? "حفظ التعديلات" : "إضافة"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

// ══════════════════════════════════════════════════════════════
// Main Catalog Page
// ══════════════════════════════════════════════════════════════

export function CatalogPage() {
  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
          الكتالوج
        </h1>
        <p className="text-gray-500 dark:text-gray-400 mt-1">
          إدارة العلامات التجارية والأجهزة وأنواع الجودة
        </p>
      </div>

      {/* Tabs */}
      <Tabs defaultValue="brands" className="w-full">
        <TabsList className="w-full max-w-md">
          <TabsTrigger value="brands" className="flex-1 gap-2">
            <Building2 className="h-4 w-4" />
            العلامات التجارية
          </TabsTrigger>
          <TabsTrigger value="devices" className="flex-1 gap-2">
            <Smartphone className="h-4 w-4" />
            الأجهزة
          </TabsTrigger>
          <TabsTrigger value="quality" className="flex-1 gap-2">
            <Tag className="h-4 w-4" />
            أنواع الجودة
          </TabsTrigger>
        </TabsList>

        <TabsContent value="brands" className="mt-6">
          <BrandsTab />
        </TabsContent>

        <TabsContent value="devices" className="mt-6">
          <DevicesTab />
        </TabsContent>

        <TabsContent value="quality" className="mt-6">
          <QualityTypesTab />
        </TabsContent>
      </Tabs>
    </div>
  );
}

export default CatalogPage;
