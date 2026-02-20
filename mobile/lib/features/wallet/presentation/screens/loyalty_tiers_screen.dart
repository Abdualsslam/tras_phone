/// Loyalty Tiers Screen - Display all loyalty tiers
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../../data/models/loyalty_tier_model.dart';

class LoyaltyTiersScreen extends StatefulWidget {
  const LoyaltyTiersScreen({super.key});

  @override
  State<LoyaltyTiersScreen> createState() => _LoyaltyTiersScreenState();
}

class _LoyaltyTiersScreenState extends State<LoyaltyTiersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadTiers();
    context.read<WalletCubit>().loadPoints();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.loyaltyTiers)),
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
                      context.read<WalletCubit>().loadTiers();
                      context.read<WalletCubit>().loadPoints();
                    },
                    child: Text(AppLocalizations.of(context)!.retryAction),
                  ),
                ],
              ),
            );
          }

          final tiers = state is WalletLoaded
              ? (state.tiers ?? [])
              : <LoyaltyTier>[];
          final loyaltyPoints = state is WalletLoaded
              ? state.loyaltyPoints
              : null;

          final currentTierId = loyaltyPoints?.tier.id;

          // Sort tiers by minPoints
          final sortedTiers = List<LoyaltyTier>.from(tiers)
            ..sort((a, b) => a.minPoints.compareTo(b.minPoints));

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<WalletCubit>().loadTiers();
              await context.read<WalletCubit>().loadPoints();
            },
            child: sortedTiers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.medal_star,
                          size: 64.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد مستويات متاحة',
                          style: TextStyle(
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: sortedTiers.length,
                    itemBuilder: (context, index) {
                      final tier = sortedTiers[index];
                      final isCurrent = tier.id == currentTierId;
                      final isUnlocked = loyaltyPoints != null
                          ? loyaltyPoints.points >= tier.minPoints
                          : false;

                      return _buildTierCard(
                        context,
                        theme,
                        isDark,
                        tier,
                        isCurrent,
                        isUnlocked,
                        locale,
                        index == sortedTiers.length - 1,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    LoyaltyTier tier,
    bool isCurrent,
    bool isUnlocked,
    String locale,
    bool isLast,
  ) {
    final tierColor = tier.getColor() ?? AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: isCurrent
            ? Border.all(color: tierColor, width: 2)
            : Border.all(
                color: AppColors.dividerLight,
                width: 1,
              ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: tierColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Badge/Icon
              if (tier.badgeImage != null)
                Image.network(
                  tier.badgeImage!,
                  width: 48.w,
                  height: 48.w,
                  errorBuilder: (_, __, ___) => _buildTierIcon(tier, tierColor),
                )
              else
                _buildTierIcon(tier, tierColor),
              SizedBox(width: 12.w),
              // Name and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tier.getName(locale),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: tierColor,
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: tierColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              'الحالي',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: tierColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${tier.minPoints}+ نقطة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Description
          if (tier.getDescription(locale) != null) ...[
            SizedBox(height: 12.h),
            Text(
              tier.getDescription(locale)!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],

          SizedBox(height: 16.h),

          // Benefits
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (tier.pointsMultiplier > 1)
                _buildBenefitChip(
                  'x${tier.pointsMultiplier.toStringAsFixed(1)} نقاط',
                  Iconsax.star,
                  tierColor,
                ),
              if (tier.discountPercentage > 0)
                _buildBenefitChip(
                  'خصم ${tier.discountPercentage.toStringAsFixed(0)}%',
                  Iconsax.percentage_square,
                  tierColor,
                ),
              if (tier.freeShipping)
                _buildBenefitChip(
                  'شحن مجاني',
                  Iconsax.truck,
                  tierColor,
                ),
              if (tier.prioritySupport)
                _buildBenefitChip(
                  'دعم متميز',
                  Iconsax.headphone,
                  tierColor,
                ),
              if (tier.earlyAccess)
                _buildBenefitChip(
                  'وصول مبكر',
                  Iconsax.clock,
                  tierColor,
                ),
              if (tier.customBenefits != null)
                ...tier.customBenefits!.map(
                  (benefit) => _buildBenefitChip(
                    benefit,
                    Iconsax.gift,
                    tierColor,
                  ),
                ),
            ],
          ),

          // Requirements
          if (tier.minSpend != null || tier.minOrders != null) ...[
            SizedBox(height: 16.h),
            Divider(color: AppColors.dividerLight),
            SizedBox(height: 12.h),
            Text(
              'متطلبات إضافية:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            if (tier.minSpend != null)
              _buildRequirementRow(
                'إنفاق ${tier.minSpend!.toStringAsFixed(0)} ر.س',
                Iconsax.wallet_money,
              ),
            if (tier.minOrders != null)
              _buildRequirementRow(
                '${tier.minOrders} طلب',
                Iconsax.shopping_bag,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTierIcon(LoyaltyTier tier, Color color) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Iconsax.medal_star,
        color: color,
        size: 24.sp,
      ),
    );
  }

  Widget _buildBenefitChip(String label, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: AppColors.textTertiaryLight),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
