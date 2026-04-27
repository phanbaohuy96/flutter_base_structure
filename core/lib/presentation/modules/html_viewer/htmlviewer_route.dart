import '../../route/route.dart';
import 'htmlviewer_screen.dart';

class HtmlViewerRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: HtmlViewerScreen.routeName,
        builder: (context, uri, extra) {
          final args = extra as HtmlviewerScreenArgs;
          return HtmlViewerScreen(params: args);
        },
      ),
    ];
  }
}
