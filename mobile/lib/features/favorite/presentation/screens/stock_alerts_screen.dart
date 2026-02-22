/// Stock Alerts Screen - Product availability notifications
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/favorite_remote_datasource.dart';
import '../cubit/stock_alerts_cubit.dart';
import '../cubit/stock_alerts_state.dart';

class StockAlertsScreen extends StatefulWidget {
  const StockAlertsScreen({super.key});

  @override
  State<StockAlertsScreen> createState() => _StockAlertsScreenState();
}

class _StockAlertsScreenState extends State<StockAlertsScreen> {
  late final StockAlertsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = StockAlertsCubit(
      dataSource: getIt<FavoriteRemoteDataSource>(),
    );
    _cubit.loadStockAlerts();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _removeStockAlert(String alertId) async {
    await _cubit.removeStockAlert(alertId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.stockAlertRemoved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.stockAlerts)),
        body: BlocBuilder<StockAlertsCubit, StockAlertsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state is StockAlertsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is StockAlertsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.danger,
                      size: 64.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => _cubit.loadStockAlerts(),
                      child: Text(AppLocalizations.of(context)!.retryAction),
                    ),
                  ],
                ),
              );
            }

            if (state is StockAlertsLoaded) {
              if (state.alerts.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return RefreshIndicator(
                onRefresh: () => _cubit.loadStockAlerts(),
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    // Info Card
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.info_circle,
                            size: 20.sp,
                            color: AppColors.info,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'سنخبرك فور توفر المنتج مجدداً',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ...state.alerts.map((alert) => _buildAlertCard(alert, isDark)),
                  ],
                ),
              );
            }

            return _buildEmptyState(isDark);
          },
        ),
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, bool isDark) {
    final productField = alert['productId'];
    final product =
        productField is Map<String, dynamic> ? productField : null;
    final alertId = alert['_id']?.toString() ?? alert['id']?.toString() ?? '';
    final productName = product?['nameAr'] ?? product?['name'] ?? 'منتج';
    final isAvailable = alert['status'] == 'available' || alert['isAvailable'] == true;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: product?['mainImage'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      product!['mainImage'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Iconsax.box,
                        size: 28.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  )
                : Icon(
                    Iconsax.box,
                    size: 28.sp,
                    color: AppColors.textSecondaryLight,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (isAvailable ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    isAvailable ? 'متوفر الآن!' : 'في انتظار التوفر',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isAvailable
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (alertId.isNotEmpty) {
                _removeStockAlert(alertId);
              }
            },
            icon: Icon(Iconsax.trash, size: 20.sp, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.notification,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد تنبيهات',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف منتجات لتنبيهك عند توفرها',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
