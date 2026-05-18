import 'package:flutter/material.dart';

import '../../l10n/localization_ext.dart';

Widget defaultToggleButton(bool isExpanded) {
  return Builder(
    builder: (context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isExpanded ? context.coreL10n.seeLess : context.coreL10n.viewMore,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 16,
          color: Colors.grey,
        ),
      ],
    ),
  );
}

class ExpandableWidgetList extends StatefulWidget {
  final List<Widget> children;
  final Widget separator;
  final int initialVisibleItems;
  final Widget Function(bool isExpanded) toggleButton;
  final Alignment contentAlignment;
  final Alignment? toggleButtonAlignment;

  const ExpandableWidgetList({
    super.key,
    required this.children,
    this.initialVisibleItems = 3,
    this.separator = const Text(', '),
    this.toggleButton = defaultToggleButton,
    this.contentAlignment = Alignment.centerRight,
    this.toggleButtonAlignment,
  });

  @override
  State<ExpandableWidgetList> createState() => _ExpandableWidgetListState();
}

class _ExpandableWidgetListState extends State<ExpandableWidgetList> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final showToggle = widget.children.length > widget.initialVisibleItems;
    final displayedItems = showToggle && !isExpanded
        ? widget.children.take(widget.initialVisibleItems).toList()
        : widget.children;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: _getCrossAxisAlignment(widget.contentAlignment),
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Wrap(
            alignment: _getWrapAlignment(widget.contentAlignment),
            spacing: 4,
            runSpacing: 4,
            children: displayedItems.asMap().entries.map((entry) {
              final isLast = entry.key == displayedItems.length - 1;
              return Wrap(
                children: [
                  entry.value,
                  if (!isLast) widget.separator,
                ],
              );
            }).toList(),
          ),
        ),
        if (showToggle)
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: widget.toggleButton(isExpanded),
            ),
          ),
      ],
    );
  }

  CrossAxisAlignment _getCrossAxisAlignment(Alignment alignment) {
    if (alignment == Alignment.centerLeft) {
      return CrossAxisAlignment.start;
    }
    if (alignment == Alignment.center) {
      return CrossAxisAlignment.center;
    }
    return CrossAxisAlignment.end;
  }

  WrapAlignment _getWrapAlignment(Alignment alignment) {
    if (alignment == Alignment.centerLeft) {
      return WrapAlignment.start;
    }
    if (alignment == Alignment.center) {
      return WrapAlignment.center;
    }
    return WrapAlignment.end;
  }
}
