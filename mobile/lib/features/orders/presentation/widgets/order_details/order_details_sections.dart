library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../core/config/theme/app_colors.dart';
import '../../../domain/entities/order_entity.dart';
import 'quick_action.dart';
import 'section_card.dart';
import 'section_title.dart';
import 'timeline_step_data.dart';

class OrderDetailsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const OrderDetailsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.warning_2,
                size: 40.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'حدث خطأ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: 180.w,
              height: 44.h,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Iconsax.refresh, size: 18),
                label: const Text('إعادة المحاولة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailsSliverAppBar extends StatelessWidget {
  final OrderEntity order;
  final bool isDark;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onBack;
  final VoidCallback onDownloadInvoice;

  const OrderDetailsSliverAppBar({
    super.key,
    required this.order,
    required this.isDark,
    required this.statusColor,
    required this.statusIcon,
    required this.onBack,
    required this.onDownloadInvoice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMMM yyyy، hh:mm a', 'ar');

    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      stretch: true,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withValues(
              alpha: 0.3,
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.arrow_right_3),
        ),
        onPressed: onBack,
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withValues(
                alpha: 0.3,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.document_download, size: 20),
          ),
          onPressed: onDownloadInvoice,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                statusColor.withValues(alpha: 0.15),
                statusColor.withValues(alpha: 0.05),
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 56.h, 20.w, 16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.4),
                        width: 2,
                      ),
                    ),
                    child: Icon(statusIcon, size: 28.sp, color: statusColor),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    order.status.displayNameAr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${order.orderNumber}  •  ${dateFormat.format(order.createdAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OrderEstimatedDeliveryBanner extends StatelessWidget {
  final DateTime deliveryDate;

  const OrderEstimatedDeliveryBanner({super.key, required this.deliveryDate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE، dd MMMM', 'ar');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withValues(alpha: 0.1),
            AppColors.info.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.calendar_1, size: 20.sp, color: AppColors.info),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التوصيل المتوقع',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  dateFormat.format(deliveryDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderStatusTimelineSection extends StatelessWidget {
  final bool isDark;
  final OrderEntity order;
  final List<TimelineStepData> steps;
  final int currentIndex;
  final VoidCallback? onOpenShippingLabel;

  const OrderStatusTimelineSection({
    super.key,
    required this.isDark,
    required this.order,
    required this.steps,
    required this.currentIndex,
    required this.onOpenShippingLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled || order.status == OrderStatus.refunded) {
      return _CancelledBanner(order: order, isDark: isDark);
    }

    return SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'تتبع الطلب', icon: Iconsax.location),
          SizedBox(height: 20.h),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;

            return _TimelineRow(
              step: step,
              isDark: isDark,
              isCompleted: idx < currentIndex,
              isCurrent: idx == currentIndex,
              isPending: idx > currentIndex,
              isLast: idx == steps.length - 1,
              onOpenShippingLabel: onOpenShippingLabel,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineStepData step;
  final bool isDark;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPending;
  final bool isLast;
  final VoidCallback? onOpenShippingLabel;

  const _TimelineRow({
    required this.step,
    required this.isDark,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPending,
    required this.isLast,
    required this.onOpenShippingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = isCompleted
        ? AppColors.success
        : isCurrent
        ? AppColors.primary
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);
    final lineColor = isCompleted
        ? AppColors.success
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);
    final iconColor = isCompleted || isCurrent
        ? Colors.white
        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44.w,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 40.w : 32.w,
                  height: isCurrent ? 40.w : 32.w,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ]
                        : isCompleted
                        ? [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.25),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                    border: isPending
                        ? Border.all(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    isCompleted ? Iconsax.tick_circle5 : step.icon,
                    size: isCurrent ? 20.sp : 16.sp,
                    color: iconColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.success,
                                  AppColors.success.withValues(alpha: 0.4),
                                ],
                              )
                            : null,
                        color: isCompleted ? null : lineColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 20.h,
                top: isCurrent ? 8.h : 4.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isCurrent || isCompleted
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isPending
                                ? (isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight)
                                : null,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'الحالة الحالية',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (step.subtitle != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      step.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.8)
                            : AppColors.textTertiaryLight,
                        fontSize: 11.sp,
                      ),
                    ),
                  ] else if (isPending) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'في الانتظار',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                  if (step.actionLabel != null &&
                      step.actionUrl != null &&
                      isCompleted) ...[
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: onOpenShippingLabel,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.document,
                              size: 12.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              step.actionLabel!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  final OrderEntity order;
  final bool isDark;

  const _CancelledBanner({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCancelled = order.isCancelled;
    final color = isCancelled ? AppColors.error : Colors.grey;
    final label = isCancelled ? 'تم إلغاء الطلب' : 'تم استرجاع الطلب';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCancelled ? Iconsax.close_circle : Iconsax.money_recive,
                  color: color,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (order.cancelledAt != null)
                      Text(
                        DateFormat(
                          'dd/MM/yyyy - hh:mm a',
                          'ar',
                        ).format(order.cancelledAt!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (order.cancellationReason != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Iconsax.info_circle, size: 14.sp, color: color),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      order.cancellationReason!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
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

class OrderProductsSection extends StatelessWidget {
  final bool isDark;
  final OrderEntity order;

  const OrderProductsSection({
    super.key,
    required this.isDark,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'المنتجات',
            icon: Iconsax.shopping_bag,
            trailing: Text(
              '${order.items.length} منتج',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          ...order.items.asMap().entries.map((entry) {
            final isLast = entry.key == order.items.length - 1;
            return Column(
              children: [
                _OrderProductItem(isDark: isDark, item: entry.value),
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _OrderProductItem extends StatelessWidget {
  final bool isDark;
  final OrderItemEntity item;

  const _OrderProductItem({required this.isDark, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasReturn = item.returnedQuantity > 0;
    final displayQty = hasReturn ? item.effectiveQuantity : item.quantity;
    final displayTotal = hasReturn
        ? (item.effectiveQuantity * item.unitPrice)
        : item.total;

    return Container(
      padding: hasReturn
          ? EdgeInsets.all(10.w)
          : EdgeInsets.symmetric(vertical: 4.h),
      decoration: hasReturn
          ? BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.25),
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: item.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      item.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Iconsax.image,
                        color: AppColors.textTertiaryLight,
                        size: 22.sp,
                      ),
                    ),
                  )
                : Icon(
                    Iconsax.image,
                    color: AppColors.textTertiaryLight,
                    size: 22.sp,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.nameAr ?? item.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasReturn)
                      Container(
                        margin: EdgeInsets.only(right: 6.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          item.isFullyReturned ? 'مرتجع' : 'مرتجع جزئياً',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasReturn
                          ? '$displayQty × ${item.unitPrice.toStringAsFixed(0)} ر.س'
                          : '${item.quantity} × ${item.unitPrice.toStringAsFixed(0)} ر.س',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    Text(
                      '${displayTotal.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderShippingAddressSection extends StatelessWidget {
  final bool isDark;
  final ShippingAddressEntity address;

  const OrderShippingAddressSection({
    super.key,
    required this.isDark,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'عنوان التوصيل', icon: Iconsax.location),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Iconsax.map, size: 20.sp, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.fullName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      address.formattedAddress,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      address.phone,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    if (address.notes != null && address.notes!.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.note_1,
                              size: 12.sp,
                              color: AppColors.info,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                address.notes!,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.info,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderPaymentSummarySection extends StatelessWidget {
  final bool isDark;
  final OrderEntity order;
  final String Function(String?) transferStatusLabel;
  final Color Function(String?) transferStatusColor;

  const OrderPaymentSummarySection({
    super.key,
    required this.isDark,
    required this.order,
    required this.transferStatusLabel,
    required this.transferStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'ملخص الدفع', icon: Iconsax.receipt_item),
          SizedBox(height: 12.h),
          _OrderSummaryRow(
            label: 'المجموع الفرعي',
            value: '${order.subtotal.toStringAsFixed(2)} ر.س',
          ),
          SizedBox(height: 8.h),
          if (order.shippingCost > 0) ...[
            _OrderSummaryRow(
              label: 'الشحن',
              value: '${order.shippingCost.toStringAsFixed(2)} ر.س',
            ),
            SizedBox(height: 8.h),
          ],
          if (order.taxAmount > 0) ...[
            _OrderSummaryRow(
              label: 'الضريبة',
              value: '${order.taxAmount.toStringAsFixed(2)} ر.س',
            ),
            SizedBox(height: 8.h),
          ],
          if (order.discount > 0 || order.couponDiscount > 0) ...[
            _OrderSummaryRow(
              label: order.couponCode != null
                  ? 'الخصم (${order.couponCode})'
                  : 'الخصم',
              value:
                  '-${(order.discount + order.couponDiscount).toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
              valueIcon: Iconsax.discount_shape,
            ),
            SizedBox(height: 8.h),
          ],
          if (order.walletAmountUsed > 0) ...[
            _OrderSummaryRow(
              label: 'رصيد المحفظة قبل الخصم',
              value: '${order.walletBalanceBefore.toStringAsFixed(2)} ر.س',
            ),
            SizedBox(height: 8.h),
            _OrderSummaryRow(
              label: 'المحفظة',
              value: '-${order.walletAmountUsed.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
            ),
            SizedBox(height: 8.h),
            _OrderSummaryRow(
              label: 'رصيد المحفظة بعد الخصم',
              value: '${order.walletBalanceAfter.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.textSecondaryLight,
            ),
            SizedBox(height: 8.h),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${order.total.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (order.paidAmount > 0) ...[
            SizedBox(height: 10.h),
            _OrderSummaryRow(
              label: 'المدفوع',
              value: '${order.paidAmount.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
            ),
          ],
          if (order.remainingAmount > 0) ...[
            SizedBox(height: 8.h),
            _OrderSummaryRow(
              label: 'المتبقي',
              value: '${order.remainingAmount.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.error,
            ),
          ],
          if (order.paymentMethod != null) ...[
            SizedBox(height: 12.h),
            Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  order.paymentMethod!.icon,
                  size: 18.sp,
                  color: AppColors.textSecondaryLight,
                ),
                SizedBox(width: 8.w),
                Text('طريقة الدفع', style: theme.textTheme.bodySmall),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    order.paymentMethod!.displayNameAr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Iconsax.money_recive,
                  size: 18.sp,
                  color: AppColors.textSecondaryLight,
                ),
                SizedBox(width: 8.w),
                Text('حالة الدفع', style: theme.textTheme.bodySmall),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: order.paymentStatus.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    order.paymentStatus.displayNameAr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: order.paymentStatus.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (order.paymentMethod == OrderPaymentMethod.bankTransfer) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('حالة التحويل', style: theme.textTheme.bodySmall),
                Text(
                  transferStatusLabel(order.transferStatus),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: transferStatusColor(order.transferStatus),
                  ),
                ),
              ],
            ),
            if (order.paymentRejectionReason != null &&
                order.paymentRejectionReason!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _OrderSummaryRow(
                label: 'سبب الرفض',
                value: order.paymentRejectionReason!,
                valueColor: AppColors.error,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? valueIcon;

  const _OrderSummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (valueIcon != null) ...[
              Icon(
                valueIcon,
                size: 14.sp,
                color: valueColor ?? AppColors.textSecondaryLight,
              ),
              SizedBox(width: 6.w),
            ],
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: valueColor != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}

class OrderQuickActionsRow extends StatelessWidget {
  final bool isDark;
  final List<OrderQuickAction> actions;

  const OrderQuickActionsRow({
    super.key,
    required this.isDark,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: actions.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: entry.key < actions.length - 1 ? 8.w : 0,
            ),
            child: _QuickActionCard(isDark: isDark, action: entry.value),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final bool isDark;
  final OrderQuickAction action;

  const _QuickActionCard({required this.isDark, required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: action.color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(action.icon, size: 20.sp, color: action.color),
              ),
              SizedBox(height: 8.h),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderBottomActionsRow extends StatelessWidget {
  final bool canCancel;
  final VoidCallback onCancel;
  final VoidCallback onContactSupport;

  const OrderBottomActionsRow({
    super.key,
    required this.canCancel,
    required this.onCancel,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (canCancel) ...[
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: Icon(
                  Iconsax.close_circle,
                  color: AppColors.error,
                  size: 18.sp,
                ),
                label: Text(
                  'إلغاء الطلب',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: onContactSupport,
              icon: Icon(Iconsax.message, size: 18.sp),
              label: Text('تواصل معنا', style: TextStyle(fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
