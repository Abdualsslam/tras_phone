/// Order Details Screen - Full order information with real API data
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';

import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  OrderEntity? _order;
  bool _isLoading = true;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _loadOrder();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
        if (order != null) _animController.forward();
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
    context.go('/home?tab=1');
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
        body: _buildBody(theme, isDark),
      ),
    );
  }

  Widget _buildBody(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return const OrderDetailsShimmer();
    }

    if (_error != null) {
      return _buildErrorState(theme);
    }

    if (_order == null) {
      return Center(
        child: Text('لم يتم العثور على الطلب', style: theme.textTheme.bodyLarge),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Collapsing App Bar with status hero
          _buildSliverAppBar(theme, isDark),

          // Content
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Estimated delivery
                if (_order!.estimatedDeliveryDate != null &&
                    !_order!.isCancelled &&
                    _order!.status != OrderStatus.delivered &&
                    _order!.status != OrderStatus.completed)
                  _buildEstimatedDelivery(theme, isDark),

                SizedBox(height: 16.h),

                // Status Timeline
                _buildStatusTimeline(theme, isDark),
                SizedBox(height: 16.h),

                // Products
                _buildProductsSection(theme, isDark),
                SizedBox(height: 16.h),

                // Shipping Address
                if (_order!.shippingAddress != null) ...[
                  _buildShippingAddress(theme, isDark),
                  SizedBox(height: 16.h),
                ],

                // Payment Summary
                _buildPaymentSummary(theme, isDark),
                SizedBox(height: 16.h),

                // Quick Actions
                _buildQuickActions(context, theme, isDark),
                SizedBox(height: 16.h),

                // Rate Order
                if (_order!.canRate) ...[
                  _buildRateSection(context, theme, isDark),
                  SizedBox(height: 16.h),
                ],

                // Bottom Actions
                _buildActions(context, theme, isDark),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
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
              child: Icon(Iconsax.warning_2, size: 40.sp, color: AppColors.error),
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
              _error!,
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
                onPressed: _loadOrder,
                icon: const Icon(Iconsax.refresh, size: 18),
                label: const Text('إعادة المحاولة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Sliver App Bar with Status Hero ───
  Widget _buildSliverAppBar(ThemeData theme, bool isDark) {
    final order = _order!;
    final statusColor = _getStatusColor(order.status);
    final dateFormat = DateFormat('dd MMMM yyyy، hh:mm a', 'ar');

    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      stretch: true,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.arrow_right_3),
        ),
        onPressed: _navigateToOrdersList,
      ),
      actions: [
        if (_order != null)
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.document_download, size: 20),
            ),
            onPressed: () => _downloadInvoice(context),
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
                  // Status icon circle
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
                    child: Icon(
                      _getStatusIcon(order.status),
                      size: 28.sp,
                      color: statusColor,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Status text
                  Text(
                    order.status.displayNameAr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Order number + date
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

  // ─── Estimated Delivery Banner ───
  Widget _buildEstimatedDelivery(ThemeData theme, bool isDark) {
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
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
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
                  dateFormat.format(_order!.estimatedDeliveryDate!),
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

  // ─── Status Helpers ───
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

  // ─── Status Timeline (Modern Vertical) ───
  Widget _buildStatusTimeline(ThemeData theme, bool isDark) {
    final order = _order!;

    if (order.isCancelled || order.status == OrderStatus.refunded) {
      return _buildCancelledBanner(theme, isDark, order);
    }

    final steps = _buildTimelineSteps(order);
    final currentIndex = _getCurrentStepIndex(order);

    return _SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'تتبع الطلب', icon: Iconsax.location),
          SizedBox(height: 20.h),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isCompleted = idx < currentIndex;
            final isCurrent = idx == currentIndex;
            final isPending = idx > currentIndex;
            final isLast = idx == steps.length - 1;
            return _buildTimelineRow(
              theme,
              isDark,
              step: step,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isPending: isPending,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  List<_TimelineStepData> _buildTimelineSteps(OrderEntity order) {
    final dateFormat = DateFormat('dd/MM - hh:mm a', 'ar');
    String? fmt(DateTime? d) => d != null ? dateFormat.format(d) : null;

    return [
      _TimelineStepData(
        label: 'تم الطلب',
        subtitle: fmt(order.createdAt),
        icon: Iconsax.receipt_item,
      ),
      _TimelineStepData(
        label: 'تم التأكيد',
        subtitle: fmt(order.confirmedAt),
        icon: Iconsax.tick_square,
      ),
      _TimelineStepData(
        label: 'قيد التجهيز',
        subtitle: fmt(order.confirmedAt),
        icon: Iconsax.box,
      ),
      _TimelineStepData(
        label: 'تم الشحن',
        subtitle: fmt(order.shippedAt),
        icon: Iconsax.truck,
      ),
      _TimelineStepData(
        label: 'تم التوصيل',
        subtitle: fmt(order.deliveredAt),
        icon: Iconsax.tick_circle,
      ),
    ];
  }

  int _getCurrentStepIndex(OrderEntity order) {
    return switch (order.status) {
      OrderStatus.pending => 0,
      OrderStatus.confirmed => 1,
      OrderStatus.processing => 2,
      OrderStatus.readyForPickup => 2,
      OrderStatus.shipped => 3,
      OrderStatus.outForDelivery => 3,
      OrderStatus.delivered => 4,
      OrderStatus.completed => 4,
      _ => 0,
    };
  }

  Widget _buildTimelineRow(
    ThemeData theme,
    bool isDark, {
    required _TimelineStepData step,
    required bool isCompleted,
    required bool isCurrent,
    required bool isPending,
    required bool isLast,
  }) {
    // Colors
    final Color dotColor = isCompleted
        ? AppColors.success
        : isCurrent
            ? AppColors.primary
            : (isDark ? AppColors.dividerDark : AppColors.dividerLight);

    final Color lineColor = isCompleted
        ? AppColors.success
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);

    final Color iconColor = isCompleted || isCurrent
        ? Colors.white
        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Right side: dot + line (RTL layout)
          SizedBox(
            width: 44.w,
            child: Column(
              children: [
                // Dot / icon circle
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
                // Connector line
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
          // Left side: text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 20.h,
                top: isCurrent ? 8.h : 4.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label row with "الحالة الحالية" badge
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledBanner(ThemeData theme, bool isDark, OrderEntity order) {
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
                        DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(order.cancelledAt!),
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

  // ─── Products Section ───
  Widget _buildProductsSection(ThemeData theme, bool isDark) {
    final order = _order!;

    return _SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
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
                _buildProductItem(theme, isDark, entry.value),
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Divider(
                      height: 1,
                      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem(ThemeData theme, bool isDark, OrderItemEntity item) {
    final hasReturn = item.returnedQuantity > 0;
    final displayQty = hasReturn ? item.effectiveQuantity : item.quantity;
    final displayTotal =
        hasReturn ? (item.effectiveQuantity * item.unitPrice) : item.total;

    return Container(
      padding: hasReturn ? EdgeInsets.all(10.w) : EdgeInsets.symmetric(vertical: 4.h),
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
          // Product image
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark
                  : AppColors.backgroundLight,
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
          // Product info
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

  // ─── Shipping Address ───
  Widget _buildShippingAddress(ThemeData theme, bool isDark) {
    final address = _order!.shippingAddress!;

    return _SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'عنوان التوصيل', icon: Iconsax.location),
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
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Iconsax.note_1, size: 12.sp, color: AppColors.info),
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

  // ─── Payment Summary ───
  Widget _buildPaymentSummary(ThemeData theme, bool isDark) {
    final order = _order!;

    return _SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'ملخص الدفع', icon: Iconsax.receipt_item),
          SizedBox(height: 12.h),
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
              valueIcon: Iconsax.discount_shape,
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
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          // Total row with highlight
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
            _buildSummaryRow(
              theme,
              'المدفوع',
              '${order.paidAmount.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
            ),
          ],
          if (order.remainingAmount > 0) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              theme,
              'المتبقي',
              '${order.remainingAmount.toStringAsFixed(2)} ر.س',
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
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.surfaceDark : AppColors.backgroundLight),
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
            // Payment status badge
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
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
    IconData? valueIcon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (valueIcon != null) ...[
              Icon(valueIcon, size: 14.sp, color: valueColor ?? AppColors.textSecondaryLight),
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

  // ─── Quick Actions (Grid Style) ───
  Widget _buildQuickActions(BuildContext context, ThemeData theme, bool isDark) {
    final order = _order!;
    final canUploadReceipt =
        order.paymentMethod == OrderPaymentMethod.bankTransfer &&
        order.paymentStatus == PaymentStatus.unpaid;
    final canReturn = order.status == OrderStatus.delivered ||
        order.status == OrderStatus.completed;

    final actions = <_QuickAction>[
      _QuickAction(
        icon: Iconsax.document_text,
        label: 'الفاتورة',
        color: AppColors.info,
        onTap: () => context.push('/order/${order.id}/invoice'),
      ),
      if (canUploadReceipt)
        _QuickAction(
          icon: Iconsax.document_upload,
          label: 'رفع إيصال',
          color: AppColors.accent,
          onTap: () => context.push(
            '/order/${order.id}/upload-receipt',
            extra: {'amount': order.remainingAmount},
          ),
        ),
      if (canReturn)
        _QuickAction(
          icon: Iconsax.rotate_left,
          label: 'طلب إرجاع',
          color: AppColors.warning,
          onTap: () => context.push('/returns/select-items'),
        ),
    ];

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      children: actions.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: entry.key < actions.length - 1 ? 8.w : 0,
            ),
            child: _buildQuickActionCard(theme, isDark, entry.value),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionCard(
    ThemeData theme,
    bool isDark,
    _QuickAction action,
  ) {
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
            border: Border.all(
              color: action.color.withValues(alpha: 0.15),
            ),
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
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Rate Section ───
  Widget _buildRateSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return _OrderRateSection(
      orderId: widget.orderId,
      onRated: _loadOrder,
    );
  }

  // ─── Download Invoice ───
  Future<void> _downloadInvoice(BuildContext context) async {
    final cubit = context.read<OrdersCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final url = await cubit.getOrderInvoice(widget.orderId);
      if (url.isNotEmpty && mounted) {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('تعذر فتح رابط الفاتورة')),
          );
        }
      } else if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('لا يوجد رابط للفاتورة')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('فشل تحميل الفاتورة: ${e.toString()}')),
        );
      }
    }
  }

  // ─── Bottom Actions ───
  Widget _buildActions(BuildContext context, ThemeData theme, bool isDark) {
    final order = _order!;

    return Row(
      children: [
        if (order.canCancel) ...[
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context),
                icon: Icon(Iconsax.close_circle, color: AppColors.error, size: 18.sp),
                label: Text(
                  'إلغاء الطلب',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
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
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/support');
              },
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

  void _showCancelDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          final hasReason = reasonController.text.trim().isNotEmpty;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Row(
              children: [
                Icon(Iconsax.warning_2, color: AppColors.error, size: 22.sp),
                SizedBox(width: 8.w),
                const Text('إلغاء الطلب'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
                SizedBox(height: 16.h),
                TextField(
                  controller: reasonController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'سبب الإلغاء (مطلوب)',
                    hintText: 'أدخل سبب الإلغاء...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('لا'),
              ),
              TextButton(
                onPressed: hasReason
                    ? () async {
                        final reason = reasonController.text.trim();
                        Navigator.of(dialogContext).pop();
                        await context.read<OrdersCubit>().cancelOrder(
                              widget.orderId,
                              reason: reason,
                            );
                        if (mounted) {
                          await _loadOrder();
                        }
                      }
                    : null,
                child: const Text(
                  'نعم، إلغاء',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Timeline Step Data Model ───
class _TimelineStepData {
  final String label;
  final String? subtitle;
  final IconData icon;

  _TimelineStepData({
    required this.label,
    this.subtitle,
    required this.icon,
  });
}

// ─── Reusable Section Card ───
class _SectionCard extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _SectionCard({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}

// ─── Reusable Section Title ───
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

// ─── Quick Action Model ───
class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

// ─── Order Rate Section ───
class _OrderRateSection extends StatefulWidget {
  final String orderId;
  final Future<void> Function() onRated;

  const _OrderRateSection({
    required this.orderId,
    required this.onRated,
  });

  @override
  State<_OrderRateSection> createState() => _OrderRateSectionState();
}

class _OrderRateSectionState extends State<_OrderRateSection> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return _SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: 'قيّم طلبك', icon: Iconsax.star_1),
          SizedBox(height: 16.h),
          // Star rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: _isSubmitting
                    ? null
                    : () => setState(() => _rating = starValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Icon(
                    starValue <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 36.sp,
                    color: starValue <= _rating
                        ? AppColors.accent
                        : AppColors.textTertiaryLight,
                  ),
                ),
              );
            }),
          ),
          if (_rating > 0) ...[
            SizedBox(height: 4.h),
            Center(
              child: Text(
                _getRatingLabel(_rating),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          SizedBox(height: 14.h),
          TextField(
            controller: _commentController,
            enabled: !_isSubmitting,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'أضف تعليقاً (اختياري)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: _rating > 0 && !_isSubmitting ? _submitRating : null,
              icon: _isSubmitting
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Iconsax.send_1, size: 18.sp),
              label: Text(
                _isSubmitting ? 'جاري الإرسال...' : 'إرسال التقييم',
                style: TextStyle(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingLabel(int rating) {
    return switch (rating) {
      1 => 'سيء',
      2 => 'مقبول',
      3 => 'جيد',
      4 => 'جيد جداً',
      5 => 'ممتاز',
      _ => '',
    };
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    try {
      await context.read<OrdersCubit>().rateOrder(
            orderId: widget.orderId,
            rating: _rating,
            comment: _commentController.text.trim().isNotEmpty
                ? _commentController.text.trim()
                : null,
          );
      if (mounted) {
        await widget.onRated();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إرسال التقييم')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
