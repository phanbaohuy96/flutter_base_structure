import 'package:collection/collection.dart';
import 'package:fl_utils/fl_utils.dart';

export 'impl/request_header_service_impl.dart';
export 'providers/env_config_header_provider.dart';
export 'providers/language_header_provider.dart';
export 'providers/system_header_provider.dart';

enum RequestHeaderKey {
  authorization('Authorization'),
  clientId('X-Client-Id'),
  accessToken('x-access-token'),
  contentType('Content-Type'),
  accept('accept'),
  device('device'),
  osversion('os-version'),
  osplatform('os-platform'),
  model('model'),
  appVersion('app-version'),
  appVersionFull('app-version-full'),
  platform('platform'),
  apiKey('x-core-api-key'),
  language('Accept-Language'),
  deviceId('device-id');

  const RequestHeaderKey(this.key);
  final String key;
}

abstract class RequestHeaderService {
  RequestHeaderService(List<HeaderProvider> providers) : _providers = providers;

  final List<HeaderProvider> _providers;

  List<HeaderProvider> get interceptors => _providers;

  Future<Map<String, String>> get requestHeaders;

  void addProvider(HeaderProvider provider) {
    if (!_providers.contains(provider)) {
      _providers.add(provider);
    }
  }

  void addProviders(List<HeaderProvider> providers) {
    for (final element in providers) {
      addProvider(element);
    }
  }

  void removeProviderWhere(bool Function(HeaderProvider) test) {
    _providers.removeWhere(test);
  }

  T? findProvider<T extends HeaderProvider>() {
    if (T == HeaderProvider) {
      return null;
    }
    return asOrNull(
      _providers.firstWhereOrNull((element) => element.runtimeType == T),
    );
  }
}

abstract class HeaderProvider {
  Future<Map<String, String>> build();
}
