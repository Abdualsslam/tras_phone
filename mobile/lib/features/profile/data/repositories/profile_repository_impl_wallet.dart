part of 'profile_repository_impl.dart';

class _ProfileRepositoryWalletDelegate {
  final ProfileRemoteDataSource dataSource;

  const _ProfileRepositoryWalletDelegate({required this.dataSource});

  Future<WalletModel> getWallet() => dataSource.getWallet();

  Future<List<WalletTransactionModel>> getWalletTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) => dataSource.getWalletTransactions(page: page, limit: limit, type: type);

  Future<bool> requestWithdrawal(double amount, String bankDetails) =>
      dataSource.requestWithdrawal(amount, bankDetails);

  Future<LoyaltyModel> getLoyaltyPoints() => dataSource.getLoyaltyPoints();

  Future<bool> redeemPoints(int points) => dataSource.redeemPoints(points);

  Future<ReferralInfoModel> getReferralInfo() => dataSource.getReferralInfo();

  Future<bool> applyReferralCode(String code) =>
      dataSource.applyReferralCode(code);
}
