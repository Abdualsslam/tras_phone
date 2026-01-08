import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { settingsApi } from '@/api/settings.api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import {
    Settings as SettingsIcon,
    Building2,
    Globe,
    Bell,
    Shield,
    CreditCard,
    Truck,
    Save,
    Loader2,
} from 'lucide-react';

export function SettingsPage() {
    const { t } = useTranslation();
    const queryClient = useQueryClient();
    const [activeTab, setActiveTab] = useState('general');

    // Fetch store settings
    const { data: storeSettings, isLoading: storeLoading } = useQuery({
        queryKey: ['settings-store'],
        queryFn: settingsApi.getStoreSettings,
        enabled: activeTab === 'general',
    });

    // Fetch localization settings
    const { data: localizationSettings, isLoading: localizationLoading } = useQuery({
        queryKey: ['settings-localization'],
        queryFn: settingsApi.getLocalizationSettings,
        enabled: activeTab === 'localization',
    });

    // Fetch notification settings
    const { data: notificationSettings, isLoading: notificationLoading } = useQuery({
        queryKey: ['settings-notifications'],
        queryFn: settingsApi.getNotificationSettings,
        enabled: activeTab === 'notifications',
    });

    // Update mutations
    const updateStoreMutation = useMutation({
        mutationFn: settingsApi.updateStoreSettings,
        onSuccess: () => queryClient.invalidateQueries({ queryKey: ['settings-store'] }),
    });

    const updateLocalizationMutation = useMutation({
        mutationFn: settingsApi.updateLocalizationSettings,
        onSuccess: () => queryClient.invalidateQueries({ queryKey: ['settings-localization'] }),
    });

    const updateNotificationsMutation = useMutation({
        mutationFn: settingsApi.updateNotificationSettings,
        onSuccess: () => queryClient.invalidateQueries({ queryKey: ['settings-notifications'] }),
    });

    const tabs = [
        { id: 'general', label: 'عام', icon: Building2 },
        { id: 'localization', label: 'اللغة والموقع', icon: Globe },
        { id: 'notifications', label: 'الإشعارات', icon: Bell },
        { id: 'security', label: 'الأمان', icon: Shield },
        { id: 'payment', label: 'الدفع', icon: CreditCard },
        { id: 'shipping', label: 'الشحن', icon: Truck },
    ];

    const isLoading =
        (activeTab === 'general' && storeLoading) ||
        (activeTab === 'localization' && localizationLoading) ||
        (activeTab === 'notifications' && notificationLoading);

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100">{t('sidebar.settings')}</h1>
                <p className="text-gray-500 dark:text-gray-400 mt-1">إعدادات النظام والتفضيلات</p>
            </div>

            <div className="grid lg:grid-cols-4 gap-6">
                {/* Sidebar */}
                <Card className="lg:col-span-1">
                    <CardContent className="p-2">
                        <nav className="space-y-1">
                            {tabs.map((tab) => (
                                <button
                                    key={tab.id}
                                    onClick={() => setActiveTab(tab.id)}
                                    className={`w-full flex items-center gap-3 px-3 py-2 rounded-lg text-sm transition-colors ${activeTab === tab.id
                                        ? 'bg-primary-50 text-primary-700 font-medium'
                                        : 'text-gray-600 hover:bg-gray-100'
                                        }`}
                                >
                                    <tab.icon className="h-4 w-4" />
                                    {tab.label}
                                </button>
                            ))}
                        </nav>
                    </CardContent>
                </Card>

                {/* Content */}
                <div className="lg:col-span-3">
                    {isLoading ? (
                        <Card>
                            <CardContent className="flex items-center justify-center py-12">
                                <Loader2 className="h-8 w-8 animate-spin text-primary-600" />
                            </CardContent>
                        </Card>
                    ) : activeTab === 'general' ? (
                        <Card>
                            <CardHeader>
                                <CardTitle>الإعدادات العامة</CardTitle>
                                <CardDescription>معلومات المتجر الأساسية</CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="grid md:grid-cols-2 gap-4">
                                    <div className="space-y-2">
                                        <Label>اسم المتجر</Label>
                                        <Input defaultValue={storeSettings?.storeName || 'TRAS Phone'} />
                                    </div>
                                    <div className="space-y-2">
                                        <Label>البريد الإلكتروني</Label>
                                        <Input type="email" defaultValue={storeSettings?.storeEmail || ''} />
                                    </div>
                                    <div className="space-y-2">
                                        <Label>رقم الهاتف</Label>
                                        <Input defaultValue={storeSettings?.storePhone || ''} dir="ltr" />
                                    </div>
                                    <div className="space-y-2">
                                        <Label>العنوان</Label>
                                        <Input defaultValue={storeSettings?.storeAddress || ''} />
                                    </div>
                                </div>
                                <div className="space-y-2">
                                    <Label>وصف المتجر</Label>
                                    <textarea
                                        className="w-full h-24 p-3 border border-gray-300 rounded-lg resize-none focus:outline-none focus:ring-2 focus:ring-primary-500"
                                        defaultValue={storeSettings?.storeDescription || ''}
                                    />
                                </div>
                                <Button disabled={updateStoreMutation.isPending}>
                                    {updateStoreMutation.isPending ? (
                                        <Loader2 className="h-4 w-4 animate-spin" />
                                    ) : (
                                        <Save className="h-4 w-4" />
                                    )}
                                    حفظ التغييرات
                                </Button>
                            </CardContent>
                        </Card>
                    ) : activeTab === 'localization' ? (
                        <Card>
                            <CardHeader>
                                <CardTitle>اللغة والموقع</CardTitle>
                                <CardDescription>إعدادات اللغة والعملة والتوقيت</CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-4">
                                <div className="grid md:grid-cols-2 gap-4">
                                    <div className="space-y-2">
                                        <Label>اللغة الافتراضية</Label>
                                        <select
                                            className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
                                            defaultValue={localizationSettings?.defaultLanguage || 'ar'}
                                        >
                                            <option value="ar">العربية</option>
                                            <option value="en">English</option>
                                        </select>
                                    </div>
                                    <div className="space-y-2">
                                        <Label>العملة</Label>
                                        <select
                                            className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
                                            defaultValue={localizationSettings?.defaultCurrency || 'SAR'}
                                        >
                                            <option value="SAR">ريال سعودي (SAR)</option>
                                            <option value="USD">دولار أمريكي (USD)</option>
                                            <option value="AED">درهم إماراتي (AED)</option>
                                        </select>
                                    </div>
                                    <div className="space-y-2">
                                        <Label>المنطقة الزمنية</Label>
                                        <select
                                            className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
                                            defaultValue={localizationSettings?.timezone || 'Asia/Riyadh'}
                                        >
                                            <option value="Asia/Riyadh">توقيت الرياض (GMT+3)</option>
                                            <option value="Asia/Dubai">توقيت دبي (GMT+4)</option>
                                        </select>
                                    </div>
                                    <div className="space-y-2">
                                        <Label>تنسيق التاريخ</Label>
                                        <select
                                            className="w-full h-10 rounded-lg border border-gray-300 px-3 text-sm"
                                            defaultValue={localizationSettings?.dateFormat || 'DD/MM/YYYY'}
                                        >
                                            <option value="DD/MM/YYYY">DD/MM/YYYY</option>
                                            <option value="MM/DD/YYYY">MM/DD/YYYY</option>
                                            <option value="YYYY-MM-DD">YYYY-MM-DD</option>
                                        </select>
                                    </div>
                                </div>
                                <Button disabled={updateLocalizationMutation.isPending}>
                                    {updateLocalizationMutation.isPending ? (
                                        <Loader2 className="h-4 w-4 animate-spin" />
                                    ) : (
                                        <Save className="h-4 w-4" />
                                    )}
                                    حفظ التغييرات
                                </Button>
                            </CardContent>
                        </Card>
                    ) : activeTab === 'notifications' ? (
                        <Card>
                            <CardHeader>
                                <CardTitle>إعدادات الإشعارات</CardTitle>
                                <CardDescription>تخصيص إشعارات البريد والتطبيق</CardDescription>
                            </CardHeader>
                            <CardContent className="space-y-6">
                                {[
                                    { key: 'newOrder', label: 'طلب جديد', desc: 'إشعار عند استلام طلب جديد' },
                                    { key: 'newCustomer', label: 'عميل جديد', desc: 'إشعار عند تسجيل عميل جديد' },
                                    { key: 'lowStock', label: 'مخزون منخفض', desc: 'تنبيه عند انخفاض المخزون' },
                                    { key: 'supportTicket', label: 'تذكرة دعم', desc: 'إشعار عند فتح تذكرة دعم جديدة' },
                                ].map((item) => (
                                    <div key={item.key} className="flex items-center justify-between py-2 border-b border-gray-100">
                                        <div>
                                            <p className="font-medium text-gray-900 dark:text-gray-100">{item.label}</p>
                                            <p className="text-sm text-gray-500">{item.desc}</p>
                                        </div>
                                        <label className="relative inline-flex items-center cursor-pointer">
                                            <input
                                                type="checkbox"
                                                className="sr-only peer"
                                                defaultChecked={(notificationSettings as any)?.[item.key] ?? true}
                                            />
                                            <div className="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-2 peer-focus:ring-primary-500 rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary-600"></div>
                                        </label>
                                    </div>
                                ))}
                                <Button disabled={updateNotificationsMutation.isPending}>
                                    {updateNotificationsMutation.isPending ? (
                                        <Loader2 className="h-4 w-4 animate-spin" />
                                    ) : (
                                        <Save className="h-4 w-4" />
                                    )}
                                    حفظ التغييرات
                                </Button>
                            </CardContent>
                        </Card>
                    ) : (
                        <Card>
                            <CardHeader>
                                <CardTitle>
                                    {activeTab === 'security' && 'إعدادات الأمان'}
                                    {activeTab === 'payment' && 'إعدادات الدفع'}
                                    {activeTab === 'shipping' && 'إعدادات الشحن'}
                                </CardTitle>
                                <CardDescription>قريباً...</CardDescription>
                            </CardHeader>
                            <CardContent className="py-12 text-center text-gray-500">
                                <SettingsIcon className="h-12 w-12 mx-auto mb-4 text-gray-300" />
                                <p>هذا القسم قيد التطوير</p>
                            </CardContent>
                        </Card>
                    )}
                </div>
            </div>
        </div>
    );
}
