library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../l10n/app_localizations.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../models/loyalty_view_data.dart';
import '../widgets/loyalty_points_sections.dart';

class LoyaltyPointsScreen extends StatefulWidget {
  const LoyaltyPointsScreen({super.key});

  @override
  State<LoyaltyPointsScreen> createState() => _LoyaltyPointsScreenState();
}

class _LoyaltyPointsScreenState extends State<LoyaltyPointsScreen> {
  @override
  void initState() {
    super.initState();
    _loadLoyaltyData();
  }

  Future<void> _loadLoyaltyData() async {
    final walletCubit = context.read<WalletCubit>();
    await walletCubit.loadPoints();
    await walletCubit.loadTiers();
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
            onPressed: () => context.push('/loyalty/transactions'),
            tooltip: AppLocalizations.of(context)!.pointsTransactions,
          ),
        ],
      ),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletError) {
            return LoyaltyErrorState(
              message: state.message,
              onRetry: _loadLoyaltyData,
            );
          }

          final loadedState = state is WalletLoaded ? state : null;
          final loyaltyPoints = loadedState?.loyaltyPoints;
          final tiers = loadedState?.tiers;
          final viewData = loyaltyPoints != null && tiers != null
              ? LoyaltyViewData.fromData(loyaltyPoints, tiers, locale)
              : null;

          return RefreshIndicator(
            onRefresh: _loadLoyaltyData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  if (loyaltyPoints != null)
                    LoyaltyPointsCard(
                      loyaltyPoints: loyaltyPoints,
                      locale: locale,
                    )
                  else
                    LoyaltyCardPlaceholder(isDark: isDark),
                  SizedBox(height: 24.h),
                  if (viewData != null)
                    LoyaltyTierProgressCard(
                      viewData: viewData,
                      isDark: isDark,
                      locale: locale,
                    )
                  else
                    LoyaltyCardPlaceholder(isDark: isDark),
                  SizedBox(height: 24.h),
                  LoyaltyRewardsSection(
                    rewards: viewData?.rewards ?? const [],
                    isDark: isDark,
                  ),
                  SizedBox(height: 24.h),
                  LoyaltyHowToEarnSection(isDark: isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
