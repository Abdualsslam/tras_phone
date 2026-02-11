/// Screen to select items from all eligible orders for return
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../data/models/return_model.dart';

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
            final eligibleOrders = state.orders;

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
                return _OrderCard(
                  order: order,
                  selectedItems: _selectedItems,
                  onItemToggle: (orderItemId, quantity) {
                    setState(() {
                      if (_selectedItems.containsKey(orderItemId)) {
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
      bottomNavigationBar: _selectedItems.isNotEmpty
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
                    'متابعة (${_selectedItems.length} منتج)',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  void _proceed(BuildContext context) {
    if (_selectedItems.isEmpty) return;

    // Convert selectedItems to List<CreateReturnItemRequest>
    final items = _selectedItems.entries
        .map(
          (e) => CreateReturnItemRequest(orderItemId: e.key, quantity: e.value),
        )
        .toList();

    context.push('/returns/create', extra: items);
  }
}

/// بطاقة الطلب مع المنتجات
class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final Map<String, int> selectedItems;
  final Function(String, int) onItemToggle;

  const _OrderCard({
    required this.order,
    required this.selectedItems,
    required this.onItemToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        title: Text(
          'طلب ${order.orderNumber}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('${order.items.length} منتج'),
        children: order.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          // Note: In production, order items should have unique IDs from the API
          // For now, we use a combination that should be unique
          // The backend will need to provide orderItemId in the API response
          final orderItemId =
              '${order.id}_${item.productId}_${item.variantId ?? ''}_$index';
          final isSelected = selectedItems.containsKey(orderItemId);

          return CheckboxListTile(
            value: isSelected,
            onChanged: (checked) {
              onItemToggle(orderItemId, item.quantity);
            },
            title: Text(item.getName('ar')),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text(
                  'السعر: ${item.unitPrice.toStringAsFixed(2)} ر.س',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'الكمية: ${item.quantity}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            secondary: item.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: item.image!,
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 50.w,
                        height: 50.w,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 50.w,
                        height: 50.w,
                        color: Colors.grey[300],
                        child: Icon(Icons.image, color: Colors.grey[600]),
                      ),
                    ),
                  )
                : Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.image, color: Colors.grey[600]),
                  ),
          );
        }).toList(),
      ),
    );
  }
}
