import 'package:flutter/material.dart';

import 'item_devider.dart';

class InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final ItemDivider divider;
  final EdgeInsets padding;
  final Widget myOwnValueWidget;

  const InfoItem({
    Key key,
    this.title,
    this.value,
    this.color = Colors.white,
    this.divider = ItemDivider.space,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.myOwnValueWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom:
            divider == ItemDivider.none || divider == ItemDivider.line ? 0 : 16,
      ),
      color: color,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title ?? '--',
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(color: Colors.black),
              ),
              const SizedBox(width: 8),
              myOwnValueWidget ??
                  Expanded(
                    child: Text(
                      value ?? '--',
                      style: Theme.of(context).textTheme.subtitle2,
                      textAlign: TextAlign.end,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
