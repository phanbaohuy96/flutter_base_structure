import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:extended_image/extended_image.dart';
import 'package:fl_ui/fl_ui.dart';
import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart' as svg_provider;

typedef ImageViewErrorBuilder =
    Widget Function(
      BuildContext context,
      Object? error,
      StackTrace? stackTrace,
    );

class ImageView extends StatelessWidget {
  const ImageView({
    Key? key,
    required this.source,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.alignment = Alignment.center,
    this.placeHolder,
    this.errorPlaceHolder,
    this.package,
    this.loadingRadius,
    this.cacheWidth,
    this.cacheHeight,
    this.errorBuilder,
  });

  final String source;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final Alignment alignment;
  final String? placeHolder;
  final String? errorPlaceHolder;
  final String? package;
  final double? loadingRadius;
  final int? cacheWidth;
  final int? cacheHeight;
  final ImageViewErrorBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return _buildImage(
      context,
      source.isEmpty ? placeHolder ?? '' : source,
    );
  }

  Widget _buildImage(BuildContext context, String image) {
    if (image.isEmpty) {
      if (placeHolder.isNotNullOrEmpty) {
        return ImageView(
          source: placeHolder!,
          width: width,
          height: height,
          fit: fit,
          color: color,
          alignment: alignment,
          package: package,
          errorBuilder: errorBuilder,
        );
      }
      return errorBuilder?.call(
            context,
            Exception('Image not found: $source'),
            StackTrace.current,
          ) ??
          SizedBox(
            width: width,
            height: height,
          );
    }

    // Check if image is AVIF format
    final isAvif = image.toLowerCase().contains('.avif');

    final isLocalFile =
        !image.isUrl &&
        !image.startsWith('packages/') &&
        !image.startsWith('assets/');

    if (image.isUrl) {
      if (isAvif) {
        return AvifImage.network(
          image,
          width: width,
          height: height,
          fit: fit ?? BoxFit.contain,
          alignment: alignment,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Loading(
              brightness: MediaQuery.of(context).platformBrightness,
              radius: loadingRadius ?? 12,
            );
          },
          errorBuilder:
              ConditionBuilder.from([
                Conditional(
                  condition: () => errorBuilder != null,
                  value: () => errorBuilder,
                ),
                Conditional(
                  condition: () => errorPlaceHolder.isNotNullOrEmpty,
                  value: () =>
                      (context, error, stackTrace) => ImageView(
                        source: errorPlaceHolder!,
                        width: width,
                        height: height,
                        fit: fit,
                        color: color,
                        alignment: alignment,
                        package: package,
                        errorBuilder: errorBuilder,
                      ),
                ),
              ]).build(
                orElse: () => null,
              ),
        );
      }
      return ExtendedNetworkImage(
        image,
        width: width,
        height: height,
        fit: fit,
        color: color,
        alignment: alignment,
        loadingRadius: loadingRadius,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        placeHolder: placeHolder,
        errorBuilder:
            ConditionBuilder.from([
              Conditional(
                condition: () => errorBuilder != null,
                value: () => (state) {
                  return errorBuilder!(
                    context,
                    state.lastException,
                    state.lastStack,
                  );
                },
              ),
              Conditional(
                condition: () => errorPlaceHolder.isNotNullOrEmpty,
                value: () =>
                    (state) => ImageView(
                      source: errorPlaceHolder!,
                      width: width,
                      height: height,
                      fit: fit,
                      color: color,
                      alignment: alignment,
                      package: package,
                      errorBuilder: errorBuilder,
                    ),
              ),
            ]).build(
              orElse: () => null,
            ),
      );
    }
    if (image.contains('.svg')) {
      return SvgPicture.asset(
        image,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        colorFilter: color?.let(
          (it) => ColorFilter.mode(it, ui.BlendMode.srcIn),
        ),
        alignment: alignment,
        package: package,
        errorBuilder: errorBuilder,
      );
    }

    // Handle local files (e.g., from file_picker cache)
    if (isLocalFile) {
      return Image.file(
        File(image),
        width: width,
        height: height,
        fit: fit,
        color: color,
        alignment: alignment,
        cacheWidth: cacheWidth,
        cacheHeight: cacheHeight,
        errorBuilder: errorBuilder,
      );
    }

    // Handle AVIF asset images using flutter_avif
    if (isAvif) {
      return AvifImage.asset(
        package != null ? 'packages/$package/$image' : image,
        width: width,
        height: height,
        fit: fit ?? BoxFit.contain,
        alignment: alignment,
        errorBuilder: errorBuilder,
      );
    }

    return Image.asset(
      image,
      width: width,
      height: height,
      fit: fit,
      color: color,
      alignment: alignment,
      package: package,
      errorBuilder: errorBuilder,
    );
  }
}

class ExtendedNetworkImage extends StatelessWidget {
  const ExtendedNetworkImage(
    this.image, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.color,
    this.alignment = Alignment.center,
    this.placeHolder,
    this.errorBuilder,
    this.loadingBuilder,
    this.brightness,
    this.cached = true,
    this.loadingRadius,
    this.cacheWidth,
    this.cacheHeight,
  });

  final String image;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;
  final Alignment alignment;
  final String? placeHolder;
  final Widget Function(ExtendedImageState state)? errorBuilder;
  final Widget Function(ExtendedImageState state)? loadingBuilder;
  final Brightness? brightness;
  final bool cached;
  final double? loadingRadius;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      image,
      width: width,
      height: height,
      fit: fit,
      color: color,
      alignment: alignment,
      cache: cached,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return loadingBuilder?.call(state) ??
                Loading(
                  brightness:
                      brightness ?? MediaQuery.of(context).platformBrightness,
                  radius: maxLoadingSize,
                );
          case LoadState.failed:
            if (errorBuilder != null) {
              return errorBuilder!.call(state);
            }
            if (placeHolder.isNotNullOrEmpty) {
              return ImageView(
                source: placeHolder!,
                width: width,
                height: height,
                fit: fit,
                alignment: alignment,
                color: color,
              );
            }
            return Icon(
              Icons.error,
              size: maxLoadingSize,
            );
          case LoadState.completed:
            if (state.wasSynchronouslyLoaded) {
              return state.completedWidget;
            }
            return null;
        }
      },
    );
  }

  double get maxLoadingSize {
    if (loadingRadius != null) {
      return loadingRadius!;
    }
    if (width != null && height != null) {
      return min(12, min(width!, height!) * 3 / 2);
    }
    return 12;
  }
}

class ImageViewProviderFactory {
  ImageViewProviderFactory(this.source)
    : provider = source.let((it) {
        final isAvif = it.toLowerCase().contains('.avif');
        if (it.isUrl) {
          if (isAvif) {
            return NetworkAvifImage(it);
          }
          return ExtendedNetworkImageProvider(it);
        }
        if (it.contains('.svg')) {
          return svg_provider.Svg(it);
        }
        if (isAvif) {
          return AssetAvifImage(it);
        }
        return AssetImage(it);
      });

  final String source;
  final ImageProvider provider;
}
