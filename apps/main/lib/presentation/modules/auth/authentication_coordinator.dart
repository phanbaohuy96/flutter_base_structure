import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'signin/signin_route_args.dart';

extension AuthenticationCoordinator on BuildContext {
  Future<bool?> openSignIn({
    required CoreAppPreferenceData localDataManager,
    String? returnTo,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    final destination = signInDestination(returnTo);
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

  Future<bool?> completeSignIn({
    String? returnTo,
    PushBehavior pushBehavior = const PushReplacementNamedBehavior(),
  }) {
    return pushBehavior.push<bool>(this, signInDestination(returnTo));
  }
}

String signInDestination(String? returnTo) {
  return returnTo ?? DevModeDashboardScreen.routeName;
}
