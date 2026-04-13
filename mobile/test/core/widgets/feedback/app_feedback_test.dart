import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tras_phone/core/errors/failures.dart';
import 'package:tras_phone/core/widgets/feedback/app_error.dart';
import 'package:tras_phone/core/widgets/feedback/app_snackbar.dart';
import 'package:tras_phone/l10n/app_localizations.dart';

Widget _buildTestApp(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, __) {
      return MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );
    },
  );
}

void main() {
  group('AppError', () {
    testWidgets('renders a network failure with retry action', (tester) async {
      var retried = false;

      await tester.pumpWidget(
        _buildTestApp(
          AppError(
            failure: const NetworkFailure(),
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('No Connection'), findsOneWidget);
      expect(
        find.text('Please check your internet connection and try again'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('renders a server failure message', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const AppError(
            failure: ServerFailure(message: 'Backend unavailable'),
          ),
        ),
      );

      expect(find.text('Server Error'), findsOneWidget);
      expect(find.text('Backend unavailable'), findsOneWidget);
    });
  });

  group('AppSnackbar', () {
    testWidgets('shows a network snackbar message', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => AppSnackbar.showFailure(
                context,
                const NetworkFailure(),
              ),
              child: const Text('show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('show'));
      await tester.pump();

      expect(find.text('No Connection'), findsOneWidget);
      expect(
        find.text('Please check your internet connection and try again'),
        findsOneWidget,
      );
    });

    testWidgets('shows a validation snackbar message', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => AppSnackbar.showFailure(
                context,
                const ValidationFailure(message: 'Invalid coupon'),
              ),
              child: const Text('show'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('show'));
      await tester.pump();

      expect(find.text('Check Your Input'), findsOneWidget);
      expect(find.text('Invalid coupon'), findsOneWidget);
    });
  });
}
