/// App Router - GoRouter composition root
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_route_paths.dart';
import 'route_groups/account_routes.dart';
import 'route_groups/auth_routes.dart';
import 'route_groups/catalog_routes.dart';
import 'route_groups/commerce_routes.dart';
import 'route_groups/content_routes.dart';
import 'route_groups/home_routes.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutePaths.splash,
  routes: [
    ...buildAuthRoutes(),
    ...buildHomeRoutes(),
    ...buildCatalogRoutes(),
    ...buildCommerceRoutes(),
    ...buildAccountRoutes(),
    ...buildContentRoutes(),
  ],
);
