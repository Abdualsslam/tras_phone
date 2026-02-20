/// Loyalty Points Screen - Display loyalty points and rewards
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../../data/models/loyalty_points_model.dart';
import '../../data/models/loyalty_tier_model.dart';

class LoyaltyPointsScreen extends StatefulWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  State<LoyaltyPointsScreen> createState() => _LoyaltyPointsScreenState();
}

class _LoyaltyPointsScreenState extends State<LoyaltyPointsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadPoints();
    context.read<WalletCubit>().loadTiers();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.loyaltyPointsTitle),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_text),
            onPressed: () {
              context.push('/loyalty/transactions');
            },
            tooltip: AppLocalizations.of(context)!.pointsTransactions,
          ),
        ],
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading && state is! WalletLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WalletCubit>().loadPoints();
                      context.read<WalletCubit>().loadTiers();
                    },
                    child: Text(AppLocalizations.of(context)!.retryAction),
                  ),
                ],
              ),
            );
          }

          final loyaltyPoints = state is WalletLoaded
              ? state.loyaltyPoints
              : null;
          final tiers = state is WalletLoaded ? state.tiers : null;

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<WalletCubit>().loadPoints();
              await context.read<WalletCubit>().loadTiers();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Points Card
                  if (loyaltyPoints != null)
                    _buildPointsCard(context, theme, isDark, loyaltyPoints, locale)
                  else
                    _buildPointsCardPlaceholder(theme, isDark),
                  SizedBox(height: 24.h),

                  // Tier Progress
                  if (loyaltyPoints != null && tiers != null)
                    _buildTierProgress(context, theme, isDark, loyaltyPoints, tiers, locale)
                  else
                    _buildTierProgressPlaceholder(theme, isDark),
                  SizedBox(height: 24.h),

                  // Rewards
                  _buildRewardsSection(context, theme, isDark, loyaltyPoints),
                  SizedBox(height: 24.h),

                  // How to earn
                  _buildHowToEarn(theme, isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPointsCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    LoyaltyPoints loyaltyPoints,
    String locale,
  ) {
    final tierColor = loyaltyPoints.tier.getColor() ?? Colors.amber;
    final gradientColors = [
      tierColor.withValues(alpha: 0.8),
      tierColor,
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: tierColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (loyaltyPoints.tier.badgeImage != null)
            Image.network(
              loyaltyPoints.tier.badgeImage!,
              width: 64.w,
              height: 64.w,
              errorBuilder: (_, __, ___) => Icon(
                Iconsax.medal_star,
                color: Colors.white,
                size: 48.sp,
              ),
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
                color: Colors.orange.withValues(alpha: 0.3),
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

  Widget _buildPointsCardPlaceholder(ThemeData theme, bool isDark) {
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
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTierProgress(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    LoyaltyPoints loyaltyPoints,
    List<LoyaltyTier> tiers,
    String locale,
  ) {
    // Sort tiers by minPoints
    final sortedTiers = List<LoyaltyTier>.from(tiers)
      ..sort((a, b) => a.minPoints.compareTo(b.minPoints));

    // Find current tier index
    final currentTierIndex = sortedTiers.indexWhere(
      (t) => t.id == loyaltyPoints.tier.id,
    );

    // Find next tier
    LoyaltyTier? nextTier;
    if (currentTierIndex >= 0 && currentTierIndex < sortedTiers.length - 1) {
      nextTier = sortedTiers[currentTierIndex + 1];
    }

    // Calculate progress
    double progress = 0.0;
    String progressText = '';
    if (nextTier != null) {
      final pointsNeeded = nextTier.minPoints - loyaltyPoints.points;
      final totalNeeded = nextTier.minPoints - loyaltyPoints.tier.minPoints;
      progress = totalNeeded > 0
          ? (loyaltyPoints.points - loyaltyPoints.tier.minPoints) / totalNeeded
          : 1.0;
      progress = progress.clamp(0.0, 1.0);
      progressText = pointsNeeded > 0
          ? 'أنت بحاجة لـ $pointsNeeded نقطة للوصول للمستوى ${nextTier.getName(locale)}'
          : 'أنت في أعلى مستوى!';
    } else {
      progress = 1.0;
      progressText = 'أنت في أعلى مستوى!';
    }

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
            nextTier != null
                ? 'تقدمك للمستوى ${nextTier.getName(locale)}'
                : 'مستواك الحالي',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          if (sortedTiers.length <= 3)
            Row(
              children: sortedTiers.asMap().entries.map((entry) {
                final index = entry.key;
                final tier = entry.value;
                final isActive = tier.id == loyaltyPoints.tier.id ||
                    sortedTiers
                        .take(index + 1)
                        .any((t) => t.minPoints <= loyaltyPoints.points);
                final isCurrent = tier.id == loyaltyPoints.tier.id;

                return Expanded(
                  child: Row(
                    children: [
                      _buildTierBadge(
                        tier.getName(locale),
                        tier.getColor() ?? Colors.grey,
                        isActive,
                        isCurrent,
                      ),
                      if (index < sortedTiers.length - 1)
                        Expanded(
                          child: _buildProgressLine(
                            isActive && !isCurrent ? 1.0 : 0.0,
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
                _buildTierBadge(
                  loyaltyPoints.tier.getName(locale),
                  loyaltyPoints.tier.getColor() ?? Colors.grey,
                  true,
                  true,
                ),
                SizedBox(height: 12.h),
                if (nextTier != null)
                  _buildTierBadge(
                    nextTier.getName(locale),
                    nextTier.getColor() ?? Colors.grey,
                    false,
                    false,
                  ),
              ],
            ),
          SizedBox(height: 12.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.dividerLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              loyaltyPoints.tier.getColor() ?? AppColors.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            progressText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierProgressPlaceholder(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildTierBadge(
    String label,
    Color color,
    bool isActive,
    bool isCurrent,
  ) {
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

  Widget _buildRewardsSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    LoyaltyPoints? loyaltyPoints,
  ) {
    final currentPoints = loyaltyPoints?.points ?? 0;
    final tier = loyaltyPoints?.tier;

    final rewards = [
      if (tier != null && tier.discountPercentage > 0)
        _Reward(
          name: 'خصم ${tier.discountPercentage.toStringAsFixed(0)}%',
          points: 0,
          icon: Iconsax.percentage_square,
          available: true,
        ),
      if (tier != null && tier.freeShipping)
        _Reward(
          name: 'شحن مجاني',
          points: 0,
          icon: Iconsax.truck,
          available: true,
        ),
      _Reward(
        name: 'خصم 5%',
        points: 100,
        icon: Iconsax.percentage_square,
        available: currentPoints >= 100,
      ),
      _Reward(
        name: 'شحن مجاني',
        points: 200,
        icon: Iconsax.truck,
        available: currentPoints >= 200,
      ),
      _Reward(
        name: 'خصم 10%',
        points: 300,
        icon: Iconsax.percentage_square,
        available: currentPoints >= 300,
      ),
      _Reward(
        name: 'هدية مجانية',
        points: 500,
        icon: Iconsax.gift,
        available: currentPoints >= 500,
      ),
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
                    reward.icon,
                    size: 32.sp,
                    color: reward.available
                        ? AppColors.primary
                        : AppColors.textTertiaryLight,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    reward.name,
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
  final bool available;

  _Reward({
    required this.name,
    required this.points,
    required this.icon,
    this.available = false,
  });
}
