/// Cart Screen - Shopping cart with items, quantity controls, and checkout
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_sync_result_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_sections.dart';

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
                    cart: state.currentCart!,
                    isDark: isDark,
                    isUpdating: true,
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
            return _buildCartContent(
              cart: state.syncResult.syncedCart,
              isDark: isDark,
              isUpdating: false,
            );
          }

          final cart = state is CartLoaded
              ? state.cart
              : state is CartUpdating
              ? state.cart
              : null;

          if (cart == null || cart.isEmpty) {
            return const CartEmptyState();
          }

          return _buildCartContent(
            cart: cart,
            isDark: isDark,
            isUpdating: state is CartUpdating,
          );
        },
      ),
    );
  }

  Widget _buildCartContent({
    required CartEntity cart,
    required bool isDark,
    required bool isUpdating,
  }) {
    return CartContentView(
      cart: cart,
      isDark: isDark,
      isUpdating: isUpdating,
      onQuantityChanged: (item, quantity) {
        HapticFeedback.selectionClick();
        context.read<CartCubit>().updateQuantityLocal(item.productId, quantity);
      },
      onRemove: (item) {
        HapticFeedback.selectionClick();
        context.read<CartCubit>().removeFromCartLocal(item.productId);
      },
      onCheckout: () => _handleCheckout(context),
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
    await showDialog(
      context: context,
      builder: (dialogContext) => CartSyncIssuesDialog(
        result: result,
        getRemovalReason: _getRemovalReason,
        onCancel: () => Navigator.pop(dialogContext),
        onContinue: () {
          Navigator.pop(dialogContext);
          context.push('/checkout');
        },
      ),
    );
  }
}
