import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:fl_media/fl_media.dart';
import 'package:flutter/material.dart';

enum BannerWidgetUIStyle { bottomInside, bottomOutside }

class BannerWidget<T> extends StatefulWidget {
  final List<T>? banners;
  final void Function(T)? onTap;
  final double ratio;
  final String? Function(T) getImageUrl;
  final EdgeInsets? padding;
  final BorderRadius itemBorderRadius;
  final BannerWidgetUIStyle uiStyle;
  final Color? color;
  final Color? activeColor;
  final String? placeHolder;
  final Duration autoPlayInterval;
  final BoxFit fit;

  const BannerWidget({
    Key? key,
    this.banners,
    this.onTap,
    required this.getImageUrl,
    this.ratio = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.itemBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.uiStyle = BannerWidgetUIStyle.bottomOutside,
    this.color,
    this.activeColor,
    this.placeHolder,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  _BannerWidgetState createState() => _BannerWidgetState<T>();
}

class _BannerWidgetState<T> extends State<BannerWidget<T>> {
  final pageNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    if (widget.uiStyle == BannerWidgetUIStyle.bottomInside) {
      return AspectRatio(
        aspectRatio: widget.ratio,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            _buildCarouselSlider(),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: _buildBannerIndicator(),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        _buildCarouselSlider(),
        _buildBannerIndicator(),
      ],
    );
  }

  Widget _buildCarouselSlider() {
    final width = MediaQuery.of(context).size.width;
    const viewportFraction = 1.0;
    final imageWidth = width * viewportFraction;
    final imageHeight = imageWidth / widget.ratio;
    return CarouselSlider(
      options: CarouselOptions(
        initialPage: pageNotifier.value,
        autoPlay: (widget.banners?.length ?? 0) > 1,
        autoPlayInterval: widget.autoPlayInterval,
        aspectRatio: (imageWidth / viewportFraction) / imageHeight,
        enlargeCenterPage: true,
        viewportFraction: viewportFraction,
        enlargeStrategy: CenterPageEnlargeStrategy.height,
        onPageChanged: (index, reason) {
          pageNotifier.value = index;
        },
      ),
      items: [
        ...widget.banners!.map(
          (e) => Padding(
            padding: widget.padding ??
                const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
            child: BannerItem<T>(
              item: e,
              onTap: () => widget.onTap?.call(e),
              url: widget.getImageUrl(e),
              borderRadius: widget.itemBorderRadius,
              placeHolder: widget.placeHolder,
              fit: widget.fit,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerIndicator() {
    final numPages = widget.banners?.length ?? 0;
    if (numPages == 0) {
      return const SizedBox();
    }
    return ValueListenableBuilder(
      valueListenable: pageNotifier,
      builder: (context, dynamic idx, snapshot) {
        return DotsIndicator(
          dotsCount: numPages,
          position: (idx as int) < numPages
              ? idx.toDouble()
              : (numPages - 1).toDouble(),
          decorator: DotsDecorator(
            size: const Size.square(6),
            activeSize: const Size.square(6),
            color: widget.color ?? Colors.black12,
            activeColor:
                widget.activeColor ?? Theme.of(context).colorScheme.primary,
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            spacing: const EdgeInsets.only(left: 2, top: 7, right: 2),
          ),
        );
      },
    );
  }
}

class BannerItem<T> extends StatelessWidget {
  final T? item;
  final void Function()? onTap;
  final String? url;
  final String? placeHolder;
  final BorderRadius borderRadius;
  final BoxFit fit;

  const BannerItem({
    Key? key,
    this.item,
    this.onTap,
    this.url,
    this.placeHolder,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: ImageView(
          source: url ?? '',
          key: ValueKey('${url}_banner'),
          fit: fit,
          height: double.infinity,
          width: double.infinity,
          placeHolder: placeHolder,
        ),
      ),
    );
  }
}
