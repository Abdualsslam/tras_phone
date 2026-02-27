import { useEffect, useMemo, useState, type ReactNode } from "react";
import { useForm } from "react-hook-form";
import { ArrowDownCircle, ArrowUpCircle, Gift, Loader2 } from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { formatCurrency } from "@/lib/utils";

export type WalletOperationType = "credit" | "debit" | "points";

interface WalletOperationWizardForm {
  amount: number;
  points: number;
  description: string;
  reason: string;
  reference: string;
}

interface WalletOperationSubmitData {
  amount?: number;
  points?: number;
  description?: string;
  reason?: string;
  reference?: string;
}

interface WalletOperationWizardDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  selectedCustomerId: string;
  selectedCustomerName: string;
  walletBalance: number;
  canAddCredit: boolean;
  canDeduct: boolean;
  canAdjustPoints: boolean;
  isSubmitting: boolean;
  defaultOperation?: WalletOperationType;
  onSubmit: (operationType: WalletOperationType, data: WalletOperationSubmitData) => void;
}

const operationMeta: Record<WalletOperationType, { label: string; icon: ReactNode }> = {
  credit: { label: "إضافة رصيد", icon: <ArrowUpCircle className="h-4 w-4" /> },
  debit: { label: "خصم رصيد", icon: <ArrowDownCircle className="h-4 w-4" /> },
  points: { label: "منح نقاط", icon: <Gift className="h-4 w-4" /> },
};

