import { useMemo, useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm, Controller } from "react-hook-form";
import {
  contentApi,
  type EducationalCategory,
  type EducationalContent,
} from "@/api/content.api";
import { productsApi } from "@/api/products.api";
import { catalogApi, type CategoryTree } from "@/api/catalog.api";
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
  relatedContent: string;
  targetingProducts: string[];
  targetingCategories: string[];
  targetingBrands: string;
  targetingDevices: string;
  targetingIntentTags: string;
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
    queryFn: () => productsApi.getAll({ page: 1, limit: 200 }),
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
      relatedContent: "",
      targetingProducts: [],
      targetingCategories: [],
      targetingBrands: "",
      targetingDevices: "",
      targetingIntentTags: "",
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
    field: "relatedProducts" | "targetingProducts" | "targetingCategories",
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
      relatedContent: toIdList(content.relatedContent as any[]).join(", "),
      targetingProducts: toIdList(targeting.products),
      targetingCategories: toIdList(targeting.categories),
      targetingBrands: toIdList(targeting.brands).join(", "),
      targetingDevices: toIdList(targeting.devices).join(", "),
      targetingIntentTags: Array.isArray(targeting.intentTags)
        ? targeting.intentTags.join(", ")
        : "",
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
    const relatedContent = parseCsv(relatedContentInput);
    const parsedTargetingProducts = targetingProductsInput;
    const parsedTargetingCategories = targetingCategoriesInput;
    const parsedTargetingBrands = parseCsv(targetingBrands);
    const parsedTargetingDevices = parseCsv(targetingDevices);
    const parsedTargetingIntentTags = parseCsv(targetingIntentTags);

    const hasTargeting =
      parsedTargetingProducts.length > 0 ||
      parsedTargetingCategories.length > 0 ||
      parsedTargetingBrands.length > 0 ||
      parsedTargetingDevices.length > 0 ||
      parsedTargetingIntentTags.length > 0;

    const contentData = {
      ...baseData,
      tags,
      attachments: [],
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
                  value={contentFilters.categoryId}
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      categoryId: value,
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="جميع الفئات" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="">جميع الفئات</SelectItem>
                    {categories.map((cat) => (
                      <SelectItem key={cat._id} value={cat._id}>
                        {cat.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>

                <Select
                  value={contentFilters.type}
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      type: value,
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="جميع الأنواع" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="">جميع الأنواع</SelectItem>
                    <SelectItem value="article">مقال</SelectItem>
                    <SelectItem value="video">فيديو</SelectItem>
                    <SelectItem value="tutorial">درس</SelectItem>
                    <SelectItem value="tip">نصيحة</SelectItem>
                    <SelectItem value="guide">دليل</SelectItem>
                  </SelectContent>
                </Select>

                <Select
                  value={contentFilters.scope}
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      scope: (value || "") as ContentFilters["scope"],
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="كل النطاقات" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="">كل النطاقات</SelectItem>
                    <SelectItem value="general">عام</SelectItem>
                    <SelectItem value="contextual">مرتبط بسياق</SelectItem>
                    <SelectItem value="hybrid">هجين</SelectItem>
                  </SelectContent>
                </Select>

                <Select
                  value={contentFilters.status}
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      status: value,
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="جميع الحالات" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="">جميع الحالات</SelectItem>
                    <SelectItem value="draft">مسودة</SelectItem>
                    <SelectItem value="published">منشور</SelectItem>
                    <SelectItem value="archived">مؤرشف</SelectItem>
                  </SelectContent>
                </Select>

                <Select
                  value={
                    contentFilters.featured === undefined
                      ? ""
                      : contentFilters.featured.toString()
                  }
                  onValueChange={(value) =>
                    setContentFilters({
                      ...contentFilters,
                      featured: value === "" ? undefined : value === "true",
                      page: 1,
                    })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="الكل" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="">الكل</SelectItem>
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
              <div className="space-y-4">
                <h3 className="font-semibold">معلومات أساسية</h3>
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

              {/* Content */}
              <div className="space-y-4">
                <h3 className="font-semibold">المحتوى</h3>
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

              {/* Media */}
              <div className="space-y-4">
                <h3 className="font-semibold">الوسائط</h3>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="featuredImage">الصورة المميزة (URL)</Label>
                    <Input
                      id="featuredImage"
                      {...contentForm.register("featuredImage")}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="videoUrl">رابط الفيديو</Label>
                    <Input
                      id="videoUrl"
                      {...contentForm.register("videoUrl")}
                    />
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
              </div>

              {/* Targeting */}
              <div className="space-y-4">
                <h3 className="font-semibold">الربط والاستهداف</h3>
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
                  <Label htmlFor="relatedContent">
                    محتوى مرتبط (IDs مفصولة بفواصل)
                  </Label>
                  <Input
                    id="relatedContent"
                    placeholder="66c21..., 66c55..."
                    {...contentForm.register("relatedContent")}
                  />
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
                    <Label htmlFor="targetingBrands">
                      استهداف علامات تجارية
                    </Label>
                    <Input
                      id="targetingBrands"
                      placeholder="معرّفات مفصولة بفواصل"
                      {...contentForm.register("targetingBrands")}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="targetingDevices">استهداف أجهزة</Label>
                    <Input
                      id="targetingDevices"
                      placeholder="معرّفات مفصولة بفواصل"
                      {...contentForm.register("targetingDevices")}
                    />
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

              {/* SEO & Tags */}
              <div className="space-y-4">
                <h3 className="font-semibold">SEO والوسوم</h3>
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
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="metaDescription">وصف SEO</Label>
                    <Textarea
                      id="metaDescription"
                      {...contentForm.register("metaDescription")}
                    />
                  </div>
                </div>
              </div>

              {/* Settings */}
              <div className="space-y-4">
                <h3 className="font-semibold">الإعدادات</h3>
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
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsContentDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button type="submit">{isEditing ? "تحديث" : "إنشاء"}</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
