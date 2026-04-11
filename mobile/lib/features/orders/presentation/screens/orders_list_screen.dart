/// Orders List Screen - Displays all user orders with filtering
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/orders_list/order_card.dart';
import '../widgets/orders_list/order_stats_card.dart';
import '../widgets/orders_list/order_tab.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = <OrderTab>[
    const OrderTab(label: 'الكل', status: null, isPendingPayment: false),
    const OrderTab(
      label: 'بانتظار الدفع',
      status: null,
      isPendingPayment: true,
    ),
    const OrderTab(
      label: 'جارية',
      status: OrderStatus.processing,
      isPendingPayment: false,
    ),
    const OrderTab(
      label: 'تم الشحن',
      status: OrderStatus.shipped,
      isPendingPayment: false,
    ),
    const OrderTab(
      label: 'مكتملة',
      status: OrderStatus.delivered,
      isPendingPayment: false,
    ),
    const OrderTab(
      label: 'ملغاة',
      status: OrderStatus.cancelled,
      isPendingPayment: false,
    ),
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
    if (_tabController.indexIsChanging) return;

    final tab = _tabs[_tabController.index];
    if (tab.isPendingPayment) {
      context.read<OrdersCubit>().loadPendingPaymentOrders();
      return;
    }

    context.read<OrdersCubit>().filterByStatus(tab.status);
  }

  Future<void> _refreshActiveTab(OrderTab tab) {
    if (tab.isPendingPayment) {
      return context.read<OrdersCubit>().loadPendingPaymentOrders();
    }

    return context.read<OrdersCubit>().loadOrders(status: tab.status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.orders),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.rotate_left),
            onPressed: () => context.push('/returns'),
            tooltip: AppLocalizations.of(context)!.returns,
          ),
        ],
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
      body: BlocConsumer<OrdersCubit, OrdersState>(
        listener: (context, state) {
          if (state is BankAccountsLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<OrdersCubit>().loadOrders();
            });
          }
        },
        buildWhen: (previous, current) => current is! BankAccountsLoaded,
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const OrdersListShimmer();
          }

          if (state is OrdersError) {
            return AppError(
              message: state.message,
              onRetry: () => context.read<OrdersCubit>().loadOrders(),
            );
          }

          final orders = state is OrdersLoaded
              ? state.orders
              : state is OrdersPendingPaymentLoaded
              ? state.orders
              : <OrderEntity>[];

          if (orders.isEmpty) {
            return _buildEmptyState(theme);
          }

          final activeTab = _tabs[_tabController.index];
          final stats = state is OrdersLoaded ? state.stats : null;
          final showStats =
              stats != null &&
              activeTab.status == null &&
              !activeTab.isPendingPayment;

          return RefreshIndicator(
            onRefresh: () => _refreshActiveTab(activeTab),
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100.h),
              children: [
                if (showStats) ...[
                  OrderStatsCard(stats: stats, isDark: isDark),
                  SizedBox(height: 16.h),
                ],
                ...orders.map(
                  (order) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: OrderCard(
                      order: order,
                      isDark: isDark,
                      onTap: () => context.push('/order-details/${order.id}'),
                    ),
                  ),
                ),
              ],
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
