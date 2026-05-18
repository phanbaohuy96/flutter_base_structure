import 'package:flutter/material.dart';

import 'document_viewer_screen.dart';

class DocumentViewerRoute {
  Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        DocumentViewerScreen.routeName: (context) {
          return DocumentViewerScreen(
            args: settings.arguments as DocumentViewerArgs,
          );
        },
      };
}
