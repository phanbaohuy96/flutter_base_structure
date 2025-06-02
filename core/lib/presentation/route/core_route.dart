import '../modules/dev_mode/devmode_route.dart';
import '../modules/document_viewer/document_viewer_route.dart';
import '../modules/html_viewer/htmlviewer_route.dart';
import '../modules/webview/webview_route.dart';
import 'external/image_cropper_route.dart';
import 'route.dart';

class CoreRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      ...DevModeRoute().routers(),
      ...DocumentViewerRoute().routers(),
      ...ImageCropperRoute().routers(),
      ...WebViewRoute().routers(),
      ...HtmlViewerRoute().routers(),
    ];
  }
}
