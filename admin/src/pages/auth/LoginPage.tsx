import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useAuth } from '@/contexts/AuthContext';
import { useTheme } from '@/contexts/ThemeContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Globe, Loader2, Eye, EyeOff } from 'lucide-react';
import { updateDocumentDirection } from '@/locales/i18n';
import logo from '@/assets/logo.png';
import logoDark from '@/assets/logo_dark.png';

const loginSchema = z.object({
    email: z.string().email('البريد الإلكتروني غير صحيح'),
    password: z.string().min(6, 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'),
});

type LoginFormData = z.infer<typeof loginSchema>;

export function LoginPage() {
    const { t, i18n } = useTranslation();
    const { login } = useAuth();
    const { isDark } = useTheme();
    const navigate = useNavigate();
    const [showPassword, setShowPassword] = useState(false);
    const [error, setError] = useState('');
    const currentLogo = isDark ? logoDark : logo;

    const {
        register,
        handleSubmit,
        formState: { errors, isSubmitting },
    } = useForm<LoginFormData>({
        resolver: zodResolver(loginSchema),
    });

    const onSubmit = async (data: LoginFormData) => {
        try {
            setError('');
            await login(data);
            navigate('/');
        } catch {
            setError(t('auth.loginError'));
        }
    };

    const toggleLanguage = () => {
        const newLang = i18n.language === 'ar' ? 'en' : 'ar';
        i18n.changeLanguage(newLang);
        updateDocumentDirection(newLang);
    };

    return (
        <div className="min-h-screen bg-gradient-to-br from-primary-600 via-primary-700 to-primary-900 flex items-center justify-center p-4">
            {/* Background Pattern */}
            <div
                className="absolute inset-0 pointer-events-none opacity-10"
                style={{
                    backgroundImage: 'radial-gradient(circle, white 1px, transparent 1px)',
                    backgroundSize: '30px 30px'
                }}
            />

            {/* Language Toggle */}
            <Button
                variant="ghost"
                size="icon"
                onClick={toggleLanguage}
                className="absolute top-4 end-4 text-white hover:bg-white/20"
            >
                <Globe className="h-5 w-5" />
            </Button>

            <Card className="w-full max-w-md shadow-2xl animate-fade-in">
                <CardHeader className="text-center pb-2">
                    {/* Logo */}
                    <div className="mx-auto mb-4 flex justify-center">
                        <img 
                            src={currentLogo} 
                            alt="TRAS Logo" 
                            className="h-20 w-auto object-contain max-w-[200px]"
                        />
                    </div>
                    <CardTitle className="text-2xl font-bold">{t('auth.welcomeBack')}</CardTitle>
                    <CardDescription className="text-gray-500">
                        {t('auth.loginSubtitle')}
                    </CardDescription>
                </CardHeader>

                <CardContent>
                    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                        {error && (
                            <div className="bg-red-50 text-red-600 text-sm p-3 rounded-lg text-center">
                                {error}
                            </div>
                        )}

                        <div className="space-y-2">
                            <Label htmlFor="email">{t('auth.email')}</Label>
                            <Input
                                id="email"
                                type="email"
                                placeholder="admin@trasphone.com"
                                {...register('email')}
                                error={!!errors.email}
                            />
                            {errors.email && (
                                <p className="text-red-500 text-xs">{errors.email.message}</p>
                            )}
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="password">{t('auth.password')}</Label>
                            <div className="relative">
                                <Input
                                    id="password"
                                    type={showPassword ? 'text' : 'password'}
                                    placeholder="••••••••"
                                    {...register('password')}
                                    error={!!errors.password}
                                />
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    className="absolute end-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                                >
                                    {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                                </button>
                            </div>
                            {errors.password && (
                                <p className="text-red-500 text-xs">{errors.password.message}</p>
                            )}
                        </div>

                        <div className="flex items-center justify-between text-sm">
                            <label className="flex items-center gap-2 cursor-pointer">
                                <input type="checkbox" className="rounded border-gray-300" />
                                <span className="text-gray-600">{t('auth.rememberMe')}</span>
                            </label>
                            <button type="button" className="text-primary-600 hover:underline">
                                {t('auth.forgotPassword')}
                            </button>
                        </div>

                        <Button type="submit" className="w-full" disabled={isSubmitting}>
                            {isSubmitting ? (
                                <>
                                    <Loader2 className="h-4 w-4 animate-spin" />
                                    {t('common.loading')}
                                </>
                            ) : (
                                t('auth.loginButton')
                            )}
                        </Button>
                    </form>
                </CardContent>
            </Card>
        </div>
    );
}
