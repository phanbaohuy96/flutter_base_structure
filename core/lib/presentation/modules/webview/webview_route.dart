import '../../route/route.dart';
import 'webview_screen.dart';

class WebViewRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter<WebViewArgs>(
        path: WebViewScreen.routeName,
        builder: (context, uri, extra) {
          final args = extra as WebViewArgs?;
          return WebViewScreen(
            params: args,
          );
        },
        extraFromUrlQueries: WebViewArgs.fromUrlParams,
      ),
    ];
  }
}
