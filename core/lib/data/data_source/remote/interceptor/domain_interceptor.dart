import 'dart:async';

import 'package:dio/dio.dart';

import '../../../../core.dart';

class DomainInterceptor extends Interceptor {
  final CoreLocalDataManager localDataManager;

  DomainInterceptor({required this.localDataManager});

  @override
  Future onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final domain = localDataManager.domainReplacement;
    if (domain != null) {
      options.baseUrl = domain;
    }
    super.onRequest(options, handler);
  }
}
