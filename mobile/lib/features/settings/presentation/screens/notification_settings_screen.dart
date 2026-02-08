/// Notification Settings Screen - Manage notification preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../notifications/presentation/cubit/notifications_cubit.dart';
import '../../../notifications/data/models/notification_model.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _pushEnabled = true;
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _walletAlerts = true;
  bool _stockAlerts = false;
  bool _newProducts = true;
  bool _priceDrops = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  final NotificationsCubit _notificationsCubit = getIt<NotificationsCubit>();
  final LocalStorage _localStorage = getIt<LocalStorage>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    // Try to load from local storage first
    final savedSettings = _localStorage.getObject(StorageKeys.notificationSettings);
    if (savedSettings != null) {
      try {
        final settings = NotificationSettingsModel.fromJson(savedSettings);
        if (mounted) {
          setState(() {
            _pushEnabled = settings.pushEnabled;
            _orderUpdates = settings.orderUpdates;
            _promotions = settings.promotions;
            _walletAlerts = settings.stockAlerts; // Using stockAlerts as walletAlerts is not in the model
            _stockAlerts = settings.stockAlerts;
            _newProducts = settings.newArrivals;
            _priceDrops = settings.priceDrops;
            _emailNotifications = settings.emailEnabled;
            _smsNotifications = settings.smsEnabled;
            _isLoading = false;
          });
        }
      } catch (e) {
        // If parsing fails, load from API
      }
    }

    // Load from API
    final settings = await _notificationsCubit.getSettings();
    if (settings != null && mounted) {
      setState(() {
        _pushEnabled = settings.pushEnabled;
        _orderUpdates = settings.orderUpdates;
        _promotions = settings.promotions;
        _walletAlerts = settings.stockAlerts;
        _stockAlerts = settings.stockAlerts;
        _newProducts = settings.newArrivals;
        _priceDrops = settings.priceDrops;
        _emailNotifications = settings.emailEnabled;
        _smsNotifications = settings.smsEnabled;
        _isLoading = false;
      });

      // Save to local storage
      await _localStorage.setObject(
        StorageKeys.notificationSettings,
        settings.toJson(),
      );
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    // Update local state immediately
    setState(() {
      switch (key) {
        case 'pushEnabled':
          _pushEnabled = value;
          break;
        case 'orderUpdates':
          _orderUpdates = value;
          break;
        case 'promotions':
          _promotions = value;
          break;
        case 'walletAlerts':
          _walletAlerts = value;
          break;
        case 'stockAlerts':
          _stockAlerts = value;
          break;
        case 'newProducts':
          _newProducts = value;
          break;
        case 'priceDrops':
          _priceDrops = value;
          break;
        case 'emailNotifications':
          _emailNotifications = value;
          break;
        case 'smsNotifications':
          _smsNotifications = value;
          break;
      }
    });

    // Create updated settings model
    final updatedSettings = NotificationSettingsModel(
      pushEnabled: _pushEnabled,
      orderUpdates: _orderUpdates,
      promotions: _promotions,
      stockAlerts: _stockAlerts,
      newArrivals: _newProducts,
      priceDrops: _priceDrops,
      emailEnabled: _emailNotifications,
      smsEnabled: _smsNotifications,
    );

    // Save to local storage
    await _localStorage.setObject(
      StorageKeys.notificationSettings,
      updatedSettings.toJson(),
    );

    // Sync with API
    final success = await _notificationsCubit.updateSettings(updatedSettings);
    if (!success && mounted) {
      // Revert on failure
      _loadSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل تحديث الإعدادات'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الإشعارات')),
      body: _isLoading
          ? const SettingsListShimmer()
          : ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Push Notifications Master Toggle
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: _pushEnabled ? AppColors.primaryGradient : null,
              color: _pushEnabled
                  ? null
                  : (isDark ? AppColors.cardDark : AppColors.cardLight),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: _pushEnabled ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Iconsax.notification,
                    size: 24.sp,
                    color: _pushEnabled
                        ? Colors.white
                        : AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإشعارات الفورية',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: _pushEnabled ? Colors.white : null,
                        ),
                      ),
                      Text(
                        'تفعيل أو إيقاف جميع الإشعارات',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _pushEnabled
                              ? Colors.white70
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _pushEnabled,
                  onChanged: (v) => _updateSetting('pushEnabled', v),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.white24,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Notification Types
          Text(
            'أنواع الإشعارات',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _buildSettingItem(
            'تحديثات الطلبات',
            'حالة الطلب، الشحن، التوصيل',
            Iconsax.box,
            _orderUpdates,
            (v) => _updateSetting('orderUpdates', v),
            isDark,
          ),
          _buildSettingItem(
            'العروض والتخفيضات',
            'كوبونات، عروض خاصة',
            Iconsax.discount_shape,
            _promotions,
            (v) => _updateSetting('promotions', v),
            isDark,
          ),
          _buildSettingItem(
            'تنبيهات المحفظة',
            'الرصيد، المعاملات',
            Iconsax.wallet_3,
            _walletAlerts,
            (v) => _updateSetting('walletAlerts', v),
            isDark,
          ),
          _buildSettingItem(
            'تنبيهات المخزون',
            'توفر المنتجات مجدداً',
            Iconsax.box_time,
            _stockAlerts,
            (v) => _updateSetting('stockAlerts', v),
            isDark,
          ),
          _buildSettingItem(
            'المنتجات الجديدة',
            'وصول منتجات جديدة',
            Iconsax.box_add,
            _newProducts,
            (v) => _updateSetting('newProducts', v),
            isDark,
          ),
          _buildSettingItem(
            'انخفاض الأسعار',
            'تخفيضات على منتجات المفضلة',
            Iconsax.tag,
            _priceDrops,
            (v) => _updateSetting('priceDrops', v),
            isDark,
          ),
          SizedBox(height: 24.h),

          // Other Channels
          Text(
            'قنوات أخرى',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _buildSettingItem(
            'البريد الإلكتروني',
            'إشعارات عبر الإيميل',
            Iconsax.sms,
            _emailNotifications,
            (v) => _updateSetting('emailNotifications', v),
            isDark,
          ),
          _buildSettingItem(
            'الرسائل النصية',
            'إشعارات عبر SMS',
            Iconsax.message_text,
            _smsNotifications,
            (v) => _updateSetting('smsNotifications', v),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppTheme.radiusMd,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 20.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value && _pushEnabled,
            onChanged: _pushEnabled ? onChanged : null,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
