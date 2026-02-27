/// Cart Screen - Shopping cart with items, quantity controls, and checkout
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/shimmer/index.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_sync_result_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../../../../l10n/app_localizations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().loadLocalCart();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.cart)),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const CartShimmer();
          }

          if (state is CartError) {
            return AppError(
              message: state.message,
              onRetry: () => context.read<CartCubit>().loadLocalCart(),
            );
          }

          if (state is CartSyncing) {
            return Stack(
              children: [
                if (state.currentCart != null)
                  _buildCartContent(
                    context,
                    theme,
                    isDark,
                    state.currentCart!,
                    true,
                  )
                else
                  const Center(child: CircularProgressIndicator()),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
            );
          }

          if (state is CartSyncCompleted) {
            // After sync, reload the cart to show updated state
            final cart = state.syncResult.syncedCart;
            return _buildCartContent(context, theme, isDark, cart, false);
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
            AppLocalizations.of(context)!.emptyCart,
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
                        context.read<CartCubit>().updateQuantityLocal(
                          item.productId,
                          quantity,
                        );
                      },
                      onRemove: () {
                        context.read<CartCubit>().removeFromCartLocal(
                          item.productId,
                        );
                      },
                    ),
                  );
                }, childCount: cart.items.length),
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
            AppLocalizations.of(context)!.subtotal,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSummaryRow(
            theme,
            AppLocalizations.of(context)!.subtotal,
            '${cart.subtotal.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            theme,
            AppLocalizations.of(context)!.shipping,
            cart.shippingCost > 0
                ? '${cart.shippingCost.toStringAsFixed(0)} ر.س'
                : 'مجاني',
          ),
          if (cart.discount > 0) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              theme,
              AppLocalizations.of(context)!.discount,
              '-${cart.discount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
              valueColor: AppColors.success,
            ),
          ],
          Divider(height: 24.h),
          _buildSummaryRow(
            theme,
            AppLocalizations.of(context)!.total,
            '${cart.total.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
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
          onPressed: () => _handleCheckout(context),
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
                '${AppLocalizations.of(context)!.checkout} • ${cart.total.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    HapticFeedback.mediumImpact();

    final cartCubit = context.read<CartCubit>();
    final currentState = cartCubit.state;
    final cart = currentState is CartLoaded
        ? currentState.cart
        : (currentState is CartUpdating ? currentState.cart : null);

    if (cart == null || cart.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.emptyCart)),
        );
      }
      return;
    }

    // مزامنة السلة المحلية مع السيرفر قبل فتح الدفع
    // حتى يرجع GET /checkout/session عناصر السلة والعناوين وطرق الدفع
    final syncResult = await cartCubit.syncCart();
    if (!context.mounted) return;
    if (syncResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.tryAgain),
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            onPressed: () => _handleCheckout(context),
          ),
        ),
      );
      return;
    }

    if (syncResult.hasIssues) {
      await _showSyncIssuesDialog(context, syncResult);
    } else {
      context.push('/checkout');
    }
  }

  String _getRemovalReason(String reason) {
    switch (reason) {
      case 'out_of_stock':
        return 'نفذ المخزون';
      case 'deleted':
        return 'تم حذف المنتج';
      case 'inactive':
        return 'المنتج غير متاح';
      default:
        return 'غير متاح';
    }
  }

  Future<void> _showSyncIssuesDialog(
    BuildContext context,
    CartSyncResultEntity result,
  ) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تحديثات السلة'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result.removedItems.isNotEmpty) ...[
                Text(
                  'تم حذف المنتجات التالية:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                ...result.removedItems.map(
                  (item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.productNameAr ?? item.productId,
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      _getRemovalReason(item.reason),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              if (result.priceChangedItems.isNotEmpty) ...[
                Text(
                  'تغيرت أسعار المنتجات التالية:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                ...result.priceChangedItems.map(
                  (item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.productNameAr ?? item.productId,
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      '${item.oldPrice.toStringAsFixed(0)} → ${item.newPrice.toStringAsFixed(0)} ر.س',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              if (result.quantityAdjustedItems.isNotEmpty) ...[
                Text(
                  'تم تعديل كميات المنتجات التالية:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                ...result.quantityAdjustedItems.map(
                  (item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.productNameAr ?? item.productId,
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(
                      'الكمية المطلوبة: ${item.requestedQuantity}\n'
                      'الكمية المتاحة: ${item.availableQuantity}\n'
                      'الكمية النهائية: ${item.finalQuantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/checkout');
            },
            child: Text('موافق والمتابعة'),
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
              child: item.productImage != null
                  ? Image.network(
                      item.productImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
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
                  item.getName('ar'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${item.unitPrice.toStringAsFixed(0)} ر.س',
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
                      '${item.totalPrice.toStringAsFixed(0)} ر.س',
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
