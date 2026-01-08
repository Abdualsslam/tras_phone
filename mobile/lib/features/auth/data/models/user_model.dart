/// User Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String phone;
  final String? email;
  @JsonKey(name: 'userType')
  final String userType;
  final String status;
  @JsonKey(name: 'referralCode')
  final String? referralCode;
  @JsonKey(name: 'lastLoginAt')
  final DateTime? lastLoginAt;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.phone,
    this.email,
    required this.userType,
    required this.status,
    this.referralCode,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Handle both String id and ObjectId map from MongoDB
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      phone: phone,
      email: email,
      userType: userType,
      status: status,
      referralCode: referralCode,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
