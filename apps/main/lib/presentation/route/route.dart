import 'package:collection/collection.dart';
import 'package:core/core.dart';

import '../modules/auth/signin/views/signin_screen.dart';
import '../modules/page_not_found/page_note_found.dart';
import 'route_providers.config.dart';

GoRouter buildAppRouter(AppGlobalBloc appBloc) {
  return buildFlGoRouter(
    routeProviders: buildAppRouteProviders(),
    initialLocation: SignInScreen.routeName,
    navigatorKey: globalNavigatorKey,
    observers: [myNavigatorObserver],
    redirect: (_, state) {
      return _resolveLocaleRedirect(appBloc, state.uri);
    },
    errorBuilder: (_, __) => const NotFoundPage(),
  );
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
