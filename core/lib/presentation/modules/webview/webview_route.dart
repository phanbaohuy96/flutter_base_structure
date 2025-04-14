import 'package:flutter/material.dart';

import 'webview_screen.dart';

class WebViewRoute {
  Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        WebViewScreen.routeName: (context) {
          final args = settings.arguments as Map;
          return WebViewScreen(
            params: args['param'],
            hasBorder: args['hasBorder'],
          );
        },
      };
}
