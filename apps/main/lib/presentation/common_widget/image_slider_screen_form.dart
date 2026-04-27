import 'package:flutter/material.dart';

import 'image_slider.dart';

const _defaultImageDescriptionDecor = BoxDecoration(
  gradient: LinearGradient(
    colors: [Colors.transparent, Colors.black87],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
);

class ScreenFormWithAppbarImageSlider extends StatefulWidget {
  const ScreenFormWithAppbarImageSlider({
    super.key,
    required this.body,
    this.aspectRatio = 402 / 300,
    this.onBack,
    this.imageDescriptionBuilder,
    this.imageDescriptionDecoration,
    required this.imageUrls,
  });

  final Widget body;
  final double aspectRatio;
  final VoidCallback? onBack;
  final ImageSliderDesciptionBuilder? imageDescriptionBuilder;
  final BoxDecoration? imageDescriptionDecoration;
  final List<String> imageUrls;

  @override
  State<ScreenFormWithAppbarImageSlider> createState() =>
      _ScreenFormWithAppbarImageSliderState();
}

class _ScreenFormWithAppbarImageSliderState
    extends State<ScreenFormWithAppbarImageSlider> {
  @override
  Widget build(BuildContext context) {
    final mediaData = MediaQuery.of(context);
    final device = mediaData.size;
    final pading = mediaData.padding;
    final aspectRatio = widget.aspectRatio;
    final toolbarHeight = device.width / aspectRatio;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          forceMaterialTransparency: true,

          /// Set this is `false` for remove the padding top added
          primary: false,
          toolbarHeight: toolbarHeight,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: [
              Positioned.fill(
                child: ImageSlider(
                  images: widget.imageUrls,
                  aspectRatio: aspectRatio,
                  descriptionDecoration:
                      widget.imageDescriptionDecoration ??
                      (widget.imageDescriptionBuilder != null
                          ? _defaultImageDescriptionDecor
                          : null),
                  descriptionBuilder: widget.imageDescriptionBuilder,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: toolbarHeight - pading.top - 56,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black87,
                        Colors.black54,
                        Colors.black38,
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: pading.top,
                left: 8,
                child: IconButton(
                  onPressed: widget.onBack ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        SliverFillRemaining(hasScrollBody: true, child: widget.body),
      ],
    );
  }
}
