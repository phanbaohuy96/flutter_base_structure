import 'package:flutter/material.dart';

import '../../common/utils.dart';
import '../theme/shadow.dart';
import '../theme/theme_color.dart';

class BottomBarItemData {
  final String lable;
  final Widget icon;
  final Widget selectedIcon;

  BottomBarItemData({
    required this.lable,
    required this.icon,
    required this.selectedIcon,
  });
}

class CustomBottomNavigationBar extends StatefulWidget {
  final Future<bool> Function(int) onItemSelection;
  final int selectedIdx;
  final List<BottomBarItemData> items;

  const CustomBottomNavigationBar({
    Key? key,
    required this.onItemSelection,
    this.selectedIdx = 0,
    required this.items,
  }) : super(key: key);
  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  late ValueNotifier<int> idxNotifier;

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
    return ValueListenableBuilder<int>(
      valueListenable: idxNotifier,
      builder: (ctx, value, w) {
        return Container(
          decoration: const BoxDecoration(
            boxShadow: boxShadowlight,
            color: Colors.white,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: widget.items
                .mapIndex<Widget>(
                  (item, idx) => Expanded(
                    child: BottomItem(
                      item: item,
                      onPressed: () async {
                        if (idx != value &&
                            await widget.onItemSelection.call(idx) == true) {
                          idxNotifier.value = idx;
                        }
                      },
                      selected: idx == value,
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class BottomItem extends StatelessWidget {
  final BottomBarItemData item;
  final Function()? onPressed;
  final bool selected;

  const BottomItem({
    Key? key,
    required this.item,
    this.onPressed,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 22, height: 22, child: _getIcon),
            const SizedBox(height: 3),
            Text(item.lable, style: _getTextStyle(context))
          ],
        ),
      ),
    );
  }

  Widget get _getIcon {
    if (selected) {
      return item.selectedIcon;
    } else {
      return item.icon;
    }
  }

  TextStyle? _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    if (selected) {
      return theme.textTheme.subtitle1?.copyWith(
        color: theme.accentColor,
      );
    } else {
      return theme.textTheme.subtitle1?.copyWith(
        color: AppColor.primaryText,
      );
    }
  }
}
