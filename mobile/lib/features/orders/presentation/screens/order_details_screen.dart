/// Order Details Screen - Full order information with real API data
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderEntity? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = await context.read<OrdersCubit>().getOrderById(
        widget.orderId,
      );
      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
          if (order == null) {
            _error = 'لم يتم العثور على الطلب';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _navigateToOrdersList() {
    context.go('/orders');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _navigateToOrdersList();
          });
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.orderStatus),
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_right_3),
            onPressed: _navigateToOrdersList,
          ),
        actions: [
          if (_order != null)
            IconButton(
              icon: const Icon(Iconsax.document_download),
              onPressed: () {
                // TODO: Implement PDF download
              },
            ),
        ],
      ),
      body: _buildBody(theme, isDark),
    ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const OrderDetailsShimmer();
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(_error!, style: theme.textTheme.bodyLarge),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadOrder,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_order == null) {
      return const Center(child: Text('لم يتم العثور على الطلب'));
    }

    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            _buildOrderHeader(theme, isDark),
            SizedBox(height: 16.h),

            // Status Timeline
            _buildStatusTimeline(theme, isDark),
            SizedBox(height: 16.h),

            // Products
            _buildProductsSection(theme, isDark),
            SizedBox(height: 16.h),

            // Shipping Address
            if (_order!.shippingAddress != null)
              _buildShippingAddress(theme, isDark),
            SizedBox(height: 16.h),

            // Payment Summary
            _buildPaymentSummary(theme, isDark),
            SizedBox(height: 24.h),

            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(ThemeData theme, bool isDark) {
    final order = _order!;
    final dateFormat = DateFormat('dd MMMM yyyy، hh:mm a', 'ar');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  dateFormat.format(order.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(order.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            status.displayNameAr,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => Colors.orange,
      OrderStatus.confirmed => Colors.blue,
      OrderStatus.processing => Colors.purple,
      OrderStatus.readyForPickup => Colors.purple,
      OrderStatus.shipped => Colors.teal,
      OrderStatus.outForDelivery => Colors.teal,
      OrderStatus.delivered => AppColors.success,
      OrderStatus.completed => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
      OrderStatus.refunded => Colors.grey,
    };
  }

  IconData _getStatusIcon(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => Iconsax.clock,
      OrderStatus.confirmed => Iconsax.tick_square,
      OrderStatus.processing => Iconsax.box,
      OrderStatus.readyForPickup => Iconsax.box_tick,
      OrderStatus.shipped => Iconsax.truck,
      OrderStatus.outForDelivery => Iconsax.truck_fast,
      OrderStatus.delivered => Iconsax.tick_circle,
      OrderStatus.completed => Iconsax.medal_star,
      OrderStatus.cancelled => Iconsax.close_circle,
      OrderStatus.refunded => Iconsax.money_recive,
    };
  }

  Widget _buildStatusTimeline(ThemeData theme, bool isDark) {
    final order = _order!;
    final steps = _buildTimelineSteps(order);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطلب',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          ...steps.asMap().entries.map((entry) {
            final isLast = entry.key == steps.length - 1;
            return _buildTimelineItem(theme, entry.value, isLast);
          }),
        ],
      ),
    );
  }

  List<_TimelineStep> _buildTimelineSteps(OrderEntity order) {
    final steps = <_TimelineStep>[];

    // تم الطلب - always completed if order exists
    steps.add(_TimelineStep('تم الطلب', true, order.createdAt));

    // تم التأكيد
    if (order.confirmedAt != null) {
      steps.add(_TimelineStep('تم التأكيد', true, order.confirmedAt));
    } else if (order.status == OrderStatus.pending) {
      steps.add(_TimelineStep('تم التأكيد', false, null));
    }

    // قيد التجهيز
    if (order.status == OrderStatus.processing ||
        order.status == OrderStatus.shipped ||
        order.status == OrderStatus.delivered ||
        order.status == OrderStatus.completed) {
      steps.add(_TimelineStep('قيد التجهيز', true, order.confirmedAt));
    } else if (order.status != OrderStatus.cancelled) {
      steps.add(_TimelineStep('قيد التجهيز', false, null));
    }

    // تم الشحن
    if (order.shippedAt != null) {
      steps.add(_TimelineStep('تم الشحن', true, order.shippedAt));
    } else if (order.status != OrderStatus.cancelled) {
      steps.add(_TimelineStep('تم الشحن', false, null));
    }

    // تم التوصيل
    if (order.deliveredAt != null) {
      steps.add(_TimelineStep('تم التوصيل', true, order.deliveredAt));
    } else if (order.status != OrderStatus.cancelled) {
      steps.add(_TimelineStep('تم التوصيل', false, null));
    }

    // ملغي
    if (order.status == OrderStatus.cancelled) {
      steps.add(_TimelineStep('ملغي', true, order.cancelledAt));
    }

    return steps;
  }

  Widget _buildTimelineItem(ThemeData theme, _TimelineStep step, bool isLast) {
    final dateFormat = DateFormat('dd/MM - HH:mm', 'ar');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? AppColors.success
                    : AppColors.dividerLight,
                shape: BoxShape.circle,
              ),
              child: step.isCompleted
                  ? Icon(Iconsax.tick_circle5, size: 16.sp, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30.h,
                color: step.isCompleted
                    ? AppColors.success
                    : AppColors.dividerLight,
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: step.isCompleted
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: step.isCompleted
                        ? null
                        : AppColors.textTertiaryLight,
                  ),
                ),
                if (step.date != null)
                  Text(
                    dateFormat.format(step.date!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(ThemeData theme, bool isDark) {
    final order = _order!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المنتجات (${order.items.length})',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          ...order.items.asMap().entries.map((entry) {
            final isLast = entry.key == order.items.length - 1;
            return Column(
              children: [
                _buildProductItem(theme, isDark, entry.value),
                if (!isLast) Divider(height: 24.h),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem(ThemeData theme, bool isDark, OrderItemEntity item) {
    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: item.image != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    item.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Iconsax.image, color: AppColors.textTertiaryLight),
                  ),
                )
              : Icon(Iconsax.image, color: AppColors.textTertiaryLight),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.nameAr ?? item.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${item.quantity} × ${item.unitPrice.toStringAsFixed(0)} ر.س',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${item.total.toStringAsFixed(0)} ر.س',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingAddress(ThemeData theme, bool isDark) {
    final address = _order!.shippingAddress!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عنوان التوصيل',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            address.fullName,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(address.formattedAddress, style: theme.textTheme.bodyMedium),
          SizedBox(height: 4.h),
          Text(
            address.phone,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          if (address.notes != null && address.notes!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'ملاحظات: ${address.notes}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(ThemeData theme, bool isDark) {
    final order = _order!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            theme,
            'المجموع الفرعي',
            '${order.subtotal.toStringAsFixed(2)} ر.س',
          ),
          SizedBox(height: 8.h),
          if (order.shippingCost > 0) ...[
            _buildSummaryRow(
              theme,
              'الشحن',
              '${order.shippingCost.toStringAsFixed(2)} ر.س',
            ),
            SizedBox(height: 8.h),
          ],
          if (order.taxAmount > 0) ...[
            _buildSummaryRow(
              theme,
              'الضريبة',
              '${order.taxAmount.toStringAsFixed(2)} ر.س',
            ),
            SizedBox(height: 8.h),
          ],
          if (order.discount > 0 || order.couponDiscount > 0) ...[
            _buildSummaryRow(
              theme,
              order.couponCode != null
                  ? 'الخصم (${order.couponCode})'
                  : 'الخصم',
              '-${(order.discount + order.couponDiscount).toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
            ),
            SizedBox(height: 8.h),
          ],
          if (order.walletAmountUsed > 0) ...[
            _buildSummaryRow(
              theme,
              'المحفظة',
              '-${order.walletAmountUsed.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
            ),
            SizedBox(height: 8.h),
          ],
          Divider(height: 24.h),
          _buildSummaryRow(
            theme,
            'الإجمالي',
            '${order.total.toStringAsFixed(2)} ر.س',
            isTotal: true,
          ),
          if (order.paymentMethod != null) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('طريقة الدفع', style: theme.textTheme.bodySmall),
                Text(
                  order.paymentMethod!.displayNameAr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(color: valueColor),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final order = _order!;

    return Row(
      children: [
        if (order.canCancel)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCancelDialog(context),
              icon: const Icon(Iconsax.close_circle, color: AppColors.error),
              label: const Text(
                'إلغاء الطلب',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          )
        else
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleReorder(context),
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة الطلب'),
            ),
          ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // Navigate to support
              context.push('/support');
            },
            icon: const Icon(Iconsax.message),
            label: const Text('تواصل معنا'),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<OrdersCubit>().cancelOrder(widget.orderId);
              if (mounted) {
                await _loadOrder();
              }
            },
            child: const Text(
              'نعم، إلغاء',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReorder(BuildContext context) async {
    HapticFeedback.selectionClick();
    await context.read<OrdersCubit>().reorder(widget.orderId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تمت إضافة المنتجات إلى السلة')),
      );
      context.go('/cart');
    }
  }
}

class _TimelineStep {
  final String title;
  final bool isCompleted;
  final DateTime? date;

  _TimelineStep(this.title, this.isCompleted, this.date);
}
