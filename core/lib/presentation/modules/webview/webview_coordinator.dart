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
    return pushBehavior.push(
      this,
      WebViewScreen.routeName,
      arguments: WebViewArgs(
        url: url,
        html: html,
        title: title,
      ).adaptiveArguments,
    );
  }
}
