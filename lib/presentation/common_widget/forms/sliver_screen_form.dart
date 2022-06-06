import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../cache_network_image_wrapper.dart';

class SliverScreenForm extends StatefulWidget {
  final Widget? child;
  final String? title;
  final String? imageUrl;
  final Color? bgColor;
  final Widget? bottom;

  const SliverScreenForm({
    Key? key,
    this.child,
    this.title,
    this.imageUrl = '',
    this.bgColor,
    this.bottom,
  }) : super(key: key);

  @override
  _SliverScreenFormState createState() => _SliverScreenFormState();
}

class _SliverScreenFormState extends State<SliverScreenForm> {
  final ValueNotifier<double> _textScaleNotifier = ValueNotifier(1);
  final ColorTween _colorTween = ColorTween(
    begin: Colors.grey,
    end: Colors.white,
  );

  TextTheme get textTheme => Theme.of(context).textTheme;
  final maxExtent = 280.0;

  double minAppBarHeight = 0;
  double? maxAppBarHeight;

  @override
  void dispose() {
    _textScaleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    minAppBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: widget.bgColor,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppbar(),
                SliverToBoxAdapter(
                  child: widget.child ?? const SizedBox(),
                ),
              ],
            ),
          ),
          widget.bottom ?? const SizedBox(),
        ],
      ),
    );
  }

  Widget _buildAppbar() {
    return SliverAppBar(
      expandedHeight: maxExtent,
      floating: true,
      pinned: true,
      snap: false,
      leading: InkWell(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ValueListenableBuilder<double>(
            valueListenable: _textScaleNotifier,
            builder: (ctx, scale, w) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black45.withOpacity(scale / 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.chevron_left_outlined,
                    color: _colorTween.transform(scale),
                    size: 14,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      title: ValueListenableBuilder<double>(
        valueListenable: _textScaleNotifier,
        builder: (ctx, scale, w) {
          return Opacity(
            opacity: scale > 0.2 ? 0 : 1 - scale,
            child: Text(
              widget.title ?? '',
              style: textTheme.bodyText1?.copyWith(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
      titleSpacing: 0,
      centerTitle: true,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final scale = _updateScale(constraints.biggest.height);
          return FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            titlePadding: EdgeInsets.zero,
            centerTitle: true,
            title: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Opacity(
                opacity: scale > 0.2 ? scale : 0,
                child: Text(
                  widget.title ?? '',
                  style: textTheme.bodyText1?.copyWith(
                    fontSize: 16 - (16 * 0.5 * scale / 1.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            background: CachedNetworkImageWrapper.background(
              url: widget.imageUrl ?? '',
              fit: BoxFit.cover,
              width: double.infinity,
              height: maxExtent - 40,
            ),
          );
        },
      ),
    );
  }

  double _updateScale(double height) {
    if (maxAppBarHeight == null || maxAppBarHeight! < height) {
      maxAppBarHeight = height;
    }
    final scale =
        (height - minAppBarHeight) / (maxAppBarHeight! - minAppBarHeight);
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _textScaleNotifier.value = scale,
    );

    return scale;
  }
}
