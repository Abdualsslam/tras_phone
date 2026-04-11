/// Dependency injection setup using get_it.
library;

import 'package:get_it/get_it.dart';

import '../constants/storage_keys.dart';
import '../network/token_manager.dart';
import '../storage/local_storage.dart';
import '../../features/catalog/data/services/product_cache_service.dart';
import '../../features/favorite/data/services/favorite_cache_service.dart';
import '../../features/home/data/services/home_cache_service.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import 'registrars/auth_registrar.dart';
import 'registrars/banners_registrar.dart';
import 'registrars/cart_registrar.dart';
import 'registrars/catalog_registrar.dart';
import 'registrars/core_registrar.dart';
import 'registrars/education_registrar.dart';
import 'registrars/favorite_registrar.dart';
import 'registrars/locations_registrar.dart';
import 'registrars/notifications_registrar.dart';
import 'registrars/orders_registrar.dart';
import 'registrars/profile_registrar.dart';
import 'registrars/promotions_registrar.dart';
import 'registrars/returns_registrar.dart';
import 'registrars/settings_registrar.dart';
import 'registrars/support_registrar.dart';
import 'registrars/wallet_registrar.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  await registerCoreDependencies(getIt, onForcedLogout: _handleForcedLogout);
  registerSettingsDependencies(getIt);
  registerCatalogDependencies(getIt);
  registerCartDependencies(getIt);
  registerOrdersDependencies(getIt);
  registerProfileDependencies(getIt);
  registerFavoriteDependencies(getIt);
  registerNotificationsDependencies(getIt);
  registerReturnsDependencies(getIt);
  registerSupportDependencies(getIt);
  registerLocationsDependencies(getIt);
  registerPromotionsDependencies(getIt);
  await registerEducationDependencies(getIt);
  registerWalletDependencies(getIt);
  registerBannersDependencies(getIt);
  registerAuthDependencies(getIt);
}

Future<void> _handleForcedLogout() async {
  await getIt<TokenManager>().clearTokens();
  await getIt<LocalStorage>().setBool(StorageKeys.isLoggedIn, false);
  await getIt<LocalStorage>().remove(StorageKeys.userData);

  try {
    await getIt<ProductCacheService>().clearAll();
    await getIt<HomeCacheService>().clearHomeData();
    await getIt<FavoriteCacheService>().clearAll();
    getIt<ProfileCubit>().clearCache();
    getIt<AddressesCubit>().clearCache();
  } catch (_) {
    // Keep logout resilient even if cache cleanup fails.
  }
}
