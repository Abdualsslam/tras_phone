part of 'profile_remote_datasource.dart';

class _ProfileWalletDelegate {
  final _ProfileRemoteSupport _support;

  const _ProfileWalletDelegate({required _ProfileRemoteSupport support})
    : _support = support;

  Future<WalletModel> getWallet() async {
    _support.log('Fetching wallet');
    final response = await _support.apiClient.get(ApiEndpoints.wallet);
    return WalletModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<List<WalletTransactionModel>> getWalletTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    _support.log('Fetching wallet transactions');
    final response = await _support.apiClient.get(
      ApiEndpoints.walletTransactions,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      },
    );
    return _support
        .extractList(_support.extractPayload(response.data))
        .map(
          (json) => WalletTransactionModel.fromJson(_support.extractMap(json)),
        )
        .toList();
  }

  Future<bool> requestWithdrawal(double amount, String bankDetails) async {
    _support.log('Requesting withdrawal: $amount');
    final response = await _support.apiClient.post(
      '${ApiEndpoints.wallet}/withdraw',
      data: {'amount': amount, 'bankDetails': bankDetails},
    );
    return response.statusCode == 200;
  }

  Future<LoyaltyModel> getLoyaltyPoints() async {
    _support.log('Fetching loyalty points');
    final response = await _support.apiClient.get(ApiEndpoints.loyalty);
    return LoyaltyModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<bool> redeemPoints(int points) async {
    _support.log('Redeeming points: $points');
    final response = await _support.apiClient.post(
      '${ApiEndpoints.loyalty}/redeem',
      data: {'points': points},
    );
    return response.statusCode == 200;
  }

  Future<ReferralInfoModel> getReferralInfo() async {
    _support.log('Fetching referral info');
    final response = await _support.apiClient.get(ApiEndpoints.referral);
    return ReferralInfoModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<bool> applyReferralCode(String code) async {
    _support.log('Applying referral code: $code');
    final response = await _support.apiClient.post(
      '${ApiEndpoints.referral}/apply',
      data: {'code': code},
    );
    return response.statusCode == 200;
  }
}
