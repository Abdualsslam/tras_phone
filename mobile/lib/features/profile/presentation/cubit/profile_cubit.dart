/// Profile Cubit - State management for profile and addresses
library;

import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../data/models/address_model.dart';
import '../../data/models/update_customer_profile_dto.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/api_endpoints.dart';
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
      // Print request URL
      _printRequestUrl();
      
      final customer = await _repository.getProfile();
      
      // Print all profile data to terminal
      _printProfileData(customer);
      
      emit(ProfileLoaded(customer));
    } catch (e) {
      developer.log('Error loading profile: $e', name: 'ProfileCubit');
      emit(ProfileError(e.toString()));
    }
  }

  /// Print request URL to terminal
  void _printRequestUrl() {
    final fullUrl = '${AppConfig.baseUrl}${ApiEndpoints.profile}';
    final separator = List.filled(80, '=').join();
    print('\n$separator');
    print('🌐 API REQUEST - رابط الطلب');
    print(separator);
    print('Method: GET');
    print('URL: $fullUrl');
    print('Endpoint: ${ApiEndpoints.profile}');
    print('Base URL: ${AppConfig.baseUrl}');
    print(separator + '\n');
  }

  /// Print all profile data to terminal in a formatted way
  void _printProfileData(customer) {
    final separator = List.filled(80, '=').join();
    print('\n$separator');
    print('📋 PROFILE DATA - جميع بيانات البروفايل');
    print(separator);
    
    // Basic Information
    print('\n🔹 Basic Information - المعلومات الأساسية:');
    print('  ID: ${customer.id}');
    print('  User ID: ${customer.userId ?? "N/A"}');
    print('  Responsible Person Name: ${customer.responsiblePersonName}');
    print('  Shop Name (EN): ${customer.shopName}');
    print('  Shop Name (AR): ${customer.shopNameAr ?? "N/A"}');
    print('  Business Type: ${customer.businessType.displayName}');
    print('  Is Approved: ${customer.isApproved}');
    
    // User Information
    if (customer.user != null) {
      print('\n🔹 User Information - معلومات المستخدم:');
      print('  User ID: ${customer.user!.id}');
      print('  Phone: ${customer.user!.phone}');
      print('  Email: ${customer.user!.email ?? "N/A"}');
      print('  User Type: ${customer.user!.userType}');
      print('  Status: ${customer.user!.status}');
      print('  Is Active: ${customer.user!.isActive}');
      print('  Referral Code: ${customer.user!.referralCode ?? "N/A"}');
      print('  Last Login: ${customer.user!.lastLoginAt?.toString() ?? "N/A"}');
      print('  Created At: ${customer.user!.createdAt}');
      print('  Updated At: ${customer.user!.updatedAt}');
    }
    
    // Location Information
    print('\n🔹 Location Information - معلومات الموقع:');
    print('  City ID: ${customer.cityId ?? "N/A"}');
    print('  Market ID: ${customer.marketId ?? "N/A"}');
    print('  Address: ${customer.address ?? "N/A"}');
    print('  Latitude: ${customer.latitude ?? "N/A"}');
    print('  Longitude: ${customer.longitude ?? "N/A"}');
    
    // Pricing & Credit
    print('\n🔹 Pricing & Credit - التسعير والائتمان:');
    print('  Price Level ID: ${customer.priceLevelId ?? "N/A"}');
    print('  Credit Limit: ${customer.creditLimit.toStringAsFixed(2)} ر.س');
    print('  Credit Used: ${customer.creditUsed.toStringAsFixed(2)} ر.س');
    print('  Available Credit: ${customer.availableCredit.toStringAsFixed(2)} ر.س');
    
    // Wallet
    print('\n🔹 Wallet - المحفظة:');
    print('  Wallet Balance: ${customer.walletBalance.toStringAsFixed(2)} ر.س');
    
    // Loyalty
    print('\n🔹 Loyalty - الولاء:');
    print('  Loyalty Points: ${customer.loyaltyPoints}');
    print('  Loyalty Tier: ${customer.loyaltyTier.displayName}');
    
    // Statistics
    print('\n🔹 Statistics - الإحصائيات:');
    print('  Total Orders: ${customer.totalOrders}');
    print('  Total Spent: ${customer.totalSpent.toStringAsFixed(2)} ر.س');
    print('  Average Order Value: ${customer.averageOrderValue.toStringAsFixed(2)} ر.س');
    print('  Last Order At: ${customer.lastOrderAt?.toString() ?? "N/A"}');
    
    // Preferences
    print('\n🔹 Preferences - التفضيلات:');
    print('  Preferred Payment Method: ${customer.preferredPaymentMethod?.displayName ?? "N/A"}');
    print('  Preferred Shipping Time: ${customer.preferredShippingTime ?? "N/A"}');
    print('  Preferred Contact Method: ${customer.preferredContactMethod.displayName}');
    
    // Social Media
    print('\n🔹 Social Media - وسائل التواصل:');
    print('  Instagram Handle: ${customer.instagramHandle ?? "N/A"}');
    print('  Twitter Handle: ${customer.twitterHandle ?? "N/A"}');
    
    // Timestamps
    print('\n🔹 Timestamps - الطوابع الزمنية:');
    print('  Approved At: ${customer.approvedAt?.toString() ?? "N/A"}');
    print('  Created At: ${customer.createdAt}');
    print('  Updated At: ${customer.updatedAt}');
    
    print('\n$separator');
    print('✅ Profile data printed successfully - تم طباعة بيانات البروفايل بنجاح');
    print('$separator\n');
  }

  /// Update profile
  Future<void> updateProfile(UpdateCustomerProfileDto dto) async {
    emit(const ProfileLoading());
    try {
      final customer = await _repository.updateProfile(dto);
      emit(ProfileUpdated(customer));
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
    required String addressLine,
    required double latitude,
    required double longitude,
    String? cityId,
    String? cityName,
    String? marketName,
    String? notes,
    bool isDefault = false,
  }) async {
    emit(AddressOperationLoading(_addresses));
    try {
      final request = AddressRequest(
        label: label,
        cityId: cityId,
        cityName: cityName,
        marketName: marketName,
        addressLine: addressLine,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
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
    String? cityName,
    String? marketName,
    double? latitude,
    double? longitude,
    String? notes,
    bool? isDefault,
  }) async {
    emit(AddressOperationLoading(_addresses));
    try {
      final updates = <String, dynamic>{};
      if (label != null) updates['label'] = label;
      if (addressLine != null) updates['addressLine'] = addressLine;
      if (cityId != null) updates['cityId'] = cityId;
      if (cityName != null) updates['cityName'] = cityName;
      if (marketName != null) updates['marketName'] = marketName;
      if (latitude != null) updates['latitude'] = latitude;
      if (longitude != null) updates['longitude'] = longitude;
      if (notes != null) updates['notes'] = notes;
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
      // Check if the address being deleted is the default
      final addressToDelete = _addresses.firstWhere(
        (a) => a.id == id,
        orElse: () => throw Exception('Address not found'),
      );
      final wasDefault = addressToDelete.isDefault;

      // Delete the address
      await _repository.deleteAddress(id);
      _addresses.removeWhere((a) => a.id == id);

      // If deleted address was default and there are remaining addresses,
      // set the last address as default
      if (wasDefault && _addresses.isNotEmpty) {
        final lastAddress = _addresses.last;
        await _repository.setDefaultAddress(lastAddress.id);

        // Update local list
        _addresses = _addresses.map((a) {
          return a.copyWith(isDefault: a.id == lastAddress.id);
        }).toList();
      }

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
