import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../di/di.dart';
import 'signin/sign_in_redirect_resolver.dart';
import 'signin/signin_route_args.dart';

extension AuthenticationCoordinator on BuildContext {
  /// Opens the signin form, threading [returnTo] through as the post-signin
  /// destination. When the storage seam already holds a token the form is
  /// skipped and the caller is sent straight to the destination.
  ///
  /// [redirectResolver] resolves and validates the destination; it defaults to
  /// the bound [SignInRedirectResolver] and is injectable for tests.
  Future<bool?> openSignIn({
    required CoreAppPreferenceData localDataManager,
    String? returnTo,
    PushBehavior pushBehavior = const PushNamedBehavior(),
    SignInRedirectResolver? redirectResolver,
  }) async {
    final resolver = redirectResolver ?? injector<SignInRedirectResolver>();
    final destination = resolver.resolve(requestedRedirect: returnTo);
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
    SignInRedirectResolver? redirectResolver,
  }) {
    final resolver = redirectResolver ?? injector<SignInRedirectResolver>();
    return pushBehavior.push<bool>(
      this,
      resolver.resolve(requestedRedirect: returnTo),
    );
  }
}
