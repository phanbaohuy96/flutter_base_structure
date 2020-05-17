import 'package:flutter/material.dart';

import '../ui/dashboard/dashboard_screen.dart';
import '../ui/welcome/splash_screen.dart';
import 'route_list.dart';

class RouteGenerator {
  static Route buildRoutes(RouteSettings settings) {
    switch (settings.name) {
      case RouteList.initial:
        return buildRoute(settings, SplashScreen());
      case RouteList.dashBoardRoute:
        return buildRoute(
          settings,
          DashboardScreen(),
        );
      default:
        return buildRoute(
          settings,
          const SizedBox(),
        );
    }
  }
}

MaterialPageRoute buildRoute(RouteSettings settings, Widget builder) {
  return MaterialPageRoute(
    settings: settings,
    builder: (BuildContext context) => builder,
  );
}

MaterialPageRoute buildDialog(RouteSettings settings, Widget builder) {
  return MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
      fullscreenDialog: true);
}
