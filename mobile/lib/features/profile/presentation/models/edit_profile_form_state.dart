import 'package:flutter/material.dart';

import '../../../auth/domain/entities/customer_entity.dart';
import '../../data/models/update_customer_profile_dto.dart';
import '../../domain/repositories/profile_repository.dart';

class EditProfileFormState extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController responsiblePersonNameController =
      TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController shopNameArController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController instagramHandleController =
      TextEditingController();
  final TextEditingController twitterHandleController = TextEditingController();

  String? selectedBusinessType;
  String? selectedCityId;
  String? selectedMarketId;
  String? selectedPaymentMethod;
  String? selectedShippingTime;
  String? selectedContactMethod;

  List<Map<String, dynamic>> cities = const [];
  List<Map<String, dynamic>> markets = const [];
  bool loadingCities = false;
  bool loadingMarkets = false;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initializeFromCustomer(
    CustomerEntity customer,
    ProfileRepository repository,
  ) async {
    if (_initialized) return;

    responsiblePersonNameController.text = customer.responsiblePersonName;
    shopNameController.text = customer.shopName;
    shopNameArController.text = customer.shopNameAr ?? '';
    addressController.text = customer.address ?? '';
    instagramHandleController.text = customer.instagramHandle ?? '';
    twitterHandleController.text = customer.twitterHandle ?? '';

    selectedBusinessType = customer.businessType.name;
    selectedCityId = customer.cityId;
    selectedMarketId = customer.marketId;
    selectedPaymentMethod = customer.preferredPaymentMethod?.value;
    selectedShippingTime = customer.preferredShippingTime;
    selectedContactMethod = customer.preferredContactMethod.name;

    _initialized = true;
    notifyListeners();

    if (selectedCityId != null) {
      await loadCities(repository);
      await loadMarkets(repository, selectedCityId);
    }
  }

  Future<void> loadCities(ProfileRepository repository) async {
    loadingCities = true;
    notifyListeners();

    try {
      cities = await repository.getCities('SA');
    } finally {
      loadingCities = false;
      notifyListeners();
    }
  }

  Future<void> loadMarkets(ProfileRepository repository, String? cityId) async {
    if (cityId == null || cityId.isEmpty) {
      markets = const [];
      notifyListeners();
      return;
    }

    loadingMarkets = true;
    notifyListeners();

    try {
      markets = await repository.getAreas(cityId);
    } finally {
      loadingMarkets = false;
      notifyListeners();
    }
  }

  Future<void> onCityChanged(
    ProfileRepository repository,
    String? cityId,
  ) async {
    selectedCityId = cityId;
    selectedMarketId = null;
    markets = const [];
    notifyListeners();
    await loadMarkets(repository, cityId);
  }

  void setBusinessType(String? value) {
    selectedBusinessType = value;
    notifyListeners();
  }

  void setMarketId(String? value) {
    selectedMarketId = value;
    notifyListeners();
  }

  void setPaymentMethod(String? value) {
    selectedPaymentMethod = value;
    notifyListeners();
  }

  void setShippingTime(String? value) {
    selectedShippingTime = value;
    notifyListeners();
  }

  void setContactMethod(String? value) {
    selectedContactMethod = value;
    notifyListeners();
  }

  UpdateCustomerProfileDto buildDto() {
    return UpdateCustomerProfileDto(
      responsiblePersonName: responsiblePersonNameController.text.trim(),
      shopName: shopNameController.text.trim(),
      shopNameAr: shopNameArController.text.trim().isEmpty
          ? null
          : shopNameArController.text.trim(),
      businessType: selectedBusinessType,
      cityId: selectedCityId,
      marketId: selectedMarketId,
      address: addressController.text.trim().isEmpty
          ? null
          : addressController.text.trim(),
      preferredPaymentMethod: selectedPaymentMethod,
      preferredShippingTime: selectedShippingTime,
      preferredContactMethod: selectedContactMethod,
      instagramHandle: instagramHandleController.text.trim().isEmpty
          ? null
          : instagramHandleController.text.trim(),
      twitterHandle: twitterHandleController.text.trim().isEmpty
          ? null
          : twitterHandleController.text.trim(),
    );
  }

  @override
  void dispose() {
    responsiblePersonNameController.dispose();
    shopNameController.dispose();
    shopNameArController.dispose();
    addressController.dispose();
    instagramHandleController.dispose();
    twitterHandleController.dispose();
    super.dispose();
  }
}
