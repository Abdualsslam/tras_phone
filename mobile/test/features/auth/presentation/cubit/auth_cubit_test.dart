import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tras_phone/core/errors/failures.dart';
import 'package:tras_phone/core/services/biometric_service.dart';
import 'package:tras_phone/features/auth/domain/entities/session_entity.dart';
import 'package:tras_phone/features/auth/domain/entities/user_entity.dart';
import 'package:tras_phone/features/auth/domain/repositories/auth_repository.dart';
import 'package:tras_phone/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:tras_phone/features/auth/presentation/cubit/auth_state.dart';
import 'package:tras_phone/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:tras_phone/features/catalog/data/services/product_cache_service.dart';
import 'package:tras_phone/features/home/data/services/home_cache_service.dart';
import 'package:tras_phone/features/notifications/services/push_notification_manager.dart';
import 'package:tras_phone/features/profile/presentation/cubit/profile_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockBiometricService extends Mock implements BiometricService {}

class MockCartCubit extends Mock implements CartCubit {}

class MockProductCacheService extends Mock implements ProductCacheService {}

class MockHomeCacheService extends Mock implements HomeCacheService {}

class MockPushNotificationManager extends Mock
    implements PushNotificationManager {}

class MockProfileCubit extends Mock implements ProfileCubit {}

