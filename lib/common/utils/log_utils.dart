part of '../utils.dart';

class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

class LogUtils {
  static final Logger _logger = Logger(
    filter: MyFilter(),
    printer: PrettyPrinter(printTime: true, errorMethodCount: 16),
  );

  static final Logger _loggerNoStackDebug = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  static final Logger _loggerNoStack = Logger(
    filter: MyFilter(),
    printer: PrettyPrinter(methodCount: 0),
  );

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (Config.instance.appConfig?.developmentMode == true) {
      _loggerNoStackDebug.d(message, error, stackTrace);
    }
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (Config.instance.appConfig?.developmentMode == true) {
      _logger.e(message, error, stackTrace);
    }
  }

  static T? eCatch<T>(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (Config.instance.appConfig?.developmentMode == true) {
      _logger.w(message, error, stackTrace);
    }
    return null;
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (Config.instance.appConfig?.developmentMode == true) {
      _loggerNoStack.i(message, error, stackTrace);
    }
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (Config.instance.appConfig?.developmentMode == true) {
      _loggerNoStack.w(message, error, stackTrace);
    }
  }
}
