library;

import 'package:bloc/bloc.dart';

import '../errors/app_error_reporter.dart';

class AppBlocObserver extends BlocObserver {
  final AppErrorReporter errorReporter;

  AppBlocObserver({required this.errorReporter});

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    errorReporter.recordError(
      error,
      stackTrace,
      source: bloc.runtimeType.toString(),
    );
    super.onError(bloc, error, stackTrace);
  }
}
