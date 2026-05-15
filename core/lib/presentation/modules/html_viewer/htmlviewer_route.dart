import '../../route/route.dart';
import 'htmlviewer_screen.dart';

class HtmlViewerRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: HtmlViewerScreen.routeName,
        name: HtmlViewerScreen.routeName,
        builder: (context, uri, extra) {
          return buildRequiredRouteExtra<HtmlviewerScreenArgs>(
            extra,
            (args) => HtmlViewerScreen(params: args),
          );
        },
      ),
    ];
  }
}
