import 'dart:io';

import 'package:flutter/material.dart';

class ImageCropperScreen extends StatelessWidget {
  static const String routeName = '/image-cropper';
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
