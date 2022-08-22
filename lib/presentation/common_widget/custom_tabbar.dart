import 'package:flutter/material.dart';

import '../../common/utils/extensions.dart';

class CustomTabbar extends StatefulWidget {
  final List<String> titles;
  final int selectedIdx;
  final Future<bool> Function(int) onTap;

  const CustomTabbar({
    Key? key,
    required this.titles,
    required this.onTap,
    this.selectedIdx = 0,
  }) : super(key: key);
  @override
  _CustomTabbarState createState() => _CustomTabbarState();
}

class _CustomTabbarState extends State<CustomTabbar> {
  late ValueNotifier<int> _valueNotifier;

  @override
  void initState() {
    _valueNotifier = ValueNotifier(widget.selectedIdx);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _valueNotifier.value = widget.selectedIdx;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant CustomTabbar oldWidget) {
    if (oldWidget.selectedIdx != widget.selectedIdx) {
      _valueNotifier.value = widget.selectedIdx;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black12.withOpacity(0.05),
      ),
      child: ValueListenableBuilder(
        valueListenable: _valueNotifier,
        builder: (context, value, w) {
          return Row(
            children: widget.titles
                .mapIndex<Widget>(
                  (title, idx) => Expanded(
                    child: TabItem(
                      onTap: () async {
                        if (idx != value &&
                            await widget.onTap.call(idx) == true) {
                          _valueNotifier.value = idx;
                        }
                      },
                      selected: idx == value,
                      title: title,
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final String title;
  final bool selected;
  final void Function() onTap;

  const TabItem({
    Key? key,
    required this.title,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: selected ? themeData.primaryColorLight : Colors.transparent,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 12,
        ),
        child: Center(
          child: Text(
            title,
            style: themeData.textTheme.bodyText1?.copyWith(
              color: selected ? Colors.white : Colors.black26,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
