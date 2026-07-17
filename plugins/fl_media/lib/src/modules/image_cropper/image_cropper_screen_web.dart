import 'dart:io';

import 'package:flutter/material.dart';

class ImageCropperScreen extends StatelessWidget {
  static const String routeName = '/image-cropper';
  final File imagefile;

  const ImageCropperScreen({
    super.key,
    required this.imagefile,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
