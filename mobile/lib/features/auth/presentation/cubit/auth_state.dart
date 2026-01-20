/// Auth State - Cubit state classes
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/session_entity.dart';

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
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
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

/// OTP verified state - includes resetToken for password reset flow
class AuthOtpVerified extends AuthState {
  final String phone;
  final String? resetToken;

  const AuthOtpVerified({required this.phone, this.resetToken});

  @override
  List<Object?> get props => [phone, resetToken];
}

/// Password reset request submitted state
class AuthPasswordResetRequestSubmitted extends AuthState {
  final String requestNumber;

  const AuthPasswordResetRequestSubmitted({required this.requestNumber});

  @override
  List<Object?> get props => [requestNumber];
}

/// Password reset success state
class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

/// Profile updated state
class AuthProfileUpdated extends AuthState {
  final UserEntity user;

  const AuthProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Sessions loaded state
class AuthSessionsLoaded extends AuthState {
  final List<SessionEntity> sessions;

  const AuthSessionsLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

/// Session deleted state
class AuthSessionDeleted extends AuthState {
  final String sessionId;

  const AuthSessionDeleted(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
