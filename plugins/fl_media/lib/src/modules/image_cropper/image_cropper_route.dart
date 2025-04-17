import 'dart:io';

import 'package:flutter/material.dart';

import 'image_cropper.dart';

class ImageCropperRoute {
  Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        ImageCropperScreen.routeName: (context) {
          return ImageCropperScreen(
            imagefile: settings.arguments as File,
          );
        },
      };
}
