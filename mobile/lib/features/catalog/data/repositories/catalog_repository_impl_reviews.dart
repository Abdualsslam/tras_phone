part of 'catalog_repository_impl.dart';

class _CatalogReviewsRepositoryDelegate {
  final CatalogRemoteDataSource remoteDataSource;
  final _CatalogRepositorySupport support;

  const _CatalogReviewsRepositoryDelegate({
    required this.remoteDataSource,
    required this.support,
  });

  Future<Either<Failure, List<ProductReviewModel>>> getProductReviews(
    String productId,
  ) {
    return support.guard(() => remoteDataSource.getProductReviews(productId));
  }

  Future<Either<Failure, ProductReviewModel>> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final review = await remoteDataSource.addReview(
        productId: productId,
        rating: rating,
        title: title,
        comment: comment,
        images: images,
      );
      return Right(review);
    } catch (error) {
      final message = error is AppException ? error.message : error.toString();
      final isDuplicate =
          message.contains('E11000') ||
          message.contains('duplicate key') ||
          message.contains('dup key') ||
          message.contains('productId_1_customerId_1');

      return Left(
        ServerFailure(
          message: isDuplicate ? 'لقد قمت بتقييم هذا المنتج مسبقاً' : message,
        ),
      );
    }
  }

  Future<Either<Failure, ProductReviewModel?>> getMyReview(String productId) {
    return support.guard(() => remoteDataSource.getMyReview(productId));
  }

  Future<Either<Failure, ProductReviewModel>> updateReview({
    required String productId,
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) {
    return support.guard(
      () => remoteDataSource.updateReview(
        productId: productId,
        reviewId: reviewId,
        rating: rating,
        title: title,
        comment: comment,
        images: images,
      ),
    );
  }
}
