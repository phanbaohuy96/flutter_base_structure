import '../request_header_service.dart';

class RequestHeaderServiceImpl extends RequestHeaderService {
  RequestHeaderServiceImpl({
    List<HeaderProvider> providers = const [],
  }) : super(providers);

  @override
  Map<String, String> get requestHeaders {
    return {
      ...defaulHeader,
      for (final interceptor in interceptors) ...<String, String>{
        ...interceptor.build()..removeWhere((key, value) => value.isEmpty),
      },
    };
  }

  Map<String, String> get defaulHeader => {
        RequestHeaderKey.contentType.key: 'application/json',
        RequestHeaderKey.accept.key: 'application/json',
      };
}
