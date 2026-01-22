/// Update Customer Profile DTO - Data transfer object for updating customer profile
library;

class UpdateCustomerProfileDto {
  final String? responsiblePersonName;
  final String? shopName;
  final String? shopNameAr;
  final String? businessType;
  final String? cityId;
  final String? marketId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? preferredPaymentMethod;
  final String? preferredShippingTime;
  final String? preferredContactMethod;
  final String? instagramHandle;
  final String? twitterHandle;

  UpdateCustomerProfileDto({
    this.responsiblePersonName,
    this.shopName,
    this.shopNameAr,
    this.businessType,
    this.cityId,
    this.marketId,
    this.address,
    this.latitude,
    this.longitude,
    this.preferredPaymentMethod,
    this.preferredShippingTime,
    this.preferredContactMethod,
    this.instagramHandle,
    this.twitterHandle,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (responsiblePersonName != null) {
      map['responsiblePersonName'] = responsiblePersonName;
    }
    if (shopName != null) {
      map['shopName'] = shopName;
    }
    if (shopNameAr != null) {
      map['shopNameAr'] = shopNameAr;
    }
    if (businessType != null) {
      map['businessType'] = businessType;
    }
    if (cityId != null) {
      map['cityId'] = cityId;
    }
    if (marketId != null) {
      map['marketId'] = marketId;
    }
    if (address != null) {
      map['address'] = address;
    }
    if (latitude != null) {
      map['latitude'] = latitude;
    }
    if (longitude != null) {
      map['longitude'] = longitude;
    }
    if (preferredPaymentMethod != null) {
      map['preferredPaymentMethod'] = preferredPaymentMethod;
    }
    if (preferredShippingTime != null) {
      map['preferredShippingTime'] = preferredShippingTime;
    }
    if (preferredContactMethod != null) {
      map['preferredContactMethod'] = preferredContactMethod;
    }
    if (instagramHandle != null) {
      map['instagramHandle'] = instagramHandle;
    }
    if (twitterHandle != null) {
      map['twitterHandle'] = twitterHandle;
    }
    return map;
  }
}
