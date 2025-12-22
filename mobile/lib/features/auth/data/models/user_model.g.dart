// GENERATED CODE - DO NOT MODIFY BY HAND
// Manual implementation for user_model.g.dart

part of 'user_model.dart';

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as int,
  uuid: json['uuid'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  userType: json['user_type'] as String,
  status: json['status'] as String,
  avatar: json['avatar'] as String?,
  phoneVerifiedAt: json['phone_verified_at'] as String?,
  emailVerifiedAt: json['email_verified_at'] as String?,
  language: json['language'] as String? ?? 'ar',
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'uuid': instance.uuid,
  'phone': instance.phone,
  'email': instance.email,
  'user_type': instance.userType,
  'status': instance.status,
  'avatar': instance.avatar,
  'phone_verified_at': instance.phoneVerifiedAt,
  'email_verified_at': instance.emailVerifiedAt,
  'language': instance.language,
  'created_at': instance.createdAt,
};
