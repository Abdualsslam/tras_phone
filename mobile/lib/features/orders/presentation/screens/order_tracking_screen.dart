/// Order Tracking Screen - Track shipment progress
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String orderNumber;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  Map<String, dynamic>? _trackData;
  OrderEntity? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  Future<void> _loadTracking() async {
    final cubit = context.read<OrdersCubit>();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final trackData = await cubit.trackOrder(widget.orderId);
      final order = await cubit.getOrderById(widget.orderId);
      if (mounted) {
        setState(() {
          _trackData = trackData;
          _order = order;
          _isLoading = false;
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

  List<_TrackingEvent> _buildTrackingEvents() {
    if (_trackData != null && _trackData!['events'] is List) {
      final events = _trackData!['events'] as List;
      return events.map((e) {
        final map = e as Map<String, dynamic>;
        return _TrackingEvent(
          status: map['status']?.toString() ?? map['title']?.toString() ?? '',
          description: map['description']?.toString() ?? '',
          location: map['location']?.toString() ?? '',
          timestamp: map['timestamp'] != null
              ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
              : DateTime.now(),
          isCompleted: map['isCompleted'] == true,
        );
      }).toList();
    }

    if (_order != null) {
      return _buildEventsFromOrder(_order!);
    }

    return _defaultTrackingEvents();
  }

  List<_TrackingEvent> _buildEventsFromOrder(OrderEntity order) {
    final events = <_TrackingEvent>[];
    final now = DateTime.now();

    events.add(_TrackingEvent(
      status: 'تم الطلب',
      description: 'تم إنشاء الطلب بنجاح',
      location: '',
      timestamp: order.createdAt,
      isCompleted: true,
    ));

    if (order.confirmedAt != null) {
      events.add(_TrackingEvent(
        status: 'تم التأكيد',
        description: 'تم تأكيد الطلب',
        location: '',
        timestamp: order.confirmedAt!,
        isCompleted: true,
      ));
    }

    if (order.shippedAt != null) {
      events.add(_TrackingEvent(
        status: 'تم الشحن',
        description: 'الطلب في الطريق',
        location: '',
        timestamp: order.shippedAt!,
        isCompleted: true,
      ));
    }

    if (order.deliveredAt != null) {
      events.add(_TrackingEvent(
        status: 'تم التوصيل',
        description: 'تم تسليم الطلب',
        location: '',
        timestamp: order.deliveredAt!,
        isCompleted: true,
      ));
    } else if (order.status == OrderStatus.outForDelivery ||
        order.status == OrderStatus.shipped) {
      events.add(_TrackingEvent(
        status: 'في الطريق للتوصيل',
        description: 'الطلب مع مندوب التوصيل',
        location: '',
        timestamp: order.shippedAt ?? now,
        isCompleted: false,
      ));
    }

    if (events.isEmpty) {
      return _defaultTrackingEvents();
    }
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }

  List<_TrackingEvent> _defaultTrackingEvents() {
    return [
      _TrackingEvent(
        status: 'تم الطلب',
        description: 'جاري تجهيز طلبك',
        location: '',
        timestamp: DateTime.now(),
        isCompleted: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تتبع الشحنة')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تتبع الشحنة')),
        body: AppError(
          message: _error!,
        ),
      );
    }

    final trackingEvents = _buildTrackingEvents();
    String estimatedDelivery = 'قريباً';
    if (_trackData?['estimatedDelivery'] != null) {
      estimatedDelivery = _trackData!['estimatedDelivery'].toString();
    } else if (_order?.estimatedDeliveryDate != null) {
      final d = _order!.estimatedDeliveryDate!;
      estimatedDelivery = '${d.day}/${d.month}/${d.year}';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('تتبع الشحنة'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Order Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Column(
                children: [
                  Icon(Iconsax.truck_fast, size: 48.sp, color: Colors.white),
                  SizedBox(height: 12.h),
                  Text(
                    'في الطريق إليك',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    widget.orderNumber,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'التوصيل المتوقع: $estimatedDelivery',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Tracking Timeline
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل الشحنة',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ...trackingEvents.asMap().entries.map((entry) {
                    final isLast = entry.key == trackingEvents.length - 1;
                    return _buildTrackingItem(theme, entry.value, isLast);
                  }),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Contact Delivery
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.call),
                label: const Text('اتصل بمندوب التوصيل'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingItem(
    ThemeData theme,
    _TrackingEvent event,
    bool isLast,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: event.isCompleted
                    ? AppColors.success
                    : AppColors.dividerLight,
                shape: BoxShape.circle,
              ),
              child: event.isCompleted
                  ? Icon(Iconsax.tick_circle5, size: 16.sp, color: Colors.white)
                  : Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60.h,
                margin: EdgeInsets.symmetric(vertical: 4.h),
                color: event.isCompleted
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
                  event.status,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  event.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Iconsax.location,
                      size: 12.sp,
                      color: AppColors.textTertiaryLight,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      event.location,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Icon(
                      Iconsax.clock,
                      size: 12.sp,
                      color: AppColors.textTertiaryLight,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      _formatTime(event.timestamp),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}

class _TrackingEvent {
  final String status;
  final String description;
  final String location;
  final DateTime timestamp;
  final bool isCompleted;

  _TrackingEvent({
    required this.status,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.isCompleted,
  });
}
