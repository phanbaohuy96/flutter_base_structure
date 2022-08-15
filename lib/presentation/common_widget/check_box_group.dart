import 'package:flutter/material.dart';
import 'check_box.dart';

class CheckBoxGroup<T> extends StatefulWidget {
  final List<T> items;
  final List<T>? selectedItems;
  final void Function(List<T>) onSelectedChanged;
  final String Function(T) getLabel;
  final bool enable;
  final T? onlyItem;
  final bool Function(T, T)? compare;

  const CheckBoxGroup({
    Key? key,
    required this.items,
    required this.getLabel,
    required this.onSelectedChanged,
    this.selectedItems,
    this.enable = true,
    this.onlyItem,
    this.compare,
  }) : super(key: key);

  @override
  _CheckBoxGroupState createState() => _CheckBoxGroupState<T>();
}

class _CheckBoxGroupState<T> extends State<CheckBoxGroup<T>> {
  final seleted = <T>[];

  @override
  void initState() {
    _updateSelectedItem();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant CheckBoxGroup<T> oldWidget) {
    _updateSelectedItem();
    super.didUpdateWidget(oldWidget);
  }

  void _updateSelectedItem() {
    seleted.clear();
    if (widget.selectedItems?.isNotEmpty == true) {
      seleted.addAll(widget.selectedItems!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.items
          .map(
            (e) => CheckboxWithTitle(
              title: widget.getLabel(e),
              value: widget.compare == null
                  ? seleted.contains(e)
                  : seleted.any((other) => widget.compare!(other, e)),
              enable: widget.enable,
              onChanged: (value) {
                selectItem(value, e);
              },
            ),
          )
          .toList(),
    );
  }

  void selectItem(bool? selected, T e) {
    if (selected != true) {
      // case unselected
      if (seleted.contains(e) == true) {
        setState(() {
          seleted.remove(e);
          widget.onSelectedChanged(seleted);
        });
      }
    } else if (widget.onlyItem != null && widget.compare != null) {
      // case has onlyItem
      final isSelectedContains = seleted.any(
        (item) => widget.compare!(item, widget.onlyItem!),
      );
      final isOnly = widget.compare!(e, widget.onlyItem!);
      if ((isSelectedContains && !isOnly) || (!isSelectedContains && isOnly)) {
        // case selected another option with only item is selected or opposite
        setState(() {
          seleted
            ..clear()
            ..add(e);
          widget.onSelectedChanged(seleted);
        });
      } else {
        // case selected another option
        setState(() {
          seleted.add(e);
          widget.onSelectedChanged(seleted);
        });
      }
    } else {
      if (seleted.contains(e) != true) {
        // case selected
        setState(() {
          seleted.add(e);
          widget.onSelectedChanged(seleted);
        });
      }
    }
  }
}
