import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../modules/auth/authentication_route.dart';

@injectable
class RouteGenerator {
  RouteGenerator();

  List<CustomRouter> get routers => [
        ...CoreRoute().routers(),
        ...AuthenticationRoute().routers(),
      ];

  Route<dynamic>? generateRoute(
    RouteSettings settings, {
    bool supportUnknownRoute = true,
  }) {
    preResolveRouteParams(settings);

    final _builder = findRouteBuilder(settings);
    if (_builder == null && supportUnknownRoute != true) {
      return null;
    }

    if ([].any((e) => e == settings.name)) {
      return buildFaderPageRoute(
        _builder ?? (context) => const UnsupportedPage(),
        settings: settings,
      );
    }

    return buildRoute(
      _builder ?? (context) => const UnsupportedPage(),
      settings: settings,
    );
  }

  WidgetBuilder? findRouteBuilder(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');
    if (uri == null) {
      return null;
    }

    for (final route in routers) {
      if (route.canLaunch(uri, settings.arguments)) {
        return (context) => route.build(
              context,
              uri,
              settings.arguments,
            );
      }
    }
    return null;
  }

  void preResolveRouteParams(RouteSettings settings) {
    final uri = Uri.tryParse(settings.name ?? '');

    if (uri == null) {
      return;
    }
  }
}

Route buildFaderPageRoute<T>(WidgetBuilder builder, {RouteSettings? settings}) {
  return FaderPageRoute<T>(
    builder: (context) => TextScaleFixed(
      child: builder(context),
    ),
    settings: settings,
  );
}

Route buildRoute<T>(WidgetBuilder builder, {RouteSettings? settings}) {
  if (kIsWeb) {
    return MaterialPageRoute<T>(
      builder: (context) => TextScaleFixed(
        child: builder(context),
      ),
      settings: settings,
    );
  }
  return CupertinoPageRoute<T>(
    builder: (context) => TextScaleFixed(
      child: builder(context),
    ),
    settings: settings,
  );
}

class FaderPageRoute<T> extends PageRoute<T> {
  FaderPageRoute({
    required this.builder,
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String get barrierLabel => '';

  final WidgetBuilder builder;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: builder(context),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}
