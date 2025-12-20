/// Cart Screen - Shopping cart with items, quantity controls, and checkout
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().loadCart();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Iconsax.trash),
                  onPressed: () => _showClearCartDialog(context),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.warning_2, size: 60.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text(state.message, style: theme.textTheme.bodyLarge),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<CartCubit>().loadCart(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          final cart = state is CartLoaded
              ? state.cart
              : state is CartUpdating
              ? state.cart
              : null;

          if (cart == null || cart.isEmpty) {
            return _buildEmptyCart(theme);
          }

          return _buildCartContent(
            context,
            theme,
            isDark,
            cart,
            state is CartUpdating,
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.shopping_cart,
            size: 100.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            'سلتك فارغة',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'استعرض المنتجات وأضفها إلى سلتك',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Iconsax.shop),
            label: const Text('تصفح المنتجات'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    CartEntity cart,
    bool isUpdating,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Cart Items
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = cart.items[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _CartItemCard(
                      item: item,
                      isDark: isDark,
                      onQuantityChanged: (quantity) {
                        context.read<CartCubit>().updateQuantity(
                          item.id,
                          quantity,
                        );
                      },
                      onRemove: () {
                        context.read<CartCubit>().removeFromCart(item.id);
                      },
                    ),
                  );
                }, childCount: cart.items.length),
              ),
            ),

            // Coupon Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildCouponSection(context, theme, isDark, cart),
              ),
            ),

            // Order Summary
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: _buildOrderSummary(theme, isDark, cart),
              ),
            ),

            // Spacer for bottom bar
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),

        // Loading overlay
        if (isUpdating)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),

        // Bottom Checkout Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildCheckoutBar(context, theme, isDark, cart),
        ),
      ],
    );
  }

  Widget _buildCouponSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    CartEntity cart,
  ) {
    if (cart.couponCode != null) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.ticket_discount,
              color: AppColors.success,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم تطبيق الكوبون',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    cart.couponCode!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.close_circle, color: AppColors.success),
              onPressed: () => context.read<CartCubit>().removeCoupon(),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              decoration: InputDecoration(
                hintText: 'أدخل رمز الخصم',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_couponController.text.isNotEmpty) {
                context.read<CartCubit>().applyCoupon(_couponController.text);
                _couponController.clear();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme, bool isDark, CartEntity cart) {
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
            'ملخص الطلب',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSummaryRow(
            theme,
            'المجموع الفرعي',
            '${cart.subtotal.toStringAsFixed(0)} ر.ي',
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            theme,
            'الشحن',
            cart.shippingCost > 0
                ? '${cart.shippingCost.toStringAsFixed(0)} ر.ي'
                : 'مجاني',
          ),
          if (cart.discount > 0) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              theme,
              'الخصم',
              '-${cart.discount.toStringAsFixed(0)} ر.ي',
              valueColor: AppColors.success,
            ),
          ],
          Divider(height: 24.h),
          _buildSummaryRow(
            theme,
            'الإجمالي',
            '${cart.total.toStringAsFixed(0)} ر.ي',
            isTotal: true,
          ),
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
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    CartEntity cart,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Navigate to checkout
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('جاري التوجه للدفع...'),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.card),
              SizedBox(width: 8.w),
              Text(
                'إتمام الشراء • ${cart.total.toStringAsFixed(0)} ر.ي',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تفريغ السلة'),
        content: const Text('هل أنت متأكد من تفريغ السلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CartCubit>().clearCart();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('تفريغ'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final bool isDark;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.isDark,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = item.product;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 80.w,
              height: 80.w,
              color: isDark ? AppColors.backgroundDark : Colors.grey[100],
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Iconsax.image,
                        size: 30.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                    )
                  : Icon(
                      Iconsax.image,
                      size: 30.sp,
                      color: AppColors.textTertiaryLight,
                    ),
            ),
          ),
          SizedBox(width: 12.w),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameAr ?? product.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${item.unitPrice.toStringAsFixed(0)} ر.ي',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8.h),

                // Quantity Controls
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: item.quantity > 1 ? Iconsax.minus : Iconsax.trash,
                      color: item.quantity > 1 ? null : AppColors.error,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        if (item.quantity > 1) {
                          onQuantityChanged(item.quantity - 1);
                        } else {
                          onRemove();
                        }
                      },
                    ),
                    SizedBox(
                      width: 40.w,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Iconsax.add,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onQuantityChanged(item.quantity + 1);
                      },
                    ),
                    const Spacer(),
                    Text(
                      '${item.totalPrice.toStringAsFixed(0)} ر.ي',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
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

  Widget _buildQuantityButton({
    required IconData icon,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: (color ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 16.sp, color: color ?? AppColors.primary),
      ),
    );
  }
}
