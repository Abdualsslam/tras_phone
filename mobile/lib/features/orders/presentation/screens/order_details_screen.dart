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
import '../widgets/order_details/order_details_sections.dart';
import '../widgets/order_details/order_rate_section.dart';
import '../widgets/order_details/quick_action.dart';
import '../widgets/order_details/timeline_step_data.dart';

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
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
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
      if (!mounted) return;

      setState(() {
        _order = order;
        _isLoading = false;
        if (order == null) {
          _error = 'لم يتم العثور على الطلب';
        }
      });

      if (order != null) {
        _animController.forward();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
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
            if (mounted) {
              _navigateToOrdersList();
            }
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
      return OrderDetailsErrorState(message: _error!, onRetry: _loadOrder);
    }

    if (_order == null) {
      return Center(
        child: Text(
          'لم يتم العثور على الطلب',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    final order = _order!;
    final actions = _buildQuickActions(context, order);

    return FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          OrderDetailsSliverAppBar(
            order: order,
            isDark: isDark,
            statusColor: _getStatusColor(order.status),
            statusIcon: _getStatusIcon(order.status),
            onBack: _navigateToOrdersList,
            onDownloadInvoice: () => _downloadInvoice(context),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (order.estimatedDeliveryDate != null &&
                    !order.isCancelled &&
                    order.status != OrderStatus.delivered &&
                    order.status != OrderStatus.completed)
                  OrderEstimatedDeliveryBanner(
                    deliveryDate: order.estimatedDeliveryDate!,
                  ),
                SizedBox(height: 16.h),
                OrderStatusTimelineSection(
                  isDark: isDark,
                  order: order,
                  steps: _buildTimelineSteps(order),
                  currentIndex: _getCurrentStepIndex(order),
                  onOpenShippingLabel: order.shippingLabelUrl != null
                      ? () => _openShippingLabel(order.shippingLabelUrl!)
                      : null,
                ),
                SizedBox(height: 16.h),
                OrderProductsSection(isDark: isDark, order: order),
                SizedBox(height: 16.h),
                if (order.shippingAddress != null) ...[
                  OrderShippingAddressSection(
                    isDark: isDark,
                    address: order.shippingAddress!,
                  ),
                  SizedBox(height: 16.h),
                ],
                OrderPaymentSummarySection(
                  isDark: isDark,
                  order: order,
                  transferStatusLabel: _transferStatusLabel,
                  transferStatusColor: _transferStatusColor,
                ),
                SizedBox(height: 16.h),
                OrderQuickActionsRow(isDark: isDark, actions: actions),
                if (actions.isNotEmpty) SizedBox(height: 16.h),
                if (order.canRate) ...[
                  _buildRateSection(context, theme, isDark),
                  SizedBox(height: 16.h),
                ],
                OrderBottomActionsRow(
                  canCancel: order.canCancel,
                  onCancel: () => _showCancelDialog(context),
                  onContactSupport: () {
                    HapticFeedback.mediumImpact();
                    context.push('/support');
                  },
                ),
              ]),
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

  String _transferStatusLabel(String? status) {
    return switch ((status ?? 'not_required').toLowerCase()) {
      'awaiting_receipt' => 'بانتظار رفع الإيصال',
      'receipt_uploaded' => 'تم رفع الإيصال',
      'verified' => 'تم التحقق',
      'rejected' => 'مرفوض',
      'not_required' => 'غير مطلوب',
      _ => 'غير معروف',
    };
  }

  Color _transferStatusColor(String? status) {
    return switch ((status ?? 'not_required').toLowerCase()) {
      'awaiting_receipt' => AppColors.warning,
      'receipt_uploaded' => AppColors.info,
      'verified' => AppColors.success,
      'rejected' => AppColors.error,
      'not_required' => AppColors.textSecondaryLight,
      _ => AppColors.textSecondaryLight,
    };
  }

  List<TimelineStepData> _buildTimelineSteps(OrderEntity order) {
    final dateFormat = DateFormat('dd/MM - hh:mm a', 'ar');
    String? fmt(DateTime? date) =>
        date != null ? dateFormat.format(date) : null;

    return [
      TimelineStepData(
        label: 'تم الطلب',
        subtitle: fmt(order.createdAt),
        icon: Iconsax.receipt_item,
      ),
      TimelineStepData(
        label: 'تم التأكيد',
        subtitle: fmt(order.confirmedAt),
        icon: Iconsax.tick_square,
      ),
      TimelineStepData(
        label: 'قيد التجهيز',
        subtitle: fmt(order.confirmedAt),
        icon: Iconsax.box,
      ),
      TimelineStepData(
        label: 'تم الشحن',
        subtitle: fmt(order.shippedAt),
        icon: Iconsax.truck,
        actionLabel: order.shippingLabelUrl != null ? 'عرض البوليصة' : null,
        actionUrl: order.shippingLabelUrl,
      ),
      TimelineStepData(
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

  List<OrderQuickAction> _buildQuickActions(
    BuildContext context,
    OrderEntity order,
  ) {
    final canUploadReceipt = order.canUploadTransferReceipt;
    final canReturn =
        order.status == OrderStatus.delivered ||
        order.status == OrderStatus.completed;

    return [
      OrderQuickAction(
        icon: Iconsax.document_text,
        label: 'الفاتورة',
        color: AppColors.info,
        onTap: () => context.push('/order/${order.id}/invoice'),
      ),
      if (canUploadReceipt)
        OrderQuickAction(
          icon: Iconsax.document_upload,
          label: 'رفع إيصال',
          color: AppColors.accent,
          onTap: () => context.push(
            '/order/${order.id}/upload-receipt',
            extra: {'amount': order.remainingAmount},
          ),
        ),
      if (order.shippingLabelUrl != null)
        OrderQuickAction(
          icon: Iconsax.document,
          label: 'بوليصة الشحن',
          color: AppColors.primary,
          onTap: () => _openShippingLabel(order.shippingLabelUrl!),
        ),
      if (canReturn)
        OrderQuickAction(
          icon: Iconsax.rotate_left,
          label: 'طلب إرجاع',
          color: AppColors.warning,
          onTap: () => context.push('/returns/select-items'),
        ),
    ];
  }

  void _openShippingLabel(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildRateSection(BuildContext context, ThemeData theme, bool isDark) {
    return OrderRateSection(orderId: widget.orderId, onRated: _loadOrder);
  }

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
