/// User Entity - Domain layer representation of a user
library;

import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final String? email;
  final String userType; // 'customer' | 'admin'
  final String status; // 'pending' | 'active' | 'suspended' | 'deleted'
  final String? referralCode;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
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

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isSuspended => status == 'suspended';
  bool get isCustomer => userType == 'customer';
  bool get isAdmin => userType == 'admin';

  @override
  List<Object?> get props => [id, phone, email, userType, status];
}
