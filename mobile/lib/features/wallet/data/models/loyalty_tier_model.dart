/// Loyalty Tier Model
library;

import 'package:flutter/material.dart';

class LoyaltyTier {
  final String id;
  final String name;
  final String nameAr;
  final String code;
  final String? description;
  final String? descriptionAr;
  final int minPoints;
  final double? minSpend;
  final int? minOrders;
  final double pointsMultiplier;
  final double discountPercentage;
  final bool freeShipping;
  final bool prioritySupport;
  final bool earlyAccess;
  final List<String>? customBenefits;
  final String? icon;
  final String? color;
  final String? badgeImage;
  final int displayOrder;
  final bool isActive;

  const LoyaltyTier({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    this.description,
    this.descriptionAr,
    required this.minPoints,
    this.minSpend,
    this.minOrders,
    required this.pointsMultiplier,
    required this.discountPercentage,
    required this.freeShipping,
    required this.prioritySupport,
    required this.earlyAccess,
    this.customBenefits,
    this.icon,
    this.color,
    this.badgeImage,
    required this.displayOrder,
    required this.isActive,
  });

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) {
    return LoyaltyTier(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      minPoints: json['minPoints'] ?? 0,
      minSpend: json['minSpend']?.toDouble(),
      minOrders: json['minOrders'],
      pointsMultiplier: (json['pointsMultiplier'] ?? 1).toDouble(),
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      freeShipping: json['freeShipping'] ?? false,
      prioritySupport: json['prioritySupport'] ?? false,
      earlyAccess: json['earlyAccess'] ?? false,
      customBenefits: json['customBenefits'] != null
          ? List<String>.from(json['customBenefits'])
          : null,
      icon: json['icon'],
      color: json['color'],
      badgeImage: json['badgeImage'],
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'code': code,
        'description': description,
        'descriptionAr': descriptionAr,
        'minPoints': minPoints,
        'minSpend': minSpend,
        'minOrders': minOrders,
        'pointsMultiplier': pointsMultiplier,
        'discountPercentage': discountPercentage,
        'freeShipping': freeShipping,
        'prioritySupport': prioritySupport,
        'earlyAccess': earlyAccess,
        'customBenefits': customBenefits,
        'icon': icon,
        'color': color,
        'badgeImage': badgeImage,
        'displayOrder': displayOrder,
        'isActive': isActive,
      };

  String getName(String locale) => locale == 'ar' ? nameAr : name;

  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;

  Color? getColor() {
    if (color == null) return null;
    final hex = color!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  LoyaltyTier copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? code,
    String? description,
    String? descriptionAr,
    int? minPoints,
    double? minSpend,
    int? minOrders,
    double? pointsMultiplier,
    double? discountPercentage,
    bool? freeShipping,
    bool? prioritySupport,
    bool? earlyAccess,
    List<String>? customBenefits,
    String? icon,
    String? color,
    String? badgeImage,
    int? displayOrder,
    bool? isActive,
  }) {
    return LoyaltyTier(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      code: code ?? this.code,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      minPoints: minPoints ?? this.minPoints,
      minSpend: minSpend ?? this.minSpend,
      minOrders: minOrders ?? this.minOrders,
      pointsMultiplier: pointsMultiplier ?? this.pointsMultiplier,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      freeShipping: freeShipping ?? this.freeShipping,
      prioritySupport: prioritySupport ?? this.prioritySupport,
      earlyAccess: earlyAccess ?? this.earlyAccess,
      customBenefits: customBenefits ?? this.customBenefits,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      badgeImage: badgeImage ?? this.badgeImage,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
