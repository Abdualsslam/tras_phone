import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/promotion_model.dart';
import '../cubit/promotions_cubit.dart';
import '../cubit/promotions_state.dart';

class PromotionsBanner extends StatefulWidget {
  const PromotionsBanner({super.key});

  @override
  State<PromotionsBanner> createState() => _PromotionsBannerState();
}

class _PromotionsBannerState extends State<PromotionsBanner> {
  @override
  void initState() {
    super.initState();
    context.read<PromotionsCubit>().loadActivePromotions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromotionsCubit, PromotionsState>(
      builder: (context, state) {
        if (state is PromotionsLoaded && state.promotions.isNotEmpty) {
          return SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: state.promotions.length,
              itemBuilder: (context, index) {
                return _buildPromotionCard(state.promotions[index]);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPromotionCard(Promotion promo) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: promo.image != null
            ? DecorationImage(
                image: NetworkImage(promo.image!),
                fit: BoxFit.cover,
              )
            : null,
        gradient: promo.image == null
            ? const LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              )
            : null,
      ),
      child: Stack(
        children: [
          // Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Badge
                if (promo.badgeText != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: promo.getBadgeColor() ?? Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      promo.badgeText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                Text(
                  promo.getName('ar'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  promo.discountText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (promo.daysRemaining <= 7)
                  Text(
                    'متبقي ${promo.daysRemaining} أيام',
                    style: TextStyle(
                      color: Colors.orange[300],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
