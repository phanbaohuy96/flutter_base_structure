import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../common/utils.dart';
import 'webview_screen.dart';

export 'webview_screen.dart';

extension WebViewCoordinator on BuildContext {
  Future openWebView({
    String? url,
    String? html,
    String? title,
    String? assetPath,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    if (!kIsWeb) {
      if (kDebugMode) {
        throw UnsupportedError(
          'This web view is not supported on Web Platform',
        );
      }
      return Future.value(null);
    }
    return pushBehavior.push(
      this,
      WebViewScreen.routeName,
      arguments: WebViewArgs(
        url: url,
        html: html,
        title: title,
      ),
    );
  }
}
