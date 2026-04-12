part of 'wallet_remote_datasource.dart';

class _WalletBalanceDelegate {
  final _WalletRemoteSupport _support;

  const _WalletBalanceDelegate({required _WalletRemoteSupport support})
    : _support = support;

  Future<WalletSummary> getBalance() async {
    try {
      final response = await _support.apiClient.get('/wallet/balance');
      final body = _support.asMap(response.data);

      if (_support.isSuccessResponse(body)) {
        return WalletSummary.fromJson(_support.asMap(body['data']));
      }
      throw Exception(_support.extractMessage(body, 'فشل في جلب رصيد المحفظة'));
    } catch (error) {
      throw _support.wrapError(
        error,
        fallback: 'فشل في جلب رصيد المحفظة',
        fallbackWithDetails: 'فشل في جلب رصيد المحفظة',
      );
    }
  }

  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    WalletTransactionType? transactionType,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (transactionType != null) {
        queryParams['type'] = transactionType.apiValue;
      }

      final response = await _support.apiClient.get(
        '/wallet/transactions',
        queryParameters: queryParams,
      );
      final body = _support.asMap(response.data);

      if (_support.isSuccessResponse(body)) {
        final transactionsList = body['data'] as List? ?? [];
        return transactionsList
            .map((transaction) => WalletTransaction.fromJson(transaction))
            .toList();
      }
      throw Exception(
        _support.extractMessage(body, 'فشل في جلب معاملات المحفظة'),
      );
    } catch (error) {
      throw _support.wrapError(
        error,
        fallback: 'فشل في جلب معاملات المحفظة',
        fallbackWithDetails: 'فشل في جلب معاملات المحفظة',
      );
    }
  }
}
