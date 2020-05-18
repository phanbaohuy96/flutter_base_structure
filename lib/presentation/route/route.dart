import 'dart:io';

import 'package:flutter/material.dart';

import '../modules/dashboard/dashboard_screen.dart';
import '../modules/welcome/splash_screen.dart';
import 'route_list.dart';

class RouteGenerator {
  static Route buildRoutes(RouteSettings settings) {
    switch (settings.name) {
      case RouteList.initial:
        return buildRoute(
          SplashScreen(),
          settings: settings,
        );
      case RouteList.dashBoardRoute:
        return buildRoute(
          DashboardScreen(),
          settings: settings,
        );
      default:
        return buildRoute(
          const SizedBox(),
          settings: settings,
        );
    }
  }
}

Route buildRoute(Widget screen, {RouteSettings settings}) {
  if (Platform.isIOS) {
    return MaterialPageRoute(builder: (context) => screen, settings: settings);
  } else {
    return SlideLeftRoute(enterWidget: screen);
  }
}

class SlideLeftRoute extends PageRouteBuilder {
  final Widget enterWidget;
  SlideLeftRoute({this.enterWidget})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return enterWidget;
          },
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.5, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        );
}
