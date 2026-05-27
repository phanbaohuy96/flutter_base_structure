import 'package:core/core.dart';
import 'package:injectable/injectable.dart';

import 'signin_route_args.dart';

/// Resolves where the sign-in flow sends a user once they are authenticated.
///
/// Owns the two decisions the template previously duplicated across the router
/// redirect and [AuthenticationCoordinator]: the default home route, and the
/// validation of a requested `?redirect=` target (reject off-site URLs and
/// loop-backs to sign-in). Both callers delegate here, so the landing policy
/// has a single source of truth.
///
/// The template binds [DefaultSignInRedirectResolver], which lands on the
/// dev-mode dashboard demo. A downstream app rebinds this contract in its
/// `AppModule` to point at its own home route — and may override [resolve] to
/// tighten or relax the redirect policy (e.g. role-based landing).
abstract class SignInRedirectResolver {
  /// Returns a safe in-app destination: [requestedRedirect] when it is a
  /// same-origin path, otherwise the app's home route.
  String resolve({String? requestedRedirect});
}

@LazySingleton(as: SignInRedirectResolver)
class DefaultSignInRedirectResolver implements SignInRedirectResolver {
  /// Where authenticated users land when no explicit redirect is requested.
  String get home => DevModeDashboardScreen.routeName;

  @override
  String resolve({String? requestedRedirect}) {
    if (requestedRedirect == null) {
      return home;
    }

    final redirectUri = Uri.tryParse(requestedRedirect);
    if (redirectUri == null ||
        redirectUri.hasScheme ||
        redirectUri.hasAuthority ||
        !redirectUri.path.startsWith('/') ||
        redirectUri.path == signInRouteName) {
      return home;
    }
    return requestedRedirect;
  }
}
