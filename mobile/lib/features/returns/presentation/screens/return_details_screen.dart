/// Return Details Screen - View return request details
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';

class ReturnDetailsScreen extends StatelessWidget {
  final String returnId;

  const ReturnDetailsScreen({super.key, required this.returnId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mock return data
    final returnData = {
      'id': returnId,
      'orderNumber': 'ORD-2024-0012',
      'status': 'pending',
      'reason': 'المنتج مختلف عن الوصف',
      'description':
          'الشاشة المستلمة لا تتوافق مع موديل الهاتف المحدد في الطلب',
      'createdAt': '2024-12-18',
      'items': [
        {'name': 'شاشة iPhone 15 Pro Max', 'quantity': 1, 'price': 850.0},
      ],
      'refundAmount': 850.0,
      'refundMethod': 'wallet',
    };

    return Scaffold(
      appBar: AppBar(title: Text('طلب إرجاع #$returnId')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Status Card
          _buildStatusCard(returnData['status'] as String, isDark),
          SizedBox(height: 16.h),

          // Return Info
          _buildInfoCard(
            title: 'تفاصيل الإرجاع',
            children: [
              _buildInfoRow(
                'رقم الطلب',
                returnData['orderNumber'] as String,
                isDark,
              ),
              _buildInfoRow(
                'تاريخ الطلب',
                returnData['createdAt'] as String,
                isDark,
              ),
              _buildInfoRow(
                'سبب الإرجاع',
                returnData['reason'] as String,
                isDark,
              ),
            ],
            isDark: isDark,
          ),
          SizedBox(height: 16.h),

          // Description
          _buildInfoCard(
            title: 'الوصف',
            children: [
              Text(
                returnData['description'] as String,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.6,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
            isDark: isDark,
          ),
          SizedBox(height: 16.h),

          // Items
          _buildInfoCard(
            title: 'المنتجات',
            children: [
              for (final item in returnData['items'] as List)
                _buildItemRow(item as Map<String, dynamic>, isDark),
            ],
            isDark: isDark,
          ),
          SizedBox(height: 16.h),

          // Refund Info
          _buildInfoCard(
            title: 'معلومات الاسترداد',
            children: [
              _buildInfoRow(
                'مبلغ الاسترداد',
                '${(returnData['refundAmount'] as double).toStringAsFixed(0)} ر.س',
                isDark,
                valueColor: AppColors.success,
              ),
              _buildInfoRow(
                'طريقة الاسترداد',
                returnData['refundMethod'] == 'wallet'
                    ? 'المحفظة'
                    : 'نفس طريقة الدفع',
                isDark,
              ),
            ],
            isDark: isDark,
          ),
          SizedBox(height: 16.h),

          // Timeline
          _buildTimeline(isDark),
          SizedBox(height: 24.h),

          // Cancel Button (if pending)
          if (returnData['status'] == 'pending')
            OutlinedButton(
              onPressed: () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              child: Text(
                'إلغاء طلب الإرجاع',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String status, bool isDark) {
    final statusInfo = _getStatusInfo(status);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: statusInfo['color'].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusInfo['color'].withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: statusInfo['color'],
              shape: BoxShape.circle,
            ),
            child: Icon(statusInfo['icon'], size: 24.sp, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['label'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: statusInfo['color'],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  statusInfo['description'],
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppTheme.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    bool isDark, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color:
                  valueColor ??
                  (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Iconsax.box, size: 24.sp, color: AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'الكمية: ${item['quantity']}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${(item['price'] as double).toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(bool isDark) {
    final steps = [
      {'title': 'تم تقديم الطلب', 'date': '18 ديسمبر 2024', 'completed': true},
      {'title': 'قيد المراجعة', 'date': 'في الانتظار', 'completed': false},
      {'title': 'تمت الموافقة', 'date': '', 'completed': false},
      {'title': 'تم الاسترداد', 'date': '', 'completed': false},
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppTheme.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطلب',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          ...steps.asMap().entries.map((entry) {
            final step = entry.value;
            final isLast = entry.key == steps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: step['completed'] as bool
                            ? AppColors.success
                            : AppColors.dividerLight,
                        shape: BoxShape.circle,
                      ),
                      child: step['completed'] as bool
                          ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                          : null,
                    ),
                    if (!isLast)
                      Container(
                        width: 2.w,
                        height: 30.h,
                        color: step['completed'] as bool
                            ? AppColors.success
                            : AppColors.dividerLight,
                      ),
                  ],
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'] as String,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if ((step['date'] as String).isNotEmpty)
                          Text(
                            step['date'] as String,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'approved':
        return {
          'label': 'تمت الموافقة',
          'description': 'تم قبول طلب الإرجاع',
          'color': AppColors.success,
          'icon': Iconsax.tick_circle,
        };
      case 'rejected':
        return {
          'label': 'مرفوض',
          'description': 'تم رفض طلب الإرجاع',
          'color': AppColors.error,
          'icon': Iconsax.close_circle,
        };
      case 'refunded':
        return {
          'label': 'تم الاسترداد',
          'description': 'تم استرداد المبلغ',
          'color': AppColors.info,
          'icon': Iconsax.money_recive,
        };
      default:
        return {
          'label': 'قيد المراجعة',
          'description': 'طلبك قيد المراجعة من فريقنا',
          'color': AppColors.warning,
          'icon': Iconsax.timer_1,
        };
    }
  }

  void _showCancelDialog(BuildContext context) {
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إلغاء طلب الإرجاع')),
              );
            },
            child: Text('نعم، إلغاء', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
