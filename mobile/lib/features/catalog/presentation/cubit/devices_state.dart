/// Devices State - State classes for DevicesCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/device_entity.dart';

/// Base state for devices list
sealed class DevicesState extends Equatable {
  const DevicesState();

  @override
  List<Object?> get props => [];
}

class DevicesInitial extends DevicesState {
  const DevicesInitial();
}

class DevicesLoading extends DevicesState {
  const DevicesLoading();
}

class DevicesLoaded extends DevicesState {
  final List<DeviceEntity> devices;

  const DevicesLoaded(this.devices);

  @override
  List<Object?> get props => [devices];
}

class DevicesError extends DevicesState {
  final String message;

  const DevicesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for single device details
sealed class DeviceDetailsState extends Equatable {
  const DeviceDetailsState();

  @override
  List<Object?> get props => [];
}

class DeviceDetailsInitial extends DeviceDetailsState {
  const DeviceDetailsInitial();
}

class DeviceDetailsLoading extends DeviceDetailsState {
  const DeviceDetailsLoading();
}

class DeviceDetailsLoaded extends DeviceDetailsState {
  final DeviceEntity device;

  const DeviceDetailsLoaded(this.device);

  @override
  List<Object?> get props => [device];
}

class DeviceDetailsError extends DeviceDetailsState {
  final String message;

  const DeviceDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
