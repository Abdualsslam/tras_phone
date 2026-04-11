library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/address/presentation/screens/map_location_picker_screen.dart';
import '../../features/notifications/presentation/screens/notification_details_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/domain/entities/address_entity.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/cubit/profile_state.dart';
import '../../features/profile/presentation/screens/add_edit_address_screen.dart';
import '../../features/profile/presentation/screens/addresses_list_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/settings/presentation/screens/language_settings_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/support/presentation/screens/create_ticket_screen.dart';
import '../../features/support/presentation/screens/live_chat_screen.dart';
import '../../features/support/presentation/screens/support_tickets_screen.dart';
import '../../features/support/presentation/screens/ticket_chat_screen.dart';
import '../../features/support/presentation/screens/ticket_details_screen.dart';
import '../../features/wallet/presentation/screens/loyalty_points_screen.dart';
import '../../features/wallet/presentation/screens/loyalty_tiers_screen.dart';
import '../../features/wallet/presentation/screens/loyalty_transactions_screen.dart';
import '../../features/wallet/presentation/screens/referral_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/wallet_transactions_screen.dart';
import '../app_route_paths.dart';
import '../route_args.dart';

List<RouteBase> buildAccountRoutes() {
  return [
    GoRoute(
      path: AppRoutePaths.wallet,
      builder: (context, state) => const WalletScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.loyaltyPoints,
      builder: (context, state) => const LoyaltyPointsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.loyaltyTiers,
      builder: (context, state) => const LoyaltyTiersScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.loyaltyTransactions,
      builder: (context, state) => const LoyaltyTransactionsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.walletTransactions,
      builder: (context, state) => const WalletTransactionsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.referral,
      builder: (context, state) => const ReferralScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.addresses,
      builder: (context, state) => const AddressesListScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.mapLocationPicker,
      builder: (context, state) {
        final args = MapLocationPickerRouteArgs.fromExtra(state.extra);
        return MapLocationPickerScreen(
          initialLatitude: args.initialLatitude,
          initialLongitude: args.initialLongitude,
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.addressAdd,
      builder: (context, state) => const AddEditAddressScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.addressEdit,
      builder: (context, state) {
        final address = state.extra as AddressEntity?;
        return AddEditAddressScreen(address: address);
      },
    ),
    GoRoute(
      path: AppRoutePaths.addressEditAlias,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extraAddress = state.extra as AddressEntity?;
        final address =
            extraAddress ??
            _findAddressById(context.read<AddressesCubit>().state, id);
        return AddEditAddressScreen(address: address);
      },
    ),
    GoRoute(
      path: AppRoutePaths.support,
      builder: (context, state) => const SupportTicketsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.supportCreate,
      builder: (context, state) => const CreateTicketScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.supportCreateAlias,
      builder: (context, state) => const CreateTicketScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.supportChat,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return TicketChatScreen(ticketId: id, subject: 'تذكرة دعم');
      },
    ),
    GoRoute(
      path: AppRoutePaths.ticket,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return TicketDetailsScreen(ticketId: id);
      },
    ),
    GoRoute(
      path: AppRoutePaths.liveChat,
      builder: (context, state) => const LiveChatScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.notification,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return NotificationDetailsScreen(notificationId: id);
      },
    ),
    GoRoute(
      path: AppRoutePaths.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.settingsNotifications,
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.settingsLanguage,
      builder: (context, state) => const LanguageSettingsScreen(),
    ),
  ];
}

AddressEntity? _findAddressById(AddressesState state, String id) {
  if (id.isEmpty) return null;

  final addresses = switch (state) {
    AddressesLoaded(:final addresses) => addresses,
    AddressOperationLoading(:final addresses) => addresses,
    AddressOperationSuccess(:final addresses) => addresses,
    _ => const <AddressEntity>[],
  };

  for (final address in addresses) {
    if (address.id == id) {
      return address;
    }
  }

  return null;
}
