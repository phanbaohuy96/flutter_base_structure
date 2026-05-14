import '../../route/route.dart';
import 'document_viewer_screen.dart';

class DocumentViewerRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: DocumentViewerScreen.routeName,
        builder: (context, uri, extra) {
          return buildRequiredRouteExtra<DocumentViewerArgs>(
            extra,
            (args) => DocumentViewerScreen(args: args),
          );
        },
      ),
    ];
  }
}
