import 'package:flutter/material.dart';

import '../../../common/utils.dart';
import 'dashboard/dev_mode_dashboard_screen.dart';
import 'design_system/design_system_screen.dart';
import 'log_viewer/log_viewer_screen.dart';

extension DevModeCoordinator on BuildContext {
  Future<T?> openDevMode<T>({
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      DevModeDashboardScreen.routeName,
    );
  }

  Future<T?> openLogViewer<T>({
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      LogViewerScreen.routeName,
    );
  }

  Future<T?> viewDesignSystem<T>({
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      DesignSystemScreen.routeName,
    );
  }
}
