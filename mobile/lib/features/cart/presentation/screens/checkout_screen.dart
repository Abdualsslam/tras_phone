/// Checkout Screen - Order summary and address/payment selection
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../controllers/checkout_flow_controller.dart';
import '../cubit/checkout_session_cubit.dart';
import '../cubit/checkout_session_state.dart';
import 'checkout_screen_sections.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with WidgetsBindingObserver {
  final CheckoutFlowState _flowState = CheckoutFlowState();
  final TextEditingController _transferNotesController =
      TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  late final CheckoutFlowController _flowController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _flowController = CheckoutFlowController(
      context: context,
      state: _flowState,
      transferNotesController: _transferNotesController,
      imagePicker: _imagePicker,
      updateState: (fn) => mounted ? setState(fn) : null,
      isMounted: () => mounted,
    );
    context.read<CheckoutSessionCubit>().loadSession();
    context.read<WalletCubit>().loadBalance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _transferNotesController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<CheckoutSessionCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<OrdersCubit, OrdersState>(
      listener: (context, ordersState) {
        if (ordersState is BankAccountsLoaded) {
          _flowController.updateBankAccounts(ordersState.accounts);
        }
      },
      child: BlocConsumer<CheckoutSessionCubit, CheckoutSessionState>(
        listener: (context, sessionState) {
          if (sessionState is CheckoutSessionLoaded) {
            _flowController.syncLoadedSession(sessionState.session);
          } else if (sessionState is CheckoutSessionCouponError) {
            AppSnackbar.showError(context, sessionState.message);
          }
        },
        builder: (context, sessionState) {
          if (sessionState is CheckoutSessionLoading) {
            return _CheckoutScaffoldShell(
              title: AppLocalizations.of(context)!.checkout,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (sessionState is CheckoutSessionError) {
            return _CheckoutScaffoldShell(
              title: AppLocalizations.of(context)!.checkout,
              body: AppError(
                title: 'حدث خطأ أثناء تحميل البيانات',
                message: sessionState.message,
                onRetry: () =>
                    context.read<CheckoutSessionCubit>().loadSession(),
              ),
            );
          }

          if (sessionState is! CheckoutSessionLoaded) {
            return _CheckoutScaffoldShell(
              title: AppLocalizations.of(context)!.checkout,
              body: const SizedBox.shrink(),
            );
          }

          return _CheckoutScaffoldShell(
            title: AppLocalizations.of(context)!.checkout,
            body: CheckoutLoadedContent(
              theme: theme,
              isDark: isDark,
              session: sessionState.session,
              flowState: _flowState,
              controller: _flowController,
            ),
          );
        },
      ),
    );
  }
}

class _CheckoutScaffoldShell extends StatelessWidget {
  final String title;
  final Widget body;

  const _CheckoutScaffoldShell({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: body,
    );
  }
}
