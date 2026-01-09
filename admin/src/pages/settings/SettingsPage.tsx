import { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { useForm } from 'react-hook-form';
import {
    settingsApi,
    type Country,
    type City,
    type Currency,
    type TaxRate
} from '@/api/settings.api';
import { toast } from 'sonner';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogFooter,
} from '@/components/ui/dialog';
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table';
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select';
import {
    Globe,
    MapPin,
    Coins,
    Percent,
    Plus,
    Pencil,
    Loader2,
    Save,
    Store,
    Bell,
} from 'lucide-react';

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function SettingsPage() {
    const queryClient = useQueryClient();

    const [activeTab, setActiveTab] = useState('general');
    const [isCountryDialogOpen, setIsCountryDialogOpen] = useState(false);
    const [isCityDialogOpen, setIsCityDialogOpen] = useState(false);
    const [isCurrencyDialogOpen, setIsCurrencyDialogOpen] = useState(false);
    const [isTaxDialogOpen, setIsTaxDialogOpen] = useState(false);
    const [selectedItem, setSelectedItem] = useState<any>(null);
    const [isEditing, setIsEditing] = useState(false);

    // ─────────────────────────────────────────
    // Queries
    // ─────────────────────────────────────────

    const { data: storeSettings } = useQuery({
        queryKey: ['settings-store'],
        queryFn: () => settingsApi.getStoreSettings(),
    });

    const { data: notificationSettings } = useQuery({
        queryKey: ['settings-notifications'],
        queryFn: () => settingsApi.getNotificationSettings(),
    });

    const { data: countries = [], isLoading: countriesLoading } = useQuery({
        queryKey: ['settings-countries'],
        queryFn: () => settingsApi.getCountries(),
    });

    const { data: cities = [], isLoading: citiesLoading } = useQuery({
        queryKey: ['settings-cities'],
        queryFn: () => settingsApi.getCities(),
    });

    const { data: currencies = [], isLoading: currenciesLoading } = useQuery({
        queryKey: ['settings-currencies'],
        queryFn: () => settingsApi.getCurrencies(),
    });

    const { data: taxRates = [], isLoading: taxRatesLoading } = useQuery({
        queryKey: ['settings-tax-rates'],
        queryFn: () => settingsApi.getTaxRates(),
    });

    // ─────────────────────────────────────────
    // Mutations
    // ─────────────────────────────────────────

    const updateStoreMutation = useMutation({
        mutationFn: settingsApi.updateStoreSettings,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-store'] });
            toast.success('تم حفظ الإعدادات');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const updateNotificationsMutation = useMutation({
        mutationFn: settingsApi.updateNotificationSettings,
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-notifications'] });
            toast.success('تم حفظ إعدادات الإشعارات');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const createCountryMutation = useMutation({
        mutationFn: (data: Omit<Country, '_id'>) => settingsApi.createCountry(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-countries'] });
            setIsCountryDialogOpen(false);
            toast.success('تم إضافة الدولة');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const updateCountryMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: Partial<Country> }) => settingsApi.updateCountry(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-countries'] });
            setIsCountryDialogOpen(false);
            toast.success('تم تحديث الدولة');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const createCityMutation = useMutation({
        mutationFn: (data: Omit<City, '_id'>) => settingsApi.createCity(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-cities'] });
            setIsCityDialogOpen(false);
            toast.success('تم إضافة المدينة');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const updateCityMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: Partial<City> }) => settingsApi.updateCity(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-cities'] });
            setIsCityDialogOpen(false);
            toast.success('تم تحديث المدينة');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const createCurrencyMutation = useMutation({
        mutationFn: (data: Omit<Currency, '_id'>) => settingsApi.createCurrency(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-currencies'] });
            setIsCurrencyDialogOpen(false);
            toast.success('تم إضافة العملة');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const updateCurrencyMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: Partial<Currency> }) => settingsApi.updateCurrency(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-currencies'] });
            setIsCurrencyDialogOpen(false);
            toast.success('تم تحديث العملة');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const createTaxRateMutation = useMutation({
        mutationFn: (data: Omit<TaxRate, '_id'>) => settingsApi.createTaxRate(data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-tax-rates'] });
            setIsTaxDialogOpen(false);
            toast.success('تم إضافة معدل الضريبة');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    const updateTaxRateMutation = useMutation({
        mutationFn: ({ id, data }: { id: string; data: Partial<TaxRate> }) => settingsApi.updateTaxRate(id, data),
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings-tax-rates'] });
            setIsTaxDialogOpen(false);
            toast.success('تم تحديث معدل الضريبة');
        },
        onError: () => toast.error('حدث خطأ'),
    });

    // ─────────────────────────────────────────
    // Forms
    // ─────────────────────────────────────────

    const storeForm = useForm({
        defaultValues: storeSettings || {
            storeName: '',
            storeEmail: '',
            storePhone: '',
            storeAddress: '',
            storeDescription: '',
        },
    });

    const countryForm = useForm({
        defaultValues: {
            name: '',
            nameAr: '',
            code: '',
            phoneCode: '',
            isActive: true,
        },
    });

    const cityForm = useForm({
        defaultValues: {
            name: '',
            nameAr: '',
            countryId: '',
            isActive: true,
        },
    });

    const currencyForm = useForm({
        defaultValues: {
            name: '',
            nameAr: '',
            code: '',
            symbol: '',
            exchangeRate: 1,
            isDefault: false,
            isActive: true,
        },
    });

    const taxForm = useForm({
        defaultValues: {
            name: '',
            nameAr: '',
            rate: 0,
            countryId: '',
            isDefault: false,
            isActive: true,
        },
    });

    // ─────────────────────────────────────────
    // Handlers
    // ─────────────────────────────────────────

    const handleAddCountry = () => {
        setIsEditing(false);
        setSelectedItem(null);
        countryForm.reset({ name: '', nameAr: '', code: '', phoneCode: '', isActive: true });
        setIsCountryDialogOpen(true);
    };

    const handleEditCountry = (country: Country) => {
        setIsEditing(true);
        setSelectedItem(country);
        countryForm.reset({
            name: country.name,
            nameAr: country.nameAr || '',
            code: country.code,
            phoneCode: country.phoneCode || '',
            isActive: country.isActive,
        });
        setIsCountryDialogOpen(true);
    };

    const handleAddCity = () => {
        setIsEditing(false);
        setSelectedItem(null);
        cityForm.reset({ name: '', nameAr: '', countryId: '', isActive: true });
        setIsCityDialogOpen(true);
    };

    const handleEditCity = (city: City) => {
        setIsEditing(true);
        setSelectedItem(city);
        cityForm.reset({
            name: city.name,
            nameAr: city.nameAr || '',
            countryId: city.countryId,
            isActive: city.isActive,
        });
        setIsCityDialogOpen(true);
    };

    const handleAddCurrency = () => {
        setIsEditing(false);
        setSelectedItem(null);
        currencyForm.reset({ name: '', nameAr: '', code: '', symbol: '', exchangeRate: 1, isDefault: false, isActive: true });
        setIsCurrencyDialogOpen(true);
    };

    const handleEditCurrency = (currency: Currency) => {
        setIsEditing(true);
        setSelectedItem(currency);
        currencyForm.reset({
            name: currency.name,
            nameAr: currency.nameAr || '',
            code: currency.code,
            symbol: currency.symbol,
            exchangeRate: currency.exchangeRate,
            isDefault: currency.isDefault,
            isActive: currency.isActive,
        });
        setIsCurrencyDialogOpen(true);
    };

    const handleAddTaxRate = () => {
        setIsEditing(false);
        setSelectedItem(null);
        taxForm.reset({ name: '', nameAr: '', rate: 0, countryId: '', isDefault: false, isActive: true });
        setIsTaxDialogOpen(true);
    };

    const handleEditTaxRate = (tax: TaxRate) => {
        setIsEditing(true);
        setSelectedItem(tax);
        taxForm.reset({
            name: tax.name,
            nameAr: tax.nameAr || '',
            rate: tax.rate,
            countryId: tax.countryId || '',
            isDefault: tax.isDefault,
            isActive: tax.isActive,
        });
        setIsTaxDialogOpen(true);
    };

    const onCountrySubmit = (data: any) => {
        if (isEditing && selectedItem) {
            updateCountryMutation.mutate({ id: selectedItem._id, data });
        } else {
            createCountryMutation.mutate(data);
        }
    };

    const onCitySubmit = (data: any) => {
        if (isEditing && selectedItem) {
            updateCityMutation.mutate({ id: selectedItem._id, data });
        } else {
            createCityMutation.mutate(data);
        }
    };

    const onCurrencySubmit = (data: any) => {
        if (isEditing && selectedItem) {
            updateCurrencyMutation.mutate({ id: selectedItem._id, data });
        } else {
            createCurrencyMutation.mutate(data);
        }
    };

    const onTaxSubmit = (data: any) => {
        if (isEditing && selectedItem) {
            updateTaxRateMutation.mutate({ id: selectedItem._id, data });
        } else {
            createTaxRateMutation.mutate(data);
        }
    };

    // ─────────────────────────────────────────
    // Render
    // ─────────────────────────────────────────

    const renderLoadingState = () => (
        <div className="flex justify-center items-center h-40">
            <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
    );

    return (
        <div className="space-y-6">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold">الإعدادات</h1>
                <p className="text-muted-foreground text-sm">إدارة إعدادات النظام والتطبيق</p>
            </div>

            {/* Tabs */}
            <Tabs value={activeTab} onValueChange={setActiveTab}>
                <TabsList className="mb-4 flex-wrap">
                    <TabsTrigger value="general" className="flex items-center gap-2">
                        <Store className="h-4 w-4" />
                        عام
                    </TabsTrigger>
                    <TabsTrigger value="notifications" className="flex items-center gap-2">
                        <Bell className="h-4 w-4" />
                        الإشعارات
                    </TabsTrigger>
                    <TabsTrigger value="countries" className="flex items-center gap-2">
                        <Globe className="h-4 w-4" />
                        الدول
                    </TabsTrigger>
                    <TabsTrigger value="cities" className="flex items-center gap-2">
                        <MapPin className="h-4 w-4" />
                        المدن
                    </TabsTrigger>
                    <TabsTrigger value="currencies" className="flex items-center gap-2">
                        <Coins className="h-4 w-4" />
                        العملات
                    </TabsTrigger>
                    <TabsTrigger value="taxes" className="flex items-center gap-2">
                        <Percent className="h-4 w-4" />
                        الضرائب
                    </TabsTrigger>
                </TabsList>

                {/* General Settings Tab */}
                <TabsContent value="general">
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Store className="h-5 w-5" />
                                إعدادات المتجر
                            </CardTitle>
                        </CardHeader>
                        <CardContent>
                            <form onSubmit={storeForm.handleSubmit((data) => updateStoreMutation.mutate(data))} className="space-y-4">
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div className="space-y-2">
                                        <Label>اسم المتجر</Label>
                                        <Input {...storeForm.register('storeName')} placeholder="اسم المتجر" />
                                    </div>
                                    <div className="space-y-2">
                                        <Label>البريد الإلكتروني</Label>
                                        <Input {...storeForm.register('storeEmail')} type="email" placeholder="email@example.com" />
                                    </div>
                                    <div className="space-y-2">
                                        <Label>رقم الهاتف</Label>
                                        <Input {...storeForm.register('storePhone')} placeholder="+966..." />
                                    </div>
                                    <div className="space-y-2">
                                        <Label>العنوان</Label>
                                        <Input {...storeForm.register('storeAddress')} placeholder="العنوان الكامل" />
                                    </div>
                                </div>
                                <Button type="submit" disabled={updateStoreMutation.isPending}>
                                    {updateStoreMutation.isPending && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                    <Save className="h-4 w-4 ml-2" />
                                    حفظ
                                </Button>
                            </form>
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Notifications Tab */}
                <TabsContent value="notifications">
                    <Card>
                        <CardHeader>
                            <CardTitle className="flex items-center gap-2">
                                <Bell className="h-5 w-5" />
                                إعدادات الإشعارات
                            </CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-4">
                            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                {[
                                    { key: 'newOrder', label: 'طلب جديد' },
                                    { key: 'newCustomer', label: 'عميل جديد' },
                                    { key: 'lowStock', label: 'نفاد المخزون' },
                                    { key: 'supportTicket', label: 'تذكرة دعم' },
                                    { key: 'emailEnabled', label: 'إشعارات البريد' },
                                    { key: 'pushEnabled', label: 'إشعارات الدفع' },
                                ].map((item) => (
                                    <div key={item.key} className="flex items-center justify-between p-3 border rounded-lg">
                                        <Label>{item.label}</Label>
                                        <Switch
                                            checked={(notificationSettings as any)?.[item.key] || false}
                                            onCheckedChange={(checked: boolean) => {
                                                updateNotificationsMutation.mutate({ [item.key]: checked });
                                            }}
                                        />
                                    </div>
                                ))}
                            </div>
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Countries Tab */}
                <TabsContent value="countries">
                    <Card>
                        <CardHeader>
                            <div className="flex justify-between items-center">
                                <CardTitle className="flex items-center gap-2">
                                    <Globe className="h-5 w-5" />
                                    الدول
                                </CardTitle>
                                <Button onClick={handleAddCountry}>
                                    <Plus className="h-4 w-4 ml-2" />
                                    إضافة دولة
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {countriesLoading ? renderLoadingState() : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>الاسم</TableHead>
                                            <TableHead>الكود</TableHead>
                                            <TableHead>رمز الهاتف</TableHead>
                                            <TableHead>الحالة</TableHead>
                                            <TableHead className="w-[50px]"></TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {countries.map((country) => (
                                            <TableRow key={country._id}>
                                                <TableCell>
                                                    <div>
                                                        <p className="font-medium">{country.name}</p>
                                                        {country.nameAr && <p className="text-sm text-muted-foreground">{country.nameAr}</p>}
                                                    </div>
                                                </TableCell>
                                                <TableCell className="font-mono">{country.code}</TableCell>
                                                <TableCell>{country.phoneCode || '-'}</TableCell>
                                                <TableCell>
                                                    <Badge variant={country.isActive ? 'success' : 'secondary'}>
                                                        {country.isActive ? 'نشط' : 'غير نشط'}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>
                                                    <Button variant="ghost" size="icon" onClick={() => handleEditCountry(country)}>
                                                        <Pencil className="h-4 w-4" />
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Cities Tab */}
                <TabsContent value="cities">
                    <Card>
                        <CardHeader>
                            <div className="flex justify-between items-center">
                                <CardTitle className="flex items-center gap-2">
                                    <MapPin className="h-5 w-5" />
                                    المدن
                                </CardTitle>
                                <Button onClick={handleAddCity}>
                                    <Plus className="h-4 w-4 ml-2" />
                                    إضافة مدينة
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {citiesLoading ? renderLoadingState() : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>الاسم</TableHead>
                                            <TableHead>الدولة</TableHead>
                                            <TableHead>الحالة</TableHead>
                                            <TableHead className="w-[50px]"></TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {cities.map((city) => (
                                            <TableRow key={city._id}>
                                                <TableCell>
                                                    <div>
                                                        <p className="font-medium">{city.name}</p>
                                                        {city.nameAr && <p className="text-sm text-muted-foreground">{city.nameAr}</p>}
                                                    </div>
                                                </TableCell>
                                                <TableCell>
                                                    {countries.find(c => c._id === city.countryId)?.name || city.countryId}
                                                </TableCell>
                                                <TableCell>
                                                    <Badge variant={city.isActive ? 'success' : 'secondary'}>
                                                        {city.isActive ? 'نشط' : 'غير نشط'}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>
                                                    <Button variant="ghost" size="icon" onClick={() => handleEditCity(city)}>
                                                        <Pencil className="h-4 w-4" />
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Currencies Tab */}
                <TabsContent value="currencies">
                    <Card>
                        <CardHeader>
                            <div className="flex justify-between items-center">
                                <CardTitle className="flex items-center gap-2">
                                    <Coins className="h-5 w-5" />
                                    العملات
                                </CardTitle>
                                <Button onClick={handleAddCurrency}>
                                    <Plus className="h-4 w-4 ml-2" />
                                    إضافة عملة
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {currenciesLoading ? renderLoadingState() : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>الاسم</TableHead>
                                            <TableHead>الكود</TableHead>
                                            <TableHead>الرمز</TableHead>
                                            <TableHead>سعر الصرف</TableHead>
                                            <TableHead>الحالة</TableHead>
                                            <TableHead className="w-[50px]"></TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {currencies.map((currency) => (
                                            <TableRow key={currency._id}>
                                                <TableCell>
                                                    <div className="flex items-center gap-2">
                                                        <p className="font-medium">{currency.name}</p>
                                                        {currency.isDefault && <Badge variant="outline">افتراضي</Badge>}
                                                    </div>
                                                </TableCell>
                                                <TableCell className="font-mono">{currency.code}</TableCell>
                                                <TableCell>{currency.symbol}</TableCell>
                                                <TableCell>{currency.exchangeRate}</TableCell>
                                                <TableCell>
                                                    <Badge variant={currency.isActive ? 'success' : 'secondary'}>
                                                        {currency.isActive ? 'نشط' : 'غير نشط'}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>
                                                    <Button variant="ghost" size="icon" onClick={() => handleEditCurrency(currency)}>
                                                        <Pencil className="h-4 w-4" />
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>

                {/* Tax Rates Tab */}
                <TabsContent value="taxes">
                    <Card>
                        <CardHeader>
                            <div className="flex justify-between items-center">
                                <CardTitle className="flex items-center gap-2">
                                    <Percent className="h-5 w-5" />
                                    معدلات الضرائب
                                </CardTitle>
                                <Button onClick={handleAddTaxRate}>
                                    <Plus className="h-4 w-4 ml-2" />
                                    إضافة معدل
                                </Button>
                            </div>
                        </CardHeader>
                        <CardContent>
                            {taxRatesLoading ? renderLoadingState() : (
                                <Table>
                                    <TableHeader>
                                        <TableRow>
                                            <TableHead>الاسم</TableHead>
                                            <TableHead>المعدل</TableHead>
                                            <TableHead>الدولة</TableHead>
                                            <TableHead>الحالة</TableHead>
                                            <TableHead className="w-[50px]"></TableHead>
                                        </TableRow>
                                    </TableHeader>
                                    <TableBody>
                                        {taxRates.map((tax) => (
                                            <TableRow key={tax._id}>
                                                <TableCell>
                                                    <div className="flex items-center gap-2">
                                                        <p className="font-medium">{tax.name}</p>
                                                        {tax.isDefault && <Badge variant="outline">افتراضي</Badge>}
                                                    </div>
                                                </TableCell>
                                                <TableCell className="font-mono">{tax.rate}%</TableCell>
                                                <TableCell>
                                                    {tax.countryId ? countries.find(c => c._id === tax.countryId)?.name || '-' : 'الكل'}
                                                </TableCell>
                                                <TableCell>
                                                    <Badge variant={tax.isActive ? 'success' : 'secondary'}>
                                                        {tax.isActive ? 'نشط' : 'غير نشط'}
                                                    </Badge>
                                                </TableCell>
                                                <TableCell>
                                                    <Button variant="ghost" size="icon" onClick={() => handleEditTaxRate(tax)}>
                                                        <Pencil className="h-4 w-4" />
                                                    </Button>
                                                </TableCell>
                                            </TableRow>
                                        ))}
                                    </TableBody>
                                </Table>
                            )}
                        </CardContent>
                    </Card>
                </TabsContent>
            </Tabs>

            {/* Country Dialog */}
            <Dialog open={isCountryDialogOpen} onOpenChange={setIsCountryDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{isEditing ? 'تعديل الدولة' : 'إضافة دولة جديدة'}</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={countryForm.handleSubmit(onCountrySubmit)} className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>الاسم (EN) *</Label>
                                <Input {...countryForm.register('name')} placeholder="Country Name" />
                            </div>
                            <div className="space-y-2">
                                <Label>الاسم (AR)</Label>
                                <Input {...countryForm.register('nameAr')} placeholder="اسم الدولة" />
                            </div>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>الكود *</Label>
                                <Input {...countryForm.register('code')} placeholder="SA" className="font-mono" />
                            </div>
                            <div className="space-y-2">
                                <Label>رمز الهاتف</Label>
                                <Input {...countryForm.register('phoneCode')} placeholder="+966" />
                            </div>
                        </div>
                        <div className="flex items-center gap-2">
                            <Switch
                                id="countryActive"
                                checked={countryForm.watch('isActive')}
                                onCheckedChange={(checked: boolean) => countryForm.setValue('isActive', checked)}
                            />
                            <Label htmlFor="countryActive">نشط</Label>
                        </div>
                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsCountryDialogOpen(false)}>إلغاء</Button>
                            <Button type="submit" disabled={createCountryMutation.isPending || updateCountryMutation.isPending}>
                                {(createCountryMutation.isPending || updateCountryMutation.isPending) && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                {isEditing ? 'حفظ' : 'إضافة'}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* City Dialog */}
            <Dialog open={isCityDialogOpen} onOpenChange={setIsCityDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{isEditing ? 'تعديل المدينة' : 'إضافة مدينة جديدة'}</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={cityForm.handleSubmit(onCitySubmit)} className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>الاسم (EN) *</Label>
                                <Input {...cityForm.register('name')} placeholder="City Name" />
                            </div>
                            <div className="space-y-2">
                                <Label>الاسم (AR)</Label>
                                <Input {...cityForm.register('nameAr')} placeholder="اسم المدينة" />
                            </div>
                        </div>
                        <div className="space-y-2">
                            <Label>الدولة *</Label>
                            <Select
                                value={cityForm.watch('countryId')}
                                onValueChange={(value) => cityForm.setValue('countryId', value)}
                            >
                                <SelectTrigger>
                                    <SelectValue placeholder="اختر الدولة" />
                                </SelectTrigger>
                                <SelectContent>
                                    {countries.map((country) => (
                                        <SelectItem key={country._id} value={country._id}>
                                            {country.nameAr || country.name}
                                        </SelectItem>
                                    ))}
                                </SelectContent>
                            </Select>
                        </div>
                        <div className="flex items-center gap-2">
                            <Switch
                                id="cityActive"
                                checked={cityForm.watch('isActive')}
                                onCheckedChange={(checked: boolean) => cityForm.setValue('isActive', checked)}
                            />
                            <Label htmlFor="cityActive">نشط</Label>
                        </div>
                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsCityDialogOpen(false)}>إلغاء</Button>
                            <Button type="submit" disabled={createCityMutation.isPending || updateCityMutation.isPending}>
                                {(createCityMutation.isPending || updateCityMutation.isPending) && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                {isEditing ? 'حفظ' : 'إضافة'}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Currency Dialog */}
            <Dialog open={isCurrencyDialogOpen} onOpenChange={setIsCurrencyDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{isEditing ? 'تعديل العملة' : 'إضافة عملة جديدة'}</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={currencyForm.handleSubmit(onCurrencySubmit)} className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>الاسم (EN) *</Label>
                                <Input {...currencyForm.register('name')} placeholder="Saudi Riyal" />
                            </div>
                            <div className="space-y-2">
                                <Label>الاسم (AR)</Label>
                                <Input {...currencyForm.register('nameAr')} placeholder="ريال سعودي" />
                            </div>
                        </div>
                        <div className="grid grid-cols-3 gap-4">
                            <div className="space-y-2">
                                <Label>الكود *</Label>
                                <Input {...currencyForm.register('code')} placeholder="SAR" className="font-mono" />
                            </div>
                            <div className="space-y-2">
                                <Label>الرمز *</Label>
                                <Input {...currencyForm.register('symbol')} placeholder="ر.س" />
                            </div>
                            <div className="space-y-2">
                                <Label>سعر الصرف *</Label>
                                <Input type="number" step="0.0001" {...currencyForm.register('exchangeRate', { valueAsNumber: true })} />
                            </div>
                        </div>
                        <div className="flex items-center gap-4">
                            <div className="flex items-center gap-2">
                                <Switch
                                    id="currencyDefault"
                                    checked={currencyForm.watch('isDefault')}
                                    onCheckedChange={(checked: boolean) => currencyForm.setValue('isDefault', checked)}
                                />
                                <Label htmlFor="currencyDefault">افتراضي</Label>
                            </div>
                            <div className="flex items-center gap-2">
                                <Switch
                                    id="currencyActive"
                                    checked={currencyForm.watch('isActive')}
                                    onCheckedChange={(checked: boolean) => currencyForm.setValue('isActive', checked)}
                                />
                                <Label htmlFor="currencyActive">نشط</Label>
                            </div>
                        </div>
                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsCurrencyDialogOpen(false)}>إلغاء</Button>
                            <Button type="submit" disabled={createCurrencyMutation.isPending || updateCurrencyMutation.isPending}>
                                {(createCurrencyMutation.isPending || updateCurrencyMutation.isPending) && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                {isEditing ? 'حفظ' : 'إضافة'}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Tax Rate Dialog */}
            <Dialog open={isTaxDialogOpen} onOpenChange={setIsTaxDialogOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{isEditing ? 'تعديل معدل الضريبة' : 'إضافة معدل ضريبة جديد'}</DialogTitle>
                    </DialogHeader>
                    <form onSubmit={taxForm.handleSubmit(onTaxSubmit)} className="space-y-4">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>الاسم (EN) *</Label>
                                <Input {...taxForm.register('name')} placeholder="VAT" />
                            </div>
                            <div className="space-y-2">
                                <Label>الاسم (AR)</Label>
                                <Input {...taxForm.register('nameAr')} placeholder="ضريبة القيمة المضافة" />
                            </div>
                        </div>
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label>المعدل (%) *</Label>
                                <Input type="number" step="0.01" {...taxForm.register('rate', { valueAsNumber: true })} placeholder="15" />
                            </div>
                            <div className="space-y-2">
                                <Label>الدولة (اختياري)</Label>
                                <Select
                                    value={taxForm.watch('countryId')}
                                    onValueChange={(value) => taxForm.setValue('countryId', value)}
                                >
                                    <SelectTrigger>
                                        <SelectValue placeholder="الكل" />
                                    </SelectTrigger>
                                    <SelectContent>
                                        <SelectItem value="">الكل</SelectItem>
                                        {countries.map((country) => (
                                            <SelectItem key={country._id} value={country._id}>
                                                {country.nameAr || country.name}
                                            </SelectItem>
                                        ))}
                                    </SelectContent>
                                </Select>
                            </div>
                        </div>
                        <div className="flex items-center gap-4">
                            <div className="flex items-center gap-2">
                                <Switch
                                    id="taxDefault"
                                    checked={taxForm.watch('isDefault')}
                                    onCheckedChange={(checked: boolean) => taxForm.setValue('isDefault', checked)}
                                />
                                <Label htmlFor="taxDefault">افتراضي</Label>
                            </div>
                            <div className="flex items-center gap-2">
                                <Switch
                                    id="taxActive"
                                    checked={taxForm.watch('isActive')}
                                    onCheckedChange={(checked: boolean) => taxForm.setValue('isActive', checked)}
                                />
                                <Label htmlFor="taxActive">نشط</Label>
                            </div>
                        </div>
                        <DialogFooter>
                            <Button type="button" variant="outline" onClick={() => setIsTaxDialogOpen(false)}>إلغاء</Button>
                            <Button type="submit" disabled={createTaxRateMutation.isPending || updateTaxRateMutation.isPending}>
                                {(createTaxRateMutation.isPending || updateTaxRateMutation.isPending) && <Loader2 className="h-4 w-4 ml-2 animate-spin" />}
                                {isEditing ? 'حفظ' : 'إضافة'}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>
        </div>
    );
}

export default SettingsPage;
