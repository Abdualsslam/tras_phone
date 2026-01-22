/// Banners State
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/banner_entity.dart';

abstract class BannersState extends Equatable {
  const BannersState();

  @override
  List<Object?> get props => [];
}

class BannersInitial extends BannersState {
  const BannersInitial();
}

class BannersLoading extends BannersState {
  const BannersLoading();
}

class BannersLoaded extends BannersState {
  final List<BannerEntity> banners;

  const BannersLoaded(this.banners);

  @override
  List<Object?> get props => [banners];
}

class BannersError extends BannersState {
  final String message;

  const BannersError(this.message);

  @override
  List<Object?> get props => [message];
}
