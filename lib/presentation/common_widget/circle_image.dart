import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../../common/utils/extensions.dart';
import 'cache_network_image_wrapper.dart';

class CircleImageOutline extends StatefulWidget {
  final double diameter;
  final String image;
  final Color borderColor;
  final double borderWidth;
  final double padding;
  final Color backgroundColor;

  const CircleImageOutline({
    Key? key,
    this.diameter = 96,
    required this.image,
    this.borderColor = Colors.white,
    this.borderWidth = 4,
    this.padding = 0,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  State<CircleImageOutline> createState() => _CircleImageOutlineState();
}

class _CircleImageOutlineState extends State<CircleImageOutline> {
  final _searchController = BehaviorSubject<Uint8List>();
  @override
  void didUpdateWidget(covariant CircleImageOutline oldWidget) {
    if (widget.image.isLocalUrl) {
      if (_searchController.valueOrNull == null ||
          oldWidget.image != widget.image) {
        _searchController.add(File(widget.image).readAsBytesSync());
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    if (widget.image.isLocalUrl) {
      _searchController.add(File(widget.image).readAsBytesSync());
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(widget.image),
      height: widget.diameter,
      width: widget.diameter,
      constraints: BoxConstraints(
        maxHeight: widget.diameter,
        maxWidth: widget.diameter,
      ),
      padding: EdgeInsets.all(widget.padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(widget.diameter / 2),
        ),
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        color: widget.backgroundColor,
      ),
      child: CircleImage(
        child: Builder(builder: (context) {
          if (widget.image.isEmpty) {
            return Icon(
              Icons.person,
              size: widget.diameter,
            );
          }
          if (widget.image.isLocalUrl) {
            return StreamBuilder<Uint8List>(
              stream: _searchController.stream,
              initialData: _searchController.valueOrNull,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Icon(
                    Icons.person,
                    size: widget.diameter,
                  );
                }
                return Image(
                  image: MemoryImage(snapshot.data!),
                  width: widget.diameter,
                  height: widget.diameter,
                  fit: BoxFit.cover,
                );
              },
            );
          }
          if (widget.image.isUrl) {
            return CachedNetworkImageWrapper.avatar(
              url: widget.image,
              width: widget.diameter,
              height: widget.diameter,
              fit: BoxFit.cover,
            );
          }
          return Image.asset(
            widget.image,
            width: widget.diameter,
            height: widget.diameter,
            fit: BoxFit.cover,
          );
        }),
      ),
    );
  }
}

class CircleImage extends StatelessWidget {
  final Widget child;

  const CircleImage({Key? key, required this.child}) : super(key: key);

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
