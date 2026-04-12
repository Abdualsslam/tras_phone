part of 'cart_remote_datasource.dart';

class _CartRemoteCheckoutDelegate {
  final _CartRemoteSupport _support;

  const _CartRemoteCheckoutDelegate({required _CartRemoteSupport support})
    : _support = support;

  Future<CheckoutSessionEntity> getCheckoutSession({
    String? platform,
    String? couponCode,
  }) async {
    _support.log(
      'Getting checkout session: platform=$platform, couponCode=$couponCode',
    );

    final path = _support.buildCheckoutSessionPath(
      platform: platform,
      couponCode: couponCode,
    );
    _support.log('GET $path', name: 'CartRemoteDataSource');

    final response = await _support.apiClient.get(path);

    _support.log(
      'Response ${response.statusCode} $path',
      name: 'CartRemoteDataSource',
    );

    final payload = _support.extractMap(_support.extractPayload(response.data));
    return CheckoutSessionModel.fromJson(payload).toEntity();
  }
}
