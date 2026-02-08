/// Orders List Screen - Displays all user orders with filtering
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../../../../l10n/app_localizations.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = <_OrderTab>[
    const _OrderTab(label: 'الكل', status: null),
    const _OrderTab(label: 'جارية', status: OrderStatus.processing),
    const _OrderTab(label: 'تم الشحن', status: OrderStatus.shipped),
    const _OrderTab(label: 'مكتملة', status: OrderStatus.delivered),
    const _OrderTab(label: 'ملغاة', status: OrderStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<OrdersCubit>().loadOrders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      context.read<OrdersCubit>().filterByStatus(
        _tabs[_tabController.index].status,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.orders),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryLight,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            tabs: _tabs.map((tab) => Tab(text: tab.label)).toList(),
          ),
        ),
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const OrdersListShimmer();
          }

          if (state is OrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.warning_2, size: 60.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text(state.message, style: theme.textTheme.bodyLarge),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<OrdersCubit>().loadOrders(),
                    child: Text(AppLocalizations.of(context)!.tryAgain),
                  ),
                ],
              ),
            );
          }

          final orders = state is OrdersLoaded ? state.orders : <OrderEntity>[];

          if (orders.isEmpty) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: () => context.read<OrdersCubit>().loadOrders(
              status: _tabs[_tabController.index].status,
            ),
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100.h),
              itemCount: orders.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(
                  order: order,
                  isDark: isDark,
                  onTap: () {
                    context.push('/order-details/${order.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.box, size: 80.sp, color: AppColors.textTertiaryLight),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context)!.noResults,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم تقم بأي طلبات بعد',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTab {
  final String label;
  final OrderStatus? status;

  const _OrderTab({required this.label, this.status});
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final bool isDark;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status bar + Order number
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor.withValues(alpha: 0.15),
                      statusColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Row(
                  children: [
                    _buildStatusBadge(order.status),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _formatDate(order.createdAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiaryLight,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.arrow_left_2,
                        size: 18.sp,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product thumbnails + items summary
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (order.items.isNotEmpty) ...[
                          SizedBox(
                            height: 56.h,
                            width: (56.w * 3) + (8.w * 2),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.items.length > 3 ? 3 : order.items.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8.w),
                              itemBuilder: (context, index) {
                                final item = order.items[index];
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10.r),
                                  child: Container(
                                    width: 56.w,
                                    height: 56.h,
                                    color: isDark
                                        ? AppColors.surfaceDark
                                        : AppColors.backgroundLight,
                                    child: item.image != null
                                        ? Image.network(
                                            item.image!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Icon(
                                                  Iconsax.box,
                                                  color: AppColors.textTertiaryLight,
                                                  size: 24.sp,
                                                ),
                                          )
                                        : Icon(
                                            Iconsax.box,
                                            color: AppColors.textTertiaryLight,
                                            size: 24.sp,
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order.itemsCount} منتج',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              if (order.items.isNotEmpty)
                                Text(
                                  order.items.first.nameAr ?? order.items.first.name,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (order.items.length > 1)
                                Text(
                                  '+${order.items.length - 1} منتج آخر',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiaryLight,
                                    fontSize: 11.sp,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Total row
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.total,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${order.total.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.teal;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.refunded:
        return Colors.grey;
      case OrderStatus.readyForPickup:
        return Colors.indigo;
      case OrderStatus.outForDelivery:
        return Colors.cyan;
      case OrderStatus.completed:
        return Colors.green.shade700;
    }
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        icon = Iconsax.clock;
        break;
      case OrderStatus.confirmed:
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        icon = Iconsax.tick_circle;
        break;
      case OrderStatus.processing:
        bgColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        icon = Iconsax.box;
        break;
      case OrderStatus.shipped:
        bgColor = Colors.teal.withValues(alpha: 0.1);
        textColor = Colors.teal;
        icon = Iconsax.truck;
        break;
      case OrderStatus.delivered:
        bgColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
        icon = Iconsax.tick_circle;
        break;
      case OrderStatus.cancelled:
        bgColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.error;
        icon = Iconsax.close_circle;
        break;
      case OrderStatus.refunded:
        bgColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        icon = Iconsax.rotate_left;
        break;
      case OrderStatus.readyForPickup:
        bgColor = Colors.indigo.withValues(alpha: 0.1);
        textColor = Colors.indigo;
        icon = Iconsax.box_tick;
        break;
      case OrderStatus.outForDelivery:
        bgColor = Colors.cyan.withValues(alpha: 0.1);
        textColor = Colors.cyan;
        icon = Iconsax.truck_fast;
        break;
      case OrderStatus.completed:
        bgColor = Colors.green.shade700.withValues(alpha: 0.1);
        textColor = Colors.green.shade700;
        icon = Iconsax.verify;
        break;
    }

    final order = this.order;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            order.statusText,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
