import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm, Controller } from "react-hook-form";
import {
  contentApi,
  type Page,
  type Banner,
  type Slider,
  type SliderSlide,
  type Faq,
  type FaqCategory,
  type Testimonial,
} from "@/api/content.api";

// ══════════════════════════════════════════════════════════════
// Form Types
// ══════════════════════════════════════════════════════════════

type PageFormData = {
  title: string;
  titleAr: string;
  slug: string;
  content: string;
  contentAr: string;
  type: "header" | "footer" | "other";
  isActive: boolean;
};

type BannerFormData = {
  title: string;
  titleAr: string;
  imageUrl: string;
  linkUrl: string;
  position: string;
  order: number;
  isActive: boolean;
};

type SliderFormData = {
  name: string;
  nameAr: string;
  isActive: boolean;
};

type SlideFormData = {
  imageUrl: string;
  title: string;
  titleAr: string;
  subtitle: string;
  subtitleAr: string;
  linkUrl: string;
  order: number;
};

type FaqCategoryFormData = {
  name: string;
  nameAr: string;
  order: number;
  isActive: boolean;
};

type FaqFormData = {
  categoryId: string;
  question: string;
  questionAr: string;
  answer: string;
  answerAr: string;
  order: number;
  isActive: boolean;
};

type TestimonialFormData = {
  customerName: string;
  customerTitle: string;
  customerImage: string;
  content: string;
  contentAr: string;
  rating: number;
  isApproved: boolean;
  isFeatured: boolean;
};
import { toast } from "sonner";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
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
  FileText,
  Image,
  HelpCircle,
  Star,
  MessageSquare,
  CheckCircle,
  Eye,
  Layers,
  FolderTree,
  ChevronDown,
  ChevronUp,
} from "lucide-react";
import { formatDate } from "@/lib/utils";

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function ContentPage() {
  const queryClient = useQueryClient();

  const [activeTab, setActiveTab] = useState("pages");

  // Dialog states
  const [isPageDialogOpen, setIsPageDialogOpen] = useState(false);
  const [isBannerDialogOpen, setIsBannerDialogOpen] = useState(false);
  const [isSliderDialogOpen, setIsSliderDialogOpen] = useState(false);
  const [isSlideDialogOpen, setIsSlideDialogOpen] = useState(false);
  const [isFaqCategoryDialogOpen, setIsFaqCategoryDialogOpen] = useState(false);
  const [isFaqDialogOpen, setIsFaqDialogOpen] = useState(false);
  const [isTestimonialDialogOpen, setIsTestimonialDialogOpen] = useState(false);

  const [selectedItem, setSelectedItem] = useState<
    Page | Banner | Slider | FaqCategory | Faq | Testimonial | null
  >(null);
  const [selectedSlider, setSelectedSlider] = useState<Slider | null>(null);
  const [selectedSlideIndex, setSelectedSlideIndex] = useState<number | null>(
    null
  );
  const [isEditing, setIsEditing] = useState(false);
  const [expandedSliders, setExpandedSliders] = useState<
    Record<string, boolean>
  >({});

  // ─────────────────────────────────────────
  // Queries
  // ─────────────────────────────────────────

  const { data: pages = [], isLoading: pagesLoading } = useQuery({
    queryKey: ["content-pages"],
    queryFn: () => contentApi.getPages(),
  });

  const { data: banners = [], isLoading: bannersLoading } = useQuery({
    queryKey: ["content-banners"],
    queryFn: () => contentApi.getBanners(),
  });

  const { data: sliders = [], isLoading: slidersLoading } = useQuery({
    queryKey: ["content-sliders"],
    queryFn: () => contentApi.getSliders(),
  });

  const { data: faqCategories = [], isLoading: faqCategoriesLoading } =
    useQuery({
      queryKey: ["content-faq-categories"],
      queryFn: () => contentApi.getFaqCategories(),
    });

  const { data: faqs = [], isLoading: faqsLoading } = useQuery({
    queryKey: ["content-faqs"],
    queryFn: () => contentApi.getFaqs(),
  });

  const { data: testimonials = [], isLoading: testimonialsLoading } = useQuery({
    queryKey: ["content-testimonials"],
    queryFn: () => contentApi.getTestimonials(),
  });

  // Ensure arrays are arrays
  const safeFaqs = Array.isArray(faqs) ? faqs : [];
  const safeFaqCategories = Array.isArray(faqCategories) ? faqCategories : [];
  const safeTestimonials = Array.isArray(testimonials) ? testimonials : [];

  // ─────────────────────────────────────────
  // Page Mutations
  // ─────────────────────────────────────────

  const createPageMutation = useMutation({
    mutationFn: (data: Omit<Page, "_id" | "createdAt" | "updatedAt">) =>
      contentApi.createPage(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-pages"] });
      setIsPageDialogOpen(false);
      toast.success("تم إنشاء الصفحة بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updatePageMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Page> }) =>
      contentApi.updatePage(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-pages"] });
      setIsPageDialogOpen(false);
      setSelectedItem(null);
      toast.success("تم تحديث الصفحة بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const deletePageMutation = useMutation({
    mutationFn: (id: string) => contentApi.deletePage(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-pages"] });
      toast.success("تم حذف الصفحة");
    },
  });

  // ─────────────────────────────────────────
  // Banner Mutations
  // ─────────────────────────────────────────

  const createBannerMutation = useMutation({
    mutationFn: (data: Omit<Banner, "_id" | "impressions" | "clicks">) =>
      contentApi.createBanner(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-banners"] });
      setIsBannerDialogOpen(false);
      toast.success("تم إنشاء البنر بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateBannerMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Banner> }) =>
      contentApi.updateBanner(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-banners"] });
      setIsBannerDialogOpen(false);
      setSelectedItem(null);
      toast.success("تم تحديث البنر بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const deleteBannerMutation = useMutation({
    mutationFn: (id: string) => contentApi.deleteBanner(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-banners"] });
      toast.success("تم حذف البنر");
    },
  });

  // ─────────────────────────────────────────
  // Slider Mutations
  // ─────────────────────────────────────────

  const createSliderMutation = useMutation({
    mutationFn: (data: Omit<Slider, "_id" | "slides">) =>
      contentApi.createSlider(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-sliders"] });
      setIsSliderDialogOpen(false);
      toast.success("تم إنشاء السلايدر بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateSliderMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Slider> }) =>
      contentApi.updateSlider(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-sliders"] });
      setIsSliderDialogOpen(false);
      setSelectedItem(null);
      toast.success("تم تحديث السلايدر بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const deleteSliderMutation = useMutation({
    mutationFn: (id: string) => contentApi.deleteSlider(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-sliders"] });
      toast.success("تم حذف السلايدر");
    },
  });

  const addSlideMutation = useMutation({
    mutationFn: ({
      sliderId,
      slide,
    }: {
      sliderId: string;
      slide: Omit<SliderSlide, "_id">;
    }) => contentApi.addSlide(sliderId, slide),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-sliders"] });
      setIsSlideDialogOpen(false);
      toast.success("تم إضافة الشريحة بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateSlideMutation = useMutation({
    mutationFn: ({
      sliderId,
      slideIndex,
      slide,
    }: {
      sliderId: string;
      slideIndex: number;
      slide: Partial<SliderSlide>;
    }) => contentApi.updateSlide(sliderId, slideIndex, slide),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-sliders"] });
      setIsSlideDialogOpen(false);
      toast.success("تم تحديث الشريحة بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const removeSlideMutation = useMutation({
    mutationFn: ({
      sliderId,
      slideIndex,
    }: {
      sliderId: string;
      slideIndex: number;
    }) => contentApi.removeSlide(sliderId, slideIndex),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-sliders"] });
      toast.success("تم حذف الشريحة");
    },
  });

  // ─────────────────────────────────────────
  // FAQ Category Mutations
  // ─────────────────────────────────────────

  const createFaqCategoryMutation = useMutation({
    mutationFn: (data: Omit<FaqCategory, "_id">) =>
      contentApi.createFaqCategory(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-faq-categories"] });
      setIsFaqCategoryDialogOpen(false);
      toast.success("تم إنشاء التصنيف بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateFaqCategoryMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<FaqCategory> }) =>
      contentApi.updateFaqCategory(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-faq-categories"] });
      setIsFaqCategoryDialogOpen(false);
      setSelectedItem(null);
      toast.success("تم تحديث التصنيف بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  // ─────────────────────────────────────────
  // FAQ Mutations
  // ─────────────────────────────────────────

  const createFaqMutation = useMutation({
    mutationFn: (data: Omit<Faq, "_id" | "views">) =>
      contentApi.createFaq(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-faqs"] });
      setIsFaqDialogOpen(false);
      toast.success("تم إنشاء السؤال بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateFaqMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Faq> }) =>
      contentApi.updateFaq(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-faqs"] });
      setIsFaqDialogOpen(false);
      setSelectedItem(null);
      toast.success("تم تحديث السؤال بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const deleteFaqMutation = useMutation({
    mutationFn: (id: string) => contentApi.deleteFaq(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-faqs"] });
      toast.success("تم حذف السؤال");
    },
  });

  // ─────────────────────────────────────────
  // Testimonial Mutations
  // ─────────────────────────────────────────

  const createTestimonialMutation = useMutation({
    mutationFn: (data: Omit<Testimonial, "_id" | "createdAt">) =>
      contentApi.createTestimonial(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-testimonials"] });
      setIsTestimonialDialogOpen(false);
      toast.success("تم إنشاء الشهادة بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateTestimonialMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Testimonial> }) =>
      contentApi.updateTestimonial(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-testimonials"] });
      setIsTestimonialDialogOpen(false);
      setSelectedItem(null);
      toast.success("تم تحديث الشهادة بنجاح");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const approveTestimonialMutation = useMutation({
    mutationFn: (id: string) => contentApi.approveTestimonial(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-testimonials"] });
      toast.success("تم الموافقة على الشهادة");
    },
  });

  const deleteTestimonialMutation = useMutation({
    mutationFn: (id: string) => contentApi.deleteTestimonial(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["content-testimonials"] });
      toast.success("تم حذف الشهادة");
    },
  });

  // ─────────────────────────────────────────
  // Forms
  // ─────────────────────────────────────────

  const pageForm = useForm<PageFormData>({
    defaultValues: {
      title: "",
      titleAr: "",
      slug: "",
      content: "",
      contentAr: "",
      type: "other",
      isActive: true,
    },
  });

  const bannerForm = useForm<BannerFormData>({
    defaultValues: {
      title: "",
      titleAr: "",
      imageUrl: "",
      linkUrl: "",
      position: "home",
      order: 0,
      isActive: true,
    },
  });

  const sliderForm = useForm<SliderFormData>({
    defaultValues: {
      name: "",
      nameAr: "",
      isActive: true,
    },
  });

  const slideForm = useForm<SlideFormData>({
    defaultValues: {
      imageUrl: "",
      title: "",
      titleAr: "",
      subtitle: "",
      subtitleAr: "",
      linkUrl: "",
      order: 0,
    },
  });

  const faqCategoryForm = useForm<FaqCategoryFormData>({
    defaultValues: {
      name: "",
      nameAr: "",
      order: 0,
      isActive: true,
    },
  });

  const faqForm = useForm<FaqFormData>({
    defaultValues: {
      categoryId: "",
      question: "",
      questionAr: "",
      answer: "",
      answerAr: "",
      order: 0,
      isActive: true,
    },
  });

  const testimonialForm = useForm<TestimonialFormData>({
    defaultValues: {
      customerName: "",
      customerTitle: "",
      customerImage: "",
      content: "",
      contentAr: "",
      rating: 5,
      isApproved: false,
      isFeatured: false,
    },
  });

  // ─────────────────────────────────────────
  // Handlers - Pages
  // ─────────────────────────────────────────

  const handleAddPage = () => {
    setIsEditing(false);
    setSelectedItem(null);
    pageForm.reset({
      title: "",
      titleAr: "",
      slug: "",
      content: "",
      contentAr: "",
      type: "other",
      isActive: true,
    });
    setIsPageDialogOpen(true);
  };

  const handleEditPage = (page: Page) => {
    setIsEditing(true);
    setSelectedItem(page);
    pageForm.reset({
      title: page.title,
      titleAr: page.titleAr || "",
      slug: page.slug,
      content: page.content,
      contentAr: page.contentAr || "",
      type: page.type,
      isActive: page.isActive,
    });
    setIsPageDialogOpen(true);
  };

  const onPageSubmit = (data: PageFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updatePageMutation.mutate({ id: selectedItem._id, data });
    } else {
      createPageMutation.mutate(data);
    }
  };

  // ─────────────────────────────────────────
  // Handlers - Banners
  // ─────────────────────────────────────────

  const handleAddBanner = () => {
    setIsEditing(false);
    setSelectedItem(null);
    bannerForm.reset({
      title: "",
      titleAr: "",
      imageUrl: "",
      linkUrl: "",
      position: "home",
      order: 0,
      isActive: true,
    });
    setIsBannerDialogOpen(true);
  };

  const handleEditBanner = (banner: Banner) => {
    setIsEditing(true);
    setSelectedItem(banner);
    bannerForm.reset({
      title: banner.title,
      titleAr: banner.titleAr || "",
      imageUrl: banner.imageUrl,
      linkUrl: banner.linkUrl || "",
      position: banner.position,
      order: banner.order,
      isActive: banner.isActive,
    });
    setIsBannerDialogOpen(true);
  };

  const onBannerSubmit = (data: BannerFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateBannerMutation.mutate({ id: selectedItem._id, data });
    } else {
      createBannerMutation.mutate(data);
    }
  };

  // ─────────────────────────────────────────
  // Handlers - Sliders
  // ─────────────────────────────────────────

  const handleAddSlider = () => {
    setIsEditing(false);
    setSelectedItem(null);
    sliderForm.reset({ name: "", nameAr: "", isActive: true });
    setIsSliderDialogOpen(true);
  };

  const handleEditSlider = (slider: Slider) => {
    setIsEditing(true);
    setSelectedItem(slider);
    sliderForm.reset({
      name: slider.name,
      nameAr: slider.nameAr || "",
      isActive: slider.isActive,
    });
    setIsSliderDialogOpen(true);
  };

  const onSliderSubmit = (data: SliderFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateSliderMutation.mutate({ id: selectedItem._id, data });
    } else {
      createSliderMutation.mutate(data);
    }
  };

  const handleAddSlide = (slider: Slider) => {
    setIsEditing(false);
    setSelectedSlider(slider);
    setSelectedSlideIndex(null);
    slideForm.reset({
      imageUrl: "",
      title: "",
      titleAr: "",
      subtitle: "",
      subtitleAr: "",
      linkUrl: "",
      order: slider.slides.length,
    });
    setIsSlideDialogOpen(true);
  };

  const handleEditSlide = (
    slider: Slider,
    slideIndex: number,
    slide: SliderSlide
  ) => {
    setIsEditing(true);
    setSelectedSlider(slider);
    setSelectedSlideIndex(slideIndex);
    slideForm.reset({
      imageUrl: slide.imageUrl,
      title: slide.title || "",
      titleAr: slide.titleAr || "",
      subtitle: slide.subtitle || "",
      subtitleAr: slide.subtitleAr || "",
      linkUrl: slide.linkUrl || "",
      order: slide.order,
    });
    setIsSlideDialogOpen(true);
  };

  const onSlideSubmit = (data: SlideFormData) => {
    if (!selectedSlider) return;
    if (isEditing && selectedSlideIndex !== null) {
      updateSlideMutation.mutate({
        sliderId: selectedSlider._id,
        slideIndex: selectedSlideIndex,
        slide: data,
      });
    } else {
      addSlideMutation.mutate({ sliderId: selectedSlider._id, slide: data });
    }
  };

  const toggleSliderExpanded = (sliderId: string) => {
    setExpandedSliders((prev) => ({ ...prev, [sliderId]: !prev[sliderId] }));
  };

  // ─────────────────────────────────────────
  // Handlers - FAQ Categories
  // ─────────────────────────────────────────

  const handleAddFaqCategory = () => {
    setIsEditing(false);
    setSelectedItem(null);
    faqCategoryForm.reset({ name: "", nameAr: "", order: 0, isActive: true });
    setIsFaqCategoryDialogOpen(true);
  };

  const handleEditFaqCategory = (category: FaqCategory) => {
    setIsEditing(true);
    setSelectedItem(category);
    faqCategoryForm.reset({
      name: category.name,
      nameAr: category.nameAr || "",
      order: category.order,
      isActive: category.isActive,
    });
    setIsFaqCategoryDialogOpen(true);
  };

  const onFaqCategorySubmit = (data: FaqCategoryFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateFaqCategoryMutation.mutate({ id: selectedItem._id, data });
    } else {
      createFaqCategoryMutation.mutate(data);
    }
  };

  // ─────────────────────────────────────────
  // Handlers - FAQs
  // ─────────────────────────────────────────

  const handleAddFaq = () => {
    setIsEditing(false);
    setSelectedItem(null);
    faqForm.reset({
      categoryId: faqCategories[0]?._id || "",
      question: "",
      questionAr: "",
      answer: "",
      answerAr: "",
      order: 0,
      isActive: true,
    });
    setIsFaqDialogOpen(true);
  };

  const handleEditFaq = (faq: Faq) => {
    setIsEditing(true);
    setSelectedItem(faq);
    faqForm.reset({
      categoryId: faq.categoryId,
      question: faq.question,
      questionAr: faq.questionAr || "",
      answer: faq.answer,
      answerAr: faq.answerAr || "",
      order: faq.order,
      isActive: faq.isActive,
    });
    setIsFaqDialogOpen(true);
  };

  const onFaqSubmit = (data: FaqFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateFaqMutation.mutate({ id: selectedItem._id, data });
    } else {
      createFaqMutation.mutate(data);
    }
  };

  // ─────────────────────────────────────────
  // Handlers - Testimonials
  // ─────────────────────────────────────────

  const handleAddTestimonial = () => {
    setIsEditing(false);
    setSelectedItem(null);
    testimonialForm.reset({
      customerName: "",
      customerTitle: "",
      customerImage: "",
      content: "",
      contentAr: "",
      rating: 5,
      isApproved: false,
      isFeatured: false,
    });
    setIsTestimonialDialogOpen(true);
  };

  const handleEditTestimonial = (testimonial: Testimonial) => {
    setIsEditing(true);
    setSelectedItem(testimonial);
    testimonialForm.reset({
      customerName: testimonial.customerName,
      customerTitle: testimonial.customerTitle || "",
      customerImage: testimonial.customerImage || "",
      content: testimonial.content,
      contentAr: testimonial.contentAr || "",
      rating: testimonial.rating,
      isApproved: testimonial.isApproved,
      isFeatured: testimonial.isFeatured,
    });
    setIsTestimonialDialogOpen(true);
  };

  const onTestimonialSubmit = (data: TestimonialFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateTestimonialMutation.mutate({ id: selectedItem._id, data });
    } else {
      createTestimonialMutation.mutate(data);
    }
  };

  // ─────────────────────────────────────────
  // Stats
  // ─────────────────────────────────────────

  const activePages = pages.filter((p) => p.isActive).length;
  const activeBanners = banners.filter((b) => b.isActive).length;
  const activeSliders = sliders.filter((s) => s.isActive).length;
  const pendingTestimonials = testimonials.filter((t) => !t.isApproved).length;

  // ─────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold">إدارة المحتوى</h1>
        <p className="text-muted-foreground text-sm">
          إدارة الصفحات والبنرات والسلايدر والأسئلة الشائعة والشهادات
        </p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-100 dark:bg-blue-900/30 rounded-lg">
                <FileText className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">الصفحات</p>
                <p className="text-2xl font-bold">
                  {activePages} / {pages.length}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-green-100 dark:bg-green-900/30 rounded-lg">
                <Image className="h-5 w-5 text-green-600 dark:text-green-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">البنرات</p>
                <p className="text-2xl font-bold">
                  {activeBanners} / {banners.length}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-indigo-100 dark:bg-indigo-900/30 rounded-lg">
                <Layers className="h-5 w-5 text-indigo-600 dark:text-indigo-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">السلايدر</p>
                <p className="text-2xl font-bold">
                  {activeSliders} / {sliders.length}
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-purple-100 dark:bg-purple-900/30 rounded-lg">
                <HelpCircle className="h-5 w-5 text-purple-600 dark:text-purple-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">الأسئلة الشائعة</p>
                <p className="text-2xl font-bold">{safeFaqs.length}</p>
              </div>
            </div>
          </CardContent>
        </Card>
        <Card>
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-yellow-100 dark:bg-yellow-900/30 rounded-lg">
                <MessageSquare className="h-5 w-5 text-yellow-600 dark:text-yellow-400" />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">
                  بانتظار الموافقة
                </p>
                <p className="text-2xl font-bold">{pendingTestimonials}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="mb-4 flex-wrap">
          <TabsTrigger value="pages" className="flex items-center gap-2">
            <FileText className="h-4 w-4" />
            الصفحات
          </TabsTrigger>
          <TabsTrigger value="banners" className="flex items-center gap-2">
            <Image className="h-4 w-4" />
            البنرات
          </TabsTrigger>
          <TabsTrigger value="sliders" className="flex items-center gap-2">
            <Layers className="h-4 w-4" />
            السلايدر
          </TabsTrigger>
          <TabsTrigger value="faqs" className="flex items-center gap-2">
            <HelpCircle className="h-4 w-4" />
            الأسئلة الشائعة
          </TabsTrigger>
          <TabsTrigger value="testimonials" className="flex items-center gap-2">
            <Star className="h-4 w-4" />
            الشهادات
            {pendingTestimonials > 0 && (
              <Badge variant="warning" className="mr-1">
                {pendingTestimonials}
              </Badge>
            )}
          </TabsTrigger>
        </TabsList>

        {/* Pages Tab */}
        <TabsContent value="pages">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <FileText className="h-5 w-5" />
                  الصفحات الثابتة
                </CardTitle>
                <Button onClick={handleAddPage}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة صفحة
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {pagesLoading ? (
                <div className="flex justify-center items-center h-40">
                  <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
              ) : pages.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <FileText className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد صفحات</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>العنوان</TableHead>
                      <TableHead>Slug</TableHead>
                      <TableHead>النوع</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead>آخر تحديث</TableHead>
                      <TableHead className="w-[50px]"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {pages.map((page) => (
                      <TableRow key={page._id}>
                        <TableCell>
                          <div>
                            <p className="font-medium">{page.title}</p>
                            {page.titleAr && (
                              <p className="text-sm text-muted-foreground">
                                {page.titleAr}
                              </p>
                            )}
                          </div>
                        </TableCell>
                        <TableCell className="font-mono text-sm">
                          {page.slug}
                        </TableCell>
                        <TableCell>
                          <Badge variant="outline">
                            {page.type === "header"
                              ? "Header"
                              : page.type === "footer"
                              ? "Footer"
                              : "أخرى"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={page.isActive ? "success" : "secondary"}
                          >
                            {page.isActive ? "نشط" : "غير نشط"}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-muted-foreground text-sm">
                          {formatDate(page.updatedAt)}
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
                                onClick={() => handleEditPage(page)}
                              >
                                <Pencil className="h-4 w-4 ml-2" />
                                تعديل
                              </DropdownMenuItem>
                              <DropdownMenuItem
                                onClick={() =>
                                  deletePageMutation.mutate(page._id)
                                }
                                className="text-red-600"
                              >
                                <Trash2 className="h-4 w-4 ml-2" />
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

        {/* Banners Tab */}
        <TabsContent value="banners">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <Image className="h-5 w-5" />
                  البنرات والإعلانات
                </CardTitle>
                <Button onClick={handleAddBanner}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة بنر
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {bannersLoading ? (
                <div className="flex justify-center items-center h-40">
                  <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
              ) : banners.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <Image className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد بنرات</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                  {banners.map((banner) => (
                    <Card key={banner._id} className="overflow-hidden">
                      <div className="aspect-video bg-muted relative">
                        <img
                          src={banner.imageUrl}
                          alt={banner.title}
                          className="w-full h-full object-cover"
                          onError={(e) => {
                            (e.target as HTMLImageElement).src =
                              "/placeholder.svg";
                          }}
                        />
                        <Badge
                          variant={banner.isActive ? "success" : "secondary"}
                          className="absolute top-2 right-2"
                        >
                          {banner.isActive ? "نشط" : "غير نشط"}
                        </Badge>
                      </div>
                      <CardContent className="p-4">
                        <h3 className="font-medium mb-2">{banner.title}</h3>
                        <div className="flex justify-between items-center text-sm text-muted-foreground">
                          <span>
                            <Eye className="h-3 w-3 inline ml-1" />
                            {banner.impressions}
                          </span>
                          <div className="flex gap-2">
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() => handleEditBanner(banner)}
                            >
                              <Pencil className="h-4 w-4" />
                            </Button>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={() =>
                                deleteBannerMutation.mutate(banner._id)
                              }
                              className="text-red-600"
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
            </CardContent>
          </Card>
        </TabsContent>

        {/* Sliders Tab */}
        <TabsContent value="sliders">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <Layers className="h-5 w-5" />
                  السلايدر
                </CardTitle>
                <Button onClick={handleAddSlider}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة سلايدر
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {slidersLoading ? (
                <div className="flex justify-center items-center h-40">
                  <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
              ) : sliders.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <Layers className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد سلايدر</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {sliders.map((slider) => (
                    <Card key={slider._id}>
                      <CardHeader className="pb-2">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-3">
                            <Button
                              variant="ghost"
                              size="icon"
                              onClick={() => toggleSliderExpanded(slider._id)}
                            >
                              {expandedSliders[slider._id] ? (
                                <ChevronUp className="h-4 w-4" />
                              ) : (
                                <ChevronDown className="h-4 w-4" />
                              )}
                            </Button>
                            <div>
                              <h3 className="font-medium">{slider.name}</h3>
                              {slider.nameAr && (
                                <p className="text-sm text-muted-foreground">
                                  {slider.nameAr}
                                </p>
                              )}
                            </div>
                            <Badge
                              variant={
                                slider.isActive ? "success" : "secondary"
                              }
                            >
                              {slider.isActive ? "نشط" : "غير نشط"}
                            </Badge>
                            <Badge variant="outline">
                              {slider.slides?.length || 0} شرائح
                            </Badge>
                          </div>
                          <div className="flex items-center gap-2">
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => handleAddSlide(slider)}
                            >
                              <Plus className="h-4 w-4 ml-1" />
                              إضافة شريحة
                            </Button>
                            <DropdownMenu>
                              <DropdownMenuTrigger asChild>
                                <Button variant="ghost" size="icon">
                                  <MoreHorizontal className="h-4 w-4" />
                                </Button>
                              </DropdownMenuTrigger>
                              <DropdownMenuContent align="end">
                                <DropdownMenuItem
                                  onClick={() => handleEditSlider(slider)}
                                >
                                  <Pencil className="h-4 w-4 ml-2" />
                                  تعديل
                                </DropdownMenuItem>
                                <DropdownMenuItem
                                  onClick={() =>
                                    deleteSliderMutation.mutate(slider._id)
                                  }
                                  className="text-red-600"
                                >
                                  <Trash2 className="h-4 w-4 ml-2" />
                                  حذف
                                </DropdownMenuItem>
                              </DropdownMenuContent>
                            </DropdownMenu>
                          </div>
                        </div>
                      </CardHeader>
                      {expandedSliders[slider._id] &&
                        slider.slides &&
                        slider.slides.length > 0 && (
                          <CardContent>
                            <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                              {slider.slides.map((slide, index) => (
                                <div
                                  key={slide._id || index}
                                  className="relative group"
                                >
                                  <div className="aspect-video bg-muted rounded-lg overflow-hidden">
                                    <img
                                      src={slide.imageUrl}
                                      alt={slide.title || `Slide ${index + 1}`}
                                      className="w-full h-full object-cover"
                                      onError={(e) => {
                                        (e.target as HTMLImageElement).src =
                                          "/placeholder.svg";
                                      }}
                                    />
                                  </div>
                                  <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity rounded-lg flex items-center justify-center gap-2">
                                    <Button
                                      size="icon"
                                      variant="secondary"
                                      onClick={() =>
                                        handleEditSlide(slider, index, slide)
                                      }
                                    >
                                      <Pencil className="h-4 w-4" />
                                    </Button>
                                    <Button
                                      size="icon"
                                      variant="destructive"
                                      onClick={() =>
                                        removeSlideMutation.mutate({
                                          sliderId: slider._id,
                                          slideIndex: index,
                                        })
                                      }
                                    >
                                      <Trash2 className="h-4 w-4" />
                                    </Button>
                                  </div>
                                  <p className="text-xs text-center mt-1 text-muted-foreground truncate">
                                    {slide.title || `شريحة ${index + 1}`}
                                  </p>
                                </div>
                              ))}
                            </div>
                          </CardContent>
                        )}
                    </Card>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* FAQs Tab */}
        <TabsContent value="faqs">
          <div className="grid lg:grid-cols-3 gap-6">
            {/* FAQ Categories */}
            <Card>
              <CardHeader>
                <div className="flex justify-between items-center">
                  <CardTitle className="flex items-center gap-2 text-base">
                    <FolderTree className="h-5 w-5" />
                    التصنيفات
                  </CardTitle>
                  <Button size="sm" onClick={handleAddFaqCategory}>
                    <Plus className="h-4 w-4" />
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                {faqCategoriesLoading ? (
                  <div className="flex justify-center items-center h-20">
                    <Loader2 className="h-6 w-6 animate-spin text-primary" />
                  </div>
                ) : safeFaqCategories.length === 0 ? (
                  <p className="text-center text-muted-foreground py-4">
                    لا توجد تصنيفات
                  </p>
                ) : (
                  <div className="space-y-2">
                    {safeFaqCategories.map((cat) => (
                      <div
                        key={cat._id}
                        className="flex items-center justify-between p-2 rounded-lg hover:bg-muted"
                      >
                        <div>
                          <p className="font-medium text-sm">{cat.name}</p>
                          {cat.nameAr && (
                            <p className="text-xs text-muted-foreground">
                              {cat.nameAr}
                            </p>
                          )}
                        </div>
                        <div className="flex items-center gap-1">
                          <Badge
                            variant={cat.isActive ? "success" : "secondary"}
                            className="text-xs"
                          >
                            {cat.isActive ? "نشط" : "غير نشط"}
                          </Badge>
                          <Button
                            variant="ghost"
                            size="icon"
                            className="h-7 w-7"
                            onClick={() => handleEditFaqCategory(cat)}
                          >
                            <Pencil className="h-3 w-3" />
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </CardContent>
            </Card>

            {/* FAQs */}
            <Card className="lg:col-span-2">
              <CardHeader>
                <div className="flex justify-between items-center">
                  <CardTitle className="flex items-center gap-2">
                    <HelpCircle className="h-5 w-5" />
                    الأسئلة الشائعة
                  </CardTitle>
                  <Button
                    onClick={handleAddFaq}
                    disabled={safeFaqCategories.length === 0}
                  >
                    <Plus className="h-4 w-4 ml-2" />
                    إضافة سؤال
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                {faqsLoading ? (
                  <div className="flex justify-center items-center h-40">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                  </div>
                ) : safeFaqs.length === 0 ? (
                  <div className="text-center py-12 text-muted-foreground">
                    <HelpCircle className="h-12 w-12 mx-auto mb-4 opacity-50" />
                    <p>لا توجد أسئلة شائعة</p>
                  </div>
                ) : (
                  <div className="space-y-3">
                    {safeFaqs.map((faq) => (
                      <Card key={faq._id}>
                        <CardContent className="p-4">
                          <div className="flex justify-between items-start">
                            <div className="flex-1">
                              <h4 className="font-medium mb-2">
                                {faq.question}
                              </h4>
                              {faq.questionAr && (
                                <p className="text-sm text-muted-foreground mb-2">
                                  {faq.questionAr}
                                </p>
                              )}
                              <p className="text-sm text-muted-foreground line-clamp-2">
                                {faq.answer}
                              </p>
                            </div>
                            <div className="flex items-center gap-2 mr-4">
                              <Badge
                                variant={faq.isActive ? "success" : "secondary"}
                              >
                                {faq.isActive ? "نشط" : "غير نشط"}
                              </Badge>
                              <span className="text-xs text-muted-foreground">
                                <Eye className="h-3 w-3 inline ml-1" />
                                {faq.views}
                              </span>
                              <DropdownMenu>
                                <DropdownMenuTrigger asChild>
                                  <Button variant="ghost" size="icon">
                                    <MoreHorizontal className="h-4 w-4" />
                                  </Button>
                                </DropdownMenuTrigger>
                                <DropdownMenuContent align="end">
                                  <DropdownMenuItem
                                    onClick={() => handleEditFaq(faq)}
                                  >
                                    <Pencil className="h-4 w-4 ml-2" />
                                    تعديل
                                  </DropdownMenuItem>
                                  <DropdownMenuItem
                                    onClick={() =>
                                      deleteFaqMutation.mutate(faq._id)
                                    }
                                    className="text-red-600"
                                  >
                                    <Trash2 className="h-4 w-4 ml-2" />
                                    حذف
                                  </DropdownMenuItem>
                                </DropdownMenuContent>
                              </DropdownMenu>
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    ))}
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* Testimonials Tab */}
        <TabsContent value="testimonials">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <Star className="h-5 w-5" />
                  شهادات العملاء
                </CardTitle>
                <Button onClick={handleAddTestimonial}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة شهادة
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {testimonialsLoading ? (
                <div className="flex justify-center items-center h-40">
                  <Loader2 className="h-8 w-8 animate-spin text-primary" />
                </div>
              ) : safeTestimonials.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <Star className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد شهادات</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {safeTestimonials.map((testimonial) => (
                    <Card
                      key={testimonial._id}
                      className={
                        !testimonial.isApproved ? "border-yellow-500" : ""
                      }
                    >
                      <CardContent className="p-4">
                        <div className="flex items-start gap-4">
                          <div className="w-12 h-12 rounded-full bg-muted flex items-center justify-center flex-shrink-0">
                            {testimonial.customerImage ? (
                              <img
                                src={testimonial.customerImage}
                                alt={testimonial.customerName}
                                className="w-full h-full rounded-full object-cover"
                              />
                            ) : (
                              <span className="text-lg font-medium">
                                {testimonial.customerName.charAt(0)}
                              </span>
                            )}
                          </div>
                          <div className="flex-1">
                            <div className="flex items-center justify-between mb-2">
                              <div>
                                <p className="font-medium">
                                  {testimonial.customerName}
                                </p>
                                {testimonial.customerTitle && (
                                  <p className="text-xs text-muted-foreground">
                                    {testimonial.customerTitle}
                                  </p>
                                )}
                              </div>
                              <div className="flex items-center gap-1">
                                {[...Array(5)].map((_, i) => (
                                  <Star
                                    key={i}
                                    className={`h-4 w-4 ${
                                      i < testimonial.rating
                                        ? "text-yellow-500 fill-yellow-500"
                                        : "text-gray-300"
                                    }`}
                                  />
                                ))}
                              </div>
                            </div>
                            <p className="text-sm text-muted-foreground mb-3">
                              {testimonial.content}
                            </p>
                            <div className="flex justify-between items-center">
                              <div className="flex items-center gap-2">
                                <Badge
                                  variant={
                                    testimonial.isApproved
                                      ? "success"
                                      : "warning"
                                  }
                                >
                                  {testimonial.isApproved
                                    ? "معتمد"
                                    : "بانتظار الموافقة"}
                                </Badge>
                                {testimonial.isFeatured && (
                                  <Badge variant="default">مميز</Badge>
                                )}
                              </div>
                              <div className="flex gap-1">
                                {!testimonial.isApproved && (
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    onClick={() =>
                                      approveTestimonialMutation.mutate(
                                        testimonial._id
                                      )
                                    }
                                  >
                                    <CheckCircle className="h-4 w-4 text-green-600" />
                                  </Button>
                                )}
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() =>
                                    handleEditTestimonial(testimonial)
                                  }
                                >
                                  <Pencil className="h-4 w-4" />
                                </Button>
                                <Button
                                  variant="ghost"
                                  size="sm"
                                  onClick={() =>
                                    deleteTestimonialMutation.mutate(
                                      testimonial._id
                                    )
                                  }
                                  className="text-red-600"
                                >
                                  <Trash2 className="h-4 w-4" />
                                </Button>
                              </div>
                            </div>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Page Dialog */}
      <Dialog open={isPageDialogOpen} onOpenChange={setIsPageDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل الصفحة" : "إضافة صفحة جديدة"}
            </DialogTitle>
          </DialogHeader>
          <form
            onSubmit={pageForm.handleSubmit(onPageSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>العنوان (EN) *</Label>
                <Input
                  {...pageForm.register("title")}
                  placeholder="Page Title"
                />
              </div>
              <div className="space-y-2">
                <Label>العنوان (AR)</Label>
                <Input
                  {...pageForm.register("titleAr")}
                  placeholder="عنوان الصفحة"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Slug *</Label>
                <Input
                  {...pageForm.register("slug")}
                  placeholder="page-slug"
                  className="font-mono"
                />
              </div>
              <div className="space-y-2">
                <Label>النوع</Label>
                <select
                  {...pageForm.register("type")}
                  className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
                >
                  <option value="header">Header</option>
                  <option value="footer">Footer</option>
                  <option value="other">أخرى</option>
                </select>
              </div>
            </div>
            <div className="space-y-2">
              <Label>المحتوى (EN)</Label>
              <Textarea
                {...pageForm.register("content")}
                rows={5}
                placeholder="Page content..."
              />
            </div>
            <div className="space-y-2">
              <Label>المحتوى (AR)</Label>
              <Textarea
                {...pageForm.register("contentAr")}
                rows={5}
                placeholder="محتوى الصفحة..."
              />
            </div>
            <div className="flex items-center gap-2">
              <Controller
                control={pageForm.control}
                name="isActive"
                render={({ field }) => (
                  <Switch
                    id="pageActive"
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                )}
              />
              <Label htmlFor="pageActive">صفحة نشطة</Label>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsPageDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createPageMutation.isPending || updatePageMutation.isPending
                }
              >
                {(createPageMutation.isPending ||
                  updatePageMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إنشاء"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Banner Dialog */}
      <Dialog open={isBannerDialogOpen} onOpenChange={setIsBannerDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل البنر" : "إضافة بنر جديد"}
            </DialogTitle>
          </DialogHeader>
          <form
            onSubmit={bannerForm.handleSubmit(onBannerSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>العنوان (EN) *</Label>
                <Input
                  {...bannerForm.register("title")}
                  placeholder="Banner Title"
                />
              </div>
              <div className="space-y-2">
                <Label>العنوان (AR)</Label>
                <Input
                  {...bannerForm.register("titleAr")}
                  placeholder="عنوان البنر"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>رابط الصورة *</Label>
              <Input
                {...bannerForm.register("imageUrl")}
                placeholder="https://..."
              />
            </div>
            <div className="space-y-2">
              <Label>رابط الهدف</Label>
              <Input
                {...bannerForm.register("linkUrl")}
                placeholder="https://..."
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الموقع</Label>
                <Input
                  {...bannerForm.register("position")}
                  placeholder="home"
                />
              </div>
              <div className="space-y-2">
                <Label>الترتيب</Label>
                <Input
                  type="number"
                  {...bannerForm.register("order", { valueAsNumber: true })}
                />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Controller
                control={bannerForm.control}
                name="isActive"
                render={({ field }) => (
                  <Switch
                    id="bannerActive"
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                )}
              />
              <Label htmlFor="bannerActive">بنر نشط</Label>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsBannerDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createBannerMutation.isPending ||
                  updateBannerMutation.isPending
                }
              >
                {(createBannerMutation.isPending ||
                  updateBannerMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إنشاء"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Slider Dialog */}
      <Dialog open={isSliderDialogOpen} onOpenChange={setIsSliderDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل السلايدر" : "إضافة سلايدر جديد"}
            </DialogTitle>
          </DialogHeader>
          <form
            onSubmit={sliderForm.handleSubmit(onSliderSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (EN) *</Label>
                <Input
                  {...sliderForm.register("name")}
                  placeholder="Slider Name"
                />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  {...sliderForm.register("nameAr")}
                  placeholder="اسم السلايدر"
                />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Controller
                control={sliderForm.control}
                name="isActive"
                render={({ field }) => (
                  <Switch
                    id="sliderActive"
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                )}
              />
              <Label htmlFor="sliderActive">سلايدر نشط</Label>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsSliderDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createSliderMutation.isPending ||
                  updateSliderMutation.isPending
                }
              >
                {(createSliderMutation.isPending ||
                  updateSliderMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إنشاء"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Slide Dialog */}
      <Dialog open={isSlideDialogOpen} onOpenChange={setIsSlideDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل الشريحة" : "إضافة شريحة جديدة"}
            </DialogTitle>
            <DialogDescription>
              {selectedSlider && `السلايدر: ${selectedSlider.name}`}
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={slideForm.handleSubmit(onSlideSubmit)}
            className="space-y-4"
          >
            <div className="space-y-2">
              <Label>رابط الصورة *</Label>
              <Input
                {...slideForm.register("imageUrl")}
                placeholder="https://..."
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>العنوان (EN)</Label>
                <Input
                  {...slideForm.register("title")}
                  placeholder="Slide Title"
                />
              </div>
              <div className="space-y-2">
                <Label>العنوان (AR)</Label>
                <Input
                  {...slideForm.register("titleAr")}
                  placeholder="عنوان الشريحة"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>العنوان الفرعي (EN)</Label>
                <Input
                  {...slideForm.register("subtitle")}
                  placeholder="Subtitle"
                />
              </div>
              <div className="space-y-2">
                <Label>العنوان الفرعي (AR)</Label>
                <Input
                  {...slideForm.register("subtitleAr")}
                  placeholder="العنوان الفرعي"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>رابط الهدف</Label>
                <Input
                  {...slideForm.register("linkUrl")}
                  placeholder="https://..."
                />
              </div>
              <div className="space-y-2">
                <Label>الترتيب</Label>
                <Input
                  type="number"
                  {...slideForm.register("order", { valueAsNumber: true })}
                />
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsSlideDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  addSlideMutation.isPending || updateSlideMutation.isPending
                }
              >
                {(addSlideMutation.isPending ||
                  updateSlideMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إضافة"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* FAQ Category Dialog */}
      <Dialog
        open={isFaqCategoryDialogOpen}
        onOpenChange={setIsFaqCategoryDialogOpen}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل التصنيف" : "إضافة تصنيف جديد"}
            </DialogTitle>
          </DialogHeader>
          <form
            onSubmit={faqCategoryForm.handleSubmit(onFaqCategorySubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (EN) *</Label>
                <Input
                  {...faqCategoryForm.register("name")}
                  placeholder="Category Name"
                />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  {...faqCategoryForm.register("nameAr")}
                  placeholder="اسم التصنيف"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>الترتيب</Label>
              <Input
                type="number"
                {...faqCategoryForm.register("order", { valueAsNumber: true })}
              />
            </div>
            <div className="flex items-center gap-2">
              <Controller
                control={faqCategoryForm.control}
                name="isActive"
                render={({ field }) => (
                  <Switch
                    id="faqCatActive"
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                )}
              />
              <Label htmlFor="faqCatActive">تصنيف نشط</Label>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsFaqCategoryDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createFaqCategoryMutation.isPending ||
                  updateFaqCategoryMutation.isPending
                }
              >
                {(createFaqCategoryMutation.isPending ||
                  updateFaqCategoryMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إنشاء"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* FAQ Dialog */}
      <Dialog open={isFaqDialogOpen} onOpenChange={setIsFaqDialogOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل السؤال" : "إضافة سؤال جديد"}
            </DialogTitle>
          </DialogHeader>
          <form
            onSubmit={faqForm.handleSubmit(onFaqSubmit)}
            className="space-y-4"
          >
            <div className="space-y-2">
              <Label>التصنيف *</Label>
              <select
                {...faqForm.register("categoryId")}
                className="w-full h-10 rounded-lg border border-gray-300 dark:border-slate-600 bg-white dark:bg-slate-800 text-gray-900 dark:text-gray-100 px-3 text-sm"
              >
                {faqCategories.map((cat) => (
                  <option key={cat._id} value={cat._id}>
                    {cat.nameAr || cat.name}
                  </option>
                ))}
              </select>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>السؤال (EN) *</Label>
                <Input
                  {...faqForm.register("question")}
                  placeholder="Question?"
                />
              </div>
              <div className="space-y-2">
                <Label>السؤال (AR)</Label>
                <Input
                  {...faqForm.register("questionAr")}
                  placeholder="السؤال؟"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>الإجابة (EN) *</Label>
              <Textarea
                {...faqForm.register("answer")}
                rows={3}
                placeholder="Answer..."
              />
            </div>
            <div className="space-y-2">
              <Label>الإجابة (AR)</Label>
              <Textarea
                {...faqForm.register("answerAr")}
                rows={3}
                placeholder="الإجابة..."
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الترتيب</Label>
                <Input
                  type="number"
                  {...faqForm.register("order", { valueAsNumber: true })}
                />
              </div>
              <div className="flex items-center gap-2 pt-6">
                <Controller
                  control={faqForm.control}
                  name="isActive"
                  render={({ field }) => (
                    <Switch
                      id="faqActive"
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="faqActive">سؤال نشط</Label>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsFaqDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createFaqMutation.isPending || updateFaqMutation.isPending
                }
              >
                {(createFaqMutation.isPending ||
                  updateFaqMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إنشاء"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Testimonial Dialog */}
      <Dialog
        open={isTestimonialDialogOpen}
        onOpenChange={setIsTestimonialDialogOpen}
      >
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل الشهادة" : "إضافة شهادة جديدة"}
            </DialogTitle>
          </DialogHeader>
          <form
            onSubmit={testimonialForm.handleSubmit(onTestimonialSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>اسم العميل *</Label>
                <Input
                  {...testimonialForm.register("customerName")}
                  placeholder="اسم العميل"
                />
              </div>
              <div className="space-y-2">
                <Label>لقب العميل</Label>
                <Input
                  {...testimonialForm.register("customerTitle")}
                  placeholder="مثال: مدير، مهندس"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>رابط صورة العميل</Label>
              <Input
                {...testimonialForm.register("customerImage")}
                placeholder="https://..."
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>المحتوى (EN) *</Label>
                <Textarea
                  {...testimonialForm.register("content")}
                  rows={3}
                  placeholder="Testimonial content..."
                />
              </div>
              <div className="space-y-2">
                <Label>المحتوى (AR)</Label>
                <Textarea
                  {...testimonialForm.register("contentAr")}
                  rows={3}
                  placeholder="محتوى الشهادة..."
                />
              </div>
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label>التقييم</Label>
                <Input
                  type="number"
                  min={1}
                  max={5}
                  {...testimonialForm.register("rating", {
                    valueAsNumber: true,
                  })}
                />
              </div>
              <div className="flex items-center gap-2 pt-6">
                <Controller
                  control={testimonialForm.control}
                  name="isApproved"
                  render={({ field }) => (
                    <Switch
                      id="testimonialApproved"
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="testimonialApproved">معتمد</Label>
              </div>
              <div className="flex items-center gap-2 pt-6">
                <Controller
                  control={testimonialForm.control}
                  name="isFeatured"
                  render={({ field }) => (
                    <Switch
                      id="testimonialFeatured"
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="testimonialFeatured">مميز</Label>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsTestimonialDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createTestimonialMutation.isPending ||
                  updateTestimonialMutation.isPending
                }
              >
                {(createTestimonialMutation.isPending ||
                  updateTestimonialMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إنشاء"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export default ContentPage;
