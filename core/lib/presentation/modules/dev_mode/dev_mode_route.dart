import '../../../common/services/network_log/network_log_service.dart';
import '../../route/route.dart';
import 'app_config/app_config_screen.dart';
import 'dashboard/dev_mode_dashboard_screen.dart';
import 'design_system/design_system_screen.dart';
import 'log_viewer/log_viewer_screen.dart';
import 'log_viewer/network/network_log_detail_screen.dart';
import 'log_viewer/network/network_log_viewer_screen.dart';

class DevModeRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: DevModeDashboardScreen.routeName,
        name: DevModeDashboardScreen.routeName,
        builder: (context, uri, extra) {
          return const DevModeDashboardScreen();
        },
      ),
      CustomRouter(
        path: LogViewerScreen.routeName,
        name: LogViewerScreen.routeName,
        builder: (context, uri, extra) {
          return const LogViewerScreen();
        },
      ),
      CustomRouter(
        path: NetworkLogViewerScreen.routeName,
        name: NetworkLogViewerScreen.routeName,
        builder: (context, uri, extra) {
          return const NetworkLogViewerScreen();
        },
      ),
      CustomRouter(
        path: NetworkLogDetailScreen.routeName,
        name: NetworkLogDetailScreen.routeName,
        builder: (context, uri, extra) {
          return buildRequiredRouteExtra<NetworkLog>(
            extra,
            (log) => NetworkLogDetailScreen(log: log),
          );
        },
      ),
      CustomRouter(
        path: DesignSystemScreen.routeName,
        name: DesignSystemScreen.routeName,
        builder: (context, uri, extra) {
          return const DesignSystemScreen();
        },
      ),
      CustomRouter(
        path: AppConfigScreen.routeName,
        name: AppConfigScreen.routeName,
        builder: (context, uri, extra) {
          return const AppConfigScreen();
        },
      ),
    ];
  }
}
