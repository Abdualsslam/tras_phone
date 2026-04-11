import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'cart_sections_item.dart';

class CartEmptyState extends StatelessWidget {
  const CartEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}

class CartContentView extends StatelessWidget {
  final CartEntity cart;
  final bool isDark;
  final bool isUpdating;
  final void Function(CartItemEntity item, int quantity) onQuantityChanged;
  final ValueChanged<CartItemEntity> onRemove;
  final VoidCallback onCheckout;

  const CartContentView({
    super.key,
    required this.cart,
    required this.isDark,
    required this.isUpdating,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = cart.items[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: CartItemCard(
                      item: item,
                      isDark: isDark,
                      onQuantityChanged: (quantity) =>
                          onQuantityChanged(item, quantity),
                      onRemove: () => onRemove(item),
                    ),
                  );
                }, childCount: cart.items.length),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: CartOrderSummaryCard(cart: cart, isDark: isDark),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 100.h)),
          ],
        ),
        if (isUpdating)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CartCheckoutBar(
            isDark: isDark,
            total: cart.total,
            onCheckout: onCheckout,
          ),
        ),
      ],
    );
  }
}

class CartOrderSummaryCard extends StatelessWidget {
  final CartEntity cart;
  final bool isDark;

  const CartOrderSummaryCard({
    super.key,
    required this.cart,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          _CartSummaryRow(
            label: AppLocalizations.of(context)!.subtotal,
            value:
                '${cart.subtotal.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
          ),
          SizedBox(height: 8.h),
          _CartSummaryRow(
            label: AppLocalizations.of(context)!.shipping,
            value: cart.shippingCost > 0
                ? '${cart.shippingCost.toStringAsFixed(0)} ر.س'
                : 'مجاني',
          ),
          if (cart.discount > 0) ...[
            SizedBox(height: 8.h),
            _CartSummaryRow(
              label: AppLocalizations.of(context)!.discount,
              value:
                  '-${cart.discount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
              valueColor: AppColors.success,
            ),
          ],
          Divider(height: 24.h),
          _CartSummaryRow(
            label: AppLocalizations.of(context)!.total,
            value:
                '${cart.total.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class CartCheckoutBar extends StatelessWidget {
  final bool isDark;
  final double total;
  final VoidCallback onCheckout;

  const CartCheckoutBar({
    super.key,
    required this.isDark,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
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
          onPressed: onCheckout,
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
                '${AppLocalizations.of(context)!.checkout} • ${total.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _CartSummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}
