import 'network_log.dart';

export 'network_log.dart';

class NetworkLoggerService {
  static final NetworkLoggerService _instance =
      NetworkLoggerService._internal();

  final List<NetworkLog> _logs = [];

  factory NetworkLoggerService() => _instance;

  NetworkLoggerService._internal();

  List<NetworkLog> get logs => List.unmodifiable(_logs);

  void add(NetworkLog log) {
    _logs.insert(0, log); // newest on top
  }

  void clear() {
    _logs.clear();
  }
}
