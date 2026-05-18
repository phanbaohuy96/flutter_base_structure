import 'package:flutter/material.dart';

import 'availability_widget.dart';

class CheckboxWithTitle extends StatefulWidget {
  final String title;
  final TextStyle? style;
  final bool? value;
  final double? size;
  final void Function(bool?)? onChanged;
  final bool enable;
  final Color? borderColor;
  final double? space;

  const CheckboxWithTitle({
    Key? key,
    required this.title,
    this.size = 24,
    this.style,
    this.value,
    this.onChanged,
    this.enable = true,
    this.borderColor,
    this.space,
  }) : super(key: key);

  @override
  State<CheckboxWithTitle> createState() => _CheckboxWithTitleState();
}

class _CheckboxWithTitleState extends State<CheckboxWithTitle> {
  late bool _value;
  @override
  void initState() {
    _value = widget.value ?? false;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _value = widget.value ?? false;
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant CheckboxWithTitle oldWidget) {
    if (widget.value != oldWidget.value) {
      _value = widget.value ?? _value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return AvailabilityWidget(
      enable: widget.enable,
      child: InkWell(
        onTap: () {
          setState(() {
            _value = !_value;
            widget.onChanged?.call(_value);
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: widget.size,
                width: widget.size,
                child: Checkbox(
                  side: WidgetStateBorderSide.resolveWith(
                    (states) => BorderSide(
                      width: 1.0,
                      color: _value
                          ? theme.colorScheme.primary
                          : theme.disabledColor,
                    ),
                  ),
                  activeColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  value: _value,
                  onChanged: (bool? v) {
                    if (mounted) {
                      setState(() {
                        _value = v!;
                        widget.onChanged?.call(_value);
                      });
                    }
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(width: widget.space ?? 5),
              Expanded(
                child: Text(
                  widget.title,
                  style: widget.style ??
                      textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckBoxGroup<T> extends StatefulWidget {
  final List<T> items;
  final List<T>? selectedItems;
  final void Function(List<T>) onSelectedChanged;
  final String Function(T) getLabel;
  final bool enable;
  final T? onlyItem;
  final bool Function(T, T)? compare;
  final List<T> disableItems;
  final TextStyle? labelStyle;

  const CheckBoxGroup({
    Key? key,
    required this.items,
    required this.getLabel,
    required this.onSelectedChanged,
    this.selectedItems,
    this.enable = true,
    this.onlyItem,
    this.compare,
    this.labelStyle,
    this.disableItems = const [],
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
      children: [
        ...widget.items.map(
          (e) => AvailabilityWidget(
            enable: !widget.disableItems.any(
              (e2) => widget.compare?.call(e, e2) ?? e == e2,
            ),
            child: CheckboxWithTitle(
              title: widget.getLabel(e),
              value: widget.compare == null
                  ? seleted.contains(e)
                  : seleted.any((other) => widget.compare!(other, e)),
              enable: widget.enable,
              style: widget.labelStyle,
              onChanged: (value) {
                selectItem(value, e);
              },
            ),
          ),
        ),
      ],
    );
  }

  void selectItem(bool? selected, T e) {
    final equal = (T a, T b) {
      if (widget.compare != null) {
        return widget.compare!.call(a, b);
      }
      return a == b;
    };

    if (selected != true) {
      // case deselected
      if (seleted.any((s) => equal(e, s))) {
        setState(() {
          seleted.removeWhere((s) => widget.compare?.call(e, s) ?? s == e);
        });
      }
    } else {
      if (!seleted.any((s) => equal(e, s))) {
        if (widget.onlyItem != null) {
          if (equal(e, widget.onlyItem!)) {
            setState(() {
              seleted
                ..clear()
                ..add(e);
            });
          } else {
            final items = [
              ...seleted.where((e) => !equal(e, widget.onlyItem!)),
            ];
            setState(() {
              seleted
                ..clear()
                ..addAll(items);
            });
          }
        } else {
          // case selected
          setState(() {
            seleted.add(e);
          });
        }
      }
    }

    widget.onSelectedChanged(seleted);
  }
}
