import 'package:gql/ast.dart';
import 'package:gql/language.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../utils.dart';

class GraphqlProvider {
  final GraphQLClient _graphQLClient;
  final int timeout = 120;

  GraphqlProvider(this._graphQLClient);

  Future<T> query<T>(
    String query,
    T Function(dynamic) parseFunction,
    String? keyPath, {
    Map<String, dynamic> variables = const {},
  }) async {
    _graphQLClient.cache.store.reset();
    final result = await _graphQLClient
        .query(
          QueryOptions(
            document: parseNode(
              query,
            ),
            variables: variables,
          ),
        )
        .timeout(
          Duration(
            seconds: timeout,
          ),
        );

    if (result.hasException) {
      throw result.exception!;
    }
    LogUtils.d(result.data);
    final returning = (keyPath != null) ? result.data![keyPath] : result.data;
    return parseFunction.call(returning);
  }

  Future<List<T>?> queryList<T>(
    String query,
    T Function(dynamic) parseFunction,
    String? keyPath, {
    Map<String, dynamic> variables = const {},
  }) async {
    _graphQLClient.cache.store.reset();
    final result = await _graphQLClient
        .query(
          QueryOptions(
            document: parseNode(
              query,
            ),
            variables: variables,
          ),
        )
        .timeout(
          Duration(
            seconds: timeout,
          ),
        );
    if (result.hasException) {
      throw result.exception!;
    }

    final returning = _dataByPath(result.data, keyPath);
    LogUtils.d(returning);

    if (returning is List) {
      return returning.map((e) => parseFunction(e)).toList();
    }
    return null;
  }

  Future<T> mutate<T>(
    String query,
    T Function(dynamic) parseFunction,
    String? keyPath, {
    Map<String, dynamic> variables = const {},
  }) async {
    _graphQLClient.cache.store.reset();
    final result = await _graphQLClient
        .mutate(
          MutationOptions(
            document: parseNode(
              query,
            ),
            variables: variables,
          ),
        )
        .timeout(
          Duration(
            seconds: timeout,
          ),
        );
    if (result.hasException) {
      throw result.exception!;
    }
    LogUtils.d(result.data);
    final returning = _dataByPath(result.data, keyPath);
    return parseFunction.call(returning);
  }

  Stream<T> subscribe<T>(
    String document,
    T Function(dynamic) parseFunction,
    String? keyPath,
  ) {
    LogUtils.d('Subscription $document');
    _graphQLClient
        .subscribe(SubscriptionOptions(document: gql(document)))
        .listen((event) {
      if (event.hasException) {
        LogUtils.e('Subscription $document failed ${event.exception}');
      }
    });
    return _graphQLClient
        .subscribe(SubscriptionOptions(document: parseNode(document)))
        .where((event) => event.data != null)
        .map((event) {
      final data = _dataByPath(event.data, keyPath);
      return data.map((e) => parseFunction(e)).first;
    });
  }

  DocumentNode parseNode(String query) => transform(parseString(query), []);

  dynamic _dataByPath(Map<String, dynamic>? data, String? path) {
    if (data == null || path == null) {
      return data;
    }
    final keys = path.split('.');
    dynamic result = data;
    for (final key in keys) {
      result = result[key];
    }
    return result;
  }
}
