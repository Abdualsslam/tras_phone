part of 'wallet_remote_datasource.dart';

class _WalletLoyaltyDelegate {
  final _WalletRemoteSupport _support;

  const _WalletLoyaltyDelegate({required _WalletRemoteSupport support})
    : _support = support;

  Future<LoyaltyPoints> getPoints() async {
    try {
      final response = await _support.apiClient.get('/wallet/points');
      final body = _support.asMap(response.data);

      if (_support.isSuccessResponse(body)) {
        return LoyaltyPoints.fromJson(_support.asMap(body['data']));
      }
      throw Exception(_support.extractMessage(body, 'فشل في جلب نقاط الولاء'));
    } catch (error) {
      throw _support.wrapError(
        error,
        fallback: 'فشل في جلب نقاط الولاء',
        fallbackWithDetails: 'فشل في جلب نقاط الولاء',
      );
    }
  }

  Future<List<LoyaltyTransaction>> getPointsTransactions() async {
    try {
      final response = await _support.apiClient.get(
        '/wallet/points/transactions',
      );
      final body = _support.asMap(response.data);

      if (_support.isSuccessResponse(body)) {
        final transactionsList = body['data'] as List? ?? [];
        return transactionsList
            .map((transaction) => LoyaltyTransaction.fromJson(transaction))
            .toList();
      }
      throw Exception(
        _support.extractMessage(body, 'فشل في جلب معاملات النقاط'),
      );
    } catch (error) {
      throw _support.wrapError(
        error,
        fallback: 'فشل في جلب معاملات النقاط',
        fallbackWithDetails: 'فشل في جلب معاملات النقاط',
      );
    }
  }

  Future<List<LoyaltyTier>> getTiers() async {
    try {
      final response = await _support.apiClient.get('/wallet/tiers');
      final body = _support.asMap(response.data);

      if (_support.isSuccessResponse(body)) {
        final tiersList = body['data'] as List? ?? [];
        return tiersList.map((tier) => LoyaltyTier.fromJson(tier)).toList();
      }
      throw Exception(
        _support.extractMessage(body, 'فشل في جلب مستويات الولاء'),
      );
    } catch (error) {
      throw _support.wrapError(
        error,
        fallback: 'فشل في جلب مستويات الولاء',
        fallbackWithDetails: 'فشل في جلب مستويات الولاء',
      );
    }
  }
}
