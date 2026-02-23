import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { type ReactElement, useEffect } from "react";
import { useTranslation } from "react-i18next";
import {
  QueryClient,
  QueryClientProvider,
  MutationCache,
} from "@tanstack/react-query";
import { Toaster } from "sonner";
import { AuthProvider } from "@/contexts/AuthContext";
import { ThemeProvider } from "@/contexts/ThemeContext";
import { ProtectedRoute } from "@/components/ProtectedRoute";
import { ErrorBoundary } from "@/components/ErrorBoundary";
import { showApiErrorToast } from "@/hooks/useToast";
import { MainLayout } from "@/components/layout";
import { routeAccessConfig } from "@/config/navigation";
import { LoginPage } from "@/pages/auth/LoginPage";
import { DashboardPage } from "@/pages/dashboard/DashboardPage";
import { AdminsPage } from "@/pages/admins/AdminsPage";
import { CustomersPage } from "@/pages/customers/CustomersPage";
import { ProductsPage } from "@/pages/products/ProductsPage";
import { OrdersPage } from "@/pages/orders/OrdersPage";
import { OrderDetailsPage } from "@/pages/orders/OrderDetailsPage";
import { CategoriesPage } from "@/pages/categories/CategoriesPage";
import { InventoryPage } from "@/pages/inventory/InventoryPage";
import { PromotionsPage } from "@/pages/promotions/PromotionsPage";
import { NotificationsPage } from "@/pages/notifications/NotificationsPage";
import { SupportPage } from "@/pages/support/SupportPage";
import { AnalyticsPage } from "@/pages/analytics/AnalyticsPage";
import { SettingsPage } from "@/pages/settings/SettingsPage";
import { SuppliersPage } from "@/pages/suppliers/SuppliersPage";
import { PurchaseOrdersPage } from "@/pages/suppliers/PurchaseOrdersPage";
import { ReturnsPage } from "@/pages/returns/ReturnsPage";
import { RolesPage } from "@/pages/roles/RolesPage";
import { AuditLogsPage } from "@/pages/audit/AuditLogsPage";
import { ContentPage } from "@/pages/content/ContentPage";
import { EducationalContentPage } from "@/pages/content/EducationalContentPage";
import { WalletPage } from "@/pages/wallet/WalletPage";
import { CatalogPage } from "@/pages/catalog/CatalogPage";
import { PasswordResetRequestsPage } from "@/pages/auth/PasswordResetRequestsPage";
import { PriceLevelsPage } from "@/pages/price-levels/PriceLevelsPage";

// Import i18n configuration
import "@/locales/i18n";

// Create a client for React Query
const queryClient = new QueryClient({
  mutationCache: new MutationCache({
    onError: (error, _variables, _context, mutation) => {
      // Only show global toast if the mutation has no local onError
      if (!mutation.options.onError) {
        showApiErrorToast(error);
      }
    },
  }),
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      retry: 1,
    },
  },
});

function App() {
  const { i18n } = useTranslation();

  useEffect(() => {
    const dir = i18n.dir();
    document.documentElement.setAttribute("dir", dir);
    document.body.setAttribute("dir", dir);
    document.documentElement.setAttribute(
      "lang",
      i18n.language === "ar" ? "ar" : "en"
    );
  }, [i18n, i18n.language]);

  const withAccess = (path: string, element: ReactElement) => {
    const requiredAccess = routeAccessConfig[path];

    if (!requiredAccess) {
      return element;
    }

    return (
      <ProtectedRoute requiredAccess={requiredAccess}>{element}</ProtectedRoute>
    );
  };

  return (
    <ErrorBoundary>
      <ThemeProvider>
        <QueryClientProvider client={queryClient}>
          <BrowserRouter>
            <AuthProvider>
              <Routes>
                {/* Public Routes */}
                <Route path="/login" element={<LoginPage />} />

                {/* Protected Routes */}
                <Route
                  path="/"
                  element={
                    <ProtectedRoute>
                      <MainLayout />
                    </ProtectedRoute>
                  }
                >
                  <Route index element={<DashboardPage />} />
                  <Route
                    path="admins"
                    element={withAccess("/admins", <AdminsPage />)}
                  />
                  <Route
                    path="customers"
                    element={withAccess("/customers", <CustomersPage />)}
                  />
                  <Route
                    path="password-reset-requests"
                    element={withAccess(
                      "/password-reset-requests",
                      <PasswordResetRequestsPage />
                    )}
                  />
                  <Route
                    path="products"
                    element={withAccess("/products", <ProductsPage />)}
                  />
                  <Route
                    path="price-levels"
                    element={withAccess("/price-levels", <PriceLevelsPage />)}
                  />
                  <Route
                    path="categories"
                    element={withAccess("/categories", <CategoriesPage />)}
                  />
                  <Route
                    path="catalog"
                    element={withAccess("/catalog", <CatalogPage />)}
                  />
                  <Route
                    path="orders"
                    element={withAccess("/orders", <OrdersPage />)}
                  />
                  <Route
                    path="orders/:orderId"
                    element={withAccess(
                      "/orders/:orderId",
                      <OrderDetailsPage />
                    )}
                  />
                  <Route
                    path="inventory"
                    element={withAccess("/inventory", <InventoryPage />)}
                  />
                  <Route
                    path="suppliers"
                    element={withAccess("/suppliers", <SuppliersPage />)}
                  />
                  <Route
                    path="purchase-orders"
                    element={withAccess(
                      "/purchase-orders",
                      <PurchaseOrdersPage />
                    )}
                  />
                  <Route
                    path="returns"
                    element={withAccess("/returns", <ReturnsPage />)}
                  />
                  <Route
                    path="roles"
                    element={withAccess("/roles", <RolesPage />)}
                  />
                  <Route
                    path="promotions"
                    element={withAccess("/promotions", <PromotionsPage />)}
                  />
                  <Route
                    path="notifications"
                    element={withAccess(
                      "/notifications",
                      <NotificationsPage />
                    )}
                  />
                  <Route
                    path="support"
                    element={withAccess("/support", <SupportPage />)}
                  />
                  <Route
                    path="analytics"
                    element={withAccess("/analytics", <AnalyticsPage />)}
                  />
                  <Route
                    path="audit"
                    element={withAccess("/audit", <AuditLogsPage />)}
                  />
                  <Route
                    path="content"
                    element={withAccess("/content", <ContentPage />)}
                  />
                  <Route
                    path="educational-content"
                    element={withAccess(
                      "/educational-content",
                      <EducationalContentPage />
                    )}
                  />
                  <Route
                    path="wallet"
                    element={withAccess("/wallet", <WalletPage />)}
                  />
                  <Route
                    path="settings"
                    element={withAccess("/settings", <SettingsPage />)}
                  />
                </Route>

                {/* Catch all - redirect to dashboard */}
                <Route path="*" element={<Navigate to="/" replace />} />
              </Routes>
            </AuthProvider>
            <Toaster
              position="top-center"
              dir={i18n.dir() as "rtl" | "ltr"}
              richColors
              closeButton
              toastOptions={{ duration: 4000 }}
            />
          </BrowserRouter>
        </QueryClientProvider>
      </ThemeProvider>
    </ErrorBoundary>
  );
}

export default App;
