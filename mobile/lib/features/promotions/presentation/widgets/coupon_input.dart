import 'package:flutter/material.dart';

class CouponInput extends StatefulWidget {
  final String? appliedCode;
  final double appliedDiscount;
  final Future<String?> Function(String code) onApplyCoupon;
  final Future<void> Function() onRemoveCoupon;

  const CouponInput({
    super.key,
    this.appliedCode,
    required this.appliedDiscount,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
  });

  @override
  State<CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<CouponInput> {
  final controller = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> _applyCoupon() async {
    final code = controller.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final applyError = await widget.onApplyCoupon(code);
      if (!mounted) return;
      if (applyError != null && applyError.isNotEmpty) {
        setState(() => errorMessage = applyError);
      } else {
        controller.clear();
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _removeCoupon() async {
    setState(() {
      errorMessage = null;
      controller.clear();
    });
    await widget.onRemoveCoupon();
  }

  @override
  Widget build(BuildContext context) {
    final appliedCode = widget.appliedCode;

    // كوبون مطبق
    if (appliedCode != null && appliedCode.isNotEmpty) {
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
                    appliedCode,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'خصم: ${widget.appliedDiscount.toStringAsFixed(2)} ر.س',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: isLoading ? null : _removeCoupon,
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
              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 56)),
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
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
