/// Profile State - State classes for ProfileCubit
library;

import '../../../auth/domain/entities/customer_entity.dart';
import '../../domain/entities/address_entity.dart';

/// Base state for profile
abstract class ProfileState {
  const ProfileState();
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile loaded successfully
class ProfileLoaded extends ProfileState {
  final CustomerEntity customer;

  const ProfileLoaded(this.customer);
}

/// Profile error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);
}

/// Profile updated successfully
class ProfileUpdated extends ProfileState {
  final CustomerEntity customer;

  const ProfileUpdated(this.customer);
}

/// Base state for addresses
abstract class AddressesState {
  const AddressesState();
}

/// Initial state for addresses
class AddressesInitial extends AddressesState {
  const AddressesInitial();
}

/// Loading addresses
class AddressesLoading extends AddressesState {
  const AddressesLoading();
}

/// Addresses loaded successfully
class AddressesLoaded extends AddressesState {
  final List<AddressEntity> addresses;

  const AddressesLoaded(this.addresses);

  AddressEntity? get defaultAddress =>
      addresses.where((a) => a.isDefault).firstOrNull;
}

/// Addresses error state
class AddressesError extends AddressesState {
  final String message;

  const AddressesError(this.message);
}

/// Address operation in progress
class AddressOperationLoading extends AddressesState {
  final List<AddressEntity> addresses;

  const AddressOperationLoading(this.addresses);
}

/// Address operation success
class AddressOperationSuccess extends AddressesState {
  final List<AddressEntity> addresses;
  final String message;

  const AddressOperationSuccess(this.addresses, this.message);
}
