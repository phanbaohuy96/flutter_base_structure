import 'dart:io';

import 'package:fl_navigation/fl_navigation.dart';
import 'package:flutter/material.dart';

import 'image_cropper.dart';

extension ImageCropperCoordinator on BuildContext {
  Future<File?> cropImage({
    required File imagefile,
    PushBehavior pushBehavior = const PushNamedBehavior(),
  }) async {
    return pushBehavior.push(
      this,
      ImageCropperScreen.routeName,
      arguments: imagefile,
    );
  }
}
