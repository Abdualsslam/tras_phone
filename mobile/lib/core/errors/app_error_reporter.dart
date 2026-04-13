library;

import 'dart:developer' as developer;

abstract class AppErrorReporter {
  void recordError(
    Object error,
    StackTrace stackTrace, {
    String source = 'app',
    bool fatal = false,
  });
}

class DeveloperAppErrorReporter implements AppErrorReporter {
  const DeveloperAppErrorReporter();

  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    String source = 'app',
    bool fatal = false,
  }) {
    developer.log(
      fatal ? 'Fatal application error' : 'Application error',
      name: source,
      error: error,
      stackTrace: stackTrace,
      level: fatal ? 1000 : 900,
    );
  }
}
