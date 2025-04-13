import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
  });

  final _rand = math.Random();
  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Retry only on certain error types or status codes
    if (_shouldRetry(err)) {
      final int retryCount = requestOptions.extra['retry_count'] ?? 1;

      if (retryCount < retries) {
        requestOptions.extra['retry_count'] = retryCount + 1;
        await Future.delayed(delay(retryCount));

        try {
          final response = await dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(e as DioException);
        }
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.badResponse &&
            err.response?.statusCode == 500;
  }

  /// Delay after [attempt] number of attempts.
  ///
  /// This is computed as `pow(2, attempt) * delayFactor`, then is multiplied by
  /// between `-randomizationFactor` and `randomizationFactor` at random.
  Duration delay(int attempt) {
    const randomizationFactor = 0.25;
    const delayFactor = Duration(milliseconds: 200);
    const maxDelay = Duration(seconds: 30);

    assert(attempt >= 0, 'attempt cannot be negative');
    if (attempt <= 0) {
      return Duration.zero;
    }
    final rf = randomizationFactor * (_rand.nextDouble() * 2 - 1) + 1;
    final exp = math.min(attempt, 31); // prevent overflows.
    final delay = delayFactor * math.pow(2.0, exp) * rf;
    return delay < maxDelay ? delay : maxDelay;
  }
}
