/// Referral Screen - Invite friends and earn rewards
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const referralCode = 'TRAS2024';
    const referralLink = 'https://trasphone.com/ref/TRAS2024';

    return Scaffold(
      appBar: AppBar(title: const Text('دعوة صديق')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Hero Section
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Column(
              children: [
                Icon(Iconsax.gift, size: 60.sp, color: Colors.white),
                SizedBox(height: 16.h),
                Text(
                  'ادعُ أصدقائك واكسب!',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'احصل على 50 ر.س لكل صديق يسجل ويشتري',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Your Code
          Text(
            'كود الإحالة الخاص بك',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: AppTheme.radiusMd,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  referralCode,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 4,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: referralCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ الكود'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Iconsax.copy,
                      size: 20.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Share Buttons
          Row(
            children: [
              Expanded(
                child: _buildShareButton(
                  context,
                  Iconsax.share,
                  'مشاركة الرابط',
                  () => _shareLink(context, referralLink),
                  AppColors.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildShareButton(
                  context,
                  Iconsax.message,
                  'واتساب',
                  () => _shareWhatsApp(context, referralLink),
                  const Color(0xFF25D366),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // How it works
          Text(
            'كيف يعمل؟',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          _buildStep('1', 'شارك كود الإحالة مع أصدقائك', isDark),
          _buildStep('2', 'صديقك يسجل ويستخدم الكود', isDark),
          _buildStep('3', 'بعد أول طلب، كلاكما يحصل على 50 ر.س', isDark),
          SizedBox(height: 24.h),

          // Stats
          Text(
            'إحصائياتك',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'الدعوات المرسلة',
                  '12',
                  Iconsax.send_2,
                  isDark,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  'التسجيلات',
                  '5',
                  Iconsax.user_tick,
                  isDark,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  'المكافآت',
                  '250 ر.س',
                  Iconsax.money_recive,
                  isDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Referral History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل الإحالات',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              TextButton(onPressed: () {}, child: const Text('عرض الكل')),
            ],
          ),
          _buildReferralItem('أحمد محمد', 'مكتمل', '50 ر.س', isDark),
          _buildReferralItem('سعد العتيبي', 'مكتمل', '50 ر.س', isDark),
          _buildReferralItem('خالد الشهري', 'في الانتظار', '-', isDark),
        ],
      ),
    );
  }

  Widget _buildShareButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppTheme.radiusMd,
      ),
      child: Column(
        children: [
          Icon(icon, size: 24.sp, color: AppColors.primary),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralItem(
    String name,
    String status,
    String reward,
    bool isDark,
  ) {
    final isCompleted = status == 'مكتمل';
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              name[0],
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4.h),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (isCompleted ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            reward,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isCompleted
                  ? AppColors.success
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _shareLink(BuildContext context, String link) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فتح خيارات المشاركة...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareWhatsApp(BuildContext context, String link) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فتح واتساب...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
