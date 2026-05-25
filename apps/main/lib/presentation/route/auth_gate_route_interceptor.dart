import 'package:core/core.dart';

import '../modules/auth/authentication_route.dart';
import '../modules/auth/signin/signin_route_args.dart';
import '../modules/auth/signin/views/signin_screen.dart';

/// The canonical demonstration of [RouteProviderInterceptor]: gates every
/// route provider except the auth provider itself behind a token check,
/// redirecting unauthenticated callers to [SignInScreen] with a
/// `?redirect=` query so the original destination is preserved.
///
/// Reads auth state synchronously via [CoreLocalDataManager.isAuthenticated].
/// Bootstrap the cache by `await`-ing `localDataManager.token` once during
/// app init.
///
/// Downstream apps can replace [isProtected] to opt particular providers in
/// or out, or compose this with additional interceptors.
class AuthGateRouteInterceptor extends RouteProviderInterceptor {
  AuthGateRouteInterceptor({
    required this.localDataManager,
    this.isProtected = _defaultIsProtected,
  });

  final CoreLocalDataManager localDataManager;
  final bool Function(IRoute provider) isProtected;

  static bool _defaultIsProtected(IRoute provider) =>
      provider is! AuthenticationRoute;

  @override
  void onResolve(
    RouteProviderResolution resolution,
    RouteProviderInterceptorHandler handler,
  ) {
    if (!isProtected(resolution.provider)) {
      handler.next(resolution);
      return;
    }

    final guardedRouters = resolution.routers.map(_guardRouter).toList();
    handler.next(resolution.copyWith(routers: guardedRouters));
  }

  CustomRouter _guardRouter(CustomRouter router) {
    final existingRedirect = router.redirect;
    return router.copyWith(
      redirect: (context, state) {
        if (localDataManager.isAuthenticated) {
          return existingRedirect?.call(context, state);
        }
        return SigninRouteArgs(
          redirectTo: state.uri.toString(),
        ).toRouteLocation();
      },
    );
  }
}
