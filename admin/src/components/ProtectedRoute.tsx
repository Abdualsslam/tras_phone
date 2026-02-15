import { Link, Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import type { AccessRequirement } from '@/types';
import { Button } from '@/components/ui/button';

interface ProtectedRouteProps {
    children: React.ReactNode;
    requiredAccess?: AccessRequirement;
}

export function ProtectedRoute({ children, requiredAccess }: ProtectedRouteProps) {
    const { isAuthenticated, isLoading, hasAccess } = useAuth();
    const location = useLocation();

    if (isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gray-50">
                <div className="flex flex-col items-center gap-4">
                    <div className="w-12 h-12 border-4 border-primary-200 border-t-primary-600 rounded-full animate-spin" />
                    <p className="text-gray-500">جاري التحميل...</p>
                </div>
            </div>
        );
    }

    if (!isAuthenticated) {
        return <Navigate to="/login" state={{ from: location }} replace />;
    }

    if (requiredAccess && !hasAccess(requiredAccess)) {
        return (
            <div className="min-h-[50vh] flex items-center justify-center">
                <div className="max-w-md w-full rounded-xl border border-red-200 bg-red-50/70 p-6 text-center space-y-3 dark:border-red-800 dark:bg-red-900/10">
                    <h2 className="text-lg font-semibold text-red-800 dark:text-red-300">غير مصرح بالوصول</h2>
                    <p className="text-sm text-red-700 dark:text-red-400">
                        ليس لديك الصلاحيات المطلوبة لعرض هذه الصفحة.
                    </p>
                    <Button asChild>
                        <Link to="/">العودة للرئيسية</Link>
                    </Button>
                </div>
            </div>
        );
    }

    return <>{children}</>;
}
