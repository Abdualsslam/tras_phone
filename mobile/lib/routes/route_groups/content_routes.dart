library;

import 'package:go_router/go_router.dart';

import '../../features/education/presentation/screens/education_categories_screen.dart';
import '../../features/education/presentation/screens/education_details_screen.dart';
import '../../features/education/presentation/screens/education_list_screen.dart';
import '../../features/education/presentation/screens/faq_screen.dart';
import '../../features/education/presentation/screens/static_page_screen.dart';
import '../../features/favorite/presentation/screens/favorite_empty_screen.dart';
import '../../features/favorite/presentation/screens/favorite_screen.dart';
import '../../features/favorite/presentation/screens/stock_alerts_screen.dart';
import '../../features/returns/data/models/return_model.dart';
import '../../features/returns/presentation/screens/create_return_screen.dart';
import '../../features/returns/presentation/screens/return_details_screen.dart';
import '../../features/returns/presentation/screens/returns_list_screen.dart';
import '../../features/returns/presentation/screens/select_items_for_return_screen.dart';
import '../../features/reviews/presentation/screens/my_reviews_screen.dart';
import '../../features/reviews/presentation/screens/pending_reviews_screen.dart';
import '../../features/reviews/presentation/screens/product_reviews_screen.dart';
import '../../features/reviews/presentation/screens/write_review_screen.dart';
import '../app_route_paths.dart';
import '../route_args.dart';

List<RouteBase> buildContentRoutes() {
  return [
    GoRoute(
      path: AppRoutePaths.favorites,
      builder: (context, state) => const FavoriteScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.favoriteEmpty,
      builder: (context, state) => const FavoriteEmptyScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.stockAlerts,
      builder: (context, state) => const StockAlertsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.productReviews,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final args = ProductReviewsRouteArgs.fromExtra(state.extra);
        return ProductReviewsScreen(
          productId: id,
          productName: args.productName,
          averageRating: args.averageRating,
          reviewsCount: args.reviewsCount,
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.writeReview,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final args = WriteReviewRouteArgs.fromExtra(state.extra);
        return WriteReviewScreen(
          productId: id,
          productName: args.productName ?? 'المنتج',
        );
      },
    ),
    GoRoute(
      path: AppRoutePaths.writeReviewAlias,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return WriteReviewScreen(productId: id, productName: 'المنتج');
      },
    ),
    GoRoute(
      path: AppRoutePaths.myReviews,
      builder: (context, state) => const MyReviewsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.pendingReviews,
      builder: (context, state) => const PendingReviewsScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.returns,
      builder: (context, state) => const ReturnsListScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.returnsSelectItems,
      builder: (context, state) => const SelectItemsForReturnScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.returnsCreate,
      builder: (context, state) {
        final preSelectedItems = state.extra as List<CreateReturnItemRequest>?;
        return CreateReturnScreen(preSelectedItems: preSelectedItems);
      },
    ),
    GoRoute(
      path: AppRoutePaths.returnDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ReturnDetailsScreen(returnId: id);
      },
    ),
    GoRoute(
      path: AppRoutePaths.faq,
      builder: (context, state) => const FaqScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.terms,
      builder: (context, state) =>
          const StaticPageScreen(title: 'الشروط والأحكام', slug: 'terms'),
    ),
    GoRoute(
      path: AppRoutePaths.privacy,
      builder: (context, state) =>
          const StaticPageScreen(title: 'سياسة الخصوصية', slug: 'privacy'),
    ),
    GoRoute(
      path: AppRoutePaths.about,
      builder: (context, state) =>
          const StaticPageScreen(title: 'عن التطبيق', slug: 'about'),
    ),
    GoRoute(
      path: AppRoutePaths.education,
      builder: (context, state) => const EducationCategoriesScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.educationList,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return EducationListScreen(categoryId: id);
      },
    ),
    GoRoute(
      path: AppRoutePaths.educationDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return EducationDetailsScreen(contentId: id);
      },
    ),
  ];
}
