import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../data/data_source/local/local_data_manager.dart';
import '../../../di/di.dart';
import 'signin/views/signin_screen.dart';

extension AuthenticationCoordinator on BuildContext {
  /// Opens the signin form, threading [returnTo] through as the post-signin
  /// destination. When the storage seam already holds a token, the form is
  /// skipped entirely and the caller is sent straight to [returnTo].
  ///
  /// Defaults to [DevModeDashboardScreen.routeName] so the template demo
  /// always lands somewhere meaningful; downstream apps pass their own
  /// post-signin route.
  Future<bool?> openSignIn({
    String? returnTo,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    final destination = returnTo ?? DevModeDashboardScreen.routeName;
    final existingToken = await injector<LocalDataManager>().token;
    if (existingToken != null) {
      await pushBehavior.push<dynamic>(this, destination);
      return true;
    }
    return pushBehavior.push<bool>(
      this,
      SignInScreen.routeName,
      arguments: SigninRouteArgs(redirectTo: destination).adaptiveArguments,
    );
  }
}
