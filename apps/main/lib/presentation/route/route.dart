import 'package:collection/collection.dart';
import 'package:core/core.dart';

import '../../di/di.dart';
import '../modules/auth/authentication_coordinator.dart';
import '../modules/auth/signin/sign_in_redirect_resolver.dart';
import '../modules/auth/signin/signin_route_args.dart';
import '../modules/auth/signin/views/signin_screen.dart';
import '../modules/page_not_found/page_note_found.dart';
import 'auth_gate_route_interceptor.dart';
import 'route_providers.config.dart';

GoRouter buildAppRouter(AppGlobalBloc appBloc) {
  final localDataManager = injector<CoreLocalDataManager>();
  final redirectResolver = injector<SignInRedirectResolver>();

  return buildFlGoRouter(
    routeProviders: buildAppRouteProviders(),
    routeProviderInterceptors: [
      AuthGateRouteInterceptor(localDataManager: localDataManager),
    ],
    initialLocation: SignInScreen.routeName,
    navigatorKey: globalNavigatorKey,
    observers: [myNavigatorObserver],
    redirect: (_, state) {
      return _resolveLocaleRedirect(appBloc, state.uri) ??
          _resolveAuthenticatedSignInRedirect(
            localDataManager,
            redirectResolver,
            state.uri,
          );
    },
    errorBuilder: (context, __) => NotFoundPage(
      onBackToWelcomePage: () {
        context.openSignIn(
          localDataManager: localDataManager,
          pushBehavior: PushNamedAndRemoveUntilBehavior.removeAll(),
        );
      },
    ),
  );
}

String? _resolveAuthenticatedSignInRedirect(
  CoreLocalDataManager localDataManager,
  SignInRedirectResolver redirectResolver,
  Uri uri,
) {
  if (!localDataManager.isAuthenticated || uri.path != SignInScreen.routeName) {
    return null;
  }

  final requestedRedirect = SigninRouteArgs.fromUrlParams(
    uri.queryParameters,
  ).redirectTo;
  return redirectResolver.resolve(requestedRedirect: requestedRedirect);
}

String? _resolveLocaleRedirect(AppGlobalBloc appBloc, Uri uri) {
  final queryParameters = uri.queryParameters;
  final languageCode = queryParameters['hl'] ?? queryParameters['lang'];
  final locale = AppLocale.supportedLocales.firstWhereOrNull((locale) {
    return locale.languageCode == languageCode?.toLowerCase();
  });

  if (locale == null) {
    return null;
  }

  if (appBloc.state.locale != locale) {
    appBloc.changeLocale(locale);
  }

  final nextQueryParameters = Map<String, String>.from(queryParameters)
    ..remove('hl')
    ..remove('lang');
  final nextUri = uri.replace(queryParameters: nextQueryParameters);
  final nextLocation = nextUri.toString();

  if (nextLocation == uri.toString()) {
    return null;
  }

  return nextLocation;
}
