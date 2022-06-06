import 'package:flutter/material.dart';

import '../../route/route_list.dart';
import 'splash/splash_screen.dart';

class WelcomeRoute {
  static Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        RouteList.initial: (context) => SplashScreen(),
      };
}
