import 'dart:io';

import 'package:fl_media/fl_media.dart';

import '../route.dart';

class ImageCropperRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: ImageCropperScreen.routeName,
        builder: (context, uri, extra) {
          return buildRequiredRouteExtra<File>(
            extra,
            (imagefile) => ImageCropperScreen(imagefile: imagefile),
          );
        },
      ),
    ];
  }
}
