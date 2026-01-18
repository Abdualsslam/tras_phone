/// Profile Cubit - State management for profile and addresses
library;

import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/models/address_model.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import 'profile_state.dart';

/// Cubit for managing customer profile
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit({required ProfileRepository repository})
    : _repository = repository,
      super(const ProfileInitial());

  /// Load customer profile
  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final customer = await _repository.getProfile();
      emit(ProfileLoaded(customer));
    } catch (e) {
      developer.log('Error loading profile: $e', name: 'ProfileCubit');
      emit(ProfileError(e.toString()));
    }
  }

  /// Update profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    emit(const ProfileLoading());
    try {
      final customer = await _repository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        avatar: avatar,
      );
      emit(ProfileLoaded(customer));
    } catch (e) {
      developer.log('Error updating profile: $e', name: 'ProfileCubit');
      emit(ProfileError(e.toString()));
    }
  }

  /// Delete account
  Future<bool> deleteAccount({String? reason}) async {
    emit(const ProfileLoading());
    try {
      final success = await _repository.deleteAccount(reason: reason);
      if (success) {
        // Account deleted successfully - emit a success state
        // Note: We still return bool for compatibility
        emit(ProfileLoaded(
          // Create a minimal customer entity for success state
          // This won't be used but satisfies the state requirement
          CustomerEntity(
            id: '',
            userId: '',
            customerCode: '',
            responsiblePersonName: '',
            shopName: '',
            cityId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ));
      } else {
        emit(const ProfileError('فشل حذف الحساب'));
      }
      return success;
    } catch (e) {
      developer.log('Error deleting account: $e', name: 'ProfileCubit');
      emit(ProfileError(e.toString()));
      return false;
    }
  }
}

/// Cubit for managing customer addresses
class AddressesCubit extends Cubit<AddressesState> {
  final ProfileRepository _repository;
  List<AddressEntity> _addresses = [];

  AddressesCubit({required ProfileRepository repository})
    : _repository = repository,
      super(const AddressesInitial());

  /// Load all addresses
  Future<void> loadAddresses() async {
    emit(const AddressesLoading());
    try {
      _addresses = await _repository.getAddresses();
      emit(AddressesLoaded(_addresses));
    } catch (e) {
      developer.log('Error loading addresses: $e', name: 'AddressesCubit');
      emit(AddressesError(e.toString()));
    }
  }

  /// Create new address
  Future<void> createAddress({
    required String label,
    required String cityId,
    required String addressLine,
    String? recipientName,
    String? phone,
    String? marketId,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    emit(AddressOperationLoading(_addresses));
    try {
      final request = AddressRequest(
        label: label,
        cityId: cityId,
        addressLine: addressLine,
        recipientName: recipientName,
        phone: phone,
        marketId: marketId,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );

      final newAddress = await _repository.createAddress(request);

      // If new address is default, update other addresses
      if (isDefault) {
        _addresses = _addresses
            .map((a) => a.copyWith(isDefault: false))
            .toList();
      }

      _addresses.add(newAddress);
      emit(AddressOperationSuccess(_addresses, 'تم إضافة العنوان بنجاح'));
    } catch (e) {
      developer.log('Error creating address: $e', name: 'AddressesCubit');
      emit(AddressesError(e.toString()));
    }
  }

  /// Update existing address
  Future<void> updateAddress({
    required String id,
    String? label,
    String? addressLine,
    String? cityId,
    String? recipientName,
    String? phone,
    String? marketId,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) async {
    emit(AddressOperationLoading(_addresses));
    try {
      final updates = <String, dynamic>{};
      if (label != null) updates['label'] = label;
      if (addressLine != null) updates['addressLine'] = addressLine;
      if (cityId != null) updates['cityId'] = cityId;
      if (recipientName != null) updates['recipientName'] = recipientName;
      if (phone != null) updates['phone'] = phone;
      if (marketId != null) updates['marketId'] = marketId;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (isDefault != null) updates['isDefault'] = isDefault;

      final updated = await _repository.updateAddress(id, updates);

      // Update local list
      final index = _addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        // If setting as default, update others
        if (isDefault == true) {
          _addresses = _addresses
              .map((a) => a.copyWith(isDefault: false))
              .toList();
        }
        _addresses[index] = updated;
      }

      emit(AddressOperationSuccess(_addresses, 'تم تحديث العنوان بنجاح'));
    } catch (e) {
      developer.log('Error updating address: $e', name: 'AddressesCubit');
      emit(AddressesError(e.toString()));
    }
  }

  /// Delete address
  Future<void> deleteAddress(String id) async {
    emit(AddressOperationLoading(_addresses));
    try {
      await _repository.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);
      emit(AddressOperationSuccess(_addresses, 'تم حذف العنوان بنجاح'));
    } catch (e) {
      developer.log('Error deleting address: $e', name: 'AddressesCubit');
      emit(AddressesError(e.toString()));
    }
  }

  /// Set address as default
  Future<void> setDefaultAddress(String id) async {
    emit(AddressOperationLoading(_addresses));
    try {
      await _repository.setDefaultAddress(id);

      // Update local list
      _addresses = _addresses.map((a) {
        return a.copyWith(isDefault: a.id == id);
      }).toList();

      emit(AddressOperationSuccess(_addresses, 'تم تعيين العنوان الافتراضي'));
    } catch (e) {
      developer.log(
        'Error setting default address: $e',
        name: 'AddressesCubit',
      );
      emit(AddressesError(e.toString()));
    }
  }

  /// Get default address
  AddressEntity? get defaultAddress =>
      _addresses.where((a) => a.isDefault).firstOrNull;
}
