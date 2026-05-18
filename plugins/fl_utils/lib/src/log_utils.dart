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
    printTime: false,
    errorMethodCount: 16,
    printEmojis: false,
    colors: false,
    lineLength: 80,
  );

  static final LogPrinter noStackPrinter = PrettyPrinter(
    printTime: false,
    methodCount: 0,
    printEmojis: false,
    colors: false,
    lineLength: 80,
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
    this.cacheLimit = 100,
  });

  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _appendLog(message, Level.debug, error, stackTrace);
    if (showLog) {
      _loggerNoStackDebug.d(message, error, stackTrace);
    }
  }

  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _appendLog(message, Level.error, error, stackTrace);
    if (showLog) {
      _logger.e(message, error, stackTrace);
    }
  }

  T? eCatch<T>(
    dynamic message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    _appendLog(message, Level.warning, error, stackTrace);
    if (showLog) {
      _logger.w(message, error, stackTrace);
    }
    return null;
  }

  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _appendLog(message, Level.info, error, stackTrace);
    if (showLog) {
      _loggerNoStack.i(message, error, stackTrace);
    }
  }

  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _appendLog(message, Level.warning, error, stackTrace);
    if (showLog) {
      _loggerNoStack.w(message, error, stackTrace);
    }
  }

  void _appendLog(
    dynamic message,
    Level level, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!cacheToView) {
      return;
    }

    if (logs.length == cacheLimit) {
      logs.removeAt(0);
    }

    logs.add(AppLog(message, level, error, stackTrace));
  }
}
