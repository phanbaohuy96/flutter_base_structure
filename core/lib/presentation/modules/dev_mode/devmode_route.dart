import 'package:flutter/material.dart';

import 'dashboard/dev_mode_dashboard_screen.dart';
import 'design_system/design_system_screen.dart';
import 'log_viewer/log_viewer_screen.dart';

class DevModeRoute {
  Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        DevModeDashboardScreen.routeName: (context) {
          return const DevModeDashboardScreen();
        },
        LogViewerScreen.routeName: (context) {
          return const LogViewerScreen();
        },
        DesignSystemScreen.routeName: (context) {
          return const DesignSystemScreen();
        },
      };
}
