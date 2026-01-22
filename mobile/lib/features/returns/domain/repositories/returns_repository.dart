/// Returns Repository - Abstract interface for returns operations
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/return_entity.dart';
import '../enums/return_enums.dart';
import '../../data/models/return_model.dart';

/// Abstract repository interface for returns operations
abstract class ReturnsRepository {
  /// Get my returns with optional filtering
  Future<Either<Failure, List<ReturnEntity>>> getMyReturns({
    ReturnStatus? status,
    int page = 1,
    int limit = 20,
  });

  /// Get return by ID
  Future<Either<Failure, ReturnEntity>> getReturnById(String id);

  /// Create new return request
  Future<Either<Failure, ReturnEntity>> createReturn(CreateReturnRequest request);

  /// Cancel return request
  Future<Either<Failure, bool>> cancelReturn(String id);

  /// Get return reasons (public endpoint)
  Future<Either<Failure, List<ReturnReasonEntity>>> getReturnReasons();

  /// Upload return images
  Future<Either<Failure, List<String>>> uploadReturnImages(List<String> imagePaths);

  /// Get return policy
  Future<Either<Failure, Map<String, dynamic>>> getReturnPolicy();
}
