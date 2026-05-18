import 'package:fl_media/fl_media.dart';
import 'package:flutter/material.dart';

import '../modules/dev_mode/devmode_route.dart';
import '../modules/document_viewer/document_viewer_route.dart';
import '../modules/webview/webview_route.dart';

class CoreRoute {
  Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        ...DevModeRoute().getAll(settings),
        ...DocumentViewerRoute().getAll(settings),
        ...ImageCropperRoute().getAll(settings),
        ...WebViewRoute().getAll(settings),
      };
}
