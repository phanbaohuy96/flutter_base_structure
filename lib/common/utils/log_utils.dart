part of '../utils.dart';

class MyFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

class AppLog {
  final dynamic message;
  final dynamic error;
  final StackTrace? stackTrace;
  final Level level;

  AppLog(this.message, this.level, [this.error, this.stackTrace]);

  List<String> get logStrings {
    final logEvent = LogEvent(level, message, error, stackTrace);
    switch (level) {
      case Level.error:
        return LogUtils.printer.log(logEvent);
      default:
        return LogUtils.noStackPrinter.log(logEvent);
    }
  }
}

class LogUtils {
  static final LogPrinter printer = PrettyPrinter(
    printTime: true,
    errorMethodCount: 16,
  );

  static final LogPrinter noStackPrinter = PrettyPrinter(methodCount: 0);

  static final logs = <AppLog>[];

  static final Logger _logger = Logger(
    filter: MyFilter(),
    printer: printer,
  );

  static final Logger _loggerNoStackDebug = Logger(
    printer: noStackPrinter,
  );

  static final Logger _loggerNoStack = Logger(
    filter: MyFilter(),
    printer: noStackPrinter,
  );

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _appendLog(message, Level.debug, error, stackTrace);
    if (Config.instance.appConfig.developmentMode == true) {
      _loggerNoStackDebug.d(message, error, stackTrace);
    }
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _appendLog(message, Level.error, error, stackTrace);
    if (Config.instance.appConfig.developmentMode == true) {
      _logger.e(message, error, stackTrace);
    }
  }

  static T? eCatch<T>(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _appendLog(message, Level.warning, error, stackTrace);
    if (Config.instance.appConfig.developmentMode == true) {
      _logger.w(message, error, stackTrace);
    }
    return null;
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _appendLog(message, Level.info, error, stackTrace);
    if (Config.instance.appConfig.developmentMode == true) {
      _loggerNoStack.i(message, error, stackTrace);
    }
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _appendLog(message, Level.warning, error, stackTrace);
    if (Config.instance.appConfig.developmentMode == true) {
      _loggerNoStack.w(message, error, stackTrace);
    }
  }

  static void _appendLog(
    dynamic message,
    Level level, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!Config.instance.appConfig.isDevBuild) {
      return;
    }
    const limitLogs = 50;

    if (logs.length == limitLogs) {
      logs.removeAt(0);
    }

    logs.add(AppLog(message, level, error, stackTrace));
  }
}
