/// User Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String uuid;
  final String phone;
  final String? email;
  @JsonKey(name: 'user_type')
  final String userType;
  final String status;
  final String? avatar;
  @JsonKey(name: 'phone_verified_at')
  final String? phoneVerifiedAt;
  @JsonKey(name: 'email_verified_at')
  final String? emailVerifiedAt;
  final String language;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.uuid,
    required this.phone,
    this.email,
    required this.userType,
    required this.status,
    this.avatar,
    this.phoneVerifiedAt,
    this.emailVerifiedAt,
    this.language = 'ar',
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      uuid: uuid,
      phone: phone,
      email: email,
      userType: userType,
      status: status,
      avatar: avatar,
      phoneVerified: phoneVerifiedAt != null,
      emailVerified: emailVerifiedAt != null,
      language: language,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }
}
