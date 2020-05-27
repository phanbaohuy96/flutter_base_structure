import 'package:flutter/cupertino.dart';
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
  return CupertinoPageRoute(builder: (context) => screen, settings: settings);
}
