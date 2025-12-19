/// Auth State - Cubit state classes
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Authenticated state
class AuthAuthenticated extends AuthState {
  final CustomerEntity customer;

  const AuthAuthenticated(this.customer);

  @override
  List<Object?> get props => [customer];
}

/// Unauthenticated state
class AuthUnauthenticated extends AuthState {
  final bool isFirstLaunch;

  const AuthUnauthenticated({this.isFirstLaunch = false});

  @override
  List<Object?> get props => [isFirstLaunch];
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// OTP sent state
class AuthOtpSent extends AuthState {
  final String phone;
  final String purpose;

  const AuthOtpSent({required this.phone, required this.purpose});

  @override
  List<Object?> get props => [phone, purpose];
}

/// OTP verified state
class AuthOtpVerified extends AuthState {
  final String phone;

  const AuthOtpVerified({required this.phone});

  @override
  List<Object?> get props => [phone];
}

/// Password reset success state
class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

/// Profile updated state
class AuthProfileUpdated extends AuthState {
  final CustomerEntity customer;

  const AuthProfileUpdated(this.customer);

  @override
  List<Object?> get props => [customer];
}
