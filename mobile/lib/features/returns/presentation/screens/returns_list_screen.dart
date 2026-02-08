/// Returns List Screen - List of return requests
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/enums/return_enums.dart';
import '../cubit/returns_cubit.dart';
import '../cubit/returns_state.dart';

class ReturnsListScreen extends StatelessWidget {
  const ReturnsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ReturnsCubit>()..loadReturns(),
      child: const _ReturnsListView(),
    );
  }
}

class _ReturnsListView extends StatefulWidget {
  const _ReturnsListView();

  @override
  State<_ReturnsListView> createState() => _ReturnsListViewState();
}

class _ReturnsListViewState extends State<_ReturnsListView> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.returns),
        actions: [
          // Filter button
          PopupMenuButton<ReturnStatus?>(
            icon: const Icon(Iconsax.filter),
            onSelected: (status) {
              context.read<ReturnsCubit>().filterByStatus(status);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('الكل'),
              ),
              ...ReturnStatus.values.map((status) => PopupMenuItem(
                    value: status,
                    child: Text(status.displayNameAr),
                  )),
            ],
          ),
        ],
      ),
      body: BlocBuilder<ReturnsCubit, ReturnsState>(
        builder: (context, state) {
          if (state is ReturnsLoading) {
            return const ReturnsListShimmer();
          }

          if (state is ReturnsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.info_circle,
                    size: 64.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<ReturnsCubit>().refresh(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is ReturnsLoaded) {
            if (state.returns.isEmpty) {
              return _buildEmptyState(theme);
            }

            return RefreshIndicator(
              onRefresh: () => context.read<ReturnsCubit>().refresh(),
              child: ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: state.returns.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (index == state.returns.length) {
                    // Load more button
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: ElevatedButton(
                          onPressed: () =>
                              context.read<ReturnsCubit>().loadMore(),
                          child: const Text('تحميل المزيد'),
                        ),
                      ),
                    );
                  }

                  final returnRequest = state.returns[index];
                  return _buildReturnCard(
                    context,
                    theme,
                    isDark,
                    returnRequest,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/returns/select-items');
        },
        icon: const Icon(Iconsax.add),
        label: const Text('طلب إرجاع'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.rotate_left,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد طلبات إرجاع',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    returnRequest,
  ) {
    return InkWell(
      onTap: () {
        context.push('/returns/${returnRequest.id}');
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${returnRequest.returnNumber}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                _buildStatusBadge(returnRequest.status),
              ],
            ),
            SizedBox(height: 12.h),
            if (returnRequest.orderIds.isNotEmpty)
              Text(
                '${returnRequest.orderIds.length} ${returnRequest.orderIds.length == 1 ? 'طلب' : 'طلبات'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            if (returnRequest.items != null && returnRequest.items!.isNotEmpty)
              Text(
                '${returnRequest.items!.length} ${returnRequest.items!.length == 1 ? 'منتج' : 'منتجات'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            SizedBox(height: 8.h),
            if (returnRequest.refundAmount > 0)
              Text(
                'مبلغ الاسترداد: ${returnRequest.refundAmount.toStringAsFixed(2)} ر.س',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            SizedBox(height: 8.h),
            Text(
              _formatDate(returnRequest.createdAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReturnStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status.displayNameAr,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: status.color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy/MM/dd', 'ar').format(date);
  }
}
