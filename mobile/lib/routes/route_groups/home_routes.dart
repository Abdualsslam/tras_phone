library;

import 'package:go_router/go_router.dart';

import '../../features/navigation/presentation/screens/main_navigation_shell.dart';
import '../app_route_paths.dart';

List<RouteBase> buildHomeRoutes() {
  return [
    GoRoute(
      path: AppRoutePaths.home,
      builder: (context, state) {
        final tabIndex =
            int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
        return MainNavigationShell(initialIndex: tabIndex.clamp(0, 4));
      },
    ),
    GoRoute(
      path: AppRoutePaths.promotionAlias,
      redirect: (context, state) => AppRoutePaths.home,
    ),
  ];
}
