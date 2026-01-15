/// Shipping Cost Widget - عرض تكلفة الشحن
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/locations_cubit.dart';
import '../cubit/locations_state.dart';

class ShippingCostWidget extends StatelessWidget {
  final String cityId;
  final double orderTotal;
  final String locale;

  const ShippingCostWidget({
    super.key,
    required this.cityId,
    required this.orderTotal,
    this.locale = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationsCubit, LocationsState>(
      builder: (context, state) {
        final shipping = state.shippingCalculation;

        if (shipping == null) {
          return const SizedBox.shrink();
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale == 'ar'
                          ? 'الشحن إلى ${shipping.getZoneName(locale)}'
                          : 'Shipping to ${shipping.getZoneName(locale)}',
                    ),
                    if (shipping.isFreeShipping)
                      Chip(
                        label: Text(
                          locale == 'ar' ? 'شحن مجاني' : 'Free Shipping',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.green[100],
                      )
                    else
                      Text(
                        '${shipping.totalCost.toStringAsFixed(2)} ${locale == 'ar' ? 'ر.س' : 'SAR'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                if (shipping.estimatedDeliveryDays != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        locale == 'ar'
                            ? 'التوصيل خلال ${shipping.estimatedDeliveryDays} أيام'
                            : 'Delivery in ${shipping.estimatedDeliveryDays} days',
                      ),
                    ],
                  ),
                ],
                // رسالة الشحن المجاني
                if (!shipping.isFreeShipping &&
                    shipping.freeShippingThreshold != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      locale == 'ar'
                          ? 'أضف ${(shipping.freeShippingThreshold! - orderTotal).toStringAsFixed(2)} ر.س للحصول على شحن مجاني'
                          : 'Add ${(shipping.freeShippingThreshold! - orderTotal).toStringAsFixed(2)} SAR for free shipping',
                      style: TextStyle(color: Colors.blue[800], fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
