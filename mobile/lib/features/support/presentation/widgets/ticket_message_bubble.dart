/// Ticket Message Bubble Widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/support_model.dart';

class TicketMessageBubble extends StatelessWidget {
  final TicketMessageModel message;
  final bool isDark;

  const TicketMessageBubble({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isFromCustomer = message.isFromCustomer;

    return Align(
      alignment: isFromCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: isFromCustomer ? 50.w : 0,
          right: isFromCustomer ? 0 : 50.w,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isFromCustomer
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isFromCustomer ? 16.r : 4.r),
            bottomRight: Radius.circular(isFromCustomer ? 4.r : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isFromCustomer && message.senderName.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Text(
                  message.senderName,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: isFromCustomer
                        ? Colors.white.withValues(alpha: 0.9)
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                fontSize: 14.sp,
                color: isFromCustomer
                    ? Colors.white
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
              ),
            ),
            if (message.attachments.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: message.attachments.map((url) {
                  return _buildAttachment(url);
                }).toList(),
              ),
            ],
            SizedBox(height: 4.h),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10.sp,
                color: isFromCustomer
                    ? Colors.white.withValues(alpha: 0.7)
                    : (isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(String url) {
    final isImage = url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png') ||
        url.toLowerCase().endsWith('.gif') ||
        url.toLowerCase().endsWith('.webp');

    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.network(
          url,
          width: 80.w,
          height: 80.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 80.w,
              height: 80.h,
              color: Colors.grey[300],
              child: Icon(Icons.broken_image, size: 24.sp),
            );
          },
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.attach_file, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            url.split('/').last,
            style: TextStyle(fontSize: 11.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'أمس ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE HH:mm', 'ar').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy HH:mm', 'ar').format(dateTime);
    }
  }
}
