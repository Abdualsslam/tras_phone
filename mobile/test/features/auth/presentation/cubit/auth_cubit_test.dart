import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tras_phone/core/errors/failures.dart';
import 'package:tras_phone/features/auth/domain/entities/user_entity.dart';
import 'package:tras_phone/features/auth/domain/repositories/auth_repository.dart';
import 'package:tras_phone/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:tras_phone/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  final now = DateTime(2024, 1, 1);
  final testUser = UserEntity(
    id: 'user-1',
    phone: '+966500000000',
    email: 'test@test.com',
    userType: 'customer',
    status: 'active',
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  AuthCubit createCubit() => AuthCubit(repository: mockRepository);

  group('initial state', () {
    test('should be AuthInitial', () {
      final cubit = createCubit();
      expect(cubit.state, const AuthInitial());
      cubit.close();
    });
  });

  group('checkAuthStatus', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated(isFirstLaunch: true)] on first launch',
      build: () {
        when(() => mockRepository.isFirstLaunch())
            .thenAnswer((_) async => true);
        return createCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(isFirstLaunch: true),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated(isFirstLaunch: false)] when not logged in',
      build: () {
        when(() => mockRepository.isFirstLaunch())
            .thenAnswer((_) async => false);
        when(() => mockRepository.isLoggedIn())
            .thenAnswer((_) async => false);
        return createCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(isFirstLaunch: false),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logged in but no cached user and API fails',
      build: () {
        when(() => mockRepository.isFirstLaunch())
            .thenAnswer((_) async => false);
        when(() => mockRepository.isLoggedIn())
            .thenAnswer((_) async => true);
        when(() => mockRepository.getCachedUser()).thenReturn(null);
        when(() => mockRepository.getProfile()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Server error')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(isFirstLaunch: false),
      ],
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on login failure',
      build: () {
        when(() => mockRepository.login(
              phone: any(named: 'phone'),
              password: any(named: 'password'),
            )).thenAnswer(
          (_) async =>
              const Left(AuthFailure(message: 'Invalid credentials')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.login(phone: '+966500000000', password: 'wrong'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('Invalid credentials'),
      ],
    );
  });

  group('sendOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOtpSent] on success',
      build: () {
        when(() => mockRepository.sendOtp(
              phone: any(named: 'phone'),
              purpose: any(named: 'purpose'),
            )).thenAnswer((_) async => const Right(null));
        return createCubit();
      },
      act: (cubit) =>
          cubit.sendOtp(phone: '+966500000000', purpose: 'registration'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthOtpSent(phone: '+966500000000', purpose: 'registration'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockRepository.sendOtp(
              phone: any(named: 'phone'),
              purpose: any(named: 'purpose'),
            )).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'OTP failed')),
        );
        return createCubit();
      },
      act: (cubit) =>
          cubit.sendOtp(phone: '+966500000000', purpose: 'registration'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('OTP failed'),
      ],
    );
  });

  group('verifyOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOtpVerified] on success',
      build: () {
        when(() => mockRepository.verifyOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
              purpose: any(named: 'purpose'),
            )).thenAnswer((_) async => const Right(true));
        return createCubit();
      },
      act: (cubit) => cubit.verifyOtp(
        phone: '+966500000000',
        otp: '1234',
        purpose: 'registration',
      ),
      expect: () => [
        isA<AuthLoading>(),
        const AuthOtpVerified(phone: '+966500000000'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockRepository.verifyOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
              purpose: any(named: 'purpose'),
            )).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid OTP')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.verifyOtp(
        phone: '+966500000000',
        otp: '0000',
        purpose: 'registration',
      ),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('Invalid OTP'),
      ],
    );
  });

  group('logout', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockRepository.logout()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Logout failed')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('Logout failed'),
      ],
    );
  });

  group('forgotPassword', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthPasswordResetRequestSubmitted] on success',
      build: () {
        when(() => mockRepository.forgotPassword(
              phone: any(named: 'phone'),
              customerNotes: any(named: 'customerNotes'),
            )).thenAnswer((_) async => const Right('REQ-001'));
        return createCubit();
      },
      act: (cubit) => cubit.forgotPassword(phone: '+966500000000'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthPasswordResetRequestSubmitted(requestNumber: 'REQ-001'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockRepository.forgotPassword(
              phone: any(named: 'phone'),
              customerNotes: any(named: 'customerNotes'),
            )).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not found')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.forgotPassword(phone: '+966500000000'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('Not found'),
      ],
    );
  });

  group('verifyResetOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOtpVerified with resetToken] on success',
      build: () {
        when(() => mockRepository.verifyResetOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => const Right('reset-token-123'));
        return createCubit();
      },
      act: (cubit) =>
          cubit.verifyResetOtp(phone: '+966500000000', otp: '1234'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthOtpVerified(
          phone: '+966500000000',
          resetToken: 'reset-token-123',
        ),
      ],
    );
  });

  group('resetPassword', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSuccess] on success',
      build: () {
        when(() => mockRepository.resetPassword(
              resetToken: any(named: 'resetToken'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async => const Right(true));
        return createCubit();
      },
      act: (cubit) => cubit.resetPassword(
        resetToken: 'token',
        newPassword: 'newPass123',
      ),
      expect: () => [
        isA<AuthLoading>(),
        const AuthPasswordResetSuccess(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockRepository.resetPassword(
              resetToken: any(named: 'resetToken'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Invalid reset token')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.resetPassword(
        resetToken: 'bad-token',
        newPassword: 'newPass123',
      ),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('Invalid reset token'),
      ],
    );
  });

  group('changePassword', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSuccess] on success',
      build: () {
        when(() => mockRepository.changePassword(
              oldPassword: any(named: 'oldPassword'),
              newPassword: any(named: 'newPassword'),
            )).thenAnswer((_) async => const Right(true));
        return createCubit();
      },
      act: (cubit) => cubit.changePassword(
        oldPassword: 'old',
        newPassword: 'new',
      ),
      expect: () => [
        isA<AuthLoading>(),
        const AuthPasswordResetSuccess(),
      ],
    );
  });

  group('currentUser', () {
    test('returns null when state is not AuthAuthenticated', () {
      when(() => mockRepository.getCachedUser()).thenReturn(null);
      final cubit = createCubit();
      expect(cubit.currentUser, isNull);
      cubit.close();
    });

    test('returns cached user from repository as fallback', () {
      when(() => mockRepository.getCachedUser()).thenReturn(testUser);
      final cubit = createCubit();
      expect(cubit.currentUser, testUser);
      cubit.close();
    });
  });
}
