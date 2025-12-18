import 'package:flutter/material.dart';

import '../../../common/services/network_log/network_log_service.dart';
import '../../../common/utils.dart';
import 'app_config/app_config_screen.dart';
import 'dashboard/dev_mode_dashboard_screen.dart';
import 'design_system/design_system_screen.dart';
import 'log_viewer/log_viewer_screen.dart';
import 'log_viewer/network/network_log_detail_screen.dart';
import 'log_viewer/network/network_log_viewer_screen.dart';

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

  Future<T?> openNetWorkLogViewer<T>({
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      NetworkLogViewerScreen.routeName,
    );
  }

  Future<T?> openNetworkLogDetail<T>({
    required NetworkLog log,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      NetworkLogDetailScreen.routeName,
      arguments: log,
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

  Future<T?> openAppConfig<T>({
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      AppConfigScreen.routeName,
    );
  }
}
