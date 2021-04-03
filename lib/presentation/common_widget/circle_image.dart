import 'dart:math';
import 'package:flutter/material.dart';

import 'cache_network_image_wrapper.dart';

class CircleImageOutline extends StatelessWidget {
  final double diameter;
  final String image;
  final Color borderColor;
  final double borderWidth;
  final bool isUrlImage;
  final double padding;
  final Color backgroundColor;

  const CircleImageOutline({
    Key key,
    this.diameter,
    this.image,
    this.borderColor,
    this.borderWidth = 4,
    this.isUrlImage = false,
    this.padding = 0,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      key: image?.isNotEmpty == true ? ValueKey(image) : null,
      height: diameter,
      width: diameter,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(diameter),
        ),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        color: backgroundColor,
      ),
      child: CircleImage(
        child: isUrlImage
            ? CachedNetworkImageWrapper.avatar(
                url: image ?? '',
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
              )
            : Image.asset(
                image,
                width: diameter,
                height: diameter,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}

class CircleImage extends StatelessWidget {
  final Widget child;
  const CircleImage({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(clipper: CircleClip(), child: child);
  }
}

class CircleClip extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: min(size.width, size.height) / 2,
    );
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
