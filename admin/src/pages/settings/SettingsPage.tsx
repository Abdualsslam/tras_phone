import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useForm, Controller } from "react-hook-form";
import {
  settingsApi,
  type Country,
  type City,
  type Currency,
  type TaxRate,
  type ShippingZone,
  type PaymentMethod,
  type AppVersion,
  type StoreSettings,
} from "@/api/settings.api";

// ══════════════════════════════════════════════════════════════
// Form Types
// ══════════════════════════════════════════════════════════════

type CountryFormData = {
  name: string;
  nameAr: string;
  code: string;
  phoneCode: string;
  isActive: boolean;
};

type CityFormData = {
  name: string;
  nameAr: string;
  countryId: string;
  isActive: boolean;
};

type CurrencyFormData = {
  name: string;
  nameAr: string;
  code: string;
  symbol: string;
  exchangeRate: number;
  isDefault: boolean;
  isActive: boolean;
};

type TaxFormData = {
  name: string;
  nameAr: string;
  rate: number;
  countryId: string;
  isDefault: boolean;
  isActive: boolean;
};

type ShippingZoneFormData = {
  name: string;
  nameAr: string;
  countries: string[];
  rates: { minWeight: number; maxWeight: number; price: number }[];
  isActive: boolean;
};

type PaymentMethodFormData = {
  name: string;
  nameAr: string;
  code: string;
  type: "online" | "offline" | "wallet";
  isActive: boolean;
};

type AppVersionFormData = {
  platform: "android" | "ios";
  version: string;
  buildNumber: number;
  minRequiredVersion: string;
  releaseNotes: string;
  releaseNotesAr: string;
  downloadUrl: string;
  isCurrent: boolean;
  isForceUpdate: boolean;
  isActive: boolean;
};
import { toast } from "sonner";

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
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
  Truck,
  CreditCard,
  Smartphone,
  MoreHorizontal,
  Trash2,
  Check,
  Star,
} from "lucide-react";
import { formatDate } from "@/lib/utils";

// ══════════════════════════════════════════════════════════════
// Component
// ══════════════════════════════════════════════════════════════

