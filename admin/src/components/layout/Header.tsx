import { useTranslation } from 'react-i18next';
import { useAuth } from '@/contexts/AuthContext';
import { updateDocumentDirection } from '@/locales/i18n';
import { Button } from '@/components/ui/button';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { getInitials } from '@/lib/utils';
import {
    Bell,
    Globe,
    LogOut,
    Menu,
    Search,
} from 'lucide-react';

interface HeaderProps {
    onMenuClick: () => void;
}

export function Header({ onMenuClick }: HeaderProps) {
    const { t, i18n } = useTranslation();
    const { user, logout } = useAuth();

    const toggleLanguage = () => {
        const newLang = i18n.language === 'ar' ? 'en' : 'ar';
        i18n.changeLanguage(newLang);
        updateDocumentDirection(newLang);
    };

    return (
        <header className="h-16 bg-white border-b border-gray-200 flex items-center justify-between px-4 gap-4">
            {/* Left side */}
            <div className="flex items-center gap-4">
                <Button variant="ghost" size="icon" onClick={onMenuClick} className="lg:hidden">
                    <Menu className="h-5 w-5" />
                </Button>

                {/* Search */}
                <div className="hidden md:flex items-center gap-2 bg-gray-100 rounded-lg px-3 py-2 w-80">
                    <Search className="h-4 w-4 text-gray-400" />
                    <input
                        type="text"
                        placeholder={t('common.search')}
                        className="bg-transparent border-none outline-none text-sm flex-1 placeholder:text-gray-400"
                    />
                </div>
            </div>

            {/* Right side */}
            <div className="flex items-center gap-2">
                {/* Language Toggle */}
                <Button variant="ghost" size="icon" onClick={toggleLanguage}>
                    <Globe className="h-5 w-5" />
                </Button>

                {/* Notifications */}
                <Button variant="ghost" size="icon" className="relative">
                    <Bell className="h-5 w-5" />
                    <span className="absolute top-1 end-1 w-2 h-2 bg-red-500 rounded-full" />
                </Button>

                {/* User Menu */}
                <div className="flex items-center gap-3 ps-3 border-s border-gray-200">
                    <div className="hidden sm:block text-end">
                        <p className="text-sm font-medium text-gray-900">{user?.name}</p>
                        <p className="text-xs text-gray-500">{user?.department || 'Admin'}</p>
                    </div>
                    <Avatar>
                        <AvatarImage src={user?.avatar} alt={user?.name} />
                        <AvatarFallback>{user?.name ? getInitials(user.name) : 'AD'}</AvatarFallback>
                    </Avatar>
                    <Button variant="ghost" size="icon" onClick={logout}>
                        <LogOut className="h-5 w-5" />
                    </Button>
                </div>
            </div>
        </header>
    );
}
