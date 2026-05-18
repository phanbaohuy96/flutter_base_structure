import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:fl_ui/fl_ui.dart';
import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';

import 'hero_widget.dart';
import 'image_zoom.dart';

void openImageGallery({
  required BuildContext context,
  required List<String> images,
  int forcusIndex = 0,
  String? heroTag,
  bool rootNavigator = false,
  Function(String url)? onDownload,
}) {
  Navigator.of(context, rootNavigator: rootNavigator).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      pageBuilder: (c, a1, a2) => Material(
        color: Colors.transparent,
        child: ImageGalleryWidget(
          images: images,
          forcusIndex: forcusIndex,
          heroTag: heroTag,
          onDownload: onDownload,
        ),
      ),
      transitionsBuilder: (c, anim, a2, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );
}

class ImageGalleryWidget extends StatefulWidget {
  const ImageGalleryWidget({
    super.key,
    required this.images,
    this.forcusIndex = 0,
    this.heroTag,
    this.onDownload,
  });

  final List<String> images;
  final int forcusIndex;
  final String? heroTag;
  final Function(String url)? onDownload;

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  late final PageController _pageController;

  final slidePagekey = GlobalKey<ExtendedImageSlidePageState>();

  @override
  void initState() {
    _pageController = PageController(
      initialPage: widget.forcusIndex,
    );
    super.initState();
  }

  List<String> get images => widget.images;

  @override
  Widget build(BuildContext context) {
    final pageCount = images.length;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: ExtendedImageSlidePage(
        key: slidePagekey,
        slideAxis: SlideAxis.both,
        slideType: SlideType.onlyImage,
        slidePageBackgroundHandler: (offset, pageSize) {
          return defaultSlidePageBackgroundHandler(
            offset: offset,
            pageSize: pageSize,
            color: Colors.black,
            pageGestureAxis: SlideAxis.both,
          );
        },
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SafeArea(
                    child: PageView.builder(
                      itemCount: pageCount,
                      controller: _pageController,
                      itemBuilder: (context, index) {
                        final image = ImageZoom(
                          url: images[index],
                        );
                        if (widget.heroTag.isNotNullOrEmpty) {
                          return HeroWidget(
                            tag: widget.heroTag!,
                            slideType: SlideType.wholePage,
                            slidePagekey: slidePagekey,
                            child: image,
                          );
                        }
                        return image;
                      },
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: max(MediaQuery.of(context).padding.bottom, 16),
              right: 0,
              left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
                ),
                child: PageIndicatorWidget(
                  countItem: pageCount,
                  controller: _pageController,
                  color: Colors.grey,
                  size: const Size(8, 8),
                  activeSize: const Size(8, 8),
                  colorActive: Colors.white,
                  initialPage: widget.forcusIndex,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top,
              right: 0,
              child: Row(
                children: [
                  if (widget.onDownload != null)
                    IconButton(
                      onPressed: () => widget.onDownload!(
                        images[_pageController.page!.toInt()],
                      ),
                      icon: const Icon(
                        Icons.save_alt_outlined,
                        color: Colors.white,
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
