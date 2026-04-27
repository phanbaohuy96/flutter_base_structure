import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

typedef ImageSliderDesciptionBuilder =
    Widget Function(BuildContext context, int index);

class ImageSlider extends StatefulWidget {
  const ImageSlider({
    super.key,
    required this.images,
    this.aspectRatio = 1.5,
    this.descriptionBuilder,
    this.descriptionDecoration = const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.black12,
          Colors.black26,
          Colors.black54,
          Colors.black87,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  });

  final List<String> images;
  final double aspectRatio;
  final ImageSliderDesciptionBuilder? descriptionBuilder;
  final BoxDecoration? descriptionDecoration;

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> with StorageServiceMixin {
  var _currentImageIndex = 0;
  late final heroTag = '$runtimeType-$hashCode';
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Hero(
          tag: heroTag,
          child: CarouselSlider(
            options: CarouselOptions(
              aspectRatio: widget.aspectRatio,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
            items: widget.images.mapIndex((image, idx) {
              return InkWell(
                onTap: () => onTapImage(image, idx),
                child: ImageViewWrapper.item(
                  image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            }).toList(),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            constraints: const BoxConstraints(minHeight: 91),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: widget.descriptionDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.descriptionBuilder != null) ...[
                  Expanded(
                    child: widget.descriptionBuilder!(
                      context,
                      _currentImageIndex,
                    ),
                  ),
                  const Gap(12),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    '${_currentImageIndex + 1}/${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void onTapImage(String image, int idx) {
    openImageGallery(
      context: context,
      images: widget.images.map((e) {
        if (e.isUrl) {
          return e;
        }
        return storageAssetProvider.url(e);
      }).toList(),
      heroTag: heroTag,
      focusIndex: idx,
    );
  }
}
