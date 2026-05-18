import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

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
    final logEvent = LogEvent(
      level,
      message,
      error: error,
      stackTrace: stackTrace,
    );
    switch (level) {
      case Level.error:
        return LogUtils.printer.log(logEvent);
      default:
        return LogUtils.noStackPrinter.log(logEvent);
    }
  }

  String get logStr => logStrings.join('\n');
}

class LogUtils {
  static final LogPrinter printer = PrettyPrinter(
    dateTimeFormat: (time) => '[${time.toIso8601String()}]',
    errorMethodCount: 16,
    printEmojis: false,
    colors: false,
    lineLength: 80,
    noBoxingByDefault: true,
  );

  static final LogPrinter noStackPrinter = PrettyPrinter(
    dateTimeFormat: (time) => '[${time.toIso8601String()}]',
    methodCount: 0,
    printEmojis: false,
    colors: false,
    lineLength: 80,
    noBoxingByDefault: true,
  );

  final logs = <AppLog>[];
  final bool showLog;
  final bool cacheToView;
  final int cacheLimit;

  final Logger _logger = Logger(
    filter: MyFilter(),
    printer: printer,
  );

  final Logger _loggerNoStackDebug = Logger(
    printer: noStackPrinter,
  );

  final Logger _loggerNoStack = Logger(
    filter: MyFilter(),
    printer: noStackPrinter,
  );

  LogUtils({
    this.showLog = true,
    this.cacheToView = true,
    this.cacheLimit = 1000,
  });

  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final logObject = _createLog(message, Level.debug, error, stackTrace);
    _appendLog(logObject);
    if (showLog) {
      if (kIsWeb) {
        return debugPrint('D ${logObject.logStr}');
      }
      _loggerNoStackDebug.d(message, error: error, stackTrace: stackTrace);
    }
  }

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final log = _createLog(message, Level.error, error, stackTrace);
    _appendLog(log);
    if (showLog) {
      if (kIsWeb) {
        return debugPrint('E ${log.logStr}');
      }
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  T? eCatch<T>(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    final log = _createLog(message, Level.warning, error, stackTrace);
    _appendLog(log);
    if (showLog) {
      if (kIsWeb) {
        debugPrint('E ${log.logStr}');
      }
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
    return null;
  }

  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final log = _createLog(message, Level.info, error, stackTrace);
    _appendLog(log);
    if (showLog) {
      if (kIsWeb) {
        return debugPrint('I ${log.logStr}');
      }
      _loggerNoStack.i(message, error: error, stackTrace: stackTrace);
    }
  }

  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    final log = _createLog(message, Level.warning, error, stackTrace);
    _appendLog(log);
    if (showLog) {
      if (kIsWeb) {
        return debugPrint('W ${log.logStr}');
      }
      _loggerNoStack.w(message, error: error, stackTrace: stackTrace);
    }
  }

  void _appendLog(AppLog log) {
    if (!cacheToView) {
      return;
    }

    if (logs.length == cacheLimit) {
      logs.removeAt(0);
    }

    logs.add(log);
  }

  AppLog _createLog(
    dynamic message,
    Level level, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    return AppLog(message, level, error, stackTrace);
  }
}
