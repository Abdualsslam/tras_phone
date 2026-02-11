/// Return Status Card - Widget to display return request status with timeline
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/return_entity.dart';

class ReturnStatusCard extends StatelessWidget {
  final ReturnEntity returnRequest;

  const ReturnStatusCard({super.key, required this.returnRequest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: EdgeInsets.all(16.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${returnRequest.returnNumber}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusBadge(returnRequest.status),
              ],
            ),
            SizedBox(height: 16.h),

            // Timeline
            _buildStatusTimeline(returnRequest.status, isDark),

            SizedBox(height: 16.h),

            // Refund Amount
            if (returnRequest.refundAmount > 0)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('مبلغ الاسترداد', style: theme.textTheme.bodyMedium),
                    Text(
                      '${returnRequest.refundAmount.toStringAsFixed(2)} ر.س',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),

            // Rejection Reason
            if (returnRequest.status == ReturnStatus.rejected &&
                returnRequest.rejectionReason != null)
              Container(
                margin: EdgeInsets.only(top: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red[700],
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        returnRequest.rejectionReason!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReturnStatus status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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

  Widget _buildStatusTimeline(ReturnStatus currentStatus, bool isDark) {
    final statuses = [
      ReturnStatus.pending,
      ReturnStatus.approved,
      ReturnStatus.pickupScheduled,
      ReturnStatus.pickedUp,
      ReturnStatus.inspecting,
      ReturnStatus.completed,
    ];

    final currentIndex = statuses.indexOf(currentStatus);
    if (currentIndex == -1) {
      // Status not in timeline (e.g., rejected, cancelled)
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حالة الطلب',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        Row(
          children: statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = index <= currentIndex;
            final isLast = index == statuses.length - 1;

            return Expanded(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: isCompleted ? status.color : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                size: 14.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      if (!isLast)
                        Container(
                          width: 2.w,
                          height: 30.h,
                          color: isCompleted ? status.color : Colors.grey[300],
                        ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
