import '../../route/route.dart';
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
        builder: (context, uri, extra) {
          return const DevModeDashboardScreen();
        },
      ),
      CustomRouter(
        path: LogViewerScreen.routeName,
        builder: (context, uri, extra) {
          return const LogViewerScreen();
        },
      ),
      CustomRouter(
        path: NetworkLogViewerScreen.routeName,
        builder: (context, uri, extra) {
          return const NetworkLogViewerScreen();
        },
      ),
      CustomRouter(
        path: NetworkLogDetailScreen.routeName,
        builder: (context, uri, extra) {
          return NetworkLogDetailScreen(
            log: extra,
          );
        },
      ),
      CustomRouter(
        path: DesignSystemScreen.routeName,
        builder: (context, uri, extra) {
          return const DesignSystemScreen();
        },
      ),
    ];
  }
}
