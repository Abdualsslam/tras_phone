import { useTranslation } from "react-i18next";
import { useAuth } from "@/contexts/AuthContext";
import { useTheme } from "@/contexts/ThemeContext";
import { updateDocumentDirection } from "@/locales/i18n";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { getInitials } from "@/lib/utils";
import { Bell, Globe, LogOut, Menu, Moon, Search, Sun } from "lucide-react";

interface HeaderProps {
  onMenuClick: () => void;
}

export function Header({ onMenuClick }: HeaderProps) {
  const { t, i18n } = useTranslation();
  const { user, logout } = useAuth();
  const { isDark, toggleTheme } = useTheme();

  const toggleLanguage = () => {
    const newLang = i18n.dir() === "rtl" ? "en" : "ar";
    i18n.changeLanguage(newLang);
    updateDocumentDirection(newLang);
  };

  return (
    <header className="h-16 bg-white dark:bg-slate-900 border-b border-gray-200 dark:border-slate-700 flex items-center justify-between px-4 gap-4 transition-colors duration-300">
      {/* Left side */}
      <div className="flex items-center gap-4">
        <Button
          variant="ghost"
          size="icon"
          onClick={onMenuClick}
          className="lg:hidden dark:text-gray-300 dark:hover:bg-slate-800"
        >
          <Menu className="h-5 w-5" />
        </Button>

        {/* Search */}
        <div className="hidden md:flex items-center gap-2 bg-gray-100 dark:bg-slate-800 rounded-lg px-3 py-2 w-80">
          <Search className="h-4 w-4 text-gray-400 dark:text-gray-500" />
          <input
            type="text"
            placeholder={t("common.search")}
            className="bg-transparent border-none outline-none text-sm flex-1 placeholder:text-gray-400 dark:placeholder:text-gray-500 dark:text-gray-200"
          />
        </div>
      </div>

      {/* Right side */}
      <div className="flex items-center gap-2">
        {/* Dark Mode Toggle */}
        <Button
          variant="ghost"
          size="icon"
          onClick={toggleTheme}
          className="dark:text-gray-300 dark:hover:bg-slate-800"
          title={
            isDark
              ? t("common.switchToLightMode")
              : t("common.switchToDarkMode")
          }
        >
          {isDark ? <Sun className="h-5 w-5" /> : <Moon className="h-5 w-5" />}
        </Button>

        {/* Language Toggle */}
        <Button
          variant="ghost"
          size="icon"
          onClick={toggleLanguage}
          className="dark:text-gray-300 dark:hover:bg-slate-800"
        >
          <Globe className="h-5 w-5" />
        </Button>

        {/* Notifications */}
        <Button
          variant="ghost"
          size="icon"
          className="relative dark:text-gray-300 dark:hover:bg-slate-800"
        >
          <Bell className="h-5 w-5" />
          <span className="absolute top-1 end-1 w-2 h-2 bg-red-500 rounded-full" />
        </Button>

        {/* User Menu */}
        <div className="flex items-center gap-3 ps-3 border-s border-gray-200 dark:border-slate-700">
          <div className="hidden sm:block text-end">
            <p className="text-sm font-medium text-gray-900 dark:text-gray-100">
              {user?.fullName}
            </p>
            <p className="text-xs text-gray-500 dark:text-gray-400">
              {user?.department || t("common.systemAdmin")}
            </p>
          </div>
          <Avatar>
            <AvatarImage src={user?.userId?.avatar} alt={user?.fullName} />
            <AvatarFallback className="dark:bg-slate-700 dark:text-gray-200">
              {user?.fullName ? getInitials(user.fullName) : "AD"}
            </AvatarFallback>
          </Avatar>
          <Button
            variant="ghost"
            size="icon"
            onClick={logout}
            className="dark:text-gray-300 dark:hover:bg-slate-800"
          >
            <LogOut className="h-5 w-5" />
          </Button>
        </div>
      </div>
    </header>
  );
}
