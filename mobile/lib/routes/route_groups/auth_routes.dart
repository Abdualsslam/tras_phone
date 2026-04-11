library;

import 'package:go_router/go_router.dart';

import '../../core/security/app_security_models.dart';
import '../../features/auth/presentation/screens/biometric_login_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/security_blocked_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../app_route_paths.dart';
import '../route_args.dart';

List<RouteBase> buildAuthRoutes() {
  return [
    GoRoute(
      path: AppRoutePaths.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.securityBlocked,
      builder: (context, state) {
        final assessment =
            state.extra as AppSecurityAssessment? ??
            const AppSecurityAssessment(
              status: AppSecurityStatus.blocked,
              signals: LocalSecuritySignals(
                platform: 'unknown',
                isDebuggable: false,
                isDebuggerAttached: false,
                isEmulator: false,
                hasTestKeys: false,
                hasRootFiles: false,
                hasMagiskFiles: false,
                hasHookFramework: false,
                hasFridaServer: false,
                packageName: null,
                appVersion: null,
                issues: <String>['security_blocked'],
              ),
              reasons: <String>['security_blocked'],
              enforcementEnabled: true,
            );

        return SecurityBlockedScreen(assessment: assessment);
      },
    ),
    GoRoute(
      path: AppRoutePaths.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.biometricLogin,
      builder: (context, state) => const BiometricLoginScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutePaths.otpVerification,
      builder: (context, state) {
        final args = OtpVerificationRouteArgs.fromExtra(state.extra);
        return OtpVerificationScreen(phone: args.phone, purpose: args.purpose);
      },
    ),
    GoRoute(
      path: AppRoutePaths.resetPassword,
      builder: (context, state) {
        final args = ResetPasswordRouteArgs.fromExtra(state.extra);
        return ResetPasswordScreen(
          phone: args.phone,
          resetToken: args.resetToken,
        );
      },
    ),
  ];
}
