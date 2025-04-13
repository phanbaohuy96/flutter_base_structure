import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:fl_media/fl_media.dart';
import 'package:flutter/material.dart';

class HorizontalImages extends StatelessWidget {
  const HorizontalImages({
    super.key,
    required this.images,
    this.visibleCount = 3,
  });

  final List<String> images;
  final int visibleCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imagesInView = images.take(
          visibleCount,
        );
        final remaining = max(images.length - visibleCount, 0);
        final itemWidth = constraints.maxWidth / visibleCount;
        return SizedBox(
          width: itemWidth * imagesInView.length,
          height: constraints.maxWidth / visibleCount,
          child: Row(
            children: [
              ...imagesInView.mapIndexed(
                (index, e) => Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: InkWell(
                    onTap: () => openImageGallery(
                      context: context,
                      images: images,
                      forcusIndex: index,
                      heroTag: '$hashCode $runtimeType $index $e',
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Builder(
                        builder: (context) {
                          final image = Hero(
                            tag: '$hashCode $runtimeType $index $e',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: ImageView(
                                source: e,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                          if (index == visibleCount - 1 && remaining > 0) {
                            return Stack(
                              children: [
                                Positioned.fill(child: image),
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black26,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '+$remaining',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return image;
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
