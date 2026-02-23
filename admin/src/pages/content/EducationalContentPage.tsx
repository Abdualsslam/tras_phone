import { useMemo, useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm, Controller } from "react-hook-form";
import {
  contentApi,
  type EducationalCategory,
  type EducationalContent,
} from "@/api/content.api";
import { productsApi } from "@/api/products.api";
import { uploadsApi, isValidFileSize, isValidImageType, isValidVideoType } from "@/api/uploads.api";
import {
  catalogApi,
  type BrandWithDevices,
  type CategoryTree,
  type Device,
} from "@/api/catalog.api";
import { toast } from "sonner";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogDescription,
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
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Plus,
  MoreHorizontal,
  Pencil,
  Trash2,
  Loader2,
  BookOpen,
  FolderTree,
  Eye,
  Heart,
  Share2,
  CheckCircle,
  Search,
  X,
  Upload,
} from "lucide-react";
import { formatDate } from "@/lib/utils";

// ══════════════════════════════════════════════════════════════
// Form Types
// ══════════════════════════════════════════════════════════════

type CategoryFormData = {
  name: string;
  nameAr: string;
  slug: string;
  description: string;
  descriptionAr: string;
  icon: string;
  image: string;
  sortOrder: number;
  isActive: boolean;
};

type ContentFormData = {
  title: string;
  titleAr: string;
  slug: string;
  categoryId: string;
  type: "article" | "video" | "tutorial" | "tip" | "guide";
  excerpt: string;
  excerptAr: string;
  content: string;
  contentAr: string;
  featuredImage: string;
  videoUrl: string;
  videoDuration: number;
  scope: "general" | "contextual" | "hybrid";
  relatedProducts: string[];
  relatedContent: string[];
  targetingProducts: string[];
  targetingCategories: string[];
  targetingBrands: string[];
  targetingDevices: string[];
  targetingIntentTags: string;
  attachments: string[];
  tags: string;
  metaTitle: string;
  metaDescription: string;
  status: "draft" | "published" | "archived";
  isFeatured: boolean;
  readingTime: number;
  difficulty: "beginner" | "intermediate" | "advanced";
};

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function EducationalContentPage() {
  const queryClient = useQueryClient();
  const [activeTab, setActiveTab] = useState("categories");

  // Dialog states
  const [isCategoryDialogOpen, setIsCategoryDialogOpen] = useState(false);
  const [isContentDialogOpen, setIsContentDialogOpen] = useState(false);

  const [selectedCategory, setSelectedCategory] =
    useState<EducationalCategory | null>(null);
  const [selectedContent, setSelectedContent] =
    useState<EducationalContent | null>(null);
  const [isEditing, setIsEditing] = useState(false);

  // Filters
  type ContentFilters = {
    categoryId: string;
    type: string;
    scope: "" | "general" | "contextual" | "hybrid";
    status: string;
    featured: boolean | undefined;
    search: string;
    page: number;
    limit: number;
  };

  const [contentFilters, setContentFilters] = useState<ContentFilters>({
    categoryId: "",
    type: "",
    scope: "",
    status: "",
    featured: undefined as boolean | undefined,
    search: "",
    page: 1,
    limit: 20,
  });

  const ALL_FILTER_VALUE = "__all__";

  // ─────────────────────────────────────────
  // Queries
  // ─────────────────────────────────────────

  const { data: categories = [], isLoading: categoriesLoading } = useQuery({
    queryKey: ["educational-categories"],
    queryFn: () => contentApi.getEducationalCategories(false),
  });

  const { data: contentData, isLoading: contentLoading } = useQuery({
    queryKey: ["educational-content", contentFilters],
    queryFn: () => {
      const { scope, ...restFilters } = contentFilters;
      return contentApi.getEducationalContent({
        ...restFilters,
        ...(scope ? { scope } : {}),
      });
    },
  });

  const { data: productsData, isLoading: productsLoading } = useQuery({
    queryKey: ["products-for-education-targeting"],
    queryFn: () => productsApi.getAll({ page: 1, limit: 1000 }),
  });

  const { data: brandsData = [], isLoading: brandsLoading } = useQuery<
    BrandWithDevices[]
  >({
    queryKey: ["brands-for-education-targeting"],
    queryFn: () => catalogApi.getAllBrands(),
  });

  const { data: devicesData = [], isLoading: devicesLoading } = useQuery<
    Device[]
  >({
    queryKey: ["devices-for-education-targeting"],
    queryFn: () => catalogApi.getDevices({ limit: 1000 }),
  });

  const { data: allContentData, isLoading: allContentLoading } = useQuery({
    queryKey: ["all-educational-content-for-relations", isContentDialogOpen],
    queryFn: () =>
      contentApi.getEducationalContent({
        status: "",
        page: 1,
        limit: 1000,
      }),
    enabled: isContentDialogOpen,
  });

  const { data: categoryTreeData, isLoading: catalogCategoriesLoading } = useQuery({
    queryKey: ["catalog-category-tree-for-education-targeting"],
    queryFn: () => catalogApi.getCategoryTree(),
  });

  const content = contentData?.data || [];
  const totalContent = contentData?.total || 0;
  const productOptions = productsData?.items || [];

  const flattenCategoryTree = (items: CategoryTree[]): CategoryTree[] => {
    const output: CategoryTree[] = [];
    const traverse = (nodes: CategoryTree[]) => {
      nodes.forEach((node) => {
        output.push(node);
        if (Array.isArray(node.children) && node.children.length > 0) {
          traverse(node.children);
        }
      });
    };
    traverse(items);
    return output;
  };

  const catalogCategoryOptions = useMemo(
    () => flattenCategoryTree(categoryTreeData || []),
    [categoryTreeData],
  );

  const [productPickerSearch, setProductPickerSearch] = useState("");
  const [categoryPickerSearch, setCategoryPickerSearch] = useState("");
  const [brandPickerSearch, setBrandPickerSearch] = useState("");
  const [devicePickerSearch, setDevicePickerSearch] = useState("");
  const [relatedContentSearch, setRelatedContentSearch] = useState("");
  const [uploadError, setUploadError] = useState<string | null>(null);
  const [isUploadingFeaturedImage, setIsUploadingFeaturedImage] = useState(false);
  const [isUploadingVideo, setIsUploadingVideo] = useState(false);
  const [isUploadingAttachments, setIsUploadingAttachments] = useState(false);

  const filteredProductOptions = useMemo(() => {
    const keyword = productPickerSearch.trim().toLowerCase();
    if (!keyword) return productOptions;
    return productOptions.filter((item) => {
      const name = (item.nameAr || item.name || "").toLowerCase();
      const sku = (item.sku || "").toLowerCase();
      return name.includes(keyword) || sku.includes(keyword);
    });
  }, [productOptions, productPickerSearch]);

  const filteredCatalogCategoryOptions = useMemo(() => {
    const keyword = categoryPickerSearch.trim().toLowerCase();
    if (!keyword) return catalogCategoryOptions;
    return catalogCategoryOptions.filter((item) => {
      const name = (item.nameAr || item.name || "").toLowerCase();
      const slug = (item.slug || "").toLowerCase();
      return name.includes(keyword) || slug.includes(keyword);
    });
  }, [catalogCategoryOptions, categoryPickerSearch]);

  const filteredBrands = useMemo(() => {
    const keyword = brandPickerSearch.trim().toLowerCase();
    if (!keyword) return brandsData;
    return brandsData.filter((item) => {
      const name = (item.nameAr || item.name || "").toLowerCase();
      const slug = (item.slug || "").toLowerCase();
      return name.includes(keyword) || slug.includes(keyword);
    });
  }, [brandsData, brandPickerSearch]);

  const filteredDevices = useMemo(() => {
    const keyword = devicePickerSearch.trim().toLowerCase();
    if (!keyword) return devicesData;
    return devicesData.filter((item) => {
      const name = (item.nameAr || item.name || "").toLowerCase();
      const slug = (item.slug || "").toLowerCase();
      return name.includes(keyword) || slug.includes(keyword);
    });
  }, [devicesData, devicePickerSearch]);

  const availableRelatedContent = useMemo(() => {
    const currentId = selectedContent?._id;
    const options = (allContentData?.data || []).filter((item) => item._id !== currentId);
    const keyword = relatedContentSearch.trim().toLowerCase();
    if (!keyword) return options;
    return options.filter((item) => {
      const title = (item.titleAr || item.title || "").toLowerCase();
      const slug = (item.slug || "").toLowerCase();
      return title.includes(keyword) || slug.includes(keyword);
    });
  }, [allContentData?.data, relatedContentSearch, selectedContent?._id]);

  // Stats
  const activeCategories = categories.filter((c) => c.isActive).length;
  const publishedContent = content.filter(
    (c) => c.status === "published"
  ).length;
  const featuredContent = content.filter((c) => c.isFeatured).length;

  // ─────────────────────────────────────────
  // Category Mutations
  // ─────────────────────────────────────────

  const createCategoryMutation = useMutation({
    mutationFn: (
      data: Omit<
        EducationalCategory,
        "_id" | "contentCount" | "createdAt" | "updatedAt"
      >
    ) => contentApi.createEducationalCategory(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["educational-categories"] });
      setIsCategoryDialogOpen(false);
      toast.success("تم إنشاء الفئة بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateCategoryMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: Partial<EducationalCategory>;
    }) => contentApi.updateEducationalCategory(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["educational-categories"] });
      setIsCategoryDialogOpen(false);
      setSelectedCategory(null);
      toast.success("تم تحديث الفئة بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const deleteCategoryMutation = useMutation({
    mutationFn: (id: string) => contentApi.deleteEducationalCategory(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["educational-categories"] });
      toast.success("تم حذف الفئة");
    },
  });

  // ─────────────────────────────────────────
  // Content Mutations
  // ─────────────────────────────────────────

  const createContentMutation = useMutation({
    mutationFn: (
      data: Omit<
        EducationalContent,
        | "_id"
        | "viewCount"
        | "likeCount"
        | "shareCount"
        | "createdAt"
        | "updatedAt"
        | "createdBy"
        | "updatedBy"
      >
    ) => contentApi.createEducationalContent(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["educational-content"] });
      queryClient.invalidateQueries({ queryKey: ["educational-categories"] });
      setIsContentDialogOpen(false);
      toast.success("تم إنشاء المحتوى بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateContentMutation = useMutation({
    mutationFn: ({
      id,
      data,
    }: {
      id: string;
      data: Partial<EducationalContent>;
    }) => contentApi.updateEducationalContent(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["educational-content"] });
      setIsContentDialogOpen(false);
      setSelectedContent(null);
      toast.success("تم تحديث المحتوى بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const publishContentMutation = useMutation({
    mutationFn: (id: string) => contentApi.publishEducationalContent(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["educational-content"] });
      toast.success("تم نشر المحتوى بنجاح");
    },
  });

  const deleteContentMutation = useMutation({
    mutationFn: (id: string) => contentApi.deleteEducationalContent(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["educational-content"] });
      queryClient.invalidateQueries({ queryKey: ["educational-categories"] });
      toast.success("تم حذف المحتوى");
    },
  });

  const isSavingContent =
    createContentMutation.isPending || updateContentMutation.isPending;

  // ─────────────────────────────────────────
  // Forms
  // ─────────────────────────────────────────

  const categoryForm = useForm<CategoryFormData>({
    defaultValues: {
      name: "",
      nameAr: "",
      slug: "",
      description: "",
      descriptionAr: "",
      icon: "",
      image: "",
      sortOrder: 0,
      isActive: true,
    },
  });

  const contentForm = useForm<ContentFormData>({
    defaultValues: {
      title: "",
      titleAr: "",
      slug: "",
      categoryId: "",
      type: "article",
      excerpt: "",
      excerptAr: "",
      content: "",
      contentAr: "",
      featuredImage: "",
      videoUrl: "",
      videoDuration: 0,
      scope: "general",
      relatedProducts: [],
      relatedContent: [],
      targetingProducts: [],
      targetingCategories: [],
      targetingBrands: [],
      targetingDevices: [],
      targetingIntentTags: "",
      attachments: [],
      tags: "",
      metaTitle: "",
      metaDescription: "",
      status: "draft",
      isFeatured: false,
      readingTime: 0,
      difficulty: "beginner",
    },
  });

  const parseCsv = (value: string): string[] =>
    value
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean);

  const toIdList = (items?: unknown[]): string[] => {
    if (!Array.isArray(items)) return [];
    return items
      .map((item: any) => {
        if (!item) return "";
        if (typeof item === "string") return item;
        return item._id || item.id || "";
      })
      .filter(Boolean);
  };

  const toggleArraySelection = (
    field:
      | "relatedProducts"
      | "relatedContent"
      | "targetingProducts"
      | "targetingCategories"
      | "targetingBrands"
      | "targetingDevices",
    id: string,
    checked: boolean,
  ) => {
    const current = contentForm.getValues(field) || [];
    const next = checked
      ? Array.from(new Set([...current, id]))
      : current.filter((item) => item !== id);
    contentForm.setValue(field, next, { shouldDirty: true, shouldTouch: true });
  };

  // ─────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────

  const handleCreateCategory = () => {
    setIsEditing(false);
    setSelectedCategory(null);
    categoryForm.reset();
    setIsCategoryDialogOpen(true);
  };

  const handleEditCategory = (category: EducationalCategory) => {
    setIsEditing(true);
    setSelectedCategory(category);
    categoryForm.reset({
      name: category.name,
      nameAr: category.nameAr || "",
      slug: category.slug,
      description: category.description || "",
      descriptionAr: category.descriptionAr || "",
      icon: category.icon || "",
      image: category.image || "",
      sortOrder: category.sortOrder,
      isActive: category.isActive,
    });
    setIsCategoryDialogOpen(true);
  };

  const handleDeleteCategory = (id: string) => {
    if (confirm("هل أنت متأكد من حذف هذه الفئة؟")) {
      deleteCategoryMutation.mutate(id);
    }
  };

  const handleCategorySubmit = (data: CategoryFormData) => {
    if (isEditing && selectedCategory) {
      updateCategoryMutation.mutate({ id: selectedCategory._id, data });
    } else {
      createCategoryMutation.mutate(data);
    }
  };

  const handleCreateContent = () => {
    setIsEditing(false);
    setSelectedContent(null);
    contentForm.reset();
    setProductPickerSearch("");
    setCategoryPickerSearch("");
    setBrandPickerSearch("");
    setDevicePickerSearch("");
    setRelatedContentSearch("");
    setUploadError(null);
    setIsContentDialogOpen(true);
  };

  const handleEditContent = (content: EducationalContent) => {
    setIsEditing(true);
    setSelectedContent(content);
    const categoryId =
      typeof content.categoryId === "string"
        ? content.categoryId
        : content.categoryId._id;
    const targeting = (content as any).targeting || {};
    setProductPickerSearch("");
    setCategoryPickerSearch("");
    setBrandPickerSearch("");
    setDevicePickerSearch("");
    setRelatedContentSearch("");
    setUploadError(null);
    contentForm.reset({
      title: content.title,
      titleAr: content.titleAr || "",
      slug: content.slug,
      categoryId,
      type: content.type,
      excerpt: content.excerpt || "",
      excerptAr: content.excerptAr || "",
      content: content.content,
      contentAr: content.contentAr || "",
      featuredImage: content.featuredImage || "",
      videoUrl: content.videoUrl || "",
      videoDuration: content.videoDuration || 0,
      scope: content.scope || "general",
      relatedProducts: toIdList(content.relatedProducts as any[]),
      relatedContent: toIdList(content.relatedContent as any[]),
      targetingProducts: toIdList(targeting.products),
      targetingCategories: toIdList(targeting.categories),
      targetingBrands: toIdList(targeting.brands),
      targetingDevices: toIdList(targeting.devices),
      targetingIntentTags: Array.isArray(targeting.intentTags)
        ? targeting.intentTags.join(", ")
        : "",
      attachments: Array.isArray(content.attachments)
        ? content.attachments
        : [],
      tags: content.tags.join(", "),
      metaTitle: content.metaTitle || "",
      metaDescription: content.metaDescription || "",
      status: content.status,
      isFeatured: content.isFeatured,
      readingTime: content.readingTime || 0,
      difficulty: content.difficulty,
    });
    setIsContentDialogOpen(true);
  };

  const handleDeleteContent = (id: string) => {
    if (confirm("هل أنت متأكد من حذف هذا المحتوى؟")) {
      deleteContentMutation.mutate(id);
    }
  };

  const handlePublishContent = (id: string) => {
    publishContentMutation.mutate(id);
  };

  const handleContentSubmit = (data: ContentFormData) => {
    const {
      relatedProducts: relatedProductsInput,
      relatedContent: relatedContentInput,
      targetingProducts: targetingProductsInput,
      targetingCategories: targetingCategoriesInput,
      targetingBrands,
      targetingDevices,
      targetingIntentTags,
      ...baseData
    } = data;

    const tags = parseCsv(baseData.tags);
    const relatedProducts = relatedProductsInput;
    const relatedContent = relatedContentInput;
    const parsedTargetingProducts = targetingProductsInput;
    const parsedTargetingCategories = targetingCategoriesInput;
    const parsedTargetingBrands = targetingBrands;
    const parsedTargetingDevices = targetingDevices;
    const parsedTargetingIntentTags = parseCsv(targetingIntentTags);

    const hasTargeting =
      relatedProducts.length > 0 ||
      parsedTargetingProducts.length > 0 ||
      parsedTargetingCategories.length > 0 ||
      parsedTargetingBrands.length > 0 ||
      parsedTargetingDevices.length > 0 ||
      parsedTargetingIntentTags.length > 0;

    if (baseData.scope === "contextual" && !hasTargeting) {
      toast.error(
        "المحتوى السياقي يحتاج استهداف واحد على الأقل (منتج/فئة/علامة/جهاز/وسم)",
      );
      return;
    }

    const contentData = {
      ...baseData,
      tags,
      attachments: baseData.attachments || [],
      ...(relatedProducts.length > 0 && { relatedProducts }),
      ...(relatedContent.length > 0 && { relatedContent }),
      ...(hasTargeting && {
        targeting: {
          ...(parsedTargetingProducts.length > 0 && {
            products: parsedTargetingProducts,
          }),
          ...(parsedTargetingCategories.length > 0 && {
            categories: parsedTargetingCategories,
          }),
          ...(parsedTargetingBrands.length > 0 && {
            brands: parsedTargetingBrands,
          }),
          ...(parsedTargetingDevices.length > 0 && {
            devices: parsedTargetingDevices,
          }),
          ...(parsedTargetingIntentTags.length > 0 && {
            intentTags: parsedTargetingIntentTags,
          }),
        },
      }),
    };

    if (isEditing && selectedContent) {
      updateContentMutation.mutate({
        id: selectedContent._id,
        data: contentData,
      });
    } else {
      createContentMutation.mutate(contentData);
    }
  };

  const selectedRelatedProducts = contentForm.watch("relatedProducts") || [];
  const selectedTargetingProducts = contentForm.watch("targetingProducts") || [];
  const selectedTargetingCategories =
    contentForm.watch("targetingCategories") || [];
  const selectedRelatedContent = contentForm.watch("relatedContent") || [];
  const selectedTargetingBrands = contentForm.watch("targetingBrands") || [];
  const selectedTargetingDevices = contentForm.watch("targetingDevices") || [];
  const selectedAttachments = contentForm.watch("attachments") || [];
  const featuredImageValue = contentForm.watch("featuredImage") || "";
  const metaTitleValue = contentForm.watch("metaTitle") || "";
  const metaDescriptionValue = contentForm.watch("metaDescription") || "";
  const scopeValue = contentForm.watch("scope") || "general";

  const isImageUrl = (url: string) =>
    /\.(jpg|jpeg|png|gif|webp|svg)(\?.*)?$/i.test(url);
  const isVideoUrl = (url: string) =>
    /\.(mp4|webm|mov|m4v)(\?.*)?$/i.test(url);

  const handleUploadFeaturedImage = async (file?: File) => {
    if (!file) return;

    if (!isValidImageType(file)) {
      setUploadError("نوع الصورة غير مدعوم. المسموح: JPEG, PNG, GIF, WebP, SVG");
      return;
    }
    if (!isValidFileSize(file, 10)) {
      setUploadError("حجم الصورة كبير جداً. الحد الأقصى 10MB");
      return;
    }

    setUploadError(null);
    setIsUploadingFeaturedImage(true);
    try {
      const result = await uploadsApi.uploadSingle(file, "educational/featured");
      contentForm.setValue("featuredImage", result.url, {
        shouldDirty: true,
        shouldTouch: true,
      });
    } catch (error: any) {
      setUploadError(error?.response?.data?.message || "فشل رفع الصورة");
    } finally {
      setIsUploadingFeaturedImage(false);
    }
  };

  const handleUploadVideo = async (file?: File) => {
    if (!file) return;

    if (!isValidVideoType(file)) {
      setUploadError("نوع الفيديو غير مدعوم. المسموح: MP4, WebM, MOV");
      return;
    }
    if (!isValidFileSize(file, 50)) {
      setUploadError("حجم الفيديو كبير جداً. الحد الأقصى 50MB");
      return;
    }

    setUploadError(null);
    setIsUploadingVideo(true);
    try {
      const result = await uploadsApi.uploadSingle(file, "educational/videos");
      contentForm.setValue("videoUrl", result.url, {
        shouldDirty: true,
        shouldTouch: true,
      });
    } catch (error: any) {
      setUploadError(error?.response?.data?.message || "فشل رفع الفيديو");
    } finally {
      setIsUploadingVideo(false);
    }
  };

  const handleUploadAttachments = async (files: FileList | null) => {
    const selectedFiles = Array.from(files || []);
    if (selectedFiles.length === 0) return;

    for (const file of selectedFiles) {
      const validType = isValidImageType(file) || isValidVideoType(file);
      if (!validType) {
        setUploadError(`الملف ${file.name} غير مدعوم`);
        return;
      }
      const maxSize = isValidVideoType(file) ? 50 : 10;
      if (!isValidFileSize(file, maxSize)) {
        setUploadError(`حجم الملف ${file.name} يتجاوز الحد ${maxSize}MB`);
        return;
      }
    }

    setUploadError(null);
    setIsUploadingAttachments(true);
    try {
      const uploaded = await uploadsApi.uploadMultiple(
        selectedFiles,
        "educational/attachments",
      );
      const next = Array.from(
        new Set([...(contentForm.getValues("attachments") || []), ...uploaded.map((item) => item.url)]),
      );
      contentForm.setValue("attachments", next, {
        shouldDirty: true,
        shouldTouch: true,
      });
    } catch (error: any) {
      setUploadError(error?.response?.data?.message || "فشل رفع المرفقات");
    } finally {
      setIsUploadingAttachments(false);
    }
  };

  // ─────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold">المحتوى التعليمي</h1>
        <p className="text-muted-foreground text-sm">
          إدارة الفئات والمحتوى التعليمي
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                <FolderTree className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">الفئات</p>
                <p className="text-2xl font-bold">
                  {activeCategories} / {categories.length}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                <BookOpen className="h-5 w-5 text-green-600 dark:text-green-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">المحتوى</p>
                <p className="text-2xl font-bold">{totalContent}</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                <CheckCircle className="h-5 w-5 text-purple-600 dark:text-purple-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">المنشور</p>
                <p className="text-2xl font-bold">{publishedContent}</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-orange-100 dark:bg-orange-900/30 rounded-lg">
                <Heart className="h-5 w-5 text-orange-600 dark:text-orange-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">المميز</p>
                <p className="text-2xl font-bold">{featuredContent}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="categories" className="flex items-center gap-2">
            <FolderTree className="h-4 w-4" />
            الفئات
          </TabsTrigger>
          <TabsTrigger value="content" className="flex items-center gap-2">
            <BookOpen className="h-4 w-4" />
            المحتوى
          </TabsTrigger>
        </TabsList>

        {/* Categories Tab */}
        <TabsContent value="categories">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>الفئات التعليمية</CardTitle>
                <Button onClick={handleCreateCategory}>
                  <Plus className="h-4 w-4 ms-2" />
                  إضافة فئة
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {categoriesLoading ? (
                <div className="flex justify-center py-8">
                  <Loader2 className="h-8 w-8 animate-spin" />
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>الاسم</TableHead>
                      <TableHead>المعرّف (Slug)</TableHead>
                      <TableHead>عدد المحتوى</TableHead>
                      <TableHead>الترتيب</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead>الإجراءات</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {categories.map((category) => (
                      <TableRow key={category._id}>
                        <TableCell>
                          <div>
                            <div className="font-medium">{category.name}</div>
                            {category.nameAr && (
                              <div className="text-sm text-muted-foreground">
                                {category.nameAr}
                              </div>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          <code className="text-xs">{category.slug}</code>
                        </TableCell>
                        <TableCell>{category.contentCount}</TableCell>
                        <TableCell>{category.sortOrder}</TableCell>
                        <TableCell>
                          {category.isActive ? (
                            <Badge variant="success">نشط</Badge>
                          ) : (
                            <Badge variant="secondary">معطل</Badge>
                          )}
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
                                onClick={() => handleEditCategory(category)}
                              >
                                <Pencil className="h-4 w-4 ms-2" />
                                تعديل
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                onClick={() =>
                                  handleDeleteCategory(category._id)
                                }
                                className="text-red-600"
                              >
                                <Trash2 className="h-4 w-4 ms-2" />
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
        </TabsContent>

        {/* Content Tab */}
        <TabsContent value="content">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>المحتوى التعليمي</CardTitle>
                <Button onClick={handleCreateContent}>
                  <Plus className="h-4 w-4 ms-2" />
                  إضافة محتوى
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {/* Filters */}
              <div className="grid grid-cols-1 md:grid-cols-6 gap-4 mb-4">
                <Select
                  value={contentFilters.categoryId || ALL_FILTER_VALUE}
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      categoryId: value === ALL_FILTER_VALUE ? "" : value,
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="جميع الفئات" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value={ALL_FILTER_VALUE}>جميع الفئات</SelectItem>
                    {categories.map((cat) => (
                      <SelectItem key={cat._id} value={cat._id}>
                        {cat.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>

                <Select
                  value={contentFilters.type || ALL_FILTER_VALUE}
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      type: value === ALL_FILTER_VALUE ? "" : value,
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="جميع الأنواع" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value={ALL_FILTER_VALUE}>جميع الأنواع</SelectItem>
                    <SelectItem value="article">مقال</SelectItem>
                    <SelectItem value="video">فيديو</SelectItem>
                    <SelectItem value="tutorial">درس</SelectItem>
                    <SelectItem value="tip">نصيحة</SelectItem>
                    <SelectItem value="guide">دليل</SelectItem>
                  </SelectContent>
                </Select>

                <Select
                  value={contentFilters.scope || ALL_FILTER_VALUE}
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      scope:
                        (value === ALL_FILTER_VALUE
                          ? ""
                          : value) as ContentFilters["scope"],
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="كل النطاقات" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value={ALL_FILTER_VALUE}>كل النطاقات</SelectItem>
                    <SelectItem value="general">عام</SelectItem>
                    <SelectItem value="contextual">مرتبط بسياق</SelectItem>
                    <SelectItem value="hybrid">هجين</SelectItem>
                  </SelectContent>
                </Select>

                <Select
                  value={contentFilters.status || ALL_FILTER_VALUE}
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      status: value === ALL_FILTER_VALUE ? "" : value,
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="جميع الحالات" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value={ALL_FILTER_VALUE}>جميع الحالات</SelectItem>
                    <SelectItem value="draft">مسودة</SelectItem>
                    <SelectItem value="published">منشور</SelectItem>
                    <SelectItem value="archived">مؤرشف</SelectItem>
                  </SelectContent>
                </Select>

                <Select
                  value={
                    contentFilters.featured === undefined
                      ? ALL_FILTER_VALUE
                      : contentFilters.featured.toString()
                  }
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      featured:
                        value === ALL_FILTER_VALUE
                          ? undefined
                          : value === "true",
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="الكل" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value={ALL_FILTER_VALUE}>الكل</SelectItem>
                    <SelectItem value="true">مميز فقط</SelectItem>
                    <SelectItem value="false">غير مميز</SelectItem>
                  </SelectContent>
                </Select>

                <Input
                  placeholder="بحث..."
                  value={contentFilters.search}
                  onChange={(e) =>
                    setContentFilters({
                      ...contentFilters,
                      search: e.target.value,
                      page: 1,
                    })
                  }
                />
              </div>

              {contentLoading ? (
                <div className="flex justify-center py-8">
                  <Loader2 className="h-8 w-8 animate-spin" />
                </div>
              ) : (
                <>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead>العنوان</TableHead>
                        <TableHead>الفئة</TableHead>
                        <TableHead>النوع</TableHead>
                        <TableHead>النطاق</TableHead>
                        <TableHead>الحالة</TableHead>
                        <TableHead>الإحصائيات</TableHead>
                        <TableHead>التاريخ</TableHead>
                        <TableHead>الإجراءات</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {content.map((item) => {
                        const category =
                          typeof item.categoryId === "string"
                            ? categories.find((c) => c._id === item.categoryId)
                            : item.categoryId;

                        return (
                          <TableRow key={item._id}>
                            <TableCell>
                              <div>
                                <div className="font-medium flex items-center gap-2">
                                  {item.title}
                                  {item.isFeatured && (
                                    <Badge
                                      variant="warning"
                                      className="text-xs"
                                    >
                                      مميز
                                    </Badge>
                                  )}
                                </div>
                                {item.titleAr && (
                                  <div className="text-sm text-muted-foreground">
                                    {item.titleAr}
                                  </div>
                                )}
                              </div>
                            </TableCell>
                            <TableCell>
                              {category?.name || "غير محدد"}
                            </TableCell>
                            <TableCell>
                              <Badge variant="outline">
                                {item.type === "article" && "مقال"}
                                {item.type === "video" && "فيديو"}
                                {item.type === "tutorial" && "درس"}
                                {item.type === "tip" && "نصيحة"}
                                {item.type === "guide" && "دليل"}
                              </Badge>
                            </TableCell>
                            <TableCell>
                              <Badge variant="outline">
                                {(item.scope || "general") === "general" &&
                                  "عام"}
                                {item.scope === "contextual" && "مرتبط"}
                                {item.scope === "hybrid" && "هجين"}
                              </Badge>
                            </TableCell>
                            <TableCell>
                              {item.status === "published" && (
                                <Badge variant="success">منشور</Badge>
                              )}
                              {item.status === "draft" && (
                                <Badge variant="secondary">مسودة</Badge>
                              )}
                              {item.status === "archived" && (
                                <Badge variant="destructive">مؤرشف</Badge>
                              )}
                            </TableCell>
                            <TableCell>
                              <div className="flex items-center gap-3 text-sm text-muted-foreground">
                                <div className="flex items-center gap-1">
                                  <Eye className="h-3 w-3" />
                                  {item.viewCount}
                                </div>
                                <div className="flex items-center gap-1">
                                  <Heart className="h-3 w-3" />
                                  {item.likeCount}
                                </div>
                                <div className="flex items-center gap-1">
                                  <Share2 className="h-3 w-3" />
                                  {item.shareCount}
                                </div>
                              </div>
                            </TableCell>
                            <TableCell>
                              <div className="text-sm text-muted-foreground">
                                {formatDate(item.createdAt)}
                              </div>
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
                                    onClick={() => handleEditContent(item)}
                                  >
                                    <Pencil className="h-4 w-4 ms-2" />
                                    تعديل
                                  </DropdownMenuItem>
                                  {item.status !== "published" && (
                                    <DropdownMenuItem
                                      onClick={() =>
                                        handlePublishContent(item._id)
                                      }
                                    >
                                      <CheckCircle className="h-4 w-4 ms-2" />
                                      نشر
                                    </DropdownMenuItem>
                                  )}
                                  <DropdownMenuItem
                                    onClick={() =>
                                      handleDeleteContent(item._id)
                                    }
                                    className="text-red-600"
                                  >
                                    <Trash2 className="h-4 w-4 ms-2" />
                                    حذف
                                  </DropdownMenuItem>
                                </DropdownMenuContent>
                              </DropdownMenu>
                            </TableCell>
                          </TableRow>
                        );
                      })}
                    </TableBody>
                  </Table>

                  {/* Pagination */}
                  {totalContent > contentFilters.limit && (
                    <div className="flex items-center justify-between mt-4">
                      <div className="text-sm text-muted-foreground">
                        عرض {content.length} من {totalContent}
                      </div>
                      <div className="flex gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          disabled={contentFilters.page === 1}
                          onClick={() =>
                            setContentFilters({
                              ...contentFilters,
                              page: contentFilters.page - 1,
                            })
                          }
                        >
                          السابق
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          disabled={content.length < contentFilters.limit}
                          onClick={() =>
                            setContentFilters({
                              ...contentFilters,
                              page: contentFilters.page + 1,
                            })
                          }
                        >
                          التالي
                        </Button>
                      </div>
                    </div>
                  )}
                </>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Category Dialog */}
      <Dialog
        open={isCategoryDialogOpen}
        onOpenChange={setIsCategoryDialogOpen}
      >
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل الفئة" : "إضافة فئة جديدة"}
            </DialogTitle>
            <DialogDescription>أدخل معلومات الفئة التعليمية</DialogDescription>
          </DialogHeader>
          <form onSubmit={categoryForm.handleSubmit(handleCategorySubmit)}>
            <div className="grid gap-4 py-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="name">الاسم (EN)</Label>
                  <Input
                    id="name"
                    {...categoryForm.register("name", { required: true })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="nameAr">الاسم (AR)</Label>
                  <Input id="nameAr" {...categoryForm.register("nameAr")} />
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="slug">المعرّف (Slug)</Label>
                <Input
                  id="slug"
                  {...categoryForm.register("slug", { required: true })}
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="description">الوصف (EN)</Label>
                  <Textarea
                    id="description"
                    {...categoryForm.register("description")}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="descriptionAr">الوصف (AR)</Label>
                  <Textarea
                    id="descriptionAr"
                    {...categoryForm.register("descriptionAr")}
                  />
                </div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="icon">الأيقونة</Label>
                  <Input id="icon" {...categoryForm.register("icon")} />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="image">الصورة (URL)</Label>
                  <Input id="image" {...categoryForm.register("image")} />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="sortOrder">الترتيب</Label>
                  <Input
                    id="sortOrder"
                    type="number"
                    {...categoryForm.register("sortOrder", {
                      valueAsNumber: true,
                    })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="isActive">الحالة</Label>
                  <div className="flex items-center space-x-2 h-10">
                    <Controller
                      name="isActive"
                      control={categoryForm.control}
                      render={({ field }) => (
                        <Switch
                          checked={field.value}
                          onCheckedChange={field.onChange}
                        />
                      )}
                    />
                    <Label htmlFor="isActive">نشط</Label>
                  </div>
                </div>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsCategoryDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button type="submit">{isEditing ? "تحديث" : "إنشاء"}</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Content Dialog */}
      <Dialog open={isContentDialogOpen} onOpenChange={setIsContentDialogOpen}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل المحتوى" : "إضافة محتوى جديد"}
            </DialogTitle>
            <DialogDescription>أدخل معلومات المحتوى التعليمي</DialogDescription>
          </DialogHeader>
          <form onSubmit={contentForm.handleSubmit(handleContentSubmit)}>
            <div className="grid gap-4 py-4">
              {/* Basic Info */}
              <details open className="rounded-lg border border-border bg-muted/10 p-4">
                <summary className="cursor-pointer select-none font-semibold text-sm">
                  معلومات أساسية
                </summary>
                <div className="space-y-4 mt-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="title">العنوان (EN)</Label>
                    <Input
                      id="title"
                      {...contentForm.register("title", { required: true })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="titleAr">العنوان (AR)</Label>
                    <Input id="titleAr" {...contentForm.register("titleAr")} />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="slug">المعرّف (Slug)</Label>
                    <Input
                      id="slug"
                      {...contentForm.register("slug", { required: true })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="categoryId">الفئة</Label>
                    <Controller
                      name="categoryId"
                      control={contentForm.control}
                      rules={{ required: true }}
                      render={({ field }) => (
                        <Select
                          value={field.value}
                          onValueChange={field.onChange}
                        >
                          <SelectTrigger>
                            <SelectValue placeholder="اختر الفئة" />
                          </SelectTrigger>
                          <SelectContent>
                            {categories.map((cat) => (
                              <SelectItem key={cat._id} value={cat._id}>
                                {cat.name}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      )}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="type">النوع</Label>
                    <Controller
                      name="type"
                      control={contentForm.control}
                      render={({ field }) => (
                        <Select
                          value={field.value}
                          onValueChange={field.onChange}
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="article">مقال</SelectItem>
                            <SelectItem value="video">فيديو</SelectItem>
                            <SelectItem value="tutorial">درس</SelectItem>
                            <SelectItem value="tip">نصيحة</SelectItem>
                            <SelectItem value="guide">دليل</SelectItem>
                          </SelectContent>
                        </Select>
                      )}
                    />
                  </div>
                </div>
                </div>
              </details>

              {/* Content */}
              <details open className="rounded-lg border border-border bg-muted/10 p-4">
                <summary className="cursor-pointer select-none font-semibold text-sm">
                  المحتوى
                </summary>
                <div className="space-y-4 mt-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="excerpt">الملخص (EN)</Label>
                    <Textarea
                      id="excerpt"
                      {...contentForm.register("excerpt")}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="excerptAr">الملخص (AR)</Label>
                    <Textarea
                      id="excerptAr"
                      {...contentForm.register("excerptAr")}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="content">المحتوى (EN)</Label>
                    <Textarea
                      id="content"
                      rows={6}
                      {...contentForm.register("content", { required: true })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="contentAr">المحتوى (AR)</Label>
                    <Textarea
                      id="contentAr"
                      rows={6}
                      {...contentForm.register("contentAr")}
                    />
                  </div>
                </div>
                </div>
              </details>

              {/* Media */}
              <details open className="rounded-lg border border-border bg-muted/10 p-4">
                <summary className="cursor-pointer select-none font-semibold text-sm">
                  الوسائط
                </summary>
                <div className="space-y-4 mt-4">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="featuredImage">الصورة المميزة</Label>
                    {featuredImageValue ? (
                      <div className="space-y-2">
                        <div className="relative w-full h-36 border rounded-md overflow-hidden bg-muted/20">
                          <img
                            src={featuredImageValue}
                            alt="featured"
                            className="w-full h-full object-cover"
                          />
                        </div>
                        <div className="flex items-center gap-2">
                          <label className="inline-flex items-center gap-2 px-3 py-2 border rounded-md text-sm cursor-pointer hover:bg-muted/40">
                            <input
                              type="file"
                              accept="image/*"
                              className="hidden"
                              disabled={isUploadingFeaturedImage}
                              onChange={(e) =>
                                handleUploadFeaturedImage(e.target.files?.[0])
                              }
                            />
                            {isUploadingFeaturedImage ? (
                              <Loader2 className="h-4 w-4 animate-spin" />
                            ) : (
                              <Upload className="h-4 w-4" />
                            )}
                            تغيير
                          </label>
                          <Button
                            type="button"
                            variant="outline"
                            size="sm"
                            onClick={() =>
                              contentForm.setValue("featuredImage", "", {
                                shouldDirty: true,
                                shouldTouch: true,
                              })
                            }
                          >
                            <Trash2 className="h-4 w-4" />
                          </Button>
                        </div>
                      </div>
                    ) : (
                      <label className="flex items-center justify-center gap-2 px-3 py-4 border-2 border-dashed rounded-md text-sm cursor-pointer hover:bg-muted/30">
                        <input
                          type="file"
                          accept="image/*"
                          className="hidden"
                          disabled={isUploadingFeaturedImage}
                          onChange={(e) =>
                            handleUploadFeaturedImage(e.target.files?.[0])
                          }
                        />
                        {isUploadingFeaturedImage ? (
                          <Loader2 className="h-4 w-4 animate-spin" />
                        ) : (
                          <Upload className="h-4 w-4" />
                        )}
                        رفع صورة
                      </label>
                    )}
                    <Input
                      id="featuredImage"
                      placeholder="أو ألصق رابط الصورة مباشرة"
                      {...contentForm.register("featuredImage")}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="videoUrl">رابط الفيديو</Label>
                    <Input
                      id="videoUrl"
                      {...contentForm.register("videoUrl")}
                    />
                    <label className="inline-flex items-center gap-2 px-3 py-2 border rounded-md text-sm cursor-pointer hover:bg-muted/40">
                      <input
                        type="file"
                        accept="video/*"
                        className="hidden"
                        disabled={isUploadingVideo}
                        onChange={(e) => handleUploadVideo(e.target.files?.[0])}
                      />
                      {isUploadingVideo ? (
                        <Loader2 className="h-4 w-4 animate-spin" />
                      ) : (
                        <Upload className="h-4 w-4" />
                      )}
                      رفع فيديو واستخدام رابطه
                    </label>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="videoDuration">مدة الفيديو (ثانية)</Label>
                    <Input
                      id="videoDuration"
                      type="number"
                      {...contentForm.register("videoDuration", {
                        valueAsNumber: true,
                      })}
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <Label>المرفقات</Label>
                  <label className="inline-flex items-center gap-2 px-3 py-2 border rounded-md text-sm cursor-pointer hover:bg-muted/40">
                    <input
                      type="file"
                      className="hidden"
                      multiple
                      accept="image/*,video/*"
                      disabled={isUploadingAttachments}
                      onChange={(e) => handleUploadAttachments(e.target.files)}
                    />
                    {isUploadingAttachments ? (
                      <Loader2 className="h-4 w-4 animate-spin" />
                    ) : (
                      <Upload className="h-4 w-4" />
                    )}
                    إضافة مرفقات
                  </label>
                  {selectedAttachments.length > 0 && (
                    <div className="space-y-2 border rounded-md p-2 max-h-40 overflow-y-auto">
                      {selectedAttachments.map((url) => (
                        <div
                          key={url}
                          className="flex items-center justify-between gap-2 text-sm"
                        >
                          <a
                            href={url}
                            target="_blank"
                            rel="noreferrer"
                            className="truncate text-primary hover:underline"
                          >
                            {url.split("/").pop() || url}
                          </a>
                          {isImageUrl(url) && <Badge variant="outline">صورة</Badge>}
                          {isVideoUrl(url) && <Badge variant="outline">فيديو</Badge>}
                          <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={() =>
                              contentForm.setValue(
                                "attachments",
                                selectedAttachments.filter((item) => item !== url),
                                { shouldDirty: true, shouldTouch: true },
                              )
                            }
                          >
                            <X className="h-4 w-4" />
                          </Button>
                        </div>
                      ))}
                    </div>
                  )}
                  {selectedAttachments.length > 0 && (
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
                      {selectedAttachments.slice(0, 8).map((url) => (
                        <div
                          key={`preview-${url}`}
                          className="rounded-md border bg-background overflow-hidden"
                        >
                          {isImageUrl(url) ? (
                            <img
                              src={url}
                              alt={url.split("/").pop() || "attachment"}
                              className="w-full h-20 object-cover"
                            />
                          ) : (
                            <div className="h-20 flex items-center justify-center text-xs text-muted-foreground">
                              ملف مرفق
                            </div>
                          )}
                          <div className="px-2 py-1 text-[10px] truncate">
                            {url.split("/").pop() || url}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
                {uploadError && (
                  <p className="text-sm text-red-600 dark:text-red-400">{uploadError}</p>
                )}
                </div>
              </details>

              {/* Targeting */}
              <details open className="rounded-lg border border-border bg-muted/10 p-4">
                <summary className="cursor-pointer select-none font-semibold text-sm">
                  الربط والاستهداف
                </summary>
                <div className="space-y-4 mt-4">
                <p className="text-xs text-muted-foreground">
                  المنتجات المرتبطة = روابط مرئية داخل المحتوى. الاستهداف = قواعد ظهور المحتوى تلقائياً حسب السياق.
                </p>
                {scopeValue === "contextual" && (
                  <p className="text-xs text-amber-600 dark:text-amber-400">
                    ملاحظة: النطاق السياقي يتطلب على الأقل معيار استهداف واحد.
                  </p>
                )}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="scope">نطاق المحتوى</Label>
                    <Controller
                      name="scope"
                      control={contentForm.control}
                      render={({ field }) => (
                        <Select
                          value={field.value}
                          onValueChange={field.onChange}
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="general">عام</SelectItem>
                            <SelectItem value="contextual">
                              مرتبط بسياق
                            </SelectItem>
                            <SelectItem value="hybrid">هجين</SelectItem>
                          </SelectContent>
                        </Select>
                      )}
                    />
                  </div>
                  <div className="space-y-2 md:col-span-2">
                    <Label>منتجات مرتبطة</Label>
                    <div className="relative">
                      <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        placeholder="ابحث عن منتج بالاسم أو SKU"
                        value={productPickerSearch}
                        onChange={(e) => setProductPickerSearch(e.target.value)}
                        className="ps-10"
                      />
                      {productPickerSearch && (
                        <button
                          type="button"
                          onClick={() => setProductPickerSearch("")}
                          className="absolute end-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                        >
                          <X className="h-4 w-4" />
                        </button>
                      )}
                    </div>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-2 max-h-48 overflow-y-auto border rounded-md p-2">
                      {filteredProductOptions.map((product) => (
                        <label
                          key={`related-product-${product._id}`}
                          className="flex items-center gap-2 p-2 rounded hover:bg-muted/40 cursor-pointer"
                        >
                          <input
                            type="checkbox"
                            checked={selectedRelatedProducts.includes(product._id)}
                            onChange={(e) =>
                              toggleArraySelection(
                                "relatedProducts",
                                product._id,
                                e.target.checked,
                              )
                            }
                            className="w-4 h-4 rounded"
                          />
                          <span className="text-sm truncate" title={product.nameAr || product.name}>
                            {product.nameAr || product.name}
                          </span>
                        </label>
                      ))}
                    </div>
                    <p className="text-xs text-muted-foreground">
                      تم اختيار {selectedRelatedProducts.length} منتج
                    </p>
                    {productsLoading && (
                      <p className="text-xs text-muted-foreground">جاري تحميل المنتجات...</p>
                    )}
                  </div>
                </div>
                <div className="space-y-2">
                  <Label>محتوى تعليمي مرتبط</Label>
                  <div className="relative">
                    <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                      placeholder="ابحث بعنوان المحتوى أو slug"
                      value={relatedContentSearch}
                      onChange={(e) => setRelatedContentSearch(e.target.value)}
                      className="ps-10"
                    />
                    {relatedContentSearch && (
                      <button
                        type="button"
                        onClick={() => setRelatedContentSearch("")}
                        className="absolute end-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      >
                        <X className="h-4 w-4" />
                      </button>
                    )}
                  </div>
                  <div className="grid grid-cols-1 gap-2 max-h-44 overflow-y-auto border rounded-md p-2">
                    {availableRelatedContent.map((item) => (
                      <label
                        key={`related-content-${item._id}`}
                        className="flex items-center gap-2 p-2 rounded hover:bg-muted/40 cursor-pointer"
                      >
                        <input
                          type="checkbox"
                          checked={selectedRelatedContent.includes(item._id)}
                          onChange={(e) =>
                            toggleArraySelection(
                              "relatedContent",
                              item._id,
                              e.target.checked,
                            )
                          }
                          className="w-4 h-4 rounded"
                        />
                        <span className="text-sm truncate" title={item.titleAr || item.title}>
                          {item.titleAr || item.title}
                        </span>
                      </label>
                    ))}
                  </div>
                  <p className="text-xs text-muted-foreground">
                    تم اختيار {selectedRelatedContent.length} محتوى
                  </p>
                  {allContentLoading && (
                    <p className="text-xs text-muted-foreground">جاري تحميل المحتوى...</p>
                  )}
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="targetingProducts">استهداف منتجات</Label>
                    <div className="grid grid-cols-1 gap-2 max-h-48 overflow-y-auto border rounded-md p-2">
                      {filteredProductOptions.map((product) => (
                        <label
                          key={`targeting-product-${product._id}`}
                          className="flex items-center gap-2 p-2 rounded hover:bg-muted/40 cursor-pointer"
                        >
                          <input
                            type="checkbox"
                            checked={selectedTargetingProducts.includes(product._id)}
                            onChange={(e) =>
                              toggleArraySelection(
                                "targetingProducts",
                                product._id,
                                e.target.checked,
                              )
                            }
                            className="w-4 h-4 rounded"
                          />
                          <span className="text-sm truncate" title={product.nameAr || product.name}>
                            {product.nameAr || product.name}
                          </span>
                        </label>
                      ))}
                    </div>
                    <p className="text-xs text-muted-foreground">
                      تم اختيار {selectedTargetingProducts.length} منتج
                    </p>
                  </div>
                  <div className="space-y-2">
                    <Label>استهداف فئات</Label>
                    <div className="relative">
                      <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        placeholder="ابحث باسم الفئة أو slug"
                        value={categoryPickerSearch}
                        onChange={(e) => setCategoryPickerSearch(e.target.value)}
                        className="ps-10"
                      />
                      {categoryPickerSearch && (
                        <button
                          type="button"
                          onClick={() => setCategoryPickerSearch("")}
                          className="absolute end-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                        >
                          <X className="h-4 w-4" />
                        </button>
                      )}
                    </div>
                    <div className="grid grid-cols-1 gap-2 max-h-48 overflow-y-auto border rounded-md p-2">
                      {filteredCatalogCategoryOptions.map((item) => (
                        <label
                          key={`targeting-category-${item._id}`}
                          className="flex items-center gap-2 p-2 rounded hover:bg-muted/40 cursor-pointer"
                        >
                          <input
                            type="checkbox"
                            checked={selectedTargetingCategories.includes(item._id)}
                            onChange={(e) =>
                              toggleArraySelection(
                                "targetingCategories",
                                item._id,
                                e.target.checked,
                              )
                            }
                            className="w-4 h-4 rounded"
                          />
                          <span className="text-sm truncate" title={item.nameAr || item.name}>
                            {item.nameAr || item.name}
                          </span>
                        </label>
                      ))}
                    </div>
                    <p className="text-xs text-muted-foreground">
                      تم اختيار {selectedTargetingCategories.length} فئة
                    </p>
                    {catalogCategoriesLoading && (
                      <p className="text-xs text-muted-foreground">جاري تحميل الفئات...</p>
                    )}
                  </div>
                  <div className="space-y-2">
                    <Label>استهداف علامات تجارية</Label>
                    <div className="relative">
                      <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        placeholder="ابحث باسم العلامة"
                        value={brandPickerSearch}
                        onChange={(e) => setBrandPickerSearch(e.target.value)}
                        className="ps-10"
                      />
                    </div>
                    <div className="grid grid-cols-1 gap-2 max-h-44 overflow-y-auto border rounded-md p-2">
                      {filteredBrands.map((brand) => (
                        <label
                          key={`targeting-brand-${brand._id}`}
                          className="flex items-center gap-2 p-2 rounded hover:bg-muted/40 cursor-pointer"
                        >
                          <input
                            type="checkbox"
                            checked={selectedTargetingBrands.includes(brand._id)}
                            onChange={(e) =>
                              toggleArraySelection(
                                "targetingBrands",
                                brand._id,
                                e.target.checked,
                              )
                            }
                            className="w-4 h-4 rounded"
                          />
                          <span className="text-sm truncate" title={brand.nameAr || brand.name}>
                            {brand.nameAr || brand.name}
                          </span>
                        </label>
                      ))}
                    </div>
                    <p className="text-xs text-muted-foreground">
                      تم اختيار {selectedTargetingBrands.length} علامة
                    </p>
                    {brandsLoading && (
                      <p className="text-xs text-muted-foreground">جاري تحميل العلامات...</p>
                    )}
                  </div>
                  <div className="space-y-2">
                    <Label>استهداف أجهزة</Label>
                    <div className="relative">
                      <Search className="absolute start-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400" />
                      <Input
                        placeholder="ابحث باسم الجهاز"
                        value={devicePickerSearch}
                        onChange={(e) => setDevicePickerSearch(e.target.value)}
                        className="ps-10"
                      />
                    </div>
                    <div className="grid grid-cols-1 gap-2 max-h-44 overflow-y-auto border rounded-md p-2">
                      {filteredDevices.map((device) => (
                        <label
                          key={`targeting-device-${device._id}`}
                          className="flex items-center gap-2 p-2 rounded hover:bg-muted/40 cursor-pointer"
                        >
                          <input
                            type="checkbox"
                            checked={selectedTargetingDevices.includes(device._id)}
                            onChange={(e) =>
                              toggleArraySelection(
                                "targetingDevices",
                                device._id,
                                e.target.checked,
                              )
                            }
                            className="w-4 h-4 rounded"
                          />
                          <span className="text-sm truncate" title={device.nameAr || device.name}>
                            {device.nameAr || device.name}
                          </span>
                        </label>
                      ))}
                    </div>
                    <p className="text-xs text-muted-foreground">
                      تم اختيار {selectedTargetingDevices.length} جهاز
                    </p>
                    {devicesLoading && (
                      <p className="text-xs text-muted-foreground">جاري تحميل الأجهزة...</p>
                    )}
                  </div>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="targetingIntentTags">
                    Intent Tags (battery, screen, ...)
                  </Label>
                  <Input
                    id="targetingIntentTags"
                    placeholder="بطارية, ارتفاع_الحرارة, شاشة"
                    {...contentForm.register("targetingIntentTags")}
                  />
                </div>
                </div>
              </details>

              {/* SEO & Tags */}
              <details open className="rounded-lg border border-border bg-muted/10 p-4">
                <summary className="cursor-pointer select-none font-semibold text-sm">
                  SEO والوسوم
                </summary>
                <div className="space-y-4 mt-4">
                <div className="space-y-2">
                  <Label htmlFor="tags">الوسوم (مفصولة بفواصل)</Label>
                  <Input
                    id="tags"
                    placeholder="وسم1, وسم2, وسم3"
                    {...contentForm.register("tags")}
                  />
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="metaTitle">عنوان SEO</Label>
                    <Input
                      id="metaTitle"
                      {...contentForm.register("metaTitle")}
                    />
                    <p
                      className={`text-xs ${
                        metaTitleValue.length > 60
                          ? "text-amber-600 dark:text-amber-400"
                          : "text-muted-foreground"
                      }`}
                    >
                      {metaTitleValue.length}/60
                    </p>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="metaDescription">وصف SEO</Label>
                    <Textarea
                      id="metaDescription"
                      {...contentForm.register("metaDescription")}
                    />
                    <p
                      className={`text-xs ${
                        metaDescriptionValue.length > 160
                          ? "text-amber-600 dark:text-amber-400"
                          : "text-muted-foreground"
                      }`}
                    >
                      {metaDescriptionValue.length}/160
                    </p>
                  </div>
                </div>
                </div>
              </details>

              {/* Settings */}
              <details open className="rounded-lg border border-border bg-muted/10 p-4">
                <summary className="cursor-pointer select-none font-semibold text-sm">
                  الإعدادات
                </summary>
                <div className="space-y-4 mt-4">
                <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="status">الحالة</Label>
                    <Controller
                      name="status"
                      control={contentForm.control}
                      render={({ field }) => (
                        <Select
                          value={field.value}
                          onValueChange={field.onChange}
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="draft">مسودة</SelectItem>
                            <SelectItem value="published">منشور</SelectItem>
                            <SelectItem value="archived">مؤرشف</SelectItem>
                          </SelectContent>
                        </Select>
                      )}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="difficulty">الصعوبة</Label>
                    <Controller
                      name="difficulty"
                      control={contentForm.control}
                      render={({ field }) => (
                        <Select
                          value={field.value}
                          onValueChange={field.onChange}
                        >
                          <SelectTrigger>
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="beginner">مبتدئ</SelectItem>
                            <SelectItem value="intermediate">متوسط</SelectItem>
                            <SelectItem value="advanced">متقدم</SelectItem>
                          </SelectContent>
                        </Select>
                      )}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="readingTime">وقت القراءة (دقائق)</Label>
                    <Input
                      id="readingTime"
                      type="number"
                      {...contentForm.register("readingTime", {
                        valueAsNumber: true,
                      })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="isFeatured">مميز</Label>
                    <div className="flex items-center space-x-2 h-10">
                      <Controller
                        name="isFeatured"
                        control={contentForm.control}
                        render={({ field }) => (
                          <Switch
                            checked={field.value}
                            onCheckedChange={field.onChange}
                          />
                        )}
                      />
                      <Label htmlFor="isFeatured">مميز</Label>
                    </div>
                  </div>
                </div>
                </div>
              </details>
            </div>
            <DialogFooter className="sticky bottom-0 bg-white/95 dark:bg-slate-900/95 backdrop-blur border-t border-border pt-4 mt-4">
              <div className="w-full flex items-center justify-between gap-2 text-xs text-muted-foreground">
                <span>
                  SEO: {metaTitleValue.length}/60 - {metaDescriptionValue.length}/160
                </span>
                <span>
                  مرتبط: {selectedRelatedProducts.length} منتجات | استهداف: {selectedTargetingProducts.length + selectedTargetingCategories.length + selectedTargetingBrands.length + selectedTargetingDevices.length}
                </span>
              </div>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsContentDialogOpen(false)}
                disabled={isSavingContent}
              >
                إلغاء
              </Button>
              <Button type="submit" disabled={isSavingContent}>
                {isSavingContent ? (
                  <span className="inline-flex items-center gap-2">
                    <Loader2 className="h-4 w-4 animate-spin" />
                    جاري الحفظ...
                  </span>
                ) : isEditing ? (
                  "تحديث"
                ) : (
                  "إنشاء"
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
