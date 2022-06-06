import 'package:flutter/material.dart';

import '../../route/route_list.dart';
import 'log_viewer_screen.dart';

class LogViewerRoute {
  static Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        RouteList.logViewer: (context) => const LogViewerScreen(),
      };
}
