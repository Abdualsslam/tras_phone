import 'package:flutter/material.dart';
import '../../data/models/promotion_model.dart';
import '../../domain/enums/promotion_enums.dart';

class BuyXGetYCard extends StatelessWidget {
  final Promotion promotion;

  const BuyXGetYCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    if (promotion.discountType != DiscountType.buyXGetY) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.card_giftcard, color: Colors.white, size: 32),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.getName('ar'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87),
                      children: [
                        const TextSpan(text: 'اشتر '),
                        TextSpan(
                          text: '${promotion.buyQuantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        const TextSpan(text: ' واحصل على '),
                        TextSpan(
                          text: '${promotion.getQuantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        if (promotion.getDiscountPercentage == 100)
                          const TextSpan(
                            text: ' مجاناً!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          )
                        else
                          TextSpan(
                            text:
                                ' بخصم ${promotion.getDiscountPercentage?.toInt()}%',
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
