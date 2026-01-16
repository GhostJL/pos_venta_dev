import 'package:flutter/foundation.dart';

abstract class ErrorReporter {
  void reportError(dynamic error, StackTrace? stackTrace, {String? context});
  void log(String message);
}

class AppErrorReporter implements ErrorReporter {
  static final AppErrorReporter _instance = AppErrorReporter._internal();

  factory AppErrorReporter() {
    return _instance;
  }

  AppErrorReporter._internal();

  @override
  void reportError(dynamic error, StackTrace? stackTrace, {String? context}) {
    // In a real app, this would send to Sentry/Firebase Crashlytics
    final contextMsg = context != null ? '[$context] ' : '';
    debugPrint('${contextMsg}Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  @override
  void log(String message) {
    debugPrint('[LOG] $message');
  }
}
