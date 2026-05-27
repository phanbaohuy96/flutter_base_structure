import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

const signInRouteName = '/signin';

class SigninRouteArgs {
  final String? redirectTo;

  const SigninRouteArgs({this.redirectTo});

  factory SigninRouteArgs.fromUrlParams(Map<String, dynamic> queryParameters) =>
      SigninRouteArgs(redirectTo: asOrNull(queryParameters['redirect']));

  dynamic get adaptiveArguments {
    if (kIsWeb) {
      if (redirectTo == null) {
        return null;
      }
      return <String, dynamic>{'redirect': redirectTo};
    }
    return this;
  }

  String toRouteLocation() {
    return Uri(
      path: signInRouteName,
      queryParameters: redirectTo == null ? null : {'redirect': redirectTo},
    ).toString();
  }
}
