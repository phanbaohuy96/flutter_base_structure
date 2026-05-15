import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../modules/auth/signin/views/signin_screen.dart';
import '../modules/page_not_found/page_note_found.dart';
import 'route_providers.config.dart';

GoRouter buildAppRouter(BuildContext context) {
  return buildFlGoRouter(
    routeProviders: buildAppRouteProviders(),
    initialLocation: SignInScreen.routeName,
    navigatorKey: globalNavigatorKey,
    observers: [myNavigatorObserver],
    redirect: (redirectContext, state) {
      return _resolveLocaleRedirect(context, state.uri);
    },
    errorBuilder: (_, __) => const NotFoundPage(),
  );
}

String? _resolveLocaleRedirect(BuildContext context, Uri uri) {
  final queryParameters = uri.queryParameters;
  final languageCode = queryParameters['hl'] ?? queryParameters['lang'];
  final locale = AppLocale.supportedLocales.firstWhereOrNull((locale) {
    return locale.languageCode == languageCode?.toLowerCase();
  });

  if (locale == null) {
    return null;
  }

  final appBloc = context.read<AppGlobalBloc>();
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
