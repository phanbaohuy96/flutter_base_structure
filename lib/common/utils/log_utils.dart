import 'package:logger/logger.dart';

import '../../envs.dart';

class LogUtils {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(printTime: true),
  );

  static final Logger _loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  static void d(dynamic message, [dynamic error, StackTrace stackTrace]) {
    if (appConfig?.cheat == true) {
      _loggerNoStack.d(message, error, stackTrace);
    }
  }

  static void e(dynamic message, [dynamic error, StackTrace stackTrace]) {
    if (appConfig?.cheat == true) {
      _logger.e(message, error, stackTrace);
    }
  }

  static void i(dynamic message, [dynamic error, StackTrace stackTrace]) {
    if (appConfig?.cheat == true) {
      _loggerNoStack.i(message, error, stackTrace);
    }
  }

  static void w(dynamic message, [dynamic error, StackTrace stackTrace]) {
    if (appConfig?.cheat == true) {
      _loggerNoStack.w(message, error, stackTrace);
    }
  }
}
