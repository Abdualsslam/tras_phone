/// Checkout Cart Items Widget - Display cart items in checkout screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/checkout_session_entity.dart';
import 'checkout_cart_item_row.dart';

class CheckoutCartItems extends StatefulWidget {
  final List<CheckoutCartItemEntity> items;
  final bool initiallyExpanded;
  final String locale;

  const CheckoutCartItems({
    super.key,
    required this.items,
    this.initiallyExpanded = false,
    this.locale = 'ar',
  });

  @override
  State<CheckoutCartItems> createState() => _CheckoutCartItemsState();
}

class _CheckoutCartItemsState extends State<CheckoutCartItems> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          // Header with expand/collapse toggle
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.r),
              bottom: _isExpanded ? Radius.zero : Radius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(
                    Iconsax.shopping_bag,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      '${AppLocalizations.of(context)!.products} (${widget.items.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                    size: 20.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),
          ),

          // Expandable items list
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(
                  height: 1,
                  color: AppColors.dividerLight.withValues(alpha: 0.5),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: widget.items.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 16.h,
                    color: AppColors.dividerLight.withValues(alpha: 0.3),
                  ),
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    return CheckoutCartItemRow(
                      item: item,
                      locale: widget.locale,
                    );
                  },
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
