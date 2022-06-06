import 'package:flutter/material.dart';

import '../../route/route_list.dart';
import 'dashboard_screen.dart';

class DashboardRoute {
  static Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        RouteList.dashBoardRoute: (context) => DashboardScreen(),
      };
}
