/// Screen to select items from all eligible orders for return
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../data/models/return_model.dart';
import '../widgets/returns_order_card.dart';

/// شاشة اختيار المنتجات من جميع الطلبات للإرجاع
class SelectItemsForReturnScreen extends StatelessWidget {
  const SelectItemsForReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<OrdersCubit>()..loadOrders(status: OrderStatus.delivered),
      child: const _SelectItemsForReturnView(),
    );
  }
}

class _SelectItemsForReturnView extends StatefulWidget {
  const _SelectItemsForReturnView();

  @override
  State<_SelectItemsForReturnView> createState() =>
      _SelectItemsForReturnViewState();
}

class _SelectItemsForReturnViewState extends State<_SelectItemsForReturnView> {
  /// Map of orderItemId -> quantity
  final Map<String, int> _selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر المنتجات للإرجاع'),
        centerTitle: true,
      ),
      body: BlocBuilder<OrdersCubit, OrdersState>(
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.warning_2, size: 64.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<OrdersCubit>().loadOrders(
                      status: OrderStatus.delivered,
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is OrdersLoaded) {
            final eligibleOrders = state.orders
                .where(
                  (order) => order.items.any((i) => i.returnableQuantity > 0),
                )
                .toList();

            if (eligibleOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.shopping_bag,
                      size: 80.sp,
                      color: AppColors.textTertiaryLight,
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'لا توجد طلبات مؤهلة للإرجاع',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'يجب أن تكون الطلبات في حالة "تم التسليم"',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: eligibleOrders.length,
              itemBuilder: (context, index) {
                final order = eligibleOrders[index];
                return ReturnsOrderCard(
                  order: order,
                  selectedItems: _selectedItems,
                  onItemQuantityChanged: (orderItemId, quantity) {
                    setState(() {
                      if (quantity <= 0) {
                        _selectedItems.remove(orderItemId);
                      } else {
                        _selectedItems[orderItemId] = quantity;
                      }
                    });
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: _selectedItems.values.any((q) => q > 0)
          ? SafeArea(
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => _proceed(context),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  child: Text(
                    'متابعة (${_selectedItems.values.where((q) => q > 0).length} منتج)',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _proceed(BuildContext context) {
    final selected = _selectedItems.entries.where((e) => e.value > 0);
    if (selected.isEmpty) return;

    // Convert selectedItems to List<CreateReturnItemRequest>
    final items = selected
        .map(
          (e) => CreateReturnItemRequest(orderItemId: e.key, quantity: e.value),
        )
        .toList();

    context.push('/returns/create', extra: items);
  }
}
