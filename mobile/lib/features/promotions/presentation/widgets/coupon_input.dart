import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/coupon_model.dart';
import '../../data/models/coupon_validation_model.dart';
import '../cubit/promotions_cubit.dart';
import '../cubit/promotions_state.dart';

class CouponInput extends StatefulWidget {
  final double orderTotal;
  final Function(CouponValidation) onCouponApplied;
  final VoidCallback onCouponRemoved;

  const CouponInput({
    super.key,
    required this.orderTotal,
    required this.onCouponApplied,
    required this.onCouponRemoved,
  });

  @override
  State<CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<CouponInput> {
  final controller = TextEditingController();
  bool isLoading = false;
  CouponValidation? appliedCoupon;
  String? errorMessage;

  Future<void> _applyCoupon() async {
    if (controller.text.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await context.read<PromotionsCubit>().validateCoupon(
            code: controller.text.toUpperCase(),
            orderTotal: widget.orderTotal,
          );

      if (result != null && result.isValid) {
        setState(() => appliedCoupon = result);
        widget.onCouponApplied(result);
      } else if (result != null) {
        setState(() => errorMessage = result.getMessage('ar'));
      }
    } catch (e) {
      setState(() => errorMessage = 'حدث خطأ، حاول مرة أخرى');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _removeCoupon() {
    setState(() {
      appliedCoupon = null;
      controller.clear();
    });
    widget.onCouponRemoved();
  }

  @override
  Widget build(BuildContext context) {
    // كوبون مطبق
    if (appliedCoupon != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appliedCoupon!.coupon!.code,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'خصم: ${appliedCoupon!.discountAmount?.toStringAsFixed(2)} ر.س',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _removeCoupon,
            ),
          ],
        ),
      );
    }

    // حقل الإدخال
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'أدخل كود الكوبون',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.local_offer),
                  errorText: errorMessage,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isLoading ? null : _applyCoupon,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 56),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('تطبيق'),
            ),
          ],
        ),

        // الكوبونات المتاحة
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _showAvailableCoupons(context),
          child: const Text('عرض الكوبونات المتاحة'),
        ),
      ],
    );
  }

  void _showAvailableCoupons(BuildContext context) {
    context.read<PromotionsCubit>().loadPublicCoupons();

    showModalBottomSheet(
      context: context,
      builder: (_) => BlocBuilder<PromotionsCubit, PromotionsState>(
        bloc: context.read<PromotionsCubit>(),
        builder: (context, state) {
          if (state is PromotionsLoaded && state.coupons.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.coupons.length,
              itemBuilder: (context, index) {
                final coupon = state.coupons[index];
                return _buildCouponTile(coupon);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildCouponTile(Coupon coupon) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(coupon.discountText, style: const TextStyle(fontSize: 10)),
        ),
        title: Text(coupon.code),
        subtitle: Text(coupon.getName('ar')),
        trailing: TextButton(
          onPressed: () {
            controller.text = coupon.code;
            Navigator.pop(context);
            _applyCoupon();
          },
          child: const Text('استخدام'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
