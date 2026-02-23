import { useEffect, useMemo, useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useTheme } from '@/contexts/ThemeContext';
import { useAuth } from '@/contexts/AuthContext';
import { sidebarSections } from '@/config/navigation';
import { filterSidebarSectionsByAccess } from '@/lib/access-control';
import { cn } from '@/lib/utils';
import logo from '@/assets/logo.png';
import logoDark from '@/assets/logo_dark.png';
import { ChevronDown, ChevronRight, ChevronLeft } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface SidebarProps {
    collapsed: boolean;
    onToggle: () => void;
}

const SECTION_STATE_KEY = 'sidebarExpandedSections';

const parseExpandedSections = (): Record<string, boolean> => {
    try {
        const stored = localStorage.getItem(SECTION_STATE_KEY);
        if (!stored) {
            return {};
        }

        const parsed = JSON.parse(stored);
        if (parsed && typeof parsed === 'object') {
            return parsed as Record<string, boolean>;
        }
    } catch {
        // Ignore malformed localStorage value
    }

    return {};
};

const isPathActive = (currentPath: string, itemPath: string): boolean => {
    if (itemPath === '/') {
        return currentPath === '/';
    }

    return currentPath === itemPath || currentPath.startsWith(`${itemPath}/`);
};

export function Sidebar({ collapsed, onToggle }: SidebarProps) {
    const { t, i18n } = useTranslation();
    const { isDark } = useTheme();
    const { user } = useAuth();
    const location = useLocation();
    const isRTL = i18n.dir() === 'rtl';
    const currentLogo = isDark ? logoDark : logo;
    const [expandedSections, setExpandedSections] = useState<Record<string, boolean>>(() =>
        parseExpandedSections(),
    );

    const sections = useMemo(
        () => filterSidebarSectionsByAccess(sidebarSections, user),
        [user],
    );

    const sectionExpansion = useMemo(() => {
        const next: Record<string, boolean> = {};

        sections.forEach((section) => {
            const hasActiveItem = section.items.some((item) =>
                isPathActive(location.pathname, item.path),
            );
            const isUserExpanded = expandedSections[section.id] !== false;

            next[section.id] = isUserExpanded || hasActiveItem;
        });

        return next;
    }, [expandedSections, location.pathname, sections]);

    useEffect(() => {
        localStorage.setItem(SECTION_STATE_KEY, JSON.stringify(expandedSections));
    }, [expandedSections]);

    const toggleSection = (sectionId: string) => {
        setExpandedSections((previous) => ({
            ...previous,
            [sectionId]: previous[sectionId] === false,
        }));
    };

    return (
        <aside
            dir={i18n.dir()}
            className={cn(
                'fixed top-0 h-screen bg-white dark:bg-slate-900 border-e border-gray-200 dark:border-slate-700 transition-all duration-300 z-40 flex flex-col',
                collapsed ? 'w-[72px]' : 'w-64',
                'start-0',
            )}
        >
            <div className="h-16 flex items-center justify-center border-b border-gray-200 dark:border-slate-700 px-4">
                {collapsed ? (
                    <img
                        src={currentLogo}
                        alt="TRAS Logo"
                        className="h-10 w-10 object-contain"
                    />
                ) : (
                    <div className="flex items-center gap-3">
                        <img
                            src={currentLogo}
                            alt="TRAS Logo"
                            className="h-10 w-auto object-contain max-w-[140px]"
                        />
                    </div>
                )}
            </div>

            <nav className="flex-1 overflow-y-auto py-4 px-3 space-y-5">
                {sections.map((section) => (
                    <div key={section.id}>
                        {!collapsed && (
                            <button
                                type="button"
                                onClick={() => toggleSection(section.id)}
                                className="w-full flex items-center justify-between px-3 pb-2 text-xs font-semibold tracking-wide text-gray-400 dark:text-slate-500 uppercase"
                            >
                                <span>{t(section.labelKey)}</span>
                                    <ChevronDown
                                        className={cn(
                                            'h-4 w-4 transition-transform duration-200',
                                            !sectionExpansion[section.id] && '-rotate-90',
                                        )}
                                    />
                                </button>
                        )}
                        {(collapsed || sectionExpansion[section.id]) && (
                            <ul className="space-y-1">
                                {section.items.map((item) => (
                                    <li key={item.id}>
                                        <NavLink
                                            to={item.path}
                                            end={item.path === '/'}
                                            className={({ isActive }) =>
                                                cn(
                                                    'flex items-center gap-3 px-3 py-2.5 rounded-lg transition-all duration-200',
                                                    'hover:bg-gray-100 dark:hover:bg-slate-800',
                                                    isActive
                                                        ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-700 dark:text-primary-400 font-medium'
                                                        : 'text-gray-600 dark:text-gray-400',
                                                    collapsed && 'justify-center',
                                                )
                                            }
                                        >
                                            <item.icon className="w-5 h-5 shrink-0" />
                                            {!collapsed && <span>{t(item.labelKey)}</span>}
                                        </NavLink>
                                    </li>
                                ))}
                            </ul>
                        )}
                    </div>
                ))}

                {!collapsed && sections.length === 0 && (
                    <p className="px-3 text-sm text-gray-500 dark:text-slate-400">
                        {t('sidebar.noItems')}
                    </p>
                )}
            </nav>

            <div className="p-3 border-t border-gray-200 dark:border-slate-700">
                <Button
                    variant="ghost"
                    size="icon"
                    onClick={onToggle}
                    className="w-full"
                >
                    {isRTL ? (
                        collapsed ? <ChevronLeft className="h-5 w-5" /> : <ChevronRight className="h-5 w-5" />
                    ) : (
                        collapsed ? <ChevronRight className="h-5 w-5" /> : <ChevronLeft className="h-5 w-5" />
                    )}
                </Button>
            </div>
        </aside>
    );
}
