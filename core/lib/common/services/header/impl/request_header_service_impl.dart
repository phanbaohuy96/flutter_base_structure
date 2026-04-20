import '../request_header_service.dart';

class RequestHeaderServiceImpl extends RequestHeaderService {
  RequestHeaderServiceImpl({
    List<HeaderProvider> providers = const [],
  }) : super(providers);

  @override
  Future<Map<String, String>> get requestHeaders async {
    return {
      ...defaultHeader,
      for (final interceptor in interceptors) ...<String, String>{
        ...await interceptor.build(),
      },
    };
  }

  Map<String, String> get defaultHeader => {
    RequestHeaderKey.contentType.key: 'application/json',
    RequestHeaderKey.accept.key: 'application/json',
  };
}
