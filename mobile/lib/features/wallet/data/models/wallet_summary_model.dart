library;

class WalletSummary {
  final double balance;
  final double creditLimit;
  final double creditUsed;
  final double availableCredit;

  const WalletSummary({
    required this.balance,
    required this.creditLimit,
    required this.creditUsed,
    required this.availableCredit,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      balance: (json['balance'] as num? ?? 0).toDouble(),
      creditLimit: (json['creditLimit'] as num? ?? 0).toDouble(),
      creditUsed: (json['creditUsed'] as num? ?? 0).toDouble(),
      availableCredit: (json['availableCredit'] as num? ?? 0).toDouble(),
    );
  }
}
