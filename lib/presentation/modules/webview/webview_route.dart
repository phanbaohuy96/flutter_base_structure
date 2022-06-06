import 'package:flutter/material.dart';

import '../../route/route_list.dart';
import 'webview_screen.dart';

class WebviewRoute {
  static Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        RouteList.webview: (context) => WebviewScreen(
              args: settings.arguments as WebviewArgs,
            ),
      };
}
