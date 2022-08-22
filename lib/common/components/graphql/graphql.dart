import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../constants.dart';
import '../../utils.dart';

GraphQLClient createGraphQLClient({
  required String baseUri,
  required Future<String?> Function() getToken,
  Map<String, String> headers = const <String, String>{
    'content-type': 'application/json',
    'platform': 'dealer',
  },
  Map<String, String> Function()? customHeaderFnc,
  Future<String?> Function(String)? onRefreshToken,
}) {
  var _token = '';
  CustomHttpLink httpLink;

  if (!kIsWeb) {
    // Workaround for self-signed certificate execption
    final _httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) {
        LogUtils.d({
          'From': 'GraphQLClient -> badCertificateCallback',
          'Time': DateTime.now().toString(),
          'host': host,
          'port': port,
          'cert': cert,
        });
        return true;
      };
    final _ioClient = IOClient(_httpClient);

    httpLink = CustomHttpLink(
      '$baseUri',
      defaultHeaders: headers,
      customHeaderFnc: customHeaderFnc,
      client: _ioClient,
      onRefreshToken: onRefreshToken,
    );
  } else {
    httpLink = CustomHttpLink(
      '$baseUri',
      defaultHeaders: headers,
      customHeaderFnc: customHeaderFnc,
      onRefreshToken: onRefreshToken,
    );
  }

  final authLink = AuthLink(
    getToken: () async => getToken().then((token) {
      _token = token ?? '';
      return token?.isNotEmpty == true ? 'Bearer $token' : null;
    }).catchError((err) {
      LogUtils.w('get token failed: ${err.toString()}');
    }),
    headerKey: HttpConstants.authorization,
  );

  final errorLink = ErrorLink(
    onException: (request, forward, linkException) async* {
      LogUtils.e({
        'errorCallback': 'ErrorLink -> onException',
        'time': '${DateTime.now()}',
        'request': request.body,
        'errorType': linkException.originalException?.runtimeType,
        'token': _token,
      }.toString());
      yield* forward(request);
    },
    onGraphQLError: (request, forward, response) async* {
      LogUtils.e({
        'errorCallback': 'ErrorLink -> onGraphQLError',
        'time': '${DateTime.now()}',
        'request': request.body,
        'error': response.errors?.firstOrNull?.message,
        'extensions': response.errors?.firstOrNull?.extensions,
        'token': _token,
      }.toString());
      yield* forward(request);
    },
  );

  final link = errorLink.concat(authLink.concat(httpLink));

  return GraphQLClient(
    cache: GraphQLCache(),
    link: link,
  );
}

extension _Request on Request {
  String get body => bodyMap.toString();

  Map get bodyMap => {
        'headers': {...context.entry<HttpLinkHeaders>()?.headers ?? {}},
        'query': printNode(operation.document),
        'variables': variables,
      };
}

class CustomHttpLink extends HttpLink {
  Map<String, String> Function()? customHeaderFnc;
  final Future<String?> Function(String)? onRefreshToken;

  CustomHttpLink(
    String uri, {
    required Map<String, String> defaultHeaders,
    this.customHeaderFnc,
    http.Client? client,
    this.onRefreshToken,
  }) : super(uri, defaultHeaders: defaultHeaders, httpClient: client);

  @override
  Stream<Response> request(
    Request request, [
    NextLink? forward,
  ]) async* {
    final contextHeader =
        request.context.entry<HttpLinkHeaders>()?.headers ?? {};
    final customHeader = customHeaderFnc?.call() ?? {};

    final headers = await refreshTokenIfNeeded(
      <String, String>{...customHeader, ...contextHeader},
    );

    final customRequest = Request(
      operation: request.operation,
      context: Context.fromList([HttpLinkHeaders(headers: headers)]),
      variables: request.variables,
    );

    LogUtils.d({
      'From': 'CustomHttpLink request',
      'time': '${DateTime.now()}',
      ...customRequest.bodyMap,
    }.toString());

    yield* super.request(customRequest, forward);
  }

  Future<Map<String, String>> refreshTokenIfNeeded(
    Map<String, String> headers,
  ) async {
    final token = headers[HttpConstants.authorization];
    if (token != null) {
      final realToken = token.replaceAll('Bearer ', '');
      if (JwtUtils.isAboutToExpire(realToken)) {
        final newToken = await onRefreshToken
            ?.call(realToken.toString())
            .catchError((_, __) {});

        if (newToken != null) {
          return headers..[HttpConstants.authorization] = 'Bearer $newToken';
        } else {
          throw RefreshTokenException();
        }
      } else {
        return headers;
      }
    }
    return headers;
  }
}

class RefreshTokenException implements Exception {
  final String message;
  RefreshTokenException({this.message = 'Auto refresh token failed'});
}
