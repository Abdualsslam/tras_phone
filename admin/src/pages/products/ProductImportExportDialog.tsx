import { useMemo, useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { Download, FileUp, FileSearch, RefreshCw } from "lucide-react";
import { productsApi, type ProductsImportExportResult } from "@/api/products.api";
import { getErrorMessage } from "@/api/client";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";

type ImportMode = "upsert" | "create" | "update";

interface Props {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

interface TemplateFieldOption {
  key: string;
  label: string;
  descriptionAr: string;
}

const requiredTemplateFields = [
  { key: "sku", label: "sku", descriptionAr: "كود المنتج الفريد" },
  { key: "name", label: "name", descriptionAr: "اسم المنتج (الرئيسي)" },
  { key: "nameAr", label: "nameAr", descriptionAr: "اسم المنتج بالعربية" },
  { key: "slug", label: "slug", descriptionAr: "الرابط النصي للمنتج" },
  { key: "brandSlug", label: "brandSlug", descriptionAr: "رمز البراند (slug)" },
  {
    key: "categorySlug",
    label: "categorySlug",
    descriptionAr: "رمز الفئة (slug)",
  },
  {
    key: "qualityTypeSlug",
    label: "qualityTypeSlug",
    descriptionAr: "رمز نوع الجودة (code)",
  },
  { key: "basePrice", label: "basePrice", descriptionAr: "السعر الأساسي" },
] as const satisfies readonly TemplateFieldOption[];

const optionalTemplateFields = [
  { key: "id", label: "id", descriptionAr: "معرّف المنتج (للتحديث)" },
  {
    key: "additionalCategorySlugs",
    label: "additionalCategorySlugs",
    descriptionAr: "فئات إضافية (slugs مفصولة بفواصل)",
  },
  {
    key: "compareAtPrice",
    label: "compareAtPrice",
    descriptionAr: "السعر قبل الخصم",
  },
  { key: "costPrice", label: "costPrice", descriptionAr: "سعر التكلفة" },
  { key: "stockQuantity", label: "stockQuantity", descriptionAr: "كمية المخزون" },
  {
    key: "lowStockThreshold",
    label: "lowStockThreshold",
    descriptionAr: "حد تنبيه انخفاض المخزون",
  },
  {
    key: "trackInventory",
    label: "trackInventory",
    descriptionAr: "تفعيل تتبع المخزون",
  },
  {
    key: "allowBackorder",
    label: "allowBackorder",
    descriptionAr: "السماح بالطلب عند نفاد المخزون",
  },
  { key: "status", label: "status", descriptionAr: "حالة المنتج" },
  { key: "isActive", label: "isActive", descriptionAr: "نشط/غير نشط" },
  { key: "isFeatured", label: "isFeatured", descriptionAr: "منتج مميز" },
  { key: "isNewArrival", label: "isNewArrival", descriptionAr: "وصول جديد" },
  { key: "isBestSeller", label: "isBestSeller", descriptionAr: "الأكثر مبيعًا" },
  { key: "description", label: "description", descriptionAr: "الوصف" },
  { key: "descriptionAr", label: "descriptionAr", descriptionAr: "الوصف بالعربية" },
  {
    key: "shortDescription",
    label: "shortDescription",
    descriptionAr: "وصف مختصر",
  },
  {
    key: "shortDescriptionAr",
    label: "shortDescriptionAr",
    descriptionAr: "وصف مختصر بالعربية",
  },
  { key: "mainImage", label: "mainImage", descriptionAr: "رابط الصورة الرئيسية" },
  { key: "images", label: "images", descriptionAr: "روابط صور إضافية" },
  { key: "video", label: "video", descriptionAr: "رابط الفيديو" },
  {
    key: "specifications",
    label: "specifications",
    descriptionAr: "مواصفات المنتج (JSON)",
  },
  { key: "weight", label: "weight", descriptionAr: "الوزن" },
  { key: "dimensions", label: "dimensions", descriptionAr: "الأبعاد" },
  { key: "color", label: "color", descriptionAr: "اللون" },
  { key: "tags", label: "tags", descriptionAr: "وسوم المنتج" },
  { key: "warrantyDays", label: "warrantyDays", descriptionAr: "مدة الضمان (أيام)" },
  {
    key: "warrantyDescription",
    label: "warrantyDescription",
    descriptionAr: "وصف الضمان",
  },
  { key: "metaTitle", label: "metaTitle", descriptionAr: "عنوان SEO" },
  { key: "metaTitleAr", label: "metaTitleAr", descriptionAr: "عنوان SEO بالعربية" },
  {
    key: "metaDescription",
    label: "metaDescription",
    descriptionAr: "وصف SEO",
  },
  {
    key: "metaDescriptionAr",
    label: "metaDescriptionAr",
    descriptionAr: "وصف SEO بالعربية",
  },
  {
    key: "metaKeywords",
    label: "metaKeywords",
    descriptionAr: "كلمات مفتاحية SEO",
  },
  {
    key: "compatibleDevices",
    label: "compatibleDevices",
    descriptionAr: "الأجهزة المتوافقة (slugs)",
  },
] as const satisfies readonly TemplateFieldOption[];

export function ProductImportExportDialog({ open, onOpenChange }: Props) {
  const queryClient = useQueryClient();
  const [file, setFile] = useState<File | null>(null);
  const [mode, setMode] = useState<ImportMode>("upsert");
  const [result, setResult] = useState<ProductsImportExportResult | null>(null);
  const [selectedOptionalTemplateFields, setSelectedOptionalTemplateFields] =
    useState<string[]>([]);

  const fileName = useMemo(() => file?.name || "", [file]);

  const downloadTemplateMutation = useMutation({
    mutationFn: () =>
      productsApi.downloadImportTemplate({
        optionalFields: selectedOptionalTemplateFields,
      }),
    onSuccess: (blob) => {
      downloadBlob(blob, `products-template-${Date.now()}.xlsx`);
      toast.success("تم تحميل القالب");
    },
    onError: (error) => toast.error(getErrorMessage(error, "فشل تحميل القالب")),
  });

  const exportMutation = useMutation({
    mutationFn: () => productsApi.exportProductsExcel({ includeReferences: true, includeCompatibility: true }),
    onSuccess: (blob) => {
      downloadBlob(blob, `products-export-${Date.now()}.xlsx`);
      toast.success("تم تصدير المنتجات بنجاح");
    },
    onError: (error) => toast.error(getErrorMessage(error, "فشل التصدير")),
  });

  const validateMutation = useMutation({
    mutationFn: (selectedFile: File) => productsApi.validateImportFile(selectedFile),
    onSuccess: (data) => {
      if (data?.errors?.length) {
        toast.warning(`اكتمل التحقق مع ${data.errors.length} ملاحظة/خطأ`);
      } else {
        toast.success("الملف صالح للاستيراد");
      }
    },
    onError: (error) => toast.error(getErrorMessage(error, "فشل التحقق من الملف")),
  });

  const importMutation = useMutation({
    mutationFn: (selectedFile: File) =>
      productsApi.importProductsExcel(selectedFile, { mode }),
    onSuccess: (data) => {
      const payload = (data?.validation ? data.validation : data) as ProductsImportExportResult;
      setResult(payload);
      toast.success("اكتملت عملية الاستيراد");
      queryClient.invalidateQueries({ queryKey: ["products"] });
    },
    onError: (error) => toast.error(getErrorMessage(error, "فشل الاستيراد")),
  });

  const partialMutation = useMutation({
    mutationFn: (selectedFile: File) => productsApi.partialUpdateProductsExcel(selectedFile),
    onSuccess: (data) => {
      setResult(data);
      toast.success("تم التحديث الجزئي بنجاح");
      queryClient.invalidateQueries({ queryKey: ["products"] });
    },
    onError: (error) => toast.error(getErrorMessage(error, "فشل التحديث الجزئي")),
  });

  const toggleOptionalTemplateField = (field: string) => {
    setSelectedOptionalTemplateFields((prev) =>
      prev.includes(field)
        ? prev.filter((item) => item !== field)
        : [...prev, field],
    );
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[90vh] max-w-3xl overflow-y-auto">
        <DialogHeader>
          <DialogTitle>استيراد / تصدير المنتجات (Excel)</DialogTitle>
          <DialogDescription>
            تحميل القالب، التحقق من الملف، الاستيراد الكامل، أو التحديث الجزئي (سعر/مخزون/حالة).
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          <div className="flex flex-wrap gap-2">
            <Button
              variant="outline"
              onClick={() => downloadTemplateMutation.mutate()}
              disabled={downloadTemplateMutation.isPending}
            >
              <Download className="h-4 w-4" /> تحميل القالب
            </Button>
            <Button
              variant="outline"
              onClick={() => exportMutation.mutate()}
              disabled={exportMutation.isPending}
            >
              <Download className="h-4 w-4" /> تصدير المنتجات
            </Button>
          </div>

          <div className="rounded-lg border p-3 space-y-3">
            <div className="flex items-center justify-between gap-2">
              <div>
                <p className="text-sm font-medium">تخصيص أعمدة قالب الاستيراد</p>
                <p className="text-xs text-gray-500">
                  الافتراضي: الحقول الإلزامية فقط. الحقول الاختيارية المختارة: {selectedOptionalTemplateFields.length}
                </p>
              </div>
              <div className="flex gap-2">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    setSelectedOptionalTemplateFields(
                      optionalTemplateFields.map((field) => field.key),
                    )
                  }
                >
                  تحديد الكل
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={() => setSelectedOptionalTemplateFields([])}
                >
                  إلغاء الكل
                </Button>
              </div>
            </div>

            <div className="space-y-2">
              <p className="text-xs text-gray-600">الحقول الإلزامية:</p>
              <div className="flex flex-wrap gap-2">
                {requiredTemplateFields.map((field) => (
                  <span
                    key={field.key}
                    className="inline-flex flex-col rounded-md bg-emerald-50 px-2 py-1 text-xs text-emerald-700"
                  >
                    <span className="font-medium">{field.label}</span>
                    <span className="text-[11px] text-emerald-800">{field.descriptionAr}</span>
                  </span>
                ))}
              </div>
            </div>

            <div className="space-y-2">
              <p className="text-xs text-gray-600">الحقول الاختيارية:</p>
              <div className="grid gap-2 sm:grid-cols-2 md:grid-cols-3">
                {optionalTemplateFields.map((field) => {
                  const checked = selectedOptionalTemplateFields.includes(field.key);
                  return (
                    <label
                      key={field.key}
                      className="flex items-center gap-2 rounded-md border px-2 py-1.5 text-xs cursor-pointer"
                    >
                      <input
                        type="checkbox"
                        checked={checked}
                        onChange={() => toggleOptionalTemplateField(field.key)}
                      />
                      <span className="flex flex-col gap-0.5">
                        <span className="font-medium">{field.label}</span>
                        <span className="text-[11px] text-gray-500">{field.descriptionAr}</span>
                      </span>
                    </label>
                  );
                })}
              </div>
            </div>
          </div>

          <div className="grid gap-3">
            <Input
              type="file"
              accept=".xlsx"
              onChange={(e) => {
                const selected = e.target.files?.[0] || null;
                setFile(selected);
                setResult(null);
              }}
            />
            {fileName && <p className="text-xs text-gray-500">الملف: {fileName}</p>}
          </div>

          <div className="flex items-center gap-2">
            <label className="text-sm text-gray-600">وضع الاستيراد:</label>
            <select
              value={mode}
              onChange={(e) => setMode(e.target.value as ImportMode)}
              className="h-9 rounded-md border border-gray-300 px-2 text-sm"
            >
              <option value="upsert">upsert (إنشاء/تحديث)</option>
              <option value="create">create (إنشاء فقط)</option>
              <option value="update">update (تحديث فقط)</option>
            </select>
          </div>

          <div className="flex flex-wrap gap-2">
            <Button
              onClick={() => file && validateMutation.mutate(file)}
              disabled={!file || validateMutation.isPending}
              variant="outline"
            >
              <FileSearch className="h-4 w-4" /> تحقق من الملف
            </Button>
            <Button
              onClick={() => file && importMutation.mutate(file)}
              disabled={!file || importMutation.isPending}
            >
              <FileUp className="h-4 w-4" /> استيراد كامل
            </Button>
            <Button
              onClick={() => file && partialMutation.mutate(file)}
              disabled={!file || partialMutation.isPending}
              variant="secondary"
            >
              <RefreshCw className="h-4 w-4" /> تحديث جزئي
            </Button>
          </div>

          {result && (
            <div className="rounded-lg border p-3 text-sm space-y-2">
              <p>
                الإجمالي: {result.summary.total} | إنشاء: {result.summary.created} | تحديث: {result.summary.updated} | تخطي: {result.summary.skipped} | أخطاء: {result.summary.errors}
              </p>
              {result.errors.length > 0 && (
                <div className="max-h-40 overflow-auto rounded bg-red-50 p-2 text-xs">
                  {result.errors.slice(0, 20).map((err, idx) => (
                    <p key={`${err.row}-${idx}`}>
                      [{err.sheet}] صف {err.row} - {err.field}: {err.message}
                    </p>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>
            إغلاق
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function downloadBlob(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}
