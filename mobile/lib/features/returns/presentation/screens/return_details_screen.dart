/// Return Details Screen - View return request details
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../cubit/return_details_cubit.dart';
import '../cubit/return_details_state.dart';
import '../widgets/return_status_card.dart';
import '../widgets/return_item_card.dart';

class ReturnDetailsScreen extends StatelessWidget {
  final String returnId;

  const ReturnDetailsScreen({super.key, required this.returnId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<ReturnDetailsCubit>()..loadReturn(returnId),
      child: const _ReturnDetailsView(),
    );
  }
}

class _ReturnDetailsView extends StatelessWidget {
  const _ReturnDetailsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل طلب الإرجاع'),
      ),
      body: BlocBuilder<ReturnDetailsCubit, ReturnDetailsState>(
        builder: (context, state) {
          if (state is ReturnDetailsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReturnDetailsError) {
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
                    onPressed: () {
                      final cubit = context.read<ReturnDetailsCubit>();
                      if (cubit.returnId != null) {
                        cubit.loadReturn(cubit.returnId!);
                      }
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is ReturnDetailsLoaded) {
            final returnRequest = state.returnRequest;
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<ReturnDetailsCubit>().loadReturn(returnRequest.id);
              },
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  // Status Card
                  ReturnStatusCard(returnRequest: returnRequest),
                  SizedBox(height: 16.h),

                  // Return Info
                  _buildInfoCard(
                    context,
                    theme,
                    isDark,
                    'تفاصيل الإرجاع',
                    [
                      _buildInfoRow(
                        context,
                        theme,
                        isDark,
                        'رقم الطلب',
                        returnRequest.returnNumber,
                      ),
                      if (returnRequest.orderIds.isNotEmpty)
                        _buildInfoRow(
                          context,
                          theme,
                          isDark,
                          'عدد الطلبات',
                          '${returnRequest.orderIds.length}',
                        ),
                      _buildInfoRow(
                        context,
                        theme,
                        isDark,
                        'تاريخ الطلب',
                        DateFormat('yyyy/MM/dd', 'ar').format(returnRequest.createdAt),
                      ),
                      if (returnRequest.reason != null)
                        _buildInfoRow(
                          context,
                          theme,
                          isDark,
                          'سبب الإرجاع',
                          returnRequest.reason!.getName('ar'),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Description
                  if (returnRequest.customerNotes != null)
                    _buildInfoCard(
                      context,
                      theme,
                      isDark,
                      'الوصف',
                      [
                        Text(
                          returnRequest.customerNotes!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  if (returnRequest.customerNotes != null) SizedBox(height: 16.h),

                  // Items
                  if (returnRequest.items != null && returnRequest.items!.isNotEmpty)
                    _buildInfoCard(
                      context,
                      theme,
                      isDark,
                      'المنتجات',
                      returnRequest.items!
                          .map((item) => ReturnItemCard(item: item))
                          .toList(),
                    ),
                  if (returnRequest.items != null && returnRequest.items!.isNotEmpty)
                    SizedBox(height: 16.h),

                  // Refund Info
                  _buildInfoCard(
                    context,
                    theme,
                    isDark,
                    'معلومات الاسترداد',
                    [
                      _buildInfoRow(
                        context,
                        theme,
                        isDark,
                        'قيمة المنتجات',
                        '${returnRequest.totalItemsValue.toStringAsFixed(2)} ر.س',
                      ),
                      if (returnRequest.restockingFee > 0)
                        _buildInfoRow(
                          context,
                          theme,
                          isDark,
                          'رسوم إعادة التخزين',
                          '${returnRequest.restockingFee.toStringAsFixed(2)} ر.س',
                        ),
                      if (returnRequest.shippingDeduction > 0)
                        _buildInfoRow(
                          context,
                          theme,
                          isDark,
                          'خصم الشحن',
                          '${returnRequest.shippingDeduction.toStringAsFixed(2)} ر.س',
                        ),
                      _buildInfoRow(
                        context,
                        theme,
                        isDark,
                        'مبلغ الاسترداد',
                        '${returnRequest.refundAmount.toStringAsFixed(2)} ر.س',
                        valueColor: AppColors.success,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Pickup Address
                  if (returnRequest.pickupAddress != null)
                    _buildInfoCard(
                      context,
                      theme,
                      isDark,
                      'عنوان الاستلام',
                      [
                        _buildInfoRow(
                          context,
                          theme,
                          isDark,
                          'الاسم',
                          returnRequest.pickupAddress!.fullName,
                        ),
                        _buildInfoRow(
                          context,
                          theme,
                          isDark,
                          'الهاتف',
                          returnRequest.pickupAddress!.phone,
                        ),
                        _buildInfoRow(
                          context,
                          theme,
                          isDark,
                          'العنوان',
                          returnRequest.pickupAddress!.address,
                        ),
                        _buildInfoRow(
                          context,
                          theme,
                          isDark,
                          'المدينة',
                          returnRequest.pickupAddress!.city,
                        ),
                        if (returnRequest.pickupAddress!.notes != null)
                          _buildInfoRow(
                            context,
                            theme,
                            isDark,
                            'ملاحظات',
                            returnRequest.pickupAddress!.notes!,
                          ),
                      ],
                    ),
                  if (returnRequest.pickupAddress != null) SizedBox(height: 16.h),

                  // Cancel Button (if pending)
                  if (returnRequest.canCancel)
                    OutlinedButton(
                      onPressed: () => _showCancelDialog(context, returnRequest.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('إلغاء طلب الإرجاع'),
                    ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          }

          if (state is ReturnDetailsCancelled) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.tick_circle,
                    size: 64.sp,
                    color: AppColors.success,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'تم إلغاء طلب الإرجاع',
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('العودة'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String title,
    List<Widget> children,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String returnId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء طلب الإرجاع'),
        content: const Text('هل أنت متأكد من إلغاء طلب الإرجاع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ReturnDetailsCubit>().cancelReturn(returnId);
            },
            child: Text(
              'نعم، إلغاء',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