export function SettingsPage() {
  const queryClient = useQueryClient();

  const [activeTab, setActiveTab] = useState("general");
  const [isCountryDialogOpen, setIsCountryDialogOpen] = useState(false);
  const [isCityDialogOpen, setIsCityDialogOpen] = useState(false);
  const [isCurrencyDialogOpen, setIsCurrencyDialogOpen] = useState(false);
  const [isTaxDialogOpen, setIsTaxDialogOpen] = useState(false);
  const [isShippingZoneDialogOpen, setIsShippingZoneDialogOpen] =
    useState(false);
  const [isPaymentMethodDialogOpen, setIsPaymentMethodDialogOpen] =
    useState(false);
  const [isAppVersionDialogOpen, setIsAppVersionDialogOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState<
    | Country
    | City
    | Currency
    | TaxRate
    | ShippingZone
    | PaymentMethod
    | AppVersion
    | null
  >(null);
  const [isEditing, setIsEditing] = useState(false);

  // ─────────────────────────────────────────
  // Queries
  // ─────────────────────────────────────────

  const { data: storeSettings } = useQuery({
    queryKey: ["settings-store"],
    queryFn: () => settingsApi.getStoreSettings(),
  });

  const { data: notificationSettings } = useQuery({
    queryKey: ["settings-notifications"],
    queryFn: () => settingsApi.getNotificationSettings(),
  });

  const { data: countries = [], isLoading: countriesLoading } = useQuery({
    queryKey: ["settings-countries"],
    queryFn: () => settingsApi.getCountries(),
  });

  const { data: cities = [], isLoading: citiesLoading } = useQuery({
    queryKey: ["settings-cities"],
    queryFn: () => settingsApi.getCities(),
  });

  const { data: currencies = [], isLoading: currenciesLoading } = useQuery({
    queryKey: ["settings-currencies"],
    queryFn: () => settingsApi.getCurrencies(),
  });

  const { data: taxRates = [], isLoading: taxRatesLoading } = useQuery({
    queryKey: ["settings-tax-rates"],
    queryFn: () => settingsApi.getTaxRates(),
  });

  const { data: shippingZones = [], isLoading: shippingZonesLoading } =
    useQuery({
      queryKey: ["settings-shipping-zones"],
      queryFn: () => settingsApi.getShippingZones(),
    });

  const { data: paymentMethods = [], isLoading: paymentMethodsLoading } =
    useQuery({
      queryKey: ["settings-payment-methods"],
      queryFn: () => settingsApi.getPaymentMethods(),
    });

  const { data: appVersions = [], isLoading: appVersionsLoading } = useQuery({
    queryKey: ["settings-app-versions"],
    queryFn: () => settingsApi.getAppVersions(),
  });

  // ─────────────────────────────────────────
  // Mutations - Store & Notifications
  // ─────────────────────────────────────────

  const updateStoreMutation = useMutation({
    mutationFn: settingsApi.updateStoreSettings,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-store"] });
      toast.success("تم حفظ الإعدادات");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateNotificationsMutation = useMutation({
    mutationFn: settingsApi.updateNotificationSettings,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-notifications"] });
      toast.success("تم حفظ إعدادات الإشعارات");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  // ─────────────────────────────────────────
  // Mutations - Countries
  // ─────────────────────────────────────────

  const createCountryMutation = useMutation({
    mutationFn: (data: Omit<Country, "_id">) => settingsApi.createCountry(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-countries"] });
      setIsCountryDialogOpen(false);
      toast.success("تم إضافة الدولة");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateCountryMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Country> }) =>
      settingsApi.updateCountry(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-countries"] });
      setIsCountryDialogOpen(false);
      toast.success("تم تحديث الدولة");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  // ─────────────────────────────────────────
  // Mutations - Cities
  // ─────────────────────────────────────────

  const createCityMutation = useMutation({
    mutationFn: (data: Omit<City, "_id">) => settingsApi.createCity(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-cities"] });
      setIsCityDialogOpen(false);
      toast.success("تم إضافة المدينة");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateCityMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<City> }) =>
      settingsApi.updateCity(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-cities"] });
      setIsCityDialogOpen(false);
      toast.success("تم تحديث المدينة");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  // ─────────────────────────────────────────
  // Mutations - Currencies
  // ─────────────────────────────────────────

  const createCurrencyMutation = useMutation({
    mutationFn: (data: Omit<Currency, "_id">) =>
      settingsApi.createCurrency(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-currencies"] });
      setIsCurrencyDialogOpen(false);
      toast.success("تم إضافة العملة");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateCurrencyMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<Currency> }) =>
      settingsApi.updateCurrency(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-currencies"] });
      setIsCurrencyDialogOpen(false);
      toast.success("تم تحديث العملة");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  // ─────────────────────────────────────────
  // Mutations - Tax Rates
  // ─────────────────────────────────────────

  const createTaxRateMutation = useMutation({
    mutationFn: (data: Omit<TaxRate, "_id">) => settingsApi.createTaxRate(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-tax-rates"] });
      setIsTaxDialogOpen(false);
      toast.success("تم إضافة معدل الضريبة");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateTaxRateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<TaxRate> }) =>
      settingsApi.updateTaxRate(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-tax-rates"] });
      setIsTaxDialogOpen(false);
      toast.success("تم تحديث معدل الضريبة");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  // ─────────────────────────────────────────
  // Mutations - Shipping Zones
  // ─────────────────────────────────────────

  const createShippingZoneMutation = useMutation({
    mutationFn: (data: Omit<ShippingZone, "_id">) =>
      settingsApi.createShippingZone(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-shipping-zones"] });
      setIsShippingZoneDialogOpen(false);
      toast.success("تم إضافة منطقة الشحن");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateShippingZoneMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<ShippingZone> }) =>
      settingsApi.updateShippingZone(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-shipping-zones"] });
      setIsShippingZoneDialogOpen(false);
      toast.success("تم تحديث منطقة الشحن");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  // ─────────────────────────────────────────
  // Mutations - Payment Methods
  // ─────────────────────────────────────────

  const createPaymentMethodMutation = useMutation({
    mutationFn: (data: Omit<PaymentMethod, "_id">) =>
      settingsApi.createPaymentMethod(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-payment-methods"] });
      setIsPaymentMethodDialogOpen(false);
      toast.success("تم إضافة طريقة الدفع");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updatePaymentMethodMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<PaymentMethod> }) =>
      settingsApi.updatePaymentMethod(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-payment-methods"] });
      setIsPaymentMethodDialogOpen(false);
      toast.success("تم تحديث طريقة الدفع");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  // ─────────────────────────────────────────
  // Mutations - App Versions
  // ─────────────────────────────────────────

  const createAppVersionMutation = useMutation({
    mutationFn: (data: Omit<AppVersion, "_id" | "createdAt">) =>
      settingsApi.createAppVersion(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-app-versions"] });
      setIsAppVersionDialogOpen(false);
      toast.success("تم إضافة إصدار التطبيق");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const updateAppVersionMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: Partial<AppVersion> }) =>
      settingsApi.updateAppVersion(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-app-versions"] });
      setIsAppVersionDialogOpen(false);
      toast.success("تم تحديث إصدار التطبيق");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const setCurrentVersionMutation = useMutation({
    mutationFn: (id: string) => settingsApi.setCurrentAppVersion(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-app-versions"] });
      toast.success("تم تعيين الإصدار الحالي");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  const deleteAppVersionMutation = useMutation({
    mutationFn: (id: string) => settingsApi.deleteAppVersion(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["settings-app-versions"] });
      toast.success("تم حذف الإصدار");
    },
    onError: () => toast.error("حدث خطأ"),
  });

  // ─────────────────────────────────────────
  // Forms
  // ─────────────────────────────────────────

  const storeForm = useForm<StoreSettings>({
    defaultValues: storeSettings || {
      storeName: "",
      storeEmail: "",
      storePhone: "",
      storeAddress: "",
      storeDescription: "",
    },
  });

  const countryForm = useForm<CountryFormData>({
    defaultValues: {
      name: "",
      nameAr: "",
      code: "",
      phoneCode: "",
      isActive: true,
    },
  });

  const cityForm = useForm<CityFormData>({
    defaultValues: { name: "", nameAr: "", countryId: "", isActive: true },
  });

  const currencyForm = useForm<CurrencyFormData>({
    defaultValues: {
      name: "",
      nameAr: "",
      code: "",
      symbol: "",
      exchangeRate: 1,
      isDefault: false,
      isActive: true,
    },
  });

  const taxForm = useForm<TaxFormData>({
    defaultValues: {
      name: "",
      nameAr: "",
      rate: 0,
      countryId: "",
      isDefault: false,
      isActive: true,
    },
  });

  const shippingZoneForm = useForm<ShippingZoneFormData>({
    defaultValues: {
      name: "",
      nameAr: "",
      countries: [],
      rates: [],
      isActive: true,
    },
  });

  const paymentMethodForm = useForm<PaymentMethodFormData>({
    defaultValues: {
      name: "",
      nameAr: "",
      code: "",
      type: "online",
      isActive: true,
    },
  });

  const appVersionForm = useForm<AppVersionFormData>({
    defaultValues: {
      platform: "android",
      version: "",
      buildNumber: 1,
      minRequiredVersion: "",
      releaseNotes: "",
      releaseNotesAr: "",
      downloadUrl: "",
      isCurrent: false,
      isForceUpdate: false,
      isActive: true,
    },
  });

  // ─────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────

  const handleAddCountry = () => {
    setIsEditing(false);
    setSelectedItem(null);
    countryForm.reset({
      name: "",
      nameAr: "",
      code: "",
      phoneCode: "",
      isActive: true,
    });
    setIsCountryDialogOpen(true);
  };

  const handleEditCountry = (country: Country) => {
    setIsEditing(true);
    setSelectedItem(country);
    countryForm.reset({
      name: country.name,
      nameAr: country.nameAr || "",
      code: country.code,
      phoneCode: country.phoneCode || "",
      isActive: country.isActive,
    });
    setIsCountryDialogOpen(true);
  };

  const handleAddCity = () => {
    setIsEditing(false);
    setSelectedItem(null);
    cityForm.reset({ name: "", nameAr: "", countryId: "", isActive: true });
    setIsCityDialogOpen(true);
  };

  const handleEditCity = (city: City) => {
    setIsEditing(true);
    setSelectedItem(city);
    cityForm.reset({
      name: city.name,
      nameAr: city.nameAr || "",
      countryId: city.countryId,
      isActive: city.isActive,
    });
    setIsCityDialogOpen(true);
  };

  const handleAddCurrency = () => {
    setIsEditing(false);
    setSelectedItem(null);
    currencyForm.reset({
      name: "",
      nameAr: "",
      code: "",
      symbol: "",
      exchangeRate: 1,
      isDefault: false,
      isActive: true,
    });
    setIsCurrencyDialogOpen(true);
  };

  const handleEditCurrency = (currency: Currency) => {
    setIsEditing(true);
    setSelectedItem(currency);
    currencyForm.reset({
      name: currency.name,
      nameAr: currency.nameAr || "",
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
    taxForm.reset({
      name: "",
      nameAr: "",
      rate: 0,
      countryId: "",
      isDefault: false,
      isActive: true,
    });
    setIsTaxDialogOpen(true);
  };

  const handleEditTaxRate = (tax: TaxRate) => {
    setIsEditing(true);
    setSelectedItem(tax);
    taxForm.reset({
      name: tax.name,
      nameAr: tax.nameAr || "",
      rate: tax.rate,
      countryId: tax.countryId || "",
      isDefault: tax.isDefault,
      isActive: tax.isActive,
    });
    setIsTaxDialogOpen(true);
  };

  const handleAddShippingZone = () => {
    setIsEditing(false);
    setSelectedItem(null);
    shippingZoneForm.reset({
      name: "",
      nameAr: "",
      countries: [],
      rates: [],
      isActive: true,
    });
    setIsShippingZoneDialogOpen(true);
  };

  const handleEditShippingZone = (zone: ShippingZone) => {
    setIsEditing(true);
    setSelectedItem(zone);
    shippingZoneForm.reset({
      name: zone.name,
      nameAr: zone.nameAr || "",
      countries: zone.countries,
      rates: zone.rates,
      isActive: zone.isActive,
    });
    setIsShippingZoneDialogOpen(true);
  };

  const handleAddPaymentMethod = () => {
    setIsEditing(false);
    setSelectedItem(null);
    paymentMethodForm.reset({
      name: "",
      nameAr: "",
      code: "",
      type: "online",
      isActive: true,
    });
    setIsPaymentMethodDialogOpen(true);
  };

  const handleEditPaymentMethod = (method: PaymentMethod) => {
    setIsEditing(true);
    setSelectedItem(method);
    paymentMethodForm.reset({
      name: method.name,
      nameAr: method.nameAr || "",
      code: method.code,
      type: method.type,
      isActive: method.isActive,
    });
    setIsPaymentMethodDialogOpen(true);
  };

  const handleAddAppVersion = () => {
    setIsEditing(false);
    setSelectedItem(null);
    appVersionForm.reset({
      platform: "android",
      version: "",
      buildNumber: 1,
      minRequiredVersion: "",
      releaseNotes: "",
      releaseNotesAr: "",
      downloadUrl: "",
      isCurrent: false,
      isForceUpdate: false,
      isActive: true,
    });
    setIsAppVersionDialogOpen(true);
  };

  const handleEditAppVersion = (appVersion: AppVersion) => {
    setIsEditing(true);
    setSelectedItem(appVersion);
    appVersionForm.reset({
      platform: appVersion.platform,
      version: appVersion.version,
      buildNumber: appVersion.buildNumber,
      minRequiredVersion: appVersion.minRequiredVersion || "",
      releaseNotes: appVersion.releaseNotes || "",
      releaseNotesAr: appVersion.releaseNotesAr || "",
      downloadUrl: appVersion.downloadUrl || "",
      isCurrent: appVersion.isCurrent,
      isForceUpdate: appVersion.isForceUpdate,
      isActive: appVersion.isActive,
    });
    setIsAppVersionDialogOpen(true);
  };

  // Submit handlers
  const onCountrySubmit = (data: CountryFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateCountryMutation.mutate({ id: selectedItem._id, data });
    } else {
      createCountryMutation.mutate(data);
    }
  };

  const onCitySubmit = (data: CityFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateCityMutation.mutate({ id: selectedItem._id, data });
    } else {
      createCityMutation.mutate(data);
    }
  };

  const onCurrencySubmit = (data: CurrencyFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateCurrencyMutation.mutate({ id: selectedItem._id, data });
    } else {
      createCurrencyMutation.mutate(data);
    }
  };

  const onTaxSubmit = (data: TaxFormData) => {
    // Convert "_all" value to empty string for API
    const submitData = {
      ...data,
      countryId: data.countryId === "_all" ? "" : data.countryId,
    };
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateTaxRateMutation.mutate({ id: selectedItem._id, data: submitData });
    } else {
      createTaxRateMutation.mutate(submitData);
    }
  };

  const onShippingZoneSubmit = (data: ShippingZoneFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateShippingZoneMutation.mutate({ id: selectedItem._id, data });
    } else {
      createShippingZoneMutation.mutate(data);
    }
  };

  const onPaymentMethodSubmit = (data: PaymentMethodFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updatePaymentMethodMutation.mutate({ id: selectedItem._id, data });
    } else {
      createPaymentMethodMutation.mutate(data);
    }
  };

  const onAppVersionSubmit = (data: AppVersionFormData) => {
    if (isEditing && selectedItem && "_id" in selectedItem) {
      updateAppVersionMutation.mutate({ id: selectedItem._id, data });
    } else {
      createAppVersionMutation.mutate(data);
    }
  };

  // ─────────────────────────────────────────
  // Render Helpers
  // ─────────────────────────────────────────

  const renderLoadingState = () => (
    <div className="flex justify-center items-center h-40">
      <Loader2 className="h-8 w-8 animate-spin text-primary" />
    </div>
  );

  // ─────────────────────────────────────────
  // Render
  // ─────────────────────────────────────────

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold">الإعدادات</h1>
        <p className="text-muted-foreground text-sm">
          إدارة إعدادات النظام والتطبيق
        </p>
      </div>

      {/* Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList className="mb-4 flex-wrap">
          <TabsTrigger value="general" className="flex items-center gap-2">
            <Store className="h-4 w-4" />
            عام
          </TabsTrigger>
          <TabsTrigger
            value="notifications"
            className="flex items-center gap-2"
          >
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
          <TabsTrigger value="shipping" className="flex items-center gap-2">
            <Truck className="h-4 w-4" />
            الشحن
          </TabsTrigger>
          <TabsTrigger value="payment" className="flex items-center gap-2">
            <CreditCard className="h-4 w-4" />
            الدفع
          </TabsTrigger>
          <TabsTrigger value="app-versions" className="flex items-center gap-2">
            <Smartphone className="h-4 w-4" />
            إصدارات التطبيق
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
              <form
                onSubmit={storeForm.handleSubmit((data) =>
                  updateStoreMutation.mutate(data)
                )}
                className="space-y-4"
              >
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>اسم المتجر</Label>
                    <Input
                      {...storeForm.register("storeName")}
                      placeholder="اسم المتجر"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>البريد الإلكتروني</Label>
                    <Input
                      {...storeForm.register("storeEmail")}
                      type="email"
                      placeholder="email@example.com"
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>رقم الهاتف</Label>
                    <Input
                      {...storeForm.register("storePhone")}
                      placeholder="+966..."
                    />
                  </div>
                  <div className="space-y-2">
                    <Label>العنوان</Label>
                    <Input
                      {...storeForm.register("storeAddress")}
                      placeholder="العنوان الكامل"
                    />
                  </div>
                </div>
                <Button type="submit" disabled={updateStoreMutation.isPending}>
                  {updateStoreMutation.isPending && (
                    <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                  )}
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
                {(
                  [
                    { key: "newOrder", label: "طلب جديد" },
                    { key: "newCustomer", label: "عميل جديد" },
                    { key: "lowStock", label: "نفاد المخزون" },
                    { key: "supportTicket", label: "تذكرة دعم" },
                    { key: "emailEnabled", label: "إشعارات البريد" },
                    { key: "pushEnabled", label: "إشعارات الدفع" },
                  ] as const
                ).map((item) => (
                  <div
                    key={item.key}
                    className="flex items-center justify-between p-3 border rounded-lg"
                  >
                    <Label>{item.label}</Label>
                    <Switch
                      checked={notificationSettings?.[item.key] || false}
                      onCheckedChange={(checked: boolean) => {
                        updateNotificationsMutation.mutate({
                          [item.key]: checked,
                        });
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
              {countriesLoading ? (
                renderLoadingState()
              ) : (
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
                            {country.nameAr && (
                              <p className="text-sm text-muted-foreground">
                                {country.nameAr}
                              </p>
                            )}
                          </div>
                        </TableCell>
                        <TableCell className="font-mono">
                          {country.code}
                        </TableCell>
                        <TableCell>{country.phoneCode || "-"}</TableCell>
                        <TableCell>
                          <Badge
                            variant={country.isActive ? "success" : "secondary"}
                          >
                            {country.isActive ? "نشط" : "غير نشط"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleEditCountry(country)}
                          >
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
              {citiesLoading ? (
                renderLoadingState()
              ) : (
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
                            {city.nameAr && (
                              <p className="text-sm text-muted-foreground">
                                {city.nameAr}
                              </p>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          {countries.find((c) => c._id === city.countryId)
                            ?.nameAr || countries.find((c) => c._id === city.countryId)?.name || city.countryId}
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={city.isActive ? "success" : "secondary"}
                          >
                            {city.isActive ? "نشط" : "غير نشط"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleEditCity(city)}
                          >
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
              {currenciesLoading ? (
                renderLoadingState()
              ) : (
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
                            {currency.isDefault && (
                              <Badge variant="outline">افتراضي</Badge>
                            )}
                          </div>
                        </TableCell>
                        <TableCell className="font-mono">
                          {currency.code}
                        </TableCell>
                        <TableCell>{currency.symbol}</TableCell>
                        <TableCell>{currency.exchangeRate}</TableCell>
                        <TableCell>
                          <Badge
                            variant={
                              currency.isActive ? "success" : "secondary"
                            }
                          >
                            {currency.isActive ? "نشط" : "غير نشط"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleEditCurrency(currency)}
                          >
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
              {taxRatesLoading ? (
                renderLoadingState()
              ) : (
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
                            {tax.isDefault && (
                              <Badge variant="outline">افتراضي</Badge>
                            )}
                          </div>
                        </TableCell>
                        <TableCell className="font-mono">{tax.rate}%</TableCell>
                        <TableCell>
                          {tax.countryId
                            ? countries.find((c) => c._id === tax.countryId)
                                ?.name || "-"
                            : "الكل"}
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={tax.isActive ? "success" : "secondary"}
                          >
                            {tax.isActive ? "نشط" : "غير نشط"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleEditTaxRate(tax)}
                          >
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

        {/* Shipping Zones Tab */}
        <TabsContent value="shipping">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <Truck className="h-5 w-5" />
                  مناطق الشحن
                </CardTitle>
                <Button onClick={handleAddShippingZone}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة منطقة
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {shippingZonesLoading ? (
                renderLoadingState()
              ) : shippingZones.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <Truck className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد مناطق شحن</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>الاسم</TableHead>
                      <TableHead>الدول</TableHead>
                      <TableHead>الأسعار</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead className="w-[50px]"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {shippingZones.map((zone) => (
                      <TableRow key={zone._id}>
                        <TableCell>
                          <div>
                            <p className="font-medium">{zone.name}</p>
                            {zone.nameAr && (
                              <p className="text-sm text-muted-foreground">
                                {zone.nameAr}
                              </p>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant="outline">
                            {zone.countries?.length || 0} دول
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Badge variant="outline">
                            {zone.rates?.length || 0} أسعار
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={zone.isActive ? "success" : "secondary"}
                          >
                            {zone.isActive ? "نشط" : "غير نشط"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleEditShippingZone(zone)}
                          >
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

        {/* Payment Methods Tab */}
        <TabsContent value="payment">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <CreditCard className="h-5 w-5" />
                  طرق الدفع
                </CardTitle>
                <Button onClick={handleAddPaymentMethod}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة طريقة
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {paymentMethodsLoading ? (
                renderLoadingState()
              ) : paymentMethods.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <CreditCard className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد طرق دفع</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>الاسم</TableHead>
                      <TableHead>الكود</TableHead>
                      <TableHead>النوع</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead className="w-[50px]"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {paymentMethods.map((method) => (
                      <TableRow key={method._id}>
                        <TableCell>
                          <div>
                            <p className="font-medium">{method.name}</p>
                            {method.nameAr && (
                              <p className="text-sm text-muted-foreground">
                                {method.nameAr}
                              </p>
                            )}
                          </div>
                        </TableCell>
                        <TableCell className="font-mono">
                          {method.code}
                        </TableCell>
                        <TableCell>
                          <Badge variant="outline">
                            {method.type === "online"
                              ? "إلكتروني"
                              : method.type === "offline"
                              ? "نقدي"
                              : "محفظة"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={method.isActive ? "success" : "secondary"}
                          >
                            {method.isActive ? "نشط" : "غير نشط"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => handleEditPaymentMethod(method)}
                          >
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

        {/* App Versions Tab */}
        <TabsContent value="app-versions">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <Smartphone className="h-5 w-5" />
                  إصدارات التطبيق
                </CardTitle>
                <Button onClick={handleAddAppVersion}>
                  <Plus className="h-4 w-4 ml-2" />
                  إضافة إصدار
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {appVersionsLoading ? (
                renderLoadingState()
              ) : appVersions.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground">
                  <Smartphone className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>لا توجد إصدارات</p>
                </div>
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>المنصة</TableHead>
                      <TableHead>الإصدار</TableHead>
                      <TableHead>رقم البناء</TableHead>
                      <TableHead>الحد الأدنى</TableHead>
                      <TableHead>الحالة</TableHead>
                      <TableHead>التاريخ</TableHead>
                      <TableHead className="w-[80px]"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {appVersions.map((version) => (
                      <TableRow key={version._id}>
                        <TableCell>
                          <Badge variant="outline">
                            {version.platform === "ios" ? "iOS" : "Android"}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <span className="font-mono">{version.version}</span>
                            {version.isCurrent && (
                              <Badge variant="success" className="gap-1">
                                <Star className="h-3 w-3" />
                                حالي
                              </Badge>
                            )}
                          </div>
                        </TableCell>
                        <TableCell className="font-mono">
                          {version.buildNumber}
                        </TableCell>
                        <TableCell className="font-mono">
                          {version.minRequiredVersion || "-"}
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <Badge
                              variant={
                                version.isActive ? "success" : "secondary"
                              }
                            >
                              {version.isActive ? "نشط" : "غير نشط"}
                            </Badge>
                            {version.isForceUpdate && (
                              <Badge variant="warning">إجباري</Badge>
                            )}
                          </div>
                        </TableCell>
                        <TableCell className="text-muted-foreground text-sm">
                          {formatDate(version.createdAt)}
                        </TableCell>
                        <TableCell>
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end">
                              <DropdownMenuItem
                                onClick={() => handleEditAppVersion(version)}
                              >
                                <Pencil className="h-4 w-4 ml-2" />
                                تعديل
                              </DropdownMenuItem>
                              {!version.isCurrent && (
                                <DropdownMenuItem
                                  onClick={() =>
                                    setCurrentVersionMutation.mutate(
                                      version._id
                                    )
                                  }
                                >
                                  <Check className="h-4 w-4 ml-2" />
                                  تعيين كحالي
                                </DropdownMenuItem>
                              )}
                              <DropdownMenuItem
                                onClick={() =>
                                  deleteAppVersionMutation.mutate(version._id)
                                }
                                className="text-red-600"
                              >
                                <Trash2 className="h-4 w-4 ml-2" />
                                حذف
                              </DropdownMenuItem>
                            </DropdownMenuContent>
                          </DropdownMenu>
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
            <DialogTitle>
              {isEditing ? "تعديل الدولة" : "إضافة دولة جديدة"}
            </DialogTitle>
            <DialogDescription>
              {isEditing ? "تعديل بيانات الدولة" : "إضافة دولة جديدة للنظام"}
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={countryForm.handleSubmit(onCountrySubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (EN) *</Label>
                <Input
                  {...countryForm.register("name")}
                  placeholder="Country Name"
                />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  {...countryForm.register("nameAr")}
                  placeholder="اسم الدولة"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الكود *</Label>
                <Input
                  {...countryForm.register("code")}
                  placeholder="SA"
                  className="font-mono"
                />
              </div>
              <div className="space-y-2">
                <Label>رمز الهاتف</Label>
                <Input
                  {...countryForm.register("phoneCode")}
                  placeholder="+966"
                />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Controller
                control={countryForm.control}
                name="isActive"
                render={({ field }) => (
                  <Switch
                    id="countryActive"
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                )}
              />
              <Label htmlFor="countryActive">نشط</Label>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsCountryDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createCountryMutation.isPending ||
                  updateCountryMutation.isPending
                }
              >
                {(createCountryMutation.isPending ||
                  updateCountryMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إضافة"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* City Dialog */}
      <Dialog open={isCityDialogOpen} onOpenChange={setIsCityDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل المدينة" : "إضافة مدينة جديدة"}
            </DialogTitle>
            <DialogDescription>
              {isEditing ? "تعديل بيانات المدينة" : "إضافة مدينة جديدة للنظام"}
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={cityForm.handleSubmit(onCitySubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (EN) *</Label>
                <Input {...cityForm.register("name")} placeholder="City Name" />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  {...cityForm.register("nameAr")}
                  placeholder="اسم المدينة"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>الدولة *</Label>
              <Controller
                control={cityForm.control}
                name="countryId"
                render={({ field }) => (
                  <Select value={field.value || undefined} onValueChange={field.onChange}>
                    <SelectTrigger>
                      <SelectValue placeholder="اختر الدولة" />
                    </SelectTrigger>
                    <SelectContent>
                      {countries.filter(c => c._id).map((country) => (
                        <SelectItem key={country._id} value={country._id}>
                          {country.nameAr || country.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                )}
              />
            </div>
            <div className="flex items-center gap-2">
              <Controller
                control={cityForm.control}
                name="isActive"
                render={({ field }) => (
                  <Switch
                    id="cityActive"
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                )}
              />
              <Label htmlFor="cityActive">نشط</Label>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsCityDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createCityMutation.isPending || updateCityMutation.isPending
                }
              >
                {(createCityMutation.isPending ||
                  updateCityMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إضافة"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Currency Dialog */}
      <Dialog
        open={isCurrencyDialogOpen}
        onOpenChange={setIsCurrencyDialogOpen}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل العملة" : "إضافة عملة جديدة"}
            </DialogTitle>
            <DialogDescription>
              {isEditing ? "تعديل بيانات العملة" : "إضافة عملة جديدة للنظام"}
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={currencyForm.handleSubmit(onCurrencySubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (EN) *</Label>
                <Input
                  {...currencyForm.register("name")}
                  placeholder="Saudi Riyal"
                />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  {...currencyForm.register("nameAr")}
                  placeholder="ريال سعودي"
                />
              </div>
            </div>
            <div className="grid grid-cols-3 gap-4">
              <div className="space-y-2">
                <Label>الكود *</Label>
                <Input
                  {...currencyForm.register("code")}
                  placeholder="SAR"
                  className="font-mono"
                />
              </div>
              <div className="space-y-2">
                <Label>الرمز *</Label>
                <Input {...currencyForm.register("symbol")} placeholder="ر.س" />
              </div>
              <div className="space-y-2">
                <Label>سعر الصرف *</Label>
                <Input
                  type="number"
                  step="0.0001"
                  {...currencyForm.register("exchangeRate", {
                    valueAsNumber: true,
                  })}
                />
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <Controller
                  control={currencyForm.control}
                  name="isDefault"
                  render={({ field }) => (
                    <Switch
                      id="currencyDefault"
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="currencyDefault">افتراضي</Label>
              </div>
              <div className="flex items-center gap-2">
                <Controller
                  control={currencyForm.control}
                  name="isActive"
                  render={({ field }) => (
                    <Switch
                      id="currencyActive"
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="currencyActive">نشط</Label>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsCurrencyDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createCurrencyMutation.isPending ||
                  updateCurrencyMutation.isPending
                }
              >
                {(createCurrencyMutation.isPending ||
                  updateCurrencyMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إضافة"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Tax Rate Dialog */}
      <Dialog open={isTaxDialogOpen} onOpenChange={setIsTaxDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل معدل الضريبة" : "إضافة معدل ضريبة جديد"}
            </DialogTitle>
            <DialogDescription>
              {isEditing ? "تعديل بيانات معدل الضريبة" : "إضافة معدل ضريبة جديد للنظام"}
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={taxForm.handleSubmit(onTaxSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (EN) *</Label>
                <Input {...taxForm.register("name")} placeholder="VAT" />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  {...taxForm.register("nameAr")}
                  placeholder="ضريبة القيمة المضافة"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>المعدل (%) *</Label>
                <Input
                  type="number"
                  step="0.01"
                  {...taxForm.register("rate", { valueAsNumber: true })}
                  placeholder="15"
                />
              </div>
              <div className="space-y-2">
                <Label>الدولة (اختياري)</Label>
                <Controller
                  control={taxForm.control}
                  name="countryId"
                  render={({ field }) => (
                    <Select value={field.value || undefined} onValueChange={field.onChange}>
                      <SelectTrigger>
                        <SelectValue placeholder="الكل" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="_all">الكل</SelectItem>
                        {countries.filter(c => c._id).map((country) => (
                          <SelectItem key={country._id} value={country._id}>
                            {country.nameAr || country.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  )}
                />
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <Controller
                  control={taxForm.control}
                  name="isDefault"
                  render={({ field }) => (
                    <Switch
                      id="taxDefault"
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="taxDefault">افتراضي</Label>
              </div>
              <div className="flex items-center gap-2">
                <Controller
                  control={taxForm.control}
                  name="isActive"
                  render={({ field }) => (
                    <Switch
                      id="taxActive"
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="taxActive">نشط</Label>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsTaxDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createTaxRateMutation.isPending ||
                  updateTaxRateMutation.isPending
                }
              >
                {(createTaxRateMutation.isPending ||
                  updateTaxRateMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إضافة"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Shipping Zone Dialog */}
      <Dialog
        open={isShippingZoneDialogOpen}
        onOpenChange={setIsShippingZoneDialogOpen}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل منطقة الشحن" : "إضافة منطقة شحن جديدة"}
            </DialogTitle>
            <DialogDescription>
              {isEditing ? "تعديل بيانات منطقة الشحن" : "إضافة منطقة شحن جديدة للنظام"}
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={shippingZoneForm.handleSubmit(onShippingZoneSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (EN) *</Label>
                <Input
                  {...shippingZoneForm.register("name")}
                  placeholder="Zone Name"
                />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  {...shippingZoneForm.register("nameAr")}
                  placeholder="اسم المنطقة"
                />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Controller
                control={shippingZoneForm.control}
                name="isActive"
                render={({ field }) => (
                  <Switch
                    id="shippingZoneActive"
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                )}
              />
              <Label htmlFor="shippingZoneActive">نشط</Label>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsShippingZoneDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createShippingZoneMutation.isPending ||
                  updateShippingZoneMutation.isPending
                }
              >
                {(createShippingZoneMutation.isPending ||
                  updateShippingZoneMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إضافة"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* Payment Method Dialog */}
      <Dialog
        open={isPaymentMethodDialogOpen}
        onOpenChange={setIsPaymentMethodDialogOpen}
      >
        <DialogContent>
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل طريقة الدفع" : "إضافة طريقة دفع جديدة"}
            </DialogTitle>
            <DialogDescription>
              {isEditing ? "تعديل بيانات طريقة الدفع" : "إضافة طريقة دفع جديدة للنظام"}
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={paymentMethodForm.handleSubmit(onPaymentMethodSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الاسم (EN) *</Label>
                <Input
                  {...paymentMethodForm.register("name")}
                  placeholder="Credit Card"
                />
              </div>
              <div className="space-y-2">
                <Label>الاسم (AR)</Label>
                <Input
                  {...paymentMethodForm.register("nameAr")}
                  placeholder="بطاقة ائتمان"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>الكود *</Label>
                <Input
                  {...paymentMethodForm.register("code")}
                  placeholder="credit_card"
                  className="font-mono"
                />
              </div>
              <div className="space-y-2">
                <Label>النوع *</Label>
                <Controller
                  control={paymentMethodForm.control}
                  name="type"
                  render={({ field }) => (
                    <Select value={field.value || undefined} onValueChange={field.onChange}>
                      <SelectTrigger>
                        <SelectValue placeholder="اختر النوع" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="online">إلكتروني</SelectItem>
                        <SelectItem value="offline">نقدي</SelectItem>
                        <SelectItem value="wallet">محفظة</SelectItem>
                      </SelectContent>
                    </Select>
                  )}
                />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <Controller
                control={paymentMethodForm.control}
                name="isActive"
                render={({ field }) => (
                  <Switch
                    id="paymentMethodActive"
                    checked={field.value}
                    onCheckedChange={field.onChange}
                  />
                )}
              />
              <Label htmlFor="paymentMethodActive">نشط</Label>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsPaymentMethodDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createPaymentMethodMutation.isPending ||
                  updatePaymentMethodMutation.isPending
                }
              >
                {(createPaymentMethodMutation.isPending ||
                  updatePaymentMethodMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إضافة"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>

      {/* App Version Dialog */}
      <Dialog
        open={isAppVersionDialogOpen}
        onOpenChange={setIsAppVersionDialogOpen}
      >
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              {isEditing ? "تعديل إصدار التطبيق" : "إضافة إصدار جديد"}
            </DialogTitle>
            <DialogDescription>
              {isEditing ? "تعديل بيانات إصدار التطبيق" : "إضافة إصدار جديد للتطبيق"}
            </DialogDescription>
          </DialogHeader>
          <form
            onSubmit={appVersionForm.handleSubmit(onAppVersionSubmit)}
            className="space-y-4"
          >
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>المنصة *</Label>
                <Controller
                  control={appVersionForm.control}
                  name="platform"
                  render={({ field }) => (
                    <Select value={field.value || undefined} onValueChange={field.onChange}>
                      <SelectTrigger>
                        <SelectValue placeholder="اختر المنصة" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="android">Android</SelectItem>
                        <SelectItem value="ios">iOS</SelectItem>
                      </SelectContent>
                    </Select>
                  )}
                />
              </div>
              <div className="space-y-2">
                <Label>الإصدار *</Label>
                <Input
                  {...appVersionForm.register("version")}
                  placeholder="1.0.0"
                  className="font-mono"
                />
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>رقم البناء *</Label>
                <Input
                  type="number"
                  {...appVersionForm.register("buildNumber", {
                    valueAsNumber: true,
                  })}
                />
              </div>
              <div className="space-y-2">
                <Label>الحد الأدنى المطلوب</Label>
                <Input
                  {...appVersionForm.register("minRequiredVersion")}
                  placeholder="1.0.0"
                  className="font-mono"
                />
              </div>
            </div>
            <div className="space-y-2">
              <Label>رابط التحميل</Label>
              <Input
                {...appVersionForm.register("downloadUrl")}
                placeholder="https://..."
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>ملاحظات الإصدار (EN)</Label>
                <Textarea
                  {...appVersionForm.register("releaseNotes")}
                  rows={3}
                  placeholder="Release notes..."
                />
              </div>
              <div className="space-y-2">
                <Label>ملاحظات الإصدار (AR)</Label>
                <Textarea
                  {...appVersionForm.register("releaseNotesAr")}
                  rows={3}
                  placeholder="ملاحظات الإصدار..."
                />
              </div>
            </div>
            <div className="flex items-center gap-4">
              <div className="flex items-center gap-2">
                <Controller
                  control={appVersionForm.control}
                  name="isForceUpdate"
                  render={({ field }) => (
                    <Switch
                      id="appVersionForce"
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="appVersionForce">تحديث إجباري</Label>
              </div>
              <div className="flex items-center gap-2">
                <Controller
                  control={appVersionForm.control}
                  name="isActive"
                  render={({ field }) => (
                    <Switch
                      id="appVersionActive"
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  )}
                />
                <Label htmlFor="appVersionActive">نشط</Label>
              </div>
            </div>
            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setIsAppVersionDialogOpen(false)}
              >
                إلغاء
              </Button>
              <Button
                type="submit"
                disabled={
                  createAppVersionMutation.isPending ||
                  updateAppVersionMutation.isPending
                }
              >
                {(createAppVersionMutation.isPending ||
                  updateAppVersionMutation.isPending) && (
                  <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                )}
                {isEditing ? "حفظ" : "إضافة"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export default SettingsPage;
