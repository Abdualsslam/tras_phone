/// Notification Settings Screen - Manage notification preferences
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _pushEnabled = true;
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _walletAlerts = true;
  bool _stockAlerts = false;
  bool _newProducts = true;
  bool _priceDrops = true;
  bool _emailNotifications = false;
  bool _smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('إعدادات الإشعارات')),
      body: ListView(
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
                  onChanged: (v) => setState(() => _pushEnabled = v),
                  activeColor: Colors.white,
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
            (v) => setState(() => _orderUpdates = v),
            isDark,
          ),
          _buildSettingItem(
            'العروض والتخفيضات',
            'كوبونات، عروض خاصة',
            Iconsax.discount_shape,
            _promotions,
            (v) => setState(() => _promotions = v),
            isDark,
          ),
          _buildSettingItem(
            'تنبيهات المحفظة',
            'الرصيد، المعاملات',
            Iconsax.wallet_3,
            _walletAlerts,
            (v) => setState(() => _walletAlerts = v),
            isDark,
          ),
          _buildSettingItem(
            'تنبيهات المخزون',
            'توفر المنتجات مجدداً',
            Iconsax.box_time,
            _stockAlerts,
            (v) => setState(() => _stockAlerts = v),
            isDark,
          ),
          _buildSettingItem(
            'المنتجات الجديدة',
            'وصول منتجات جديدة',
            Iconsax.box_add,
            _newProducts,
            (v) => setState(() => _newProducts = v),
            isDark,
          ),
          _buildSettingItem(
            'انخفاض الأسعار',
            'تخفيضات على منتجات المفضلة',
            Iconsax.tag,
            _priceDrops,
            (v) => setState(() => _priceDrops = v),
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
            (v) => setState(() => _emailNotifications = v),
            isDark,
          ),
          _buildSettingItem(
            'الرسائل النصية',
            'إشعارات عبر SMS',
            Iconsax.message_text,
            _smsNotifications,
            (v) => setState(() => _smsNotifications = v),
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
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
