import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AuthProvider } from '@/contexts/AuthContext';
import { ThemeProvider } from '@/contexts/ThemeContext';
import { ProtectedRoute } from '@/components/ProtectedRoute';
import { MainLayout } from '@/components/layout';
import { LoginPage } from '@/pages/auth/LoginPage';
import { DashboardPage } from '@/pages/dashboard/DashboardPage';
import { AdminsPage } from '@/pages/admins/AdminsPage';
import { CustomersPage } from '@/pages/customers/CustomersPage';
import { ProductsPage } from '@/pages/products/ProductsPage';
import { OrdersPage } from '@/pages/orders/OrdersPage';
import { CategoriesPage } from '@/pages/categories/CategoriesPage';
import { InventoryPage } from '@/pages/inventory/InventoryPage';
import { PromotionsPage } from '@/pages/promotions/PromotionsPage';
import { NotificationsPage } from '@/pages/notifications/NotificationsPage';
import { SupportPage } from '@/pages/support/SupportPage';
import { AnalyticsPage } from '@/pages/analytics/AnalyticsPage';
import { SettingsPage } from '@/pages/settings/SettingsPage';
import { SuppliersPage } from '@/pages/suppliers/SuppliersPage';
import { PurchaseOrdersPage } from '@/pages/suppliers/PurchaseOrdersPage';
import { ReturnsPage } from '@/pages/returns/ReturnsPage';
import { RolesPage } from '@/pages/roles/RolesPage';
import { AuditLogsPage } from '@/pages/audit/AuditLogsPage';
import { ContentPage } from '@/pages/content/ContentPage';
import { EducationalContentPage } from '@/pages/content/EducationalContentPage';
import { WalletPage } from '@/pages/wallet/WalletPage';
import { CatalogPage } from '@/pages/catalog/CatalogPage';
import { LiveChatPage } from '@/pages/support/LiveChatPage';
import { PasswordResetRequestsPage } from '@/pages/auth/PasswordResetRequestsPage';
import { PriceLevelsPage } from '@/pages/price-levels/PriceLevelsPage';

// Import i18n configuration
import '@/locales/i18n';

// Create a client for React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      retry: 1,
    },
  },
});

function App() {
  return (
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
                <Route path="admins" element={<AdminsPage />} />
                <Route path="customers" element={<CustomersPage />} />
                <Route path="password-reset-requests" element={<PasswordResetRequestsPage />} />
                <Route path="products" element={<ProductsPage />} />
                <Route path="price-levels" element={<PriceLevelsPage />} />
                <Route path="categories" element={<CategoriesPage />} />
                <Route path="catalog" element={<CatalogPage />} />
                <Route path="orders" element={<OrdersPage />} />
                <Route path="inventory" element={<InventoryPage />} />
                <Route path="suppliers" element={<SuppliersPage />} />
                <Route path="purchase-orders" element={<PurchaseOrdersPage />} />
                <Route path="returns" element={<ReturnsPage />} />
                <Route path="roles" element={<RolesPage />} />
                <Route path="promotions" element={<PromotionsPage />} />
                <Route path="notifications" element={<NotificationsPage />} />
                <Route path="support" element={<SupportPage />} />
                <Route path="live-chat" element={<LiveChatPage />} />
                <Route path="analytics" element={<AnalyticsPage />} />
                <Route path="audit" element={<AuditLogsPage />} />
                <Route path="content" element={<ContentPage />} />
                <Route path="educational-content" element={<EducationalContentPage />} />
                <Route path="wallet" element={<WalletPage />} />
                <Route path="settings" element={<SettingsPage />} />
              </Route>

              {/* Catch all - redirect to dashboard */}
              <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
          </AuthProvider>
        </BrowserRouter>
      </QueryClientProvider>
    </ThemeProvider>
  );
}

export default App;
