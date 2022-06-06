import 'package:flutter/material.dart';

import 'item_devider.dart';

class SelectionItem extends StatelessWidget {
  final String title;
  final bool isChecked;
  final Color? color;
  final ItemDivider? divider;
  final EdgeInsets padding;
  final Function(bool)? onTap;

  const SelectionItem({
    Key? key,
    required this.title,
    required this.isChecked,
    this.color,
    this.divider,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom:
            divider == ItemDivider.none || divider == ItemDivider.line ? 0 : 16,
      ),
      color: color,
      child: InkWell(
        onTap: () {
          onTap?.call(isChecked);
        },
        child: Padding(
          padding: EdgeInsets.only(left: padding.left, right: padding.right),
          child: Container(
            padding: EdgeInsets.only(top: padding.top, bottom: padding.bottom),
            decoration: BoxDecoration(
              border: divider == ItemDivider.line
                  ? const Border(
                      bottom: BorderSide(
                        color: Colors.black12,
                        width: 1,
                      ),
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle2
                        ?.copyWith(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                if (isChecked == true)
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: Colors.green,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
