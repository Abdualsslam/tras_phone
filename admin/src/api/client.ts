import axios, { type AxiosError, type InternalAxiosRequestConfig } from "axios";
import type { ApiResponse } from "@/types";

const API_BASE_URL =
  import.meta.env.VITE_API_URL || "http://localhost:3000/api/v1";

// Create axios instance
export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// ═══════════════════════════════════════════════════════════════
// Error helpers
// ═══════════════════════════════════════════════════════════════

/**
 * Extract a user-friendly error message from an API error.
 * Prefers Arabic message (messageAr) when available.
 */
export function getErrorMessage(
  error: unknown,
  fallback = "حدث خطأ غير متوقع"
): string {
  if (axios.isAxiosError(error)) {
    const data = error.response?.data as ApiResponse<unknown> | undefined;

    // Prefer Arabic message from unified response
    if (data?.messageAr && data.messageAr !== data.message)
      return data.messageAr;
    if (data?.message) return data.message;

    // Network / timeout errors
    if (error.code === "ERR_NETWORK")
      return "لا يمكن الاتصال بالخادم. تحقق من اتصال الإنترنت";
    if (error.code === "ECONNABORTED") return "انتهت مهلة الطلب. حاول مرة أخرى";
  }

  if (error instanceof Error) return error.message;
  return fallback;
}

/**
 * Extract validation errors array from an API error response.
 */
export function getValidationErrors(
  error: unknown
): Array<{ field?: string; message: string }> {
  if (!axios.isAxiosError(error)) return [];
  const data = error.response?.data as any;
  if (Array.isArray(data?.errors)) return data.errors;
  return [];
}

// ═══════════════════════════════════════════════════════════════
// Request interceptor - add auth token
// ═══════════════════════════════════════════════════════════════

apiClient.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem("accessToken");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// ═══════════════════════════════════════════════════════════════
// Response interceptor - token refresh + error normalisation
// ═══════════════════════════════════════════════════════════════

let isRefreshing = false;
let failedQueue: Array<{
  resolve: (token: string) => void;
  reject: (error: unknown) => void;
}> = [];

const processQueue = (error: unknown, token: string | null = null) => {
  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token!);
    }
  });
  failedQueue = [];
};

apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError<ApiResponse<unknown>>) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & {
      _retry?: boolean;
    };

    // 401 → try to refresh token
    if (error.response?.status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        }).then((token) => {
          originalRequest.headers.Authorization = `Bearer ${token}`;
          return apiClient(originalRequest);
        });
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        const refreshToken = localStorage.getItem("refreshToken");
        if (!refreshToken) throw new Error("No refresh token");

        const response = await axios.post<
          ApiResponse<{ accessToken: string; refreshToken: string }>
        >(`${API_BASE_URL}/auth/refresh`, { refreshToken });

        const { accessToken, refreshToken: newRefreshToken } =
          response.data.data;
        localStorage.setItem("accessToken", accessToken);
        localStorage.setItem("refreshToken", newRefreshToken);

        processQueue(null, accessToken);

        originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        return apiClient(originalRequest);
      } catch (refreshError) {
        processQueue(refreshError, null);
        localStorage.removeItem("accessToken");
        localStorage.removeItem("refreshToken");
        localStorage.removeItem("user");
        return Promise.reject(refreshError);
      } finally {
        isRefreshing = false;
      }
    }

    return Promise.reject(error);
  }
);

export default apiClient;
