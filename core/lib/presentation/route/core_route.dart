import 'package:fl_navigation/fl_navigation.dart';

import '../../domain/entity/config.dart';
import '../modules/dev_mode/dev_mode_route.dart';
import '../modules/document_viewer/document_viewer_route.dart';
import '../modules/html_viewer/htmlviewer_route.dart';
import '../modules/webview/webview_route.dart';
import 'external/image_cropper_route.dart';

@FlRouteProvider(isRoot: true)
class CoreRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      if (Config.instance.appConfig.isDevBuild ||
          Config.instance.appConfig.isStagBuild)
        ...DevModeRoute().routers(),
      ...DocumentViewerRoute().routers(),
      ...ImageCropperRoute().routers(),
      ...WebViewRoute().routers(),
      ...HtmlViewerRoute().routers(),
    ];
  }
}
