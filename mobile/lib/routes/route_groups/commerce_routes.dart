library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/presentation/cubit/checkout_session_cubit.dart';
import '../../features/cart/presentation/screens/address_selection_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/cart/presentation/screens/order_confirmation_screen.dart';
import '../../features/cart/presentation/screens/payment_method_screen.dart';
import '../../features/orders/presentation/screens/invoice_view_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/orders/presentation/screens/order_tracking_screen.dart';
import '../../features/orders/presentation/screens/upload_receipt_screen.dart';
import '../app_route_paths.dart';
import '../route_args.dart';

List<RouteBase> buildCommerceRoutes() {
  return [
    GoRoute(
      path: AppRoutePaths.checkout,
      builder: (context, state) => BlocProvider(
        create: (context) => CheckoutSessionCubit(
          remoteDataSource: context.read<CartRemoteDataSource>(),
        ),
        child: const CheckoutScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutePaths.checkoutPayment,
      builder: (context, state) => const PaymentMethodScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.checkoutAddress,
      builder: (context, state) => const AddressSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.orderConfirmation,
      builder: (context, state) => const OrderConfirmationScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.orders,
      redirect: (context, state) => '${AppRoutePaths.home}?tab=1',
    ),
    GoRoute(
      path: AppRoutePaths.order,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailsScreen(orderId: id);
      },
    ),
    GoRoute(
      path: AppRoutePaths.orderAlias,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailsScreen(orderId: id);
      },
    ),
    GoRoute(
      path: AppRoutePaths.orderDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailsScreen(orderId: id);
      },
    ),
    GoRoute(
      path: AppRoutePaths.orderTracking,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final orderNumber = extra is String ? extra : 'ORD-$id';
        return OrderTrackingScreen(orderId: id, orderNumber: orderNumber);
      },
    ),
    GoRoute(
      path: AppRoutePaths.orderUploadReceipt,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final args = UploadReceiptRouteArgs.fromExtra(state.extra);
        return UploadReceiptScreen(orderId: id, amount: args.amount);
      },
    ),
    GoRoute(
      path: AppRoutePaths.orderInvoice,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return InvoiceViewScreen(orderId: id);
      },
    ),
  ];
}
