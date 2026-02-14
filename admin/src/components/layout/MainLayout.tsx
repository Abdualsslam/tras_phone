import { useState } from 'react';
import { Outlet } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { cn } from '@/lib/utils';
import { Sidebar } from './Sidebar';
import { Header } from './Header';
import { useSocket } from '@/hooks/useSocket';

export function MainLayout() {
    useSocket(); // Keep WebSocket connected for support & live chat
    const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
    const [mobileSidebarOpen, setMobileSidebarOpen] = useState(false);
    const { i18n } = useTranslation();
    const isRTL = i18n.language === 'ar';

    return (
        <div className="min-h-screen bg-gray-50 dark:bg-slate-950 transition-colors duration-300">
            {/* Desktop Sidebar */}
            <div className="hidden lg:block">
                <Sidebar
                    collapsed={sidebarCollapsed}
                    onToggle={() => setSidebarCollapsed(!sidebarCollapsed)}
                />
            </div>

            {/* Mobile Sidebar Overlay */}
            {mobileSidebarOpen && (
                <div
                    className="fixed inset-0 bg-black/50 z-30 lg:hidden"
                    onClick={() => setMobileSidebarOpen(false)}
                />
            )}

            {/* Mobile Sidebar */}
            <div
                className={cn(
                    'fixed top-0 h-screen w-64 bg-white dark:bg-slate-900 z-40 transform transition-transform duration-300 lg:hidden',
                    isRTL ? 'right-0' : 'left-0',
                    mobileSidebarOpen
                        ? 'translate-x-0'
                        : isRTL
                            ? 'translate-x-full'
                            : '-translate-x-full'
                )}
            >
                <Sidebar collapsed={false} onToggle={() => setMobileSidebarOpen(false)} />
            </div>

            {/* Main Content */}
            <div
                className={cn(
                    'transition-all duration-300',
                    sidebarCollapsed ? 'lg:ms-[72px]' : 'lg:ms-64'
                )}
            >
                <Header onMenuClick={() => setMobileSidebarOpen(true)} />
                <main className="p-4 md:p-6">
                    <Outlet />
                </main>
            </div>
        </div>
    );
}
