import { toast } from "sonner";
import { getErrorMessage } from "@/api/client";

type ToastMessage = {
  en?: string;
  ar?: string;
};

function pickMessage(message: ToastMessage | string): string {
  if (typeof message === "string") return message;
  return message.ar || message.en || "";
}

export function showApiErrorToast(
  error: unknown,
  fallback = "حدث خطأ غير متوقع"
) {
  toast.error(getErrorMessage(error, fallback));
}

export function useToast() {
  return {
    success: (message: ToastMessage | string) => {
      toast.success(pickMessage(message));
    },
    error: (message: ToastMessage | string) => {
      toast.error(pickMessage(message));
    },
    info: (message: ToastMessage | string) => {
      toast.info(pickMessage(message));
    },
    warning: (message: ToastMessage | string) => {
      toast.warning(pickMessage(message));
    },
    apiError: (error: unknown, fallback = "حدث خطأ غير متوقع") => {
      showApiErrorToast(error, fallback);
    },
    dismiss: (id?: string | number) => {
      toast.dismiss(id);
    },
  };
}

export default useToast;
