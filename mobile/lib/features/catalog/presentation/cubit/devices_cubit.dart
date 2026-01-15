/// Devices Cubit - Manages devices state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'devices_state.dart';

/// Cubit for managing devices list
class DevicesCubit extends Cubit<DevicesState> {
  final CatalogRepository _repository;

  DevicesCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const DevicesInitial());

  /// Load popular devices
  Future<void> loadPopularDevices({int? limit}) async {
    emit(const DevicesLoading());

    final result = await _repository.getPopularDevices(limit: limit);

    result.fold(
      (failure) => emit(DevicesError(failure.message)),
      (devices) => emit(DevicesLoaded(devices)),
    );
  }

  /// Load devices for a specific brand
  Future<void> loadDevicesByBrand(String brandId) async {
    emit(const DevicesLoading());

    final result = await _repository.getDevicesByBrand(brandId);

    result.fold(
      (failure) => emit(DevicesError(failure.message)),
      (devices) => emit(DevicesLoaded(devices)),
    );
  }
}

/// Cubit for managing single device details
class DeviceDetailsCubit extends Cubit<DeviceDetailsState> {
  final CatalogRepository _repository;

  DeviceDetailsCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const DeviceDetailsInitial());

  /// Load device by slug
  Future<void> loadDevice(String slug) async {
    emit(const DeviceDetailsLoading());

    final result = await _repository.getDeviceBySlug(slug);

    result.fold(
      (failure) => emit(DeviceDetailsError(failure.message)),
      (device) => emit(DeviceDetailsLoaded(device)),
    );
  }
}
