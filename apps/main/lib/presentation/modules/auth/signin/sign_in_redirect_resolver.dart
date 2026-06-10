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
/// dev-mode dashboard demo. A downstream app customises the landing route by
/// extending this base and overriding [home] — the redirect validation in
/// [resolve] is inherited, so the open-redirect protection cannot be dropped by
/// accident. Apps that need a different policy (e.g. role-based landing) may
/// also override [resolve], then rebind the contract in their `AppModule`.
abstract class SignInRedirectResolver {
  /// Where authenticated users land when no explicit redirect is requested.
  ///
  /// This is the one knob most apps override.
  String get home;

  /// Returns a safe in-app destination: [requestedRedirect] when it is a
  /// same-origin path, otherwise [home].
  ///
  /// The validation lives here, shared by every subclass: anything that could
  /// escape the app (a scheme, an authority, a non-rooted path) or loop the
  /// user back to sign-in falls back to [home]. This is a security boundary —
  /// override it only to tighten or specialise the policy.
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

@LazySingleton(as: SignInRedirectResolver)
class DefaultSignInRedirectResolver extends SignInRedirectResolver {
  @override
  String get home => DevModeDashboardScreen.routeName;
}
