/// Loyalty Points Screen - Display loyalty points and rewards
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class LoyaltyPointsScreen extends StatelessWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('نقاط الولاء')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Points Card
            _buildPointsCard(theme, isDark),
            SizedBox(height: 24.h),

            // Tier Progress
            _buildTierProgress(theme, isDark),
            SizedBox(height: 24.h),

            // Rewards
            _buildRewardsSection(theme, isDark),
            SizedBox(height: 24.h),

            // How to earn
            _buildHowToEarn(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber[600]!, Colors.orange[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Iconsax.medal_star, color: Colors.white, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            '١٥٠',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            'نقطة',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'المستوى الفضي',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierProgress(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقدمك للمستوى الذهبي',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildTierBadge('برونزي', Colors.brown, true),
              Expanded(child: _buildProgressLine(1.0)),
              _buildTierBadge('فضي', Colors.grey, true),
              Expanded(child: _buildProgressLine(0.3)),
              _buildTierBadge('ذهبي', Colors.amber, false),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'أنت بحاجة لـ 350 نقطة للوصول للمستوى الذهبي',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge(String label, Color color, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isActive ? Iconsax.tick_circle5 : Iconsax.medal_star,
            color: Colors.white,
            size: 16.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? color : AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(double progress) {
    return Container(
      height: 4.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppColors.dividerLight,
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: FractionallySizedBox(
        widthFactor: progress,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardsSection(ThemeData theme, bool isDark) {
    final rewards = [
      _Reward(name: 'خصم 5%', points: 100, icon: Iconsax.percentage_square),
      _Reward(name: 'شحن مجاني', points: 200, icon: Iconsax.truck),
      _Reward(name: 'خصم 10%', points: 300, icon: Iconsax.percentage_square),
      _Reward(name: 'هدية مجانية', points: 500, icon: Iconsax.gift),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'استبدل نقاطك',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
          ),
          itemCount: rewards.length,
          itemBuilder: (ctx, index) {
            final reward = rewards[index];
            final canRedeem = 150 >= reward.points;
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16.r),
                border: canRedeem
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    reward.icon,
                    size: 32.sp,
                    color: canRedeem
                        ? AppColors.primary
                        : AppColors.textTertiaryLight,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    reward.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${reward.points} نقطة',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: canRedeem
                          ? AppColors.primary
                          : AppColors.textTertiaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHowToEarn(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'كيف تكسب النقاط؟',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          _buildEarnRow(theme, 'اطلب منتجات', 'نقطة لكل 100 ر.س'),
          SizedBox(height: 12.h),
          _buildEarnRow(theme, 'قيّم مشترياتك', '5 نقاط لكل تقييم'),
          SizedBox(height: 12.h),
          _buildEarnRow(theme, 'ادعُ صديقاً', '50 نقطة'),
        ],
      ),
    );
  }

  Widget _buildEarnRow(ThemeData theme, String action, String reward) {
    return Row(
      children: [
        Icon(Iconsax.tick_circle, color: AppColors.success, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(child: Text(action, style: theme.textTheme.bodyMedium)),
        Text(
          reward,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Reward {
  final String name;
  final int points;
  final IconData icon;

  _Reward({required this.name, required this.points, required this.icon});
}
