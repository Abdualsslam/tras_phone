import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/loyalty_points_model.dart';
import '../models/loyalty_view_data.dart';

class LoyaltyErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const LoyaltyErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class LoyaltyPointsCard extends StatelessWidget {
  final LoyaltyPoints loyaltyPoints;
  final String locale;

  const LoyaltyPointsCard({
    super.key,
    required this.loyaltyPoints,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = loyaltyPoints.tier.getColor() ?? Colors.amber;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tierColor.withValues(alpha: 0.8), tierColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (loyaltyPoints.tier.badgeImage case final badgeImage?)
            Image.network(
              badgeImage,
              width: 64.w,
              height: 64.w,
              errorBuilder: (_, _, _) =>
                  Icon(Iconsax.medal_star, color: Colors.white, size: 48.sp),
            )
          else
            Icon(Iconsax.medal_star, color: Colors.white, size: 48.sp),
          SizedBox(height: 16.h),
          Text(
            '${loyaltyPoints.points}',
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
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              loyaltyPoints.tier.getName(locale),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          if (loyaltyPoints.expiringTotal > 0) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.26),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.info_circle, color: Colors.white, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    '${loyaltyPoints.expiringTotal} نقطة ستنتهي قريباً',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LoyaltyCardPlaceholder extends StatelessWidget {
  final bool isDark;

  const LoyaltyCardPlaceholder({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class LoyaltyTierProgressCard extends StatelessWidget {
  final LoyaltyViewData viewData;
  final bool isDark;
  final String locale;

  const LoyaltyTierProgressCard({
    super.key,
    required this.viewData,
    required this.isDark,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            viewData.nextTier != null
                ? 'تقدمك نحو ${viewData.nextTier!.getName(locale)}'
                : 'مستواك الحالي',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          if (viewData.sortedTiers.length <= 3)
            Row(
              children: viewData.sortedTiers.asMap().entries.map((entry) {
                final index = entry.key;
                final tier = entry.value;
                final isActive =
                    tier.minPoints <= viewData.loyaltyPoints.points;
                final isCurrent = tier.id == viewData.loyaltyPoints.tier.id;

                return Expanded(
                  child: Row(
                    children: [
                      LoyaltyTierBadge(
                        label: tier.getName(locale),
                        color: tier.getColor() ?? Colors.grey,
                        isActive: isActive,
                        isCurrent: isCurrent,
                      ),
                      if (index < viewData.sortedTiers.length - 1)
                        Expanded(
                          child: LoyaltyProgressLine(
                            progress: isActive && !isCurrent ? 1 : 0,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            )
          else
            Column(
              children: [
                LoyaltyTierBadge(
                  label: viewData.loyaltyPoints.tier.getName(locale),
                  color: viewData.loyaltyPoints.tier.getColor() ?? Colors.grey,
                  isActive: true,
                  isCurrent: true,
                ),
                if (viewData.nextTier case final nextTier?) ...[
                  SizedBox(height: 12.h),
                  LoyaltyTierBadge(
                    label: nextTier.getName(locale),
                    color: nextTier.getColor() ?? Colors.grey,
                    isActive: false,
                    isCurrent: false,
                  ),
                ],
              ],
            ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: viewData.progress,
            backgroundColor: AppColors.dividerLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              viewData.loyaltyPoints.tier.getColor() ?? AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            viewData.progressText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class LoyaltyTierBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final bool isCurrent;

  const LoyaltyTierBadge({
    super.key,
    required this.label,
    required this.color,
    required this.isActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Icon(
            isActive
                ? (isCurrent ? Iconsax.tick_circle5 : Iconsax.medal_star)
                : Iconsax.medal_star,
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class LoyaltyProgressLine extends StatelessWidget {
  final double progress;

  const LoyaltyProgressLine({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
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
}

class LoyaltyRewardsSection extends StatelessWidget {
  final List<LoyaltyRewardItem> rewards;
  final bool isDark;

  const LoyaltyRewardsSection({
    super.key,
    required this.rewards,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16.r),
                border: reward.available
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _iconForReward(reward.type),
                    size: 32.sp,
                    color: reward.available
                        ? AppColors.primary
                        : AppColors.textTertiaryLight,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    reward.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (reward.points > 0) ...[
                    SizedBox(height: 4.h),
                    Text(
                      '${reward.points} نقطة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: reward.available
                            ? AppColors.primary
                            : AppColors.textTertiaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _iconForReward(LoyaltyRewardType type) {
    return switch (type) {
      LoyaltyRewardType.discount => Iconsax.percentage_square,
      LoyaltyRewardType.shipping => Iconsax.truck,
      LoyaltyRewardType.gift => Iconsax.gift,
      LoyaltyRewardType.support => Iconsax.message_question,
      LoyaltyRewardType.access => Iconsax.flash_1,
    };
  }
}

class LoyaltyHowToEarnSection extends StatelessWidget {
  final bool isDark;

  const LoyaltyHowToEarnSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          const LoyaltyEarnRow(
            title: 'اطلب منتجات',
            reward: 'نقطة لكل 100 ر.س',
          ),
          SizedBox(height: 12.h),
          const LoyaltyEarnRow(
            title: 'قيّم مشترياتك',
            reward: '5 نقاط لكل تقييم',
          ),
          SizedBox(height: 12.h),
          const LoyaltyEarnRow(title: 'ادعُ صديقاً', reward: '50 نقطة'),
        ],
      ),
    );
  }
}

class LoyaltyEarnRow extends StatelessWidget {
  final String title;
  final String reward;

  const LoyaltyEarnRow({super.key, required this.title, required this.reward});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(Iconsax.tick_circle, color: AppColors.success, size: 20.sp),
        SizedBox(width: 12.w),
        Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
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
