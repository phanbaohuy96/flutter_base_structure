import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'signin/signin_route_args.dart';

extension AuthenticationCoordinator on BuildContext {
  /// Opens the signin form, threading [returnTo] through as the post-signin
  /// destination. When the storage seam already holds a token the form is
  /// skipped and the caller is sent straight to the destination.
  Future<bool?> openSignIn({
    required CoreAppPreferenceData localDataManager,
    String? returnTo,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    final destination = _signInDestination(returnTo);
    if (localDataManager.isAuthenticated) {
      await pushBehavior.push<dynamic>(this, destination);
      return true;
    }
    return pushBehavior.push<bool>(
      this,
      signInRouteName,
      arguments: SigninRouteArgs(redirectTo: destination).adaptiveArguments,
    );
  }

  /// Navigates to the post-signin destination, replacing the signin route so
  /// it drops out of the back stack. Call from the success callback once the
  /// session is persisted.
  Future<bool?> completeSignIn({
    String? returnTo,
    PushBehavior pushBehavior = const PushReplacementNamedBehavior(),
  }) {
    return pushBehavior.push<bool>(this, _signInDestination(returnTo));
  }
}

/// Resolves where signin sends the user, defaulting to the template demo
/// dashboard when the caller has no explicit [returnTo].
String _signInDestination(String? returnTo) {
  return returnTo ?? DevModeDashboardScreen.routeName;
}
