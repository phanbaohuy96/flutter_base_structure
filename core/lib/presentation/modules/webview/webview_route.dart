import '../../route/route.dart';
import 'webview_screen.dart';

class WebViewRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: WebViewScreen.routeName,
        builder: (context, uri, extra) {
          final args = extra as WebViewArgs?;
          return WebViewScreen(
            params: args,
          );
        },
        verifier: (uri, extra) {
          return uri.path.startsWith(
            WebViewScreen.routeName,
          );
        },
      ),
    ];
  }
}
