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

export function ProductImportExportDialog({ open, onOpenChange }: Props) {
  const queryClient = useQueryClient();
  const [file, setFile] = useState<File | null>(null);
  const [mode, setMode] = useState<ImportMode>("upsert");
  const [result, setResult] = useState<ProductsImportExportResult | null>(null);

  const fileName = useMemo(() => file?.name || "", [file]);

  const downloadTemplateMutation = useMutation({
    mutationFn: productsApi.downloadImportTemplate,
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

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-3xl">
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
