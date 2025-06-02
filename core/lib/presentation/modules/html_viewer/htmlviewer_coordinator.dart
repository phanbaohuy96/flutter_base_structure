import 'package:flutter/material.dart';

import '../../../common/utils.dart';
import 'htmlviewer_screen.dart';

extension HtmlviewerscreenCoordinator on BuildContext {
  Future openHtmlViewer({
    required String html,
    String? title,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      HtmlViewerScreen.routeName,
      arguments: HtmlviewerScreenArgs(
        html: html,
        title: title,
      ),
    );
  }
}
