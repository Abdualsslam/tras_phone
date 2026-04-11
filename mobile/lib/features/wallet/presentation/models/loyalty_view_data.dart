import '../../data/models/loyalty_points_model.dart';
import '../../data/models/loyalty_tier_model.dart';

class LoyaltyRewardItem {
  final String title;
  final int points;
  final bool available;
  final LoyaltyRewardType type;

  const LoyaltyRewardItem({
    required this.title,
    required this.points,
    required this.available,
    required this.type,
  });
}

enum LoyaltyRewardType { discount, shipping, gift, support, access }

class LoyaltyViewData {
  final LoyaltyPoints loyaltyPoints;
  final List<LoyaltyTier> sortedTiers;
  final LoyaltyTier? nextTier;
  final int currentTierIndex;
  final double progress;
  final String progressText;
  final List<LoyaltyRewardItem> rewards;

  const LoyaltyViewData({
    required this.loyaltyPoints,
    required this.sortedTiers,
    required this.nextTier,
    required this.currentTierIndex,
    required this.progress,
    required this.progressText,
    required this.rewards,
  });

  factory LoyaltyViewData.fromData(
    LoyaltyPoints loyaltyPoints,
    List<LoyaltyTier> tiers,
    String locale,
  ) {
    final sortedTiers = List<LoyaltyTier>.from(tiers)
      ..sort((a, b) => a.minPoints.compareTo(b.minPoints));

    final currentTierIndex = sortedTiers.indexWhere(
      (tier) => tier.id == loyaltyPoints.tier.id,
    );

    final safeCurrentTierIndex = currentTierIndex < 0 ? 0 : currentTierIndex;
    final nextTier = safeCurrentTierIndex < sortedTiers.length - 1
        ? sortedTiers[safeCurrentTierIndex + 1]
        : null;

    final progress = _calculateProgress(loyaltyPoints, nextTier);
    final progressText = _buildProgressText(loyaltyPoints, nextTier, locale);

    return LoyaltyViewData(
      loyaltyPoints: loyaltyPoints,
      sortedTiers: sortedTiers,
      nextTier: nextTier,
      currentTierIndex: safeCurrentTierIndex,
      progress: progress,
      progressText: progressText,
      rewards: _buildRewards(loyaltyPoints),
    );
  }

  static double _calculateProgress(
    LoyaltyPoints loyaltyPoints,
    LoyaltyTier? nextTier,
  ) {
    if (nextTier == null) {
      return 1;
    }

    final currentTierMinPoints = loyaltyPoints.tier.minPoints;
    final totalNeeded = nextTier.minPoints - currentTierMinPoints;
    if (totalNeeded <= 0) {
      return 1;
    }

    final earnedInCurrentTier = loyaltyPoints.points - currentTierMinPoints;
    return (earnedInCurrentTier / totalNeeded).clamp(0, 1).toDouble();
  }

  static String _buildProgressText(
    LoyaltyPoints loyaltyPoints,
    LoyaltyTier? nextTier,
    String locale,
  ) {
    if (nextTier == null) {
      return 'أنت في أعلى مستوى حالياً';
    }

    final pointsNeeded = nextTier.minPoints - loyaltyPoints.points;
    if (pointsNeeded <= 0) {
      return 'أنت جاهز للانتقال إلى ${nextTier.getName(locale)}';
    }

    return 'تحتاج إلى $pointsNeeded نقطة للوصول إلى ${nextTier.getName(locale)}';
  }

  static List<LoyaltyRewardItem> _buildRewards(LoyaltyPoints loyaltyPoints) {
    final currentTier = loyaltyPoints.tier;
    final currentPoints = loyaltyPoints.points;

    final items = <LoyaltyRewardItem>[
      if (currentTier.discountPercentage > 0)
        LoyaltyRewardItem(
          title: 'خصم ${currentTier.discountPercentage.toStringAsFixed(0)}%',
          points: 0,
          available: true,
          type: LoyaltyRewardType.discount,
        ),
      if (currentTier.freeShipping)
        const LoyaltyRewardItem(
          title: 'شحن مجاني',
          points: 0,
          available: true,
          type: LoyaltyRewardType.shipping,
        ),
      if (currentTier.prioritySupport)
        const LoyaltyRewardItem(
          title: 'أولوية في الدعم',
          points: 0,
          available: true,
          type: LoyaltyRewardType.support,
        ),
      if (currentTier.earlyAccess)
        const LoyaltyRewardItem(
          title: 'وصول مبكر للعروض',
          points: 0,
          available: true,
          type: LoyaltyRewardType.access,
        ),
      LoyaltyRewardItem(
        title: 'خصم 5%',
        points: 100,
        available: currentPoints >= 100,
        type: LoyaltyRewardType.discount,
      ),
      LoyaltyRewardItem(
        title: 'شحن مجاني',
        points: 200,
        available: currentPoints >= 200,
        type: LoyaltyRewardType.shipping,
      ),
      LoyaltyRewardItem(
        title: 'خصم 10%',
        points: 300,
        available: currentPoints >= 300,
        type: LoyaltyRewardType.discount,
      ),
      LoyaltyRewardItem(
        title: 'هدية مجانية',
        points: 500,
        available: currentPoints >= 500,
        type: LoyaltyRewardType.gift,
      ),
    ];

    return items;
  }
}
