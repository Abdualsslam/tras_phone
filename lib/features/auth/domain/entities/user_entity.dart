/// User Entity - Domain layer representation of a user
library;

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String uuid;
  final String phone;
  final String? email;
  final String userType;
  final String status;
  final String? avatar;
  final bool phoneVerified;
  final bool emailVerified;
  final String language;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.uuid,
    required this.phone,
    this.email,
    required this.userType,
    required this.status,
    this.avatar,
    this.phoneVerified = false,
    this.emailVerified = false,
    this.language = 'ar',
    this.createdAt,
  });

  bool get isActive => status == 'active';
  bool get isCustomer => userType == 'customer';
  bool get isAdmin => userType == 'admin';

  @override
  List<Object?> get props => [id, uuid, phone, email, userType, status];
}
