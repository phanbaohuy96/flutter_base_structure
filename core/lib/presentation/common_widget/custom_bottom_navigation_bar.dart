import 'package:fl_media/fl_media.dart';
import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';

import '../../common/utils.dart';
import '../extentions/context_extention.dart';

class BottomBarItemData {
  final String? label;

  /// [icon] supported [String, IconData, Widget]
  final dynamic icon;

  /// [selectedIcon] supported [String, IconData, Widget, NULL]
  final dynamic selectedIcon;
  final bool? isOver;
  final Stream<int>? badgeStream;
  final int? initialBadgeCount;

  BottomBarItemData({
    this.label,
    this.icon,
    this.selectedIcon,
    this.isOver,
    this.badgeStream,
    this.initialBadgeCount,
  });
}

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({
    Key? key,
    this.onItemSelection,
    this.selectedIdx = 0,
    this.items,
    this.borderRadius,
  }) : super(key: key);

  final Future<bool> Function(int)? onItemSelection;
  final int? selectedIdx;
  final List<BottomBarItemData>? items;
  final BorderRadiusGeometry? borderRadius;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return ValueListenableBuilder<int?>(
          valueListenable: idxNotifier,
          builder: (ctx, value, w) {
            final itemWidth = constraints.maxWidth / widget.items!.length;
            return Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: context.themeColor.boxShadowLightest,
                    color: Theme.of(context).primaryColor,
                    borderRadius: widget.borderRadius,
                  ),
                  padding: const EdgeInsets.only(
                    bottom: 16,
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
                          key: ValueKey('CustomBottomNavigationBar_$idx'),
                          item: item,
                          onPressed: () async {
                            if (idx != value &&
                                await widget.onItemSelection?.call(idx) ==
                                    true) {
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
                          key: ValueKey('CustomBottomNavigationBar_$idx'),
                          item: item,
                          iconSize: itemWidth * 0.9,
                          onPressed: () async {
                            if (idx != value &&
                                await widget.onItemSelection?.call(idx) ==
                                    true) {
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
      },
    );
  }
}

class BottomItem extends StatelessWidget {
  final BottomBarItemData item;
  final void Function()? onPressed;
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
    assert(
      item.icon is String || item.icon is IconData || item.icon is Widget,
      'BottomBarItemData.icon supported [String, IconData, Widget]',
    );
    assert(
      item.selectedIcon == null ||
          item.selectedIcon is String ||
          item.selectedIcon is IconData ||
          item.selectedIcon is Widget,
      '''BottomBarItemData.selectedIcon supported [String, IconData, Widget, NULL]''',
    );
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<int>(
              stream: item.badgeStream,
              initialData: item.initialBadgeCount,
              builder: (context, snapshot) {
                return BadgeBox(
                  count: snapshot.data ?? 0,
                  child: _buildIcon(context),
                );
              },
            ),
            const SizedBox(height: 3),
            if (item.label?.isNotEmpty == true)
              Text(
                item.label!,
                style: _getTextStyle(context),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final icon =
        (selected == true ? item.selectedIcon : item.icon) ?? item.icon;
    if (icon is Widget) {
      return icon;
    }
    if (icon is IconData) {
      return Icon(
        icon,
        size: iconSize,
        color: selected ? context.themeColor.primary : Colors.grey,
      );
    }
    if (icon is! String) {
      return const SizedBox();
    }
    return ImageView(
      source: icon,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.cover,
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    final theme = context.theme;
    if (selected) {
      return theme.textTheme.bodySmall!.copyWith(
        color: context.themeColor.primary,
        fontWeight: FontWeight.w600,
      );
    } else {
      return theme.textTheme.bodySmall!.copyWith(
        color: const Color(0xff8C8C8C),
        fontWeight: FontWeight.w400,
      );
    }
  }
}
