import 'dart:io';

import 'package:flutter/material.dart';

class ImageCropperScreen extends StatelessWidget {
  static String routeName = '/image_cropper';
  final File imagefile;

  const ImageCropperScreen({
    Key? key,
    required this.imagefile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
