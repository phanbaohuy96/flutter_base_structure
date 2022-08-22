import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../common/utils/extensions.dart';
import '../theme/shadow.dart';
import '../theme/theme_color.dart';
import 'cache_network_image_wrapper.dart';

class BottomBarItemData {
  final String? label;
  final String? icon;
  final String? selectedIcon;
  final bool? isOver;
  final int? badgeCount;

  BottomBarItemData({
    this.label,
    this.icon,
    this.selectedIcon,
    this.isOver,
    this.badgeCount,
  });
}

class CustomBottomNavigationBar extends StatefulWidget {
  final Future<bool> Function(int)? onItemSelection;
  final int? selectedIdx;
  final List<BottomBarItemData>? items;

  const CustomBottomNavigationBar({
    Key? key,
    this.onItemSelection,
    this.selectedIdx = 0,
    this.items,
  }) : super(key: key);
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late ValueNotifier<int?> idxNotifier;

  @override
  void initState() {
    idxNotifier = ValueNotifier(widget.selectedIdx);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    idxNotifier.value = widget.selectedIdx;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavigationBar oldWidget) {
    idxNotifier = ValueNotifier(widget.selectedIdx);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    idxNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return ValueListenableBuilder<int?>(
        valueListenable: idxNotifier,
        builder: (ctx, value, w) {
          final itemWidth = constraints.maxWidth / widget.items!.length;
          return Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Container(
                decoration: const BoxDecoration(
                  boxShadow: boxShadowlight,
                  color: Colors.white,
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.items!.mapIndex<Widget>((item, idx) {
                    if (item.isOver == true) {
                      return SizedBox(width: itemWidth);
                    }
                    return SizedBox(
                      width: itemWidth,
                      child: BottomItem(
                        item: item,
                        onPressed: () async {
                          if (idx != value &&
                              await widget.onItemSelection?.call(idx) == true) {
                            idxNotifier.value = idx;
                          }
                        },
                        selected: idx == value,
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: Row(
                  children: widget.items!.mapIndex<Widget>((item, idx) {
                    if (item.isOver != true) {
                      return SizedBox(width: itemWidth);
                    }
                    return SizedBox(
                      width: itemWidth,
                      child: BottomItem(
                        item: item,
                        iconSize: itemWidth * 0.9,
                        onPressed: () async {
                          if (idx != value &&
                              await widget.onItemSelection?.call(idx) == true) {
                            idxNotifier.value = idx;
                          }
                        },
                        selected: idx == value,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

class BottomItem extends StatelessWidget {
  final BottomBarItemData item;
  final Function()? onPressed;
  final bool selected;
  final double iconSize;

  const BottomItem({
    Key? key,
    required this.item,
    this.onPressed,
    this.selected = false,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final count = item.badgeCount ?? 0;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Badge(
              showBadge: count > 0,
              badgeContent: Text(
                '${min(count, 99)}${count > 99 ? '+' : ''}',
                style: theme.textTheme.subtitle1?.copyWith(
                  fontSize: count > 99 ? 8 : 10,
                  color: Colors.white,
                ),
              ),
              padding: EdgeInsets.all(count > 9 ? 3 : 5),
              animationType: BadgeAnimationType.scale,
              child: _buildIcon(),
            ),
            const SizedBox(height: 3),
            if (item.label?.isNotEmpty == true)
              Text(
                item.label!,
                style: _getTextStyle(context),
                textAlign: TextAlign.center,
              )
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final icon = selected == true ? item.selectedIcon! : item.icon!;
    if (icon.contains('http')) {
      return CachedNetworkImageWrapper(
        url: icon,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.cover,
      );
    }
    if (icon.contains('svg')) {
      return SvgPicture.asset(
        icon,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        icon,
        fit: BoxFit.cover,
        width: iconSize,
        height: iconSize,
      );
    }
  }

  TextStyle _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    if (selected) {
      return theme.textTheme.subtitle1!.copyWith(
          color: theme.colorScheme.secondary,
          fontSize: 10,
          fontWeight: FontWeight.bold);
    } else {
      return theme.textTheme.subtitle1!.copyWith(
        color: AppColor.primaryText,
        fontSize: 10,
      );
    }
  }
}