export function WalletOperationWizardDialog({
  open,
  onOpenChange,
  selectedCustomerId,
  selectedCustomerName,
  walletBalance,
  canAddCredit,
  canDeduct,
  canAdjustPoints,
  isSubmitting,
  defaultOperation = "credit",
  onSubmit,
}: WalletOperationWizardDialogProps) {
  const [step, setStep] = useState<1 | 2>(1);
  const [operationType, setOperationType] = useState<WalletOperationType>(defaultOperation);

  const allowedOperations = useMemo(
    () =>
      [
        canAddCredit ? ("credit" as const) : null,
        canDeduct ? ("debit" as const) : null,
        canAdjustPoints ? ("points" as const) : null,
      ].filter((value): value is WalletOperationType => Boolean(value)),
    [canAddCredit, canDeduct, canAdjustPoints],
  );

  const form = useForm<WalletOperationWizardForm>({
    defaultValues: {
      amount: 0,
      points: 0,
      description: "",
      reason: "",
      reference: "",
    },
  });

  useEffect(() => {
    if (!open) {
      setStep(1);
      return;
    }

    if (allowedOperations.length === 0) {
      return;
    }

    const nextDefault = allowedOperations.includes(defaultOperation)
      ? defaultOperation
      : allowedOperations[0];

    setOperationType(nextDefault);
    setStep(1);
    form.reset({ amount: 0, points: 0, description: "", reason: "", reference: "" });
  }, [open, defaultOperation, allowedOperations, form]);

  const validateStepOne = async () => {
    if (operationType === "points") {
      return form.trigger(["points", "reason"]);
    }
    return form.trigger(["amount", "description"]);
  };

  const handleNext = async () => {
    const valid = await validateStepOne();
    if (!valid) {
      return;
    }
    setStep(2);
  };

  const handleConfirm = () => {
    const values = form.getValues();

    if (operationType === "points") {
      onSubmit(operationType, {
        points: values.points,
        reason: values.reason.trim(),
      });
      return;
    }

    onSubmit(operationType, {
      amount: values.amount,
      description: values.description.trim(),
      reference: values.reference.trim() || undefined,
    });
  };

  const amountValue = Number(form.watch("amount") || 0);
  const pointsValue = Number(form.watch("points") || 0);
  const previewBalance =
    operationType === "credit"
      ? walletBalance + amountValue
      : operationType === "debit"
        ? walletBalance - amountValue
        : walletBalance;

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>تنفيذ عملية محفظة</DialogTitle>
        </DialogHeader>

        <div className="mb-2 flex items-center gap-2 text-xs">
          <Badge variant={step === 1 ? "default" : "outline"}>1. إدخال البيانات</Badge>
          <Badge variant={step === 2 ? "default" : "outline"}>2. المراجعة والتأكيد</Badge>
        </div>

        {allowedOperations.length > 0 && (
          <div className="grid grid-cols-1 gap-2 md:grid-cols-3">
            {allowedOperations.map((type) => (
              <Button
                key={type}
                type="button"
                variant={operationType === type ? "default" : "outline"}
                className="justify-start gap-2"
                onClick={() => {
                  setOperationType(type);
                  setStep(1);
                }}
              >
                {operationMeta[type].icon}
                {operationMeta[type].label}
              </Button>
            ))}
          </div>
        )}

        {step === 1 ? (
          <form className="space-y-4">
            <div className="rounded-md border bg-muted/30 px-3 py-2 text-xs">
              العميل: <span className="font-medium">{selectedCustomerName || selectedCustomerId || "-"}</span>
            </div>

            {operationType === "points" ? (
              <>
                <div className="space-y-2">
                  <Label>عدد النقاط *</Label>
                  <Input
                    type="number"
                    min="1"
                    {...form.register("points", {
                      valueAsNumber: true,
                      required: true,
                      min: 1,
                    })}
                    placeholder="0"
                  />
                </div>
                <div className="space-y-2">
                  <Label>السبب *</Label>
                  <Textarea
                    {...form.register("reason", {
                      required: true,
                      validate: (value) => value.trim().length > 0 || "السبب مطلوب",
                    })}
                    placeholder="سبب منح النقاط..."
                  />
                </div>
              </>
            ) : (
              <>
                <div className="space-y-2">
                  <Label>المبلغ *</Label>
                  <Input
                    type="number"
                    step="0.01"
                    min="0.01"
                    {...form.register("amount", {
                      valueAsNumber: true,
                      required: true,
                      min: 0.01,
                    })}
                    placeholder="0.00"
                  />
                </div>
                <div className="space-y-2">
                  <Label>الوصف *</Label>
                  <Textarea
                    {...form.register("description", {
                      required: true,
                      validate: (value) => value.trim().length > 0 || "الوصف مطلوب",
                    })}
                    placeholder={operationType === "credit" ? "سبب إضافة الرصيد..." : "سبب خصم الرصيد..."}
                  />
                </div>
                <div className="space-y-2">
                  <Label>المرجع</Label>
                  <Input {...form.register("reference")} placeholder="رقم المرجع (اختياري)" />
                </div>
              </>
            )}
          </form>
        ) : (
          <div className="space-y-3 text-sm">
            <div className="rounded-md border p-3 space-y-2">
              <div className="flex justify-between">
                <span className="text-muted-foreground">العملية</span>
                <span className="font-medium">{operationMeta[operationType].label}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">العميل</span>
                <span className="font-medium">{selectedCustomerName || selectedCustomerId || "-"}</span>
              </div>
              {operationType === "points" ? (
                <>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">عدد النقاط</span>
                    <span className="font-medium">{pointsValue.toLocaleString()}</span>
                  </div>
                  <div className="flex justify-between gap-4">
                    <span className="text-muted-foreground">السبب</span>
                    <span className="font-medium text-end">{form.watch("reason") || "-"}</span>
                  </div>
                </>
              ) : (
                <>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">المبلغ</span>
                    <span className="font-medium">{formatCurrency(amountValue)}</span>
                  </div>
                  <div className="flex justify-between gap-4">
                    <span className="text-muted-foreground">الوصف</span>
                    <span className="font-medium text-end">{form.watch("description") || "-"}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">المرجع</span>
                    <span className="font-medium">{form.watch("reference") || "-"}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">الرصيد قبل</span>
                    <span>{formatCurrency(walletBalance)}</span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">الرصيد بعد</span>
                    <span className={previewBalance < 0 ? "text-red-600 font-medium" : "font-medium"}>
                      {formatCurrency(previewBalance)}
                    </span>
                  </div>
                </>
              )}
            </div>
          </div>
        )}

        <DialogFooter>
          {step === 1 ? (
            <>
              <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
                إلغاء
              </Button>
              <Button type="button" onClick={handleNext}>
                متابعة
              </Button>
            </>
          ) : (
            <>
              <Button type="button" variant="outline" onClick={() => setStep(1)}>
                رجوع
              </Button>
              <Button type="button" onClick={handleConfirm} disabled={isSubmitting}>
                {isSubmitting && <Loader2 className="h-4 w-4 ms-2 animate-spin" />}
                تأكيد العملية
              </Button>
            </>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export default WalletOperationWizardDialog;
