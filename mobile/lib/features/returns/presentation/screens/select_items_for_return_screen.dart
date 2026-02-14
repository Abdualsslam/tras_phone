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
      bottomNavigationBar:
          _selectedItems.values.any((q) => q > 0)
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

/// بطاقة الطلب مع المنتجات
class _OrderCard extends StatelessWidget {
  final OrderEntity order;
  final Map<String, int> selectedItems;
  final Function(String, int) onItemQuantityChanged;

  const _OrderCard({
    required this.order,
    required this.selectedItems,
    required this.onItemQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final returnableItems =
        order.items.where((i) => i.returnableQuantity > 0).toList();

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
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text('${returnableItems.length} منتج قابل للإرجاع'),
        children: returnableItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final orderItemId = (item.id != null && item.id!.isNotEmpty)
              ? item.id!
              : '${order.id}_${item.productId}_${item.variantId ?? ''}_$index';
          final returnableQty = item.returnableQuantity;
          final selectedQty = selectedItems[orderItemId] ?? 0;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                if (item.image != null)
                  ClipRRect(
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
                else
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.image, color: Colors.grey[600]),
                  ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.getName('ar'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'السعر: ${item.unitPrice.toStringAsFixed(2)} ر.س',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        'القابلة للإرجاع: $returnableQty من ${item.quantity}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          IconButton.filled(
                            onPressed: selectedQty <= 0
                                ? null
                                : () => onItemQuantityChanged(
                                      orderItemId,
                                      selectedQty <= 0 ? 0 : selectedQty - 1,
                                    ),
                            icon: Icon(Icons.remove, size: 18.sp),
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.all(8.w),
                              minimumSize: Size(36.w, 36.h),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              selectedQty > 0 ? '$selectedQty' : '0',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton.filled(
                            onPressed: selectedQty >= returnableQty
                                ? null
                                : () => onItemQuantityChanged(
                                      orderItemId,
                                      selectedQty + 1,
                                    ),
                            icon: Icon(Icons.add, size: 18.sp),
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.all(8.w),
                              minimumSize: Size(36.w, 36.h),
                            ),
                          ),
                          if (selectedQty <= 0) ...[
                            SizedBox(width: 8.w),
                            TextButton(
                              onPressed: () =>
                                  onItemQuantityChanged(orderItemId, 1),
                              child: const Text('إرجاع'),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
