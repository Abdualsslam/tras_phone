import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tras_phone/core/errors/failure_ui_model.dart';
import 'package:tras_phone/core/errors/failures.dart';
import 'package:tras_phone/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  group('FailureUiModel.fromFailure', () {
    test('builds a retryable full-page network model', () {
      final model = FailureUiModel.fromFailure(const NetworkFailure(), en);

      expect(model.title, 'No Connection');
      expect(model.displayType, FailureDisplayType.fullPage);
      expect(model.isRetryable, isTrue);
      expect(model.isNetworkRelated, isTrue);
      expect(model.retryLabel, 'Retry');
    });

    test('keeps validation failures inline when preferred', () {
      final model = FailureUiModel.fromFailure(
        const ValidationFailure(message: 'Please review the form'),
        en,
        preferredDisplayType: FailureDisplayType.inline,
      );

      expect(model.title, 'Check Your Input');
      expect(model.message, 'Please review the form');
      expect(model.displayType, FailureDisplayType.inline);
      expect(model.isRetryable, isFalse);
    });

    test('marks server failures as retryable', () {
      final model = FailureUiModel.fromFailure(
        const ServerFailure(message: 'Backend unavailable'),
        en,
      );

      expect(model.title, 'Server Error');
      expect(model.message, 'Backend unavailable');
      expect(model.isRetryable, isTrue);
    });
  });
}
