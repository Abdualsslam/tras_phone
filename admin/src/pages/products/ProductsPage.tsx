import { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  productsApi,
  type CreateProductDto,
  type PriceLevel,
  type ProductReview,
} from "@/api/products.api";
import {
  uploadsApi,
  isValidImageType,
  isValidVideoType,
  isValidFileSize,
} from "@/api/uploads.api";
import { catalogApi as catalogDeviceApi, type Device } from "@/api/catalog.api";
import {
  catalogApi,
  type CategoryTree,
  type QualityType,
} from "@/api/catalog.api";
import type { Product, Brand } from "@/types";
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
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Plus,
  Search,
  MoreHorizontal,
  Pencil,
  Trash2,
  Eye,
  Package,
  Loader2,
  AlertCircle,
  DollarSign,
  Star,
  Smartphone,
  Tag,
  Image,
  Video,
  X,
  Upload,
} from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { formatCurrency } from "@/lib/utils";

const statusVariants: Record<
  string,
  "success" | "warning" | "default" | "danger"
> = {
  active: "success",
  published: "success",
  draft: "warning",
  inactive: "default",
  out_of_stock: "danger",
  discontinued: "default",
  archived: "default",
};

const statusLabels: Record<string, string> = {
  active: "نشط",
  published: "منشور",
  draft: "مسودة",
  inactive: "غير نشط",
  out_of_stock: "نفذ المخزون",
  discontinued: "متوقف",
  archived: "مؤرشف",
};

interface AddProductForm {
  // Required
  sku: string;
  name: string;
  nameAr: string;
  slug: string;
  brandId: string;
  categoryId: string;
  qualityTypeId: string;
  basePrice: string;
  // Optional
  description: string;
  descriptionAr: string;
  shortDescription: string;
  shortDescriptionAr: string;
  compareAtPrice: string;
  costPrice: string;
  stockQuantity: string;
  lowStockThreshold: string;
  minOrderQuantity: string;
  maxOrderQuantity: string;
  status: string;
  isActive: boolean;
  isFeatured: boolean;
  weight: string;
  dimensions: string;
  color: string;
  // Images & Video
  mainImage: string;
  images: string[];
  video: string;
  // Additional fields
  additionalCategories: string[];
  trackInventory: boolean;
  allowBackorder: boolean;
  tags: string[];
  specifications: Record<string, string>;
  compatibleDevices: string[];
  relatedProducts: string[];
  priceLevelsPrices: Record<string, string>;
}

const initialFormData: AddProductForm = {
  sku: "",
  name: "",
  nameAr: "",
  slug: "",
  brandId: "",
  categoryId: "",
  qualityTypeId: "",
  basePrice: "",
  description: "",
  descriptionAr: "",
  shortDescription: "",
  shortDescriptionAr: "",
  compareAtPrice: "",
  costPrice: "",
  stockQuantity: "0",
  lowStockThreshold: "5",
  minOrderQuantity: "1",
  maxOrderQuantity: "",
  status: "draft",
  isActive: true,
  isFeatured: false,
  weight: "",
  dimensions: "",
  color: "",
  // Images & Video
  mainImage: "",
  images: [],
  video: "",
  // Additional fields
  additionalCategories: [],
  trackInventory: true,
  allowBackorder: false,
  tags: [],
  specifications: {},
  compatibleDevices: [],
  relatedProducts: [],
  priceLevelsPrices: {},
};