class MockAddressesCubit extends Mock implements AddressesCubit {}

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

  final testSession = SessionEntity(
    id: 'session-1',
    userId: 'user-1',
    tokenId: 'token-1',
    ipAddress: '127.0.0.1',
    userAgent: 'Flutter',
    expiresAt: now.add(const Duration(days: 30)),
    lastActivityAt: now,
    createdAt: now,
  );

  setUp(() {
    mockRepository = MockAuthRepository();

    // Register GetIt mocks for services called inside AuthCubit side-effects
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<BiometricService>()) {
      final mockBiometric = MockBiometricService();
      when(() => mockBiometric.isEnabled()).thenAnswer((_) async => false);
      getIt.registerSingleton<BiometricService>(mockBiometric);
    }
    if (!getIt.isRegistered<CartCubit>()) {
      final mockCart = MockCartCubit();
      when(
        () => mockCart.syncCart(silent: any(named: 'silent')),
      ).thenAnswer((_) async => null);
      getIt.registerSingleton<CartCubit>(mockCart);
    }
    if (!getIt.isRegistered<ProductCacheService>()) {
      final mockProductCache = MockProductCacheService();
      when(() => mockProductCache.clearAll()).thenAnswer((_) async {});
      getIt.registerSingleton<ProductCacheService>(mockProductCache);
    }
    if (!getIt.isRegistered<HomeCacheService>()) {
      final mockHomeCache = MockHomeCacheService();
      when(() => mockHomeCache.clearHomeData()).thenAnswer((_) async {});
      getIt.registerSingleton<HomeCacheService>(mockHomeCache);
    }
    if (!getIt.isRegistered<PushNotificationManager>()) {
      final mockPush = MockPushNotificationManager();
      when(
        () => mockPush.initialize(
          onNotificationTap: any(named: 'onNotificationTap'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockPush.getToken()).thenAnswer((_) async => null);
      getIt.registerSingleton<PushNotificationManager>(mockPush);
    }
    if (!getIt.isRegistered<ProfileCubit>()) {
      final mockProfile = MockProfileCubit();
      when(() => mockProfile.clearCache()).thenReturn(null);
      getIt.registerSingleton<ProfileCubit>(mockProfile);
    }
    if (!getIt.isRegistered<AddressesCubit>()) {
      final mockAddresses = MockAddressesCubit();
      when(() => mockAddresses.clearCache()).thenReturn(null);
      getIt.registerSingleton<AddressesCubit>(mockAddresses);
    }
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
        when(
          () => mockRepository.isFirstLaunch(),
        ).thenAnswer((_) async => true);
        return createCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(isFirstLaunch: true),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when not logged in',
      build: () {
        when(
          () => mockRepository.isFirstLaunch(),
        ).thenAnswer((_) async => false);
        when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => false);
        return createCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(isFirstLaunch: false),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when logged in with cached user',
      build: () {
        when(
          () => mockRepository.isFirstLaunch(),
        ).thenAnswer((_) async => false);
        when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockRepository.getCachedUser()).thenReturn(testUser);
        when(
          () => mockRepository.getProfile(),
        ).thenAnswer((_) async => Right(testUser));
        return createCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [const AuthLoading(), AuthAuthenticated(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when logged in, no cache, API succeeds',
      build: () {
        when(
          () => mockRepository.isFirstLaunch(),
        ).thenAnswer((_) async => false);
        when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
        when(() => mockRepository.getCachedUser()).thenReturn(null);
        when(
          () => mockRepository.getProfile(),
        ).thenAnswer((_) async => Right(testUser));
        return createCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [const AuthLoading(), AuthAuthenticated(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when logged in, no cache, API fails',
      build: () {
        when(
          () => mockRepository.isFirstLaunch(),
        ).thenAnswer((_) async => false);
        when(() => mockRepository.isLoggedIn()).thenAnswer((_) async => true);
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

  group('completeOnboarding', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthUnauthenticated(isFirstLaunch: false)]',
      build: () {
        when(
          () => mockRepository.setFirstLaunchComplete(),
        ).thenAnswer((_) async {});
        return createCubit();
      },
      act: (cubit) => cubit.completeOnboarding(),
      expect: () => [const AuthUnauthenticated(isFirstLaunch: false)],
    );
  });

  group('login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(
          () => mockRepository.login(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Right(testUser));
        when(
          () => mockRepository.saveBiometricCredentials(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async {});
        return createCubit();
      },
      act: (cubit) => cubit.login(phone: '+966500000000', password: 'pass123'),
      expect: () => [isA<AuthLoading>(), AuthAuthenticated(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => mockRepository.login(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          ),
        ).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid credentials')),
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

  group('register', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(
          () => mockRepository.register(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
            email: any(named: 'email'),
            responsiblePersonName: any(named: 'responsiblePersonName'),
            shopName: any(named: 'shopName'),
            shopNameAr: any(named: 'shopNameAr'),
            cityId: any(named: 'cityId'),
            businessType: any(named: 'businessType'),
          ),
        ).thenAnswer((_) async => Right(testUser));
        return createCubit();
      },
      act: (cubit) =>
          cubit.register(phone: '+966500000000', password: 'pass123'),
      expect: () => [isA<AuthLoading>(), AuthAuthenticated(testUser)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => mockRepository.register(
            phone: any(named: 'phone'),
            password: any(named: 'password'),
            email: any(named: 'email'),
            responsiblePersonName: any(named: 'responsiblePersonName'),
            shopName: any(named: 'shopName'),
            shopNameAr: any(named: 'shopNameAr'),
            cityId: any(named: 'cityId'),
            businessType: any(named: 'businessType'),
          ),
        ).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'Phone already exists')),
        );
        return createCubit();
      },
      act: (cubit) =>
          cubit.register(phone: '+966500000000', password: 'pass123'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('Phone already exists'),
      ],
    );
  });

  group('sendOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOtpSent] on success',
      build: () {
        when(
          () => mockRepository.sendOtp(
            phone: any(named: 'phone'),
            purpose: any(named: 'purpose'),
          ),
        ).thenAnswer((_) async => const Right(null));
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
        when(
          () => mockRepository.sendOtp(
            phone: any(named: 'phone'),
            purpose: any(named: 'purpose'),
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'OTP failed')),
        );
        return createCubit();
      },
      act: (cubit) =>
          cubit.sendOtp(phone: '+966500000000', purpose: 'registration'),
      expect: () => [isA<AuthLoading>(), const AuthError('OTP failed')],
    );
  });

  group('verifyOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOtpVerified] on success',
      build: () {
        when(
          () => mockRepository.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
            purpose: any(named: 'purpose'),
          ),
        ).thenAnswer((_) async => const Right(true));
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
        when(
          () => mockRepository.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
            purpose: any(named: 'purpose'),
          ),
        ).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid OTP')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.verifyOtp(
        phone: '+966500000000',
        otp: '0000',
        purpose: 'registration',
      ),
      expect: () => [isA<AuthLoading>(), const AuthError('Invalid OTP')],
    );
  });

  group('logout', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] on success',
      build: () {
        when(
          () => mockRepository.logout(),
        ).thenAnswer((_) async => const Right(null));
        return createCubit();
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        isA<AuthLoading>(),
        const AuthUnauthenticated(isFirstLaunch: false),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockRepository.logout()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Logout failed')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.logout(),
      expect: () => [isA<AuthLoading>(), const AuthError('Logout failed')],
    );
  });

  group('forgotPassword', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthPasswordResetRequestSubmitted] on success',
      build: () {
        when(
          () => mockRepository.forgotPassword(
            phone: any(named: 'phone'),
            customerNotes: any(named: 'customerNotes'),
          ),
        ).thenAnswer((_) async => const Right('REQ-001'));
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
        when(
          () => mockRepository.forgotPassword(
            phone: any(named: 'phone'),
            customerNotes: any(named: 'customerNotes'),
          ),
        ).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not found')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.forgotPassword(phone: '+966500000000'),
      expect: () => [isA<AuthLoading>(), const AuthError('Not found')],
    );
  });

  group('verifyResetOtp', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOtpVerified with resetToken] on success',
      build: () {
        when(
          () => mockRepository.verifyResetOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => const Right('reset-token-123'));
        return createCubit();
      },
      act: (cubit) => cubit.verifyResetOtp(phone: '+966500000000', otp: '1234'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthOtpVerified(
          phone: '+966500000000',
          resetToken: 'reset-token-123',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => mockRepository.verifyResetOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer(
          (_) async => const Left(AuthFailure(message: 'Invalid OTP')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.verifyResetOtp(phone: '+966500000000', otp: '0000'),
      expect: () => [isA<AuthLoading>(), const AuthError('Invalid OTP')],
    );
  });

  group('resetPassword', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthPasswordResetSuccess] on success',
      build: () {
        when(
          () => mockRepository.resetPassword(
            resetToken: any(named: 'resetToken'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => const Right(true));
        return createCubit();
      },
      act: (cubit) =>
          cubit.resetPassword(resetToken: 'token', newPassword: 'newPass123'),
      expect: () => [isA<AuthLoading>(), const AuthPasswordResetSuccess()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => mockRepository.resetPassword(
            resetToken: any(named: 'resetToken'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer(
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
        when(
          () => mockRepository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => const Right(true));
        return createCubit();
      },
      act: (cubit) =>
          cubit.changePassword(oldPassword: 'old', newPassword: 'new'),
      expect: () => [isA<AuthLoading>(), const AuthPasswordResetSuccess()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(
          () => mockRepository.changePassword(
            oldPassword: any(named: 'oldPassword'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer(
          (_) async =>
              const Left(AuthFailure(message: 'Wrong current password')),
        );
        return createCubit();
      },
      act: (cubit) =>
          cubit.changePassword(oldPassword: 'wrong', newPassword: 'new'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthError('Wrong current password'),
      ],
    );
  });

  group('getSessions', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthSessionsLoaded] on success',
      build: () {
        when(
          () => mockRepository.getSessions(),
        ).thenAnswer((_) async => Right([testSession]));
        return createCubit();
      },
      act: (cubit) => cubit.getSessions(),
      expect: () => [
        isA<AuthLoading>(),
        AuthSessionsLoaded([testSession]),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockRepository.getSessions()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Unauthorized')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.getSessions(),
      expect: () => [isA<AuthLoading>(), const AuthError('Unauthorized')],
    );
  });

  group('deleteSession', () {
    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthSessionDeleted] then reloads sessions on success',
      build: () {
        when(
          () => mockRepository.deleteSession(any()),
        ).thenAnswer((_) async => const Right(null));
        when(
          () => mockRepository.getSessions(),
        ).thenAnswer((_) async => Right([testSession]));
        return createCubit();
      },
      act: (cubit) => cubit.deleteSession('session-1'),
      expect: () => [
        isA<AuthLoading>(),
        const AuthSessionDeleted('session-1'),
        isA<AuthLoading>(),
        isA<AuthSessionsLoaded>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] on failure',
      build: () {
        when(() => mockRepository.deleteSession(any())).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not found')),
        );
        return createCubit();
      },
      act: (cubit) => cubit.deleteSession('bad-id'),
      expect: () => [isA<AuthLoading>(), const AuthError('Not found')],
    );
  });

  group('currentUser', () {
    test('returns null when state is not AuthAuthenticated and no cache', () {
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