export function ProductsPage() {
  const { t, i18n } = useTranslation();
  const queryClient = useQueryClient();
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [isDeleteDialogOpen, setIsDeleteDialogOpen] = useState(false);
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false);
  const [isDetailDialogOpen, setIsDetailDialogOpen] = useState(false);
  const [isPricesDialogOpen, setIsPricesDialogOpen] = useState(false);
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null);
  const [formData, setFormData] = useState<AddProductForm>(initialFormData);
  const [priceInputs, setPriceInputs] = useState<Record<string, string>>({});
  const [tagsInput, setTagsInput] = useState("");
  const [selectedDevices, setSelectedDevices] = useState<string[]>([]);
  const [isEditMode, setIsEditMode] = useState(false);
  const [newSpecKey, setNewSpecKey] = useState("");
  const [newSpecValue, setNewSpecValue] = useState("");
  const [formTagsInput, setFormTagsInput] = useState("");
  const [isUploadingMainImage, setIsUploadingMainImage] = useState(false);
  const [isUploadingGallery, setIsUploadingGallery] = useState(false);
  const [isUploadingVideo, setIsUploadingVideo] = useState(false);
  const [uploadError, setUploadError] = useState<string | null>(null);
  const [relatedProductsSearch, setRelatedProductsSearch] = useState("");
  const [relatedProductsDisplayCount, setRelatedProductsDisplayCount] =
    useState(5);
  const locale = i18n.language === "ar" ? "ar-SA" : "en-US";

  // Fetch products
  const { data, isLoading, error } = useQuery({
    queryKey: ["products", searchQuery, statusFilter],
    queryFn: () =>
      productsApi.getAll({
        search: searchQuery,
        status: statusFilter,
        limit: 20,
      }),
  });

  // Fetch categories for dropdown
  const { data: categories = [] } = useQuery<CategoryTree[]>({
    queryKey: ["categories-tree"],
    queryFn: catalogApi.getCategoryTree,
    enabled: isAddDialogOpen,
  });

  // Fetch brands for dropdown
  const { data: brands = [] } = useQuery<Brand[]>({
    queryKey: ["brands"],
    queryFn: () => catalogApi.getBrands(),
    enabled: isAddDialogOpen,
  });

  // Fetch quality types for dropdown
  const { data: qualityTypes = [] } = useQuery<QualityType[]>({
    queryKey: ["quality-types"],
    queryFn: catalogApi.getQualityTypes,
    enabled: isAddDialogOpen,
  });

  // Fetch price levels
  const { data: priceLevels = [] } = useQuery<PriceLevel[]>({
    queryKey: ["price-levels"],
    queryFn: productsApi.getPriceLevels,
    enabled: isPricesDialogOpen || isAddDialogOpen,
  });

  // Fetch devices for compatibility
  const { data: devices = [] } = useQuery<Device[]>({
    queryKey: ["devices-all"],
    queryFn: () => catalogDeviceApi.getDevices({ limit: 200 }),
    enabled: isAddDialogOpen || isDetailDialogOpen,
  });

  // Fetch products for related products selection
  const { data: availableProductsData } = useQuery({
    queryKey: [
      "products-for-related",
      isAddDialogOpen,
      isEditMode,
      selectedProduct?._id,
    ],
    queryFn: () =>
      productsApi.getAll({
        status: "active",
        limit: 1000, // Get all active products
      }),
    enabled: isAddDialogOpen,
  });

  // Filter out current product if in edit mode and filter by search
  const availableProducts = (availableProductsData?.items || [])
    .filter((p: Product) => !isEditMode || p._id !== selectedProduct?._id)
    .filter((p: Product) => {
      if (!relatedProductsSearch.trim()) return true;
      const searchLower = relatedProductsSearch.toLowerCase();
      return (
        (p.name || "").toLowerCase().includes(searchLower) ||
        (p.nameAr || "").toLowerCase().includes(searchLower) ||
        (p.sku || "").toLowerCase().includes(searchLower)
      );
    });

  // Get displayed products (limited by displayCount)
  const displayedProducts = availableProducts.slice(
    0,
    relatedProductsDisplayCount
  );
  const hasMoreProducts =
    availableProducts.length > relatedProductsDisplayCount;

  // Fetch product reviews when detail dialog is open
  const { data: productReviews = [] } = useQuery<ProductReview[]>({
    queryKey: ["product-reviews", selectedProduct?._id],
    queryFn: () => productsApi.getProductReviews(selectedProduct!._id),
    enabled: isDetailDialogOpen && !!selectedProduct?._id,
  });

  // Fetch product prices when editing
  const { data: productPrices = [] } = useQuery({
    queryKey: ["product-prices", selectedProduct?._id],
    queryFn: () => productsApi.getProductPrices(selectedProduct!._id),
    enabled: isEditMode && !!selectedProduct?._id && isAddDialogOpen,
  });

  // Update form data when product prices are loaded
  useEffect(() => {
    if (
      productPrices &&
      productPrices.length > 0 &&
      isEditMode &&
      isAddDialogOpen
    ) {
      const pricesMap: Record<string, string> = {};
      productPrices.forEach((price: any) => {
        if (price.priceLevelId && price.price) {
          pricesMap[price.priceLevelId] = String(price.price);
        }
      });
      setFormData((prev) => ({
        ...prev,
        priceLevelsPrices: pricesMap,
      }));
    }
  }, [productPrices, isEditMode, isAddDialogOpen]);

  // Create mutation
  const createMutation = useMutation({
    mutationFn: (data: CreateProductDto) => productsApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
      setIsAddDialogOpen(false);
      setFormData(initialFormData);
      setIsEditMode(false);
    },
  });

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: Partial<CreateProductDto>;
    }) => productsApi.update(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] });

      // Save price levels prices if any
      const pricesToSave = Object.entries(formData.priceLevelsPrices)
        .filter(([, value]) => value && Number(value) > 0)
        .map(([priceLevelId, price]) => ({
          priceLevelId,
          price: Number(price),
        }));

      if (pricesToSave.length > 0 && selectedProduct) {
        productsApi
          .setProductPrices(selectedProduct._id, pricesToSave)
          .then(() => {
            queryClient.invalidateQueries({ queryKey: ["products"] });
          });
      }

      setIsAddDialogOpen(false);
      setFormData(initialFormData);
      setIsEditMode(false);
      setSelectedProduct(null);
    },
  });

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: (id: string) => productsApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
      setIsDeleteDialogOpen(false);
      setSelectedProduct(null);
    },
  });

  // Set prices mutation
  const setPricesMutation = useMutation({
    mutationFn: ({
      productId,
      prices,
    }: {
      productId: string;
      prices: { priceLevelId: string; price: number }[];
    }) => productsApi.setProductPrices(productId, prices),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
      setIsPricesDialogOpen(false);
    },
  });

  // Set devices mutation
  const setDevicesMutation = useMutation({
    mutationFn: ({
      productId,
      deviceIds,
    }: {
      productId: string;
      deviceIds: string[];
    }) => productsApi.setCompatibleDevices(productId, deviceIds),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
    },
  });

  // Set tags mutation
  const setTagsMutation = useMutation({
    mutationFn: ({ productId, tags }: { productId: string; tags: string[] }) =>
      productsApi.setProductTags(productId, tags),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["products"] });
    },
  });

  // Approve review mutation
  const approveReviewMutation = useMutation({
    mutationFn: ({
      productId,
      reviewId,
    }: {
      productId: string;
      reviewId: string;
    }) => productsApi.approveReview(productId, reviewId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["product-reviews"] });
    },
  });

  // Delete review mutation
  const deleteReviewMutation = useMutation({
    mutationFn: ({
      productId,
      reviewId,
    }: {
      productId: string;
      reviewId: string;
    }) => productsApi.deleteReview(productId, reviewId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["product-reviews"] });
    },
  });

  const handleDelete = (product: Product) => {
    setSelectedProduct(product);
    setIsDeleteDialogOpen(true);
  };

  const handleViewDetails = (product: Product) => {
    setSelectedProduct(product);
    setSelectedDevices([]);
    setTagsInput("");
    setIsDetailDialogOpen(true);
  };

  const handleOpenPrices = (product: Product) => {
    setSelectedProduct(product);
    setPriceInputs({});
    setIsPricesDialogOpen(true);
  };

  const handleSavePrices = () => {
    if (!selectedProduct) return;
    const prices = Object.entries(priceInputs)
      .filter(([, value]) => value && Number(value) > 0)
      .map(([priceLevelId, price]) => ({ priceLevelId, price: Number(price) }));
    if (prices.length > 0) {
      setPricesMutation.mutate({ productId: selectedProduct._id, prices });
    }
  };

  const handleSaveDevices = () => {
    if (!selectedProduct) return;
    setDevicesMutation.mutate({
      productId: selectedProduct._id,
      deviceIds: selectedDevices,
    });
  };

  const handleSaveTags = () => {
    if (!selectedProduct) return;
    const tags = tagsInput
      .split(",")
      .map((t) => t.trim())
      .filter(Boolean);
    setTagsMutation.mutate({ productId: selectedProduct._id, tags });
  };

  const onDeleteConfirm = () => {
    if (selectedProduct) {
      deleteMutation.mutate(selectedProduct._id);
    }
  };

  const handleFormChange = (
    field: keyof AddProductForm,
    value: string | boolean | string[] | Record<string, string>
  ) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    // Auto-generate slug from name
    if (field === "name" && typeof value === "string") {
      const slug = value
        .toLowerCase()
        .replace(/\s+/g, "-")
        .replace(/[^\w-]/g, "");
      setFormData((prev) => ({ ...prev, slug }));
    }
  };

  const handleOpenAddDialog = () => {
    setFormData(initialFormData);
    setIsEditMode(false);
    setSelectedProduct(null);
    setFormTagsInput("");
    setUploadError(null);
    setRelatedProductsSearch("");
    setRelatedProductsDisplayCount(5);
    setIsAddDialogOpen(true);
  };

  const handleEdit = (product: Product) => {
    setSelectedProduct(product);
    setIsEditMode(true);
    // Populate form with existing product data
    setFormData({
      sku: product.sku || "",
      name: product.name || "",
      nameAr: product.nameAr || "",
      slug: (product as any).slug || "",
      brandId: (product.brand as any)?._id || "",
      categoryId: (product.category as any)?._id || "",
      qualityTypeId:
        (product as any).qualityTypeId?._id ||
        (product as any).qualityTypeId ||
        "",
      basePrice: String(product.price || ""),
      description: product.description || "",
      descriptionAr: product.descriptionAr || "",
      shortDescription: (product as any).shortDescription || "",
      shortDescriptionAr: (product as any).shortDescriptionAr || "",
      compareAtPrice: product.compareAtPrice
        ? String(product.compareAtPrice)
        : "",
      costPrice: (product as any).costPrice
        ? String((product as any).costPrice)
        : "",
      stockQuantity: String(product.stock || 0),
      lowStockThreshold: String((product as any).lowStockThreshold || 5),
      minOrderQuantity: String((product as any).minOrderQuantity || 1),
      maxOrderQuantity: (product as any).maxOrderQuantity
        ? String((product as any).maxOrderQuantity)
        : "",
      status: product.status || "draft",
      isActive: (product as any).isActive ?? true,
      isFeatured: product.featured || false,
      weight: (product as any).weight ? String((product as any).weight) : "",
      dimensions: (product as any).dimensions || "",
      color: (product as any).color || "",
      mainImage: (product as any).mainImage || "",
      images: product.images || [],
      video: (product as any).video || "",
      additionalCategories: (product as any).additionalCategories || [],
      trackInventory: (product as any).trackInventory ?? true,
      allowBackorder: (product as any).allowBackorder || false,
      tags: (product as any).tags || [],
      specifications: (product as any).specifications || {},
      compatibleDevices:
        (product as any).compatibleDevices?.map((d: any) => d._id || d) || [],
      relatedProducts:
        (product as any).relatedProducts?.map((p: any) => p._id || p) || [],
      priceLevelsPrices: {},
    });
    setFormTagsInput(((product as any).tags || []).join(", "));
    setIsAddDialogOpen(true);
  };

  const handleSubmit = () => {
    // Validate required fields
    if (
      !formData.sku ||
      !formData.name ||
      !formData.nameAr ||
      !formData.brandId ||
      !formData.categoryId ||
      !formData.qualityTypeId ||
      !formData.basePrice
    ) {
      return;
    }

    // Parse tags from input
    const parsedTags = formTagsInput
      .split(",")
      .map((t) => t.trim())
      .filter(Boolean);

    const productData: CreateProductDto = {
      sku: formData.sku,
      name: formData.name,
      nameAr: formData.nameAr,
      slug: formData.slug || formData.name.toLowerCase().replace(/\s+/g, "-"),
      brandId: formData.brandId,
      categoryId: formData.categoryId,
      qualityTypeId: formData.qualityTypeId,
      basePrice: Number(formData.basePrice),
      // Optional fields
      ...(formData.description && { description: formData.description }),
      ...(formData.descriptionAr && { descriptionAr: formData.descriptionAr }),
      ...(formData.shortDescription && {
        shortDescription: formData.shortDescription,
      }),
      ...(formData.shortDescriptionAr && {
        shortDescriptionAr: formData.shortDescriptionAr,
      }),
      ...(formData.compareAtPrice && {
        compareAtPrice: Number(formData.compareAtPrice),
      }),
      ...(formData.costPrice && { costPrice: Number(formData.costPrice) }),
      stockQuantity: Number(formData.stockQuantity) || 0,
      lowStockThreshold: Number(formData.lowStockThreshold) || 5,
      minOrderQuantity: Number(formData.minOrderQuantity) || 1,
      ...(formData.maxOrderQuantity && {
        maxOrderQuantity: Number(formData.maxOrderQuantity),
      }),
      status: formData.status as CreateProductDto["status"],
      isActive: formData.isActive,
      isFeatured: formData.isFeatured,
      trackInventory: formData.trackInventory,
      allowBackorder: formData.allowBackorder,
      ...(formData.weight && { weight: Number(formData.weight) }),
      ...(formData.dimensions && { dimensions: formData.dimensions }),
      ...(formData.color && { color: formData.color }),
      // Images & Video
      ...(formData.mainImage && { mainImage: formData.mainImage }),
      ...(formData.images.length > 0 && { images: formData.images }),
      ...(formData.video && { video: formData.video }),
      // Additional fields
      ...(formData.additionalCategories.length > 0 && {
        additionalCategories: formData.additionalCategories,
      }),
      ...(parsedTags.length > 0 && { tags: parsedTags }),
      ...(Object.keys(formData.specifications).length > 0 && {
        specifications: formData.specifications,
      }),
      ...(formData.compatibleDevices.length > 0 && {
        compatibleDevices: formData.compatibleDevices,
      }),
      ...(formData.relatedProducts.length > 0 && {
        relatedProducts: formData.relatedProducts,
      }),
    };

    if (isEditMode && selectedProduct) {
      updateMutation.mutate({ id: selectedProduct._id, data: productData });
    } else {
      createMutation.mutate(productData);
    }
  };

  const products = data?.items || [];

  return (
    <div className="space-y-6 animate-fade-in">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
            {t("products.title")}
          </h1>
          <p className="text-gray-500 dark:text-gray-400 mt-1">
            إدارة المنتجات والمخزون
          </p>
        </div>
        <Button onClick={handleOpenAddDialog}>
          <Plus className="h-4 w-4" />
          {t("products.addProduct")}
        </Button>
      </div>

      {/* Search and Filters */}
      <Card>
        <CardContent className="p-4">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
              <Input
                placeholder="البحث عن منتج بالاسم، SKU، أو التاجات..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="ps-10"
                onKeyDown={(e) => {
                  if (e.key === "Enter") {
                    e.preventDefault();
                    // Trigger search immediately on Enter
                  }
                }}
              />
              {searchQuery && (
                <button
                  onClick={() => setSearchQuery("")}
                  className="absolute end-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                >
                  ✕
                </button>
              )}
            </div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm min-w-[150px]"
            >
              <option value="">جميع الحالات</option>
              <option value="active">نشط</option>
              <option value="draft">مسودة</option>
              <option value="inactive">غير نشط</option>
            </select>
          </div>
        </CardContent>
      </Card>

      {/* Products Table */}
      <Card>
        <CardHeader className="flex flex-row items-center gap-2 pb-4">
          <Package className="h-5 w-5 text-gray-500 dark:text-gray-400" />
          <CardTitle className="text-lg">قائمة المنتجات</CardTitle>
          {data && (
            <Badge variant="secondary" className="ms-auto">
              {data.pagination?.total || products.length} منتج
            </Badge>
          )}
        </CardHeader>
        <CardContent className="p-0">
          {isLoading ? (
            <div className="flex items-center justify-center py-12">
              <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
            </div>
          ) : error ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-500 dark:text-gray-400">
              <AlertCircle className="h-12 w-12 mb-4 text-red-400" />
              <p>حدث خطأ في تحميل البيانات</p>
            </div>
          ) : products.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-gray-500 dark:text-gray-400">
              <Package className="h-12 w-12 mb-4 text-gray-300 dark:text-gray-600" />
              <p>{t("common.noData")}</p>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>المنتج</TableHead>
                  <TableHead>{t("products.sku")}</TableHead>
                  <TableHead>{t("products.category")}</TableHead>
                  <TableHead>{t("products.price")}</TableHead>
                  <TableHead>{t("products.stock")}</TableHead>
                  <TableHead>{t("products.status")}</TableHead>
                  <TableHead className="w-[50px]"></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {products.map((product) => (
                  <TableRow key={product._id}>
                    <TableCell>
                      <div className="flex items-center gap-3">
                        <div className="w-12 h-12 rounded-lg bg-gray-100 dark:bg-slate-800 overflow-hidden flex-shrink-0">
                          {(product as any).mainImage || product.images?.[0] ? (
                            <img
                              src={
                                (product as any).mainImage || product.images[0]
                              }
                              alt={product.name}
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            <div className="w-full h-full flex items-center justify-center">
                              <Package className="h-6 w-6 text-gray-300" />
                            </div>
                          )}
                        </div>
                        <div>
                          <p className="font-medium text-gray-900 dark:text-gray-100">
                            {product.name}
                          </p>
                          {product.brand && (
                            <p className="text-xs text-gray-500 dark:text-gray-400">
                              {product.brand.name}
                            </p>
                          )}
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="text-gray-600 dark:text-gray-400 font-mono text-sm">
                      {product.sku}
                    </TableCell>
                    <TableCell className="text-gray-600 dark:text-gray-400">
                      {product.category?.name || "-"}
                    </TableCell>
                    <TableCell className="font-medium text-gray-900 dark:text-gray-100">
                      {formatCurrency(product.price || 0, "SAR", locale)}
                    </TableCell>
                    <TableCell>
                      <span
                        className={
                          product.stock > 10
                            ? "text-green-600"
                            : product.stock > 0
                            ? "text-yellow-600"
                            : "text-red-600"
                        }
                      >
                        {product.stock}
                      </span>
                    </TableCell>
                    <TableCell>
                      <Badge variant={statusVariants[product.status]}>
                        {statusLabels[product.status]}
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
                            onClick={() => handleViewDetails(product)}
                          >
                            <Eye className="h-4 w-4" />
                            التفاصيل
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => handleEdit(product)}>
                            <Pencil className="h-4 w-4" />
                            تعديل
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            onClick={() => handleOpenPrices(product)}
                          >
                            <DollarSign className="h-4 w-4" />
                            مستويات الأسعار
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          <DropdownMenuItem
                            className="text-red-600"
                            onClick={() => handleDelete(product)}
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

      {/* Add/Edit Product Dialog */}
      <Dialog
        open={isAddDialogOpen}
        onOpenChange={(open) => {
          setIsAddDialogOpen(open);
          if (!open) {
            setIsEditMode(false);
            setSelectedProduct(null);
            setFormData(initialFormData);
            setFormTagsInput("");
            setRelatedProductsSearch("");
            setRelatedProductsDisplayCount(5);
          }
        }}
      >
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {isEditMode ? "تعديل المنتج" : "إضافة منتج جديد"}
            </DialogTitle>
            <DialogDescription>
              {isEditMode
                ? "قم بتعديل بيانات المنتج"
                : "أدخل بيانات المنتج الجديد"}{" "}
              (الحقول المميزة بـ * إلزامية)
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-6 py-4">
            {/* Basic Info Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                المعلومات الأساسية
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>
                    رمز المنتج (SKU) <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    dir="ltr"
                    placeholder="SKU001"
                    value={formData.sku}
                    onChange={(e) => handleFormChange("sku", e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label>
                    الرابط (Slug) <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    dir="ltr"
                    placeholder="product-slug"
                    value={formData.slug}
                    onChange={(e) => handleFormChange("slug", e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label>
                    الاسم بالإنجليزية <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    dir="ltr"
                    placeholder="Product Name"
                    value={formData.name}
                    onChange={(e) => handleFormChange("name", e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label>
                    الاسم بالعربية <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    placeholder="اسم المنتج"
                    value={formData.nameAr}
                    onChange={(e) => handleFormChange("nameAr", e.target.value)}
                  />
                </div>
              </div>
            </div>

            {/* Classification Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                التصنيف
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <Label>
                    التصنيف <span className="text-red-500">*</span>
                  </Label>
                  <select
                    value={formData.categoryId}
                    onChange={(e) =>
                      handleFormChange("categoryId", e.target.value)
                    }
                    className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                  >
                    <option value="">اختر التصنيف...</option>
                    {categories.map((cat) => (
                      <option key={cat._id} value={cat._id}>
                        {cat.nameAr || cat.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="space-y-2">
                  <Label>
                    العلامة التجارية <span className="text-red-500">*</span>
                  </Label>
                  <select
                    value={formData.brandId}
                    onChange={(e) =>
                      handleFormChange("brandId", e.target.value)
                    }
                    className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                  >
                    <option value="">اختر العلامة...</option>
                    {brands.map((brand) => (
                      <option key={brand._id} value={brand._id}>
                        {brand.nameAr || brand.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="space-y-2">
                  <Label>
                    نوع الجودة <span className="text-red-500">*</span>
                  </Label>
                  <select
                    value={formData.qualityTypeId}
                    onChange={(e) =>
                      handleFormChange("qualityTypeId", e.target.value)
                    }
                    className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                  >
                    <option value="">اختر الجودة...</option>
                    {qualityTypes.map((qt) => (
                      <option key={qt._id} value={qt._id}>
                        {qt.nameAr || qt.name}
                      </option>
                    ))}
                  </select>
                </div>
              </div>
            </div>

            {/* Pricing Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                التسعير
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <Label>
                    السعر الأساسي <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="0.00"
                    value={formData.basePrice}
                    onChange={(e) =>
                      handleFormChange("basePrice", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>السعر قبل الخصم</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="0.00"
                    value={formData.compareAtPrice}
                    onChange={(e) =>
                      handleFormChange("compareAtPrice", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>سعر التكلفة</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="0.00"
                    value={formData.costPrice}
                    onChange={(e) =>
                      handleFormChange("costPrice", e.target.value)
                    }
                  />
                </div>
              </div>
            </div>

            {/* Inventory Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                المخزون
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div className="space-y-2">
                  <Label>الكمية</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="0"
                    value={formData.stockQuantity}
                    onChange={(e) =>
                      handleFormChange("stockQuantity", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>حد التنبيه</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="5"
                    value={formData.lowStockThreshold}
                    onChange={(e) =>
                      handleFormChange("lowStockThreshold", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>الحد الأدنى للطلب</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="1"
                    value={formData.minOrderQuantity}
                    onChange={(e) =>
                      handleFormChange("minOrderQuantity", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>الحد الأقصى للطلب</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="بدون حد"
                    value={formData.maxOrderQuantity}
                    onChange={(e) =>
                      handleFormChange("maxOrderQuantity", e.target.value)
                    }
                  />
                </div>
              </div>
            </div>

            {/* Description Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                الوصف
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>الوصف المختصر (إنجليزي)</Label>
                  <Input
                    dir="ltr"
                    placeholder="Short description"
                    value={formData.shortDescription}
                    onChange={(e) =>
                      handleFormChange("shortDescription", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>الوصف المختصر (عربي)</Label>
                  <Input
                    placeholder="وصف مختصر"
                    value={formData.shortDescriptionAr}
                    onChange={(e) =>
                      handleFormChange("shortDescriptionAr", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>الوصف الكامل (إنجليزي)</Label>
                  <textarea
                    dir="ltr"
                    placeholder="Full description"
                    value={formData.description}
                    onChange={(e) =>
                      handleFormChange("description", e.target.value)
                    }
                    className="w-full min-h-[80px] rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 py-2 text-sm resize-none"
                  />
                </div>
                <div className="space-y-2">
                  <Label>الوصف الكامل (عربي)</Label>
                  <textarea
                    placeholder="الوصف الكامل"
                    value={formData.descriptionAr}
                    onChange={(e) =>
                      handleFormChange("descriptionAr", e.target.value)
                    }
                    className="w-full min-h-[80px] rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 py-2 text-sm resize-none"
                  />
                </div>
              </div>
            </div>

            {/* Physical Properties Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                الخصائص
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <Label>الوزن (جرام)</Label>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="0"
                    value={formData.weight}
                    onChange={(e) => handleFormChange("weight", e.target.value)}
                  />
                </div>
                <div className="space-y-2">
                  <Label>الأبعاد (L×W×H سم)</Label>
                  <Input
                    dir="ltr"
                    placeholder="10x5x1"
                    value={formData.dimensions}
                    onChange={(e) =>
                      handleFormChange("dimensions", e.target.value)
                    }
                  />
                </div>
                <div className="space-y-2">
                  <Label>اللون</Label>
                  <Input
                    placeholder="أسود"
                    value={formData.color}
                    onChange={(e) => handleFormChange("color", e.target.value)}
                  />
                </div>
              </div>
            </div>

            {/* Compatible Devices Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                الأجهزة المتوافقة
              </h3>
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2 max-h-64 overflow-y-auto p-2 border rounded-lg">
                {devices.map((device) => (
                  <label
                    key={device._id}
                    className="flex items-center gap-2 p-2 hover:bg-gray-50 dark:hover:bg-slate-800 rounded cursor-pointer"
                  >
                    <input
                      type="checkbox"
                      checked={formData.compatibleDevices.includes(device._id)}
                      onChange={(e) => {
                        if (e.target.checked) {
                          handleFormChange("compatibleDevices", [
                            ...formData.compatibleDevices,
                            device._id,
                          ]);
                        } else {
                          handleFormChange(
                            "compatibleDevices",
                            formData.compatibleDevices.filter(
                              (id) => id !== device._id
                            )
                          );
                        }
                      }}
                      className="w-4 h-4 rounded"
                    />
                    <span className="text-sm">{device.name}</span>
                  </label>
                ))}
              </div>
              {devices.length === 0 && (
                <p className="text-sm text-gray-500 dark:text-gray-400 text-center py-4">
                  جاري تحميل الأجهزة...
                </p>
              )}
            </div>

            {/* Related Products Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                المنتجات المشابهة
              </h3>

              {/* Search Input */}
              <div className="relative">
                <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  placeholder="البحث عن منتج بالاسم أو SKU..."
                  value={relatedProductsSearch}
                  onChange={(e) => {
                    setRelatedProductsSearch(e.target.value);
                    setRelatedProductsDisplayCount(5); // Reset display count on search
                  }}
                  className="ps-10"
                />
                {relatedProductsSearch && (
                  <button
                    onClick={() => {
                      setRelatedProductsSearch("");
                      setRelatedProductsDisplayCount(5);
                    }}
                    className="absolute end-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300"
                  >
                    <X className="h-4 w-4" />
                  </button>
                )}
              </div>

              {/* Products List */}
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2 max-h-64 overflow-y-auto p-2 border rounded-lg">
                {displayedProducts.map((product) => (
                  <label
                    key={product._id}
                    className="flex items-center gap-2 p-2 hover:bg-gray-50 dark:hover:bg-slate-800 rounded cursor-pointer"
                  >
                    <input
                      type="checkbox"
                      checked={formData.relatedProducts.includes(product._id)}
                      onChange={(e) => {
                        if (e.target.checked) {
                          handleFormChange("relatedProducts", [
                            ...formData.relatedProducts,
                            product._id,
                          ]);
                        } else {
                          handleFormChange(
                            "relatedProducts",
                            formData.relatedProducts.filter(
                              (id) => id !== product._id
                            )
                          );
                        }
                      }}
                      className="w-4 h-4 rounded"
                    />
                    <span
                      className="text-sm truncate"
                      title={product.nameAr || product.name}
                    >
                      {product.nameAr || product.name}
                    </span>
                  </label>
                ))}
              </div>

              {/* Show More Button */}
              {hasMoreProducts && (
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    setRelatedProductsDisplayCount((prev) => prev + 5)
                  }
                  className="w-full"
                >
                  المزيد (
                  {availableProducts.length - relatedProductsDisplayCount}{" "}
                  متبقي)
                </Button>
              )}

              {/* Empty State */}
              {displayedProducts.length === 0 && (
                <p className="text-sm text-gray-500 dark:text-gray-400 text-center py-4">
                  {relatedProductsSearch
                    ? "لا توجد منتجات تطابق البحث"
                    : isEditMode
                    ? "لا توجد منتجات أخرى متاحة"
                    : "جاري تحميل المنتجات..."}
                </p>
              )}

              {/* Selected Count */}
              {formData.relatedProducts.length > 0 && (
                <p className="text-xs text-gray-500 dark:text-gray-400 text-center">
                  تم اختيار {formData.relatedProducts.length} منتج
                </p>
              )}
            </div>

            {/* Price Levels Section */}
            {priceLevels.length > 0 && (
              <div className="space-y-4">
                <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2 flex items-center gap-2">
                  <DollarSign className="h-4 w-4" />
                  أسعار المستويات
                </h3>
                <div className="space-y-3 p-4 bg-gray-50 dark:bg-slate-800/50 rounded-lg">
                  <p className="text-sm text-gray-600 dark:text-gray-400">
                    يمكنك تعيين سعر مختلف لكل مستوى تسعير. اتركه فارغاً لاستخدام
                    السعر الأساسي.
                  </p>
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    {priceLevels.map((level) => {
                      const currentPrice =
                        formData.priceLevelsPrices[level._id] || "";
                      const basePrice = Number(formData.basePrice) || 0;
                      return (
                        <div key={level._id} className="space-y-2">
                          <div className="flex items-center justify-between">
                            <Label className="text-sm">
                              {level.nameAr || level.name}
                              {level.discountPercentage ? (
                                <span className="text-xs text-gray-500 ms-2">
                                  (خصم {level.discountPercentage}%)
                                </span>
                              ) : null}
                            </Label>
                            <Button
                              type="button"
                              variant="ghost"
                              size="sm"
                              className="h-6 text-xs"
                              onClick={() => {
                                handleFormChange("priceLevelsPrices", {
                                  ...formData.priceLevelsPrices,
                                  [level._id]: String(basePrice),
                                });
                              }}
                            >
                              استخدام السعر الأساسي
                            </Button>
                          </div>
                          <Input
                            type="number"
                            dir="ltr"
                            placeholder={`${basePrice.toLocaleString()} (السعر الأساسي)`}
                            className="w-full"
                            value={currentPrice}
                            onChange={(e) =>
                              handleFormChange("priceLevelsPrices", {
                                ...formData.priceLevelsPrices,
                                [level._id]: e.target.value,
                              })
                            }
                          />
                          {currentPrice && Number(currentPrice) > 0 && (
                            <p className="text-xs text-gray-500">
                              السعر: {Number(currentPrice).toLocaleString()} ر.س
                            </p>
                          )}
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>
            )}

            {/* Status Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                الحالة
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div className="space-y-2">
                  <Label>حالة المنتج</Label>
                  <select
                    value={formData.status}
                    onChange={(e) => handleFormChange("status", e.target.value)}
                    className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                  >
                    <option value="draft">مسودة</option>
                    <option value="active">نشط</option>
                    <option value="inactive">غير نشط</option>
                  </select>
                </div>
                <div className="flex items-center gap-2 pt-6">
                  <input
                    type="checkbox"
                    id="isActive"
                    checked={formData.isActive}
                    onChange={(e) =>
                      handleFormChange("isActive", e.target.checked)
                    }
                    className="w-4 h-4 rounded border-gray-300"
                  />
                  <Label htmlFor="isActive">منتج نشط</Label>
                </div>
                <div className="flex items-center gap-2 pt-6">
                  <input
                    type="checkbox"
                    id="isFeatured"
                    checked={formData.isFeatured}
                    onChange={(e) =>
                      handleFormChange("isFeatured", e.target.checked)
                    }
                    className="w-4 h-4 rounded border-gray-300"
                  />
                  <Label htmlFor="isFeatured">منتج مميز</Label>
                </div>
              </div>
            </div>

            {/* Images Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2 flex items-center gap-2">
                <Image className="h-4 w-4" />
                الصور والوسائط
              </h3>

              {uploadError && (
                <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-3 text-red-600 dark:text-red-400 text-sm">
                  {uploadError}
                </div>
              )}

              {/* Main Image */}
              <div className="space-y-2">
                <Label>الصورة الرئيسية</Label>
                {formData.mainImage ? (
                  <div className="relative w-40 h-40 rounded-lg border-2 border-dashed border-gray-300 dark:border-slate-600 overflow-hidden group">
                    <img
                      src={formData.mainImage}
                      alt="الصورة الرئيسية"
                      className="w-full h-full object-cover"
                    />
                    <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                      <button
                        type="button"
                        onClick={() => handleFormChange("mainImage", "")}
                        className="bg-red-500 text-white rounded-full p-2"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                ) : (
                  <label className="flex flex-col items-center justify-center w-40 h-40 rounded-lg border-2 border-dashed border-gray-300 dark:border-slate-600 hover:border-primary-500 dark:hover:border-primary-500 cursor-pointer transition-colors bg-gray-50 dark:bg-slate-800">
                    <input
                      type="file"
                      accept="image/*"
                      className="hidden"
                      disabled={isUploadingMainImage}
                      onChange={async (e) => {
                        const file = e.target.files?.[0];
                        if (!file) return;

                        if (!isValidImageType(file)) {
                          setUploadError(
                            "نوع الملف غير مدعوم. الأنواع المسموحة: JPEG, PNG, GIF, WebP"
                          );
                          return;
                        }
                        if (!isValidFileSize(file)) {
                          setUploadError(
                            "حجم الملف كبير جداً. الحد الأقصى 10MB"
                          );
                          return;
                        }

                        setUploadError(null);
                        setIsUploadingMainImage(true);
                        try {
                          const result = await uploadsApi.uploadSingle(
                            file,
                            "products/main"
                          );
                          handleFormChange("mainImage", result.url);
                        } catch (error: any) {
                          setUploadError(
                            error?.response?.data?.message || "فشل رفع الصورة"
                          );
                        } finally {
                          setIsUploadingMainImage(false);
                        }
                      }}
                    />
                    {isUploadingMainImage ? (
                      <Loader2 className="h-8 w-8 animate-spin text-primary-500" />
                    ) : (
                      <>
                        <Upload className="h-8 w-8 text-gray-400 mb-2" />
                        <span className="text-sm text-gray-500">اختر صورة</span>
                      </>
                    )}
                  </label>
                )}
              </div>

              {/* Gallery Images */}
              <div className="space-y-2">
                <Label>الصور الفرعية (المعرض)</Label>
                <div className="flex flex-wrap gap-3">
                  {formData.images.map((img, idx) => (
                    <div
                      key={idx}
                      className="relative w-24 h-24 rounded-lg border overflow-hidden group"
                    >
                      <img
                        src={img}
                        alt={`صورة ${idx + 1}`}
                        className="w-full h-full object-cover"
                      />
                      <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                        <button
                          type="button"
                          onClick={() => {
                            setFormData((prev) => ({
                              ...prev,
                              images: prev.images.filter((_, i) => i !== idx),
                            }));
                          }}
                          className="bg-red-500 text-white rounded-full p-1"
                        >
                          <X className="h-4 w-4" />
                        </button>
                      </div>
                    </div>
                  ))}

                  {/* Add more images button */}
                  <label className="flex flex-col items-center justify-center w-24 h-24 rounded-lg border-2 border-dashed border-gray-300 dark:border-slate-600 hover:border-primary-500 dark:hover:border-primary-500 cursor-pointer transition-colors bg-gray-50 dark:bg-slate-800">
                    <input
                      type="file"
                      accept="image/*"
                      multiple
                      className="hidden"
                      disabled={isUploadingGallery}
                      onChange={async (e) => {
                        const files = Array.from(e.target.files || []);
                        if (files.length === 0) return;

                        // Validate all files
                        for (const file of files) {
                          if (!isValidImageType(file)) {
                            setUploadError(`ملف "${file.name}" غير مدعوم`);
                            return;
                          }
                          if (!isValidFileSize(file)) {
                            setUploadError(
                              `ملف "${file.name}" كبير جداً (الحد 10MB)`
                            );
                            return;
                          }
                        }

                        setUploadError(null);
                        setIsUploadingGallery(true);
                        try {
                          const results = await uploadsApi.uploadMultiple(
                            files,
                            "products/gallery"
                          );
                          setFormData((prev) => ({
                            ...prev,
                            images: [
                              ...prev.images,
                              ...results.map((r) => r.url),
                            ],
                          }));
                        } catch (error: any) {
                          setUploadError(
                            error?.response?.data?.message || "فشل رفع الصور"
                          );
                        } finally {
                          setIsUploadingGallery(false);
                          e.target.value = "";
                        }
                      }}
                    />
                    {isUploadingGallery ? (
                      <Loader2 className="h-6 w-6 animate-spin text-primary-500" />
                    ) : (
                      <>
                        <Plus className="h-6 w-6 text-gray-400" />
                        <span className="text-xs text-gray-500 mt-1">
                          إضافة
                        </span>
                      </>
                    )}
                  </label>
                </div>
                <p className="text-xs text-gray-500">
                  يمكنك اختيار عدة صور دفعة واحدة
                </p>
              </div>

              {/* Video */}
              <div className="space-y-2">
                <Label className="flex items-center gap-2">
                  <Video className="h-4 w-4" />
                  فيديو المنتج
                </Label>
                {formData.video ? (
                  <div className="flex items-center gap-2 p-3 bg-gray-50 dark:bg-slate-800 rounded-lg border">
                    <Video className="h-5 w-5 text-primary-500" />
                    <span className="flex-1 text-sm truncate">
                      {formData.video.split("/").pop()}
                    </span>
                    <button
                      type="button"
                      onClick={() => handleFormChange("video", "")}
                      className="text-red-500 hover:text-red-700 p-1"
                    >
                      <X className="h-4 w-4" />
                    </button>
                  </div>
                ) : (
                  <label className="flex items-center justify-center gap-3 p-4 rounded-lg border-2 border-dashed border-gray-300 dark:border-slate-600 hover:border-primary-500 dark:hover:border-primary-500 cursor-pointer transition-colors bg-gray-50 dark:bg-slate-800">
                    <input
                      type="file"
                      accept="video/*"
                      className="hidden"
                      disabled={isUploadingVideo}
                      onChange={async (e) => {
                        const file = e.target.files?.[0];
                        if (!file) return;

                        if (!isValidVideoType(file)) {
                          setUploadError(
                            "نوع الفيديو غير مدعوم. الأنواع المسموحة: MP4, WebM"
                          );
                          return;
                        }
                        if (!isValidFileSize(file, 50)) {
                          setUploadError(
                            "حجم الفيديو كبير جداً. الحد الأقصى 50MB"
                          );
                          return;
                        }

                        setUploadError(null);
                        setIsUploadingVideo(true);
                        try {
                          const result = await uploadsApi.uploadSingle(
                            file,
                            "products/videos"
                          );
                          handleFormChange("video", result.url);
                        } catch (error: any) {
                          setUploadError(
                            error?.response?.data?.message || "فشل رفع الفيديو"
                          );
                        } finally {
                          setIsUploadingVideo(false);
                        }
                      }}
                    />
                    {isUploadingVideo ? (
                      <>
                        <Loader2 className="h-6 w-6 animate-spin text-primary-500" />
                        <span className="text-sm text-gray-500">
                          جارٍ الرفع...
                        </span>
                      </>
                    ) : (
                      <>
                        <Upload className="h-6 w-6 text-gray-400" />
                        <span className="text-sm text-gray-500">
                          اختر فيديو (MP4, WebM - حتى 50MB)
                        </span>
                      </>
                    )}
                  </label>
                )}
              </div>
            </div>

            {/* Additional Options Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                خيارات إضافية
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="trackInventory"
                    checked={formData.trackInventory}
                    onChange={(e) =>
                      handleFormChange("trackInventory", e.target.checked)
                    }
                    className="w-4 h-4 rounded border-gray-300"
                  />
                  <Label htmlFor="trackInventory">تتبع المخزون</Label>
                </div>
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="allowBackorder"
                    checked={formData.allowBackorder}
                    onChange={(e) =>
                      handleFormChange("allowBackorder", e.target.checked)
                    }
                    className="w-4 h-4 rounded border-gray-300"
                  />
                  <Label htmlFor="allowBackorder">السماح بالطلب المسبق</Label>
                </div>
              </div>

              {/* Additional Categories */}
              <div className="space-y-2">
                <Label>تصنيفات إضافية</Label>
                <select
                  multiple
                  value={formData.additionalCategories}
                  onChange={(e) => {
                    const selected = Array.from(
                      e.target.selectedOptions,
                      (option) => option.value
                    );
                    setFormData((prev) => ({
                      ...prev,
                      additionalCategories: selected,
                    }));
                  }}
                  className="w-full min-h-[100px] rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 py-2 text-sm"
                >
                  {categories
                    .filter((cat) => cat._id !== formData.categoryId)
                    .map((cat) => (
                      <option key={cat._id} value={cat._id}>
                        {cat.nameAr || cat.name}
                      </option>
                    ))}
                </select>
                <p className="text-xs text-gray-500">
                  اضغط Ctrl للاختيار المتعدد
                </p>
              </div>

              {/* Tags */}
              <div className="space-y-2">
                <Label className="flex items-center gap-2">
                  <Tag className="h-4 w-4" />
                  الوسوم
                </Label>
                <Input
                  placeholder="شاشة, أصلي, ضمان... (مفصولة بفاصلة)"
                  value={formTagsInput}
                  onChange={(e) => setFormTagsInput(e.target.value)}
                />
                <p className="text-xs text-gray-500">
                  أدخل الوسوم مفصولة بفواصل
                </p>
              </div>
            </div>

            {/* Specifications Section */}
            <div className="space-y-4">
              <h3 className="font-semibold text-gray-900 dark:text-gray-100 border-b dark:border-slate-700 pb-2">
                المواصفات التقنية
              </h3>
              <div className="flex gap-2">
                <Input
                  placeholder="اسم المواصفة (مثال: الدقة)"
                  value={newSpecKey}
                  onChange={(e) => setNewSpecKey(e.target.value)}
                  className="flex-1"
                />
                <Input
                  placeholder="القيمة (مثال: 1080p)"
                  value={newSpecValue}
                  onChange={(e) => setNewSpecValue(e.target.value)}
                  className="flex-1"
                />
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => {
                    if (newSpecKey.trim() && newSpecValue.trim()) {
                      setFormData((prev) => ({
                        ...prev,
                        specifications: {
                          ...prev.specifications,
                          [newSpecKey.trim()]: newSpecValue.trim(),
                        },
                      }));
                      setNewSpecKey("");
                      setNewSpecValue("");
                    }
                  }}
                >
                  <Plus className="h-4 w-4" />
                </Button>
              </div>
              {Object.keys(formData.specifications).length > 0 && (
                <div className="border rounded-lg divide-y dark:divide-slate-700">
                  {Object.entries(formData.specifications).map(
                    ([key, value]) => (
                      <div
                        key={key}
                        className="flex items-center justify-between p-2 hover:bg-gray-50 dark:hover:bg-slate-800"
                      >
                        <div>
                          <span className="font-medium">{key}:</span>{" "}
                          <span className="text-gray-600 dark:text-gray-400">
                            {value}
                          </span>
                        </div>
                        <button
                          type="button"
                          onClick={() => {
                            const newSpecs = { ...formData.specifications };
                            delete newSpecs[key];
                            setFormData((prev) => ({
                              ...prev,
                              specifications: newSpecs,
                            }));
                          }}
                          className="text-red-500 hover:text-red-700 p-1"
                        >
                          <X className="h-4 w-4" />
                        </button>
                      </div>
                    )
                  )}
                </div>
              )}
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setIsAddDialogOpen(false)}>
              إلغاء
            </Button>
            <Button
              onClick={handleSubmit}
              disabled={
                createMutation.isPending ||
                updateMutation.isPending ||
                !formData.sku ||
                !formData.name ||
                !formData.nameAr ||
                !formData.brandId ||
                !formData.categoryId ||
                !formData.qualityTypeId ||
                !formData.basePrice
              }
            >
              {(createMutation.isPending || updateMutation.isPending) && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              {isEditMode ? "تحديث المنتج" : "إضافة المنتج"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={isDeleteDialogOpen} onOpenChange={setIsDeleteDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>تأكيد الحذف</DialogTitle>
            <DialogDescription>
              هل أنت متأكد من حذف المنتج "{selectedProduct?.name}"؟ هذا الإجراء
              لا يمكن التراجع عنه.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setIsDeleteDialogOpen(false)}
            >
              {t("common.cancel")}
            </Button>
            <Button
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

      {/* Price Levels Dialog */}
      <Dialog open={isPricesDialogOpen} onOpenChange={setIsPricesDialogOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <DollarSign className="h-5 w-5" />
              مستويات الأسعار
            </DialogTitle>
            <DialogDescription>
              تعيين أسعار مختلفة لمستويات العملاء المختلفة للمنتج "
              {selectedProduct?.name}"
            </DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            {priceLevels.length === 0 ? (
              <p className="text-center text-gray-500 py-4">
                لا توجد مستويات أسعار محددة
              </p>
            ) : (
              priceLevels.map((level) => (
                <div key={level._id} className="flex items-center gap-4">
                  <div className="flex-1">
                    <Label>{level.name}</Label>
                    <p className="text-xs text-gray-500">كود: {level.code}</p>
                  </div>
                  <Input
                    type="number"
                    dir="ltr"
                    placeholder="السعر"
                    className="w-32"
                    value={priceInputs[level._id] || ""}
                    onChange={(e) =>
                      setPriceInputs({
                        ...priceInputs,
                        [level._id]: e.target.value,
                      })
                    }
                  />
                </div>
              ))
            )}
          </div>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setIsPricesDialogOpen(false)}
            >
              إلغاء
            </Button>
            <Button
              onClick={handleSavePrices}
              disabled={setPricesMutation.isPending}
            >
              {setPricesMutation.isPending && (
                <Loader2 className="h-4 w-4 animate-spin" />
              )}
              حفظ الأسعار
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Product Detail Dialog */}
      <Dialog open={isDetailDialogOpen} onOpenChange={setIsDetailDialogOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              <Package className="h-5 w-5" />
              تفاصيل المنتج: {selectedProduct?.name}
            </DialogTitle>
          </DialogHeader>

          <Tabs defaultValue="devices" className="w-full">
            <TabsList className="w-full">
              <TabsTrigger value="devices" className="flex-1 gap-2">
                <Smartphone className="h-4 w-4" />
                الأجهزة المتوافقة
              </TabsTrigger>
              <TabsTrigger value="tags" className="flex-1 gap-2">
                <Tag className="h-4 w-4" />
                الوسوم
              </TabsTrigger>
              <TabsTrigger value="reviews" className="flex-1 gap-2">
                <Star className="h-4 w-4" />
                المراجعات
              </TabsTrigger>
            </TabsList>

            {/* Devices Tab */}
            <TabsContent value="devices" className="mt-4 space-y-4">
              <div className="grid grid-cols-2 md:grid-cols-3 gap-2 max-h-64 overflow-y-auto p-2 border rounded-lg">
                {devices.map((device) => (
                  <label
                    key={device._id}
                    className="flex items-center gap-2 p-2 hover:bg-gray-50 dark:hover:bg-slate-800 rounded cursor-pointer"
                  >
                    <input
                      type="checkbox"
                      checked={selectedDevices.includes(device._id)}
                      onChange={(e) => {
                        if (e.target.checked) {
                          setSelectedDevices([...selectedDevices, device._id]);
                        } else {
                          setSelectedDevices(
                            selectedDevices.filter((id) => id !== device._id)
                          );
                        }
                      }}
                      className="w-4 h-4 rounded"
                    />
                    <span className="text-sm">{device.name}</span>
                  </label>
                ))}
              </div>
              <Button
                onClick={handleSaveDevices}
                disabled={setDevicesMutation.isPending}
              >
                {setDevicesMutation.isPending && (
                  <Loader2 className="h-4 w-4 animate-spin" />
                )}
                حفظ الأجهزة المتوافقة
              </Button>
            </TabsContent>

            {/* Tags Tab */}
            <TabsContent value="tags" className="mt-4 space-y-4">
              <div className="space-y-2">
                <Label>الوسوم (مفصولة بفاصلة)</Label>
                <Input
                  placeholder="شاشة, أصلي, ضمان..."
                  value={tagsInput}
                  onChange={(e) => setTagsInput(e.target.value)}
                />
                <p className="text-xs text-gray-500">
                  أدخل الوسوم مفصولة بفواصل
                </p>
              </div>
              <Button
                onClick={handleSaveTags}
                disabled={setTagsMutation.isPending}
              >
                {setTagsMutation.isPending && (
                  <Loader2 className="h-4 w-4 animate-spin" />
                )}
                حفظ الوسوم
              </Button>
            </TabsContent>

            {/* Reviews Tab */}
            <TabsContent value="reviews" className="mt-4 space-y-4">
              {productReviews.length === 0 ? (
                <div className="text-center py-8 text-gray-500">
                  <Star className="h-12 w-12 mx-auto mb-2 text-gray-300" />
                  <p>لا توجد مراجعات لهذا المنتج</p>
                </div>
              ) : (
                <div className="space-y-3">
                  {productReviews.map((review) => (
                    <Card key={review._id}>
                      <CardContent className="p-4">
                            <div className="flex items-start justify-between">
                          <div>
                            <div className="flex items-center gap-2">
                              <span className="font-medium">
                                {(review.customerId as any)?.shopName ||
                                  (review.customerId as any)?.companyName ||
                                  "عميل"}
                              </span>
                              <div className="flex items-center">
                                {[...Array(5)].map((_, i) => (
                                  <Star
                                    key={i}
                                    className={`h-3 w-3 ${
                                      i < review.rating
                                        ? "text-yellow-400 fill-yellow-400"
                                        : "text-gray-300"
                                    }`}
                                  />
                                ))}
                              </div>
                            </div>
                            <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                              {review.comment}
                            </p>
                            <div className="flex gap-2 mt-2">
                              {review.status === "approved" ? (
                                <Badge variant="success">معتمد</Badge>
                              ) : (
                                <Badge variant="warning">قيد المراجعة</Badge>
                              )}
                              {review.isVerifiedPurchase && (
                                <Badge variant="secondary">مشتري حقيقي</Badge>
                              )}
                            </div>
                          </div>
                          <div className="flex gap-2">
                            {review.status !== "approved" && (
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() =>
                                  approveReviewMutation.mutate({
                                    productId: selectedProduct!._id,
                                    reviewId: review._id,
                                  })
                                }
                              >
                                اعتماد
                              </Button>
                            )}
                            <Button
                              size="sm"
                              variant="ghost"
                              className="text-red-600"
                              onClick={() =>
                                deleteReviewMutation.mutate({
                                  productId: selectedProduct!._id,
                                  reviewId: review._id,
                                })
                              }
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}
            </TabsContent>
          </Tabs>

          <DialogFooter className="mt-4">
            <Button
              variant="outline"
              onClick={() => setIsDetailDialogOpen(false)}
            >
              إغلاق
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
