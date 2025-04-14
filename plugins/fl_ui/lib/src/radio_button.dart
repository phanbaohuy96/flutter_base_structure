import 'package:flutter/material.dart';

import 'availability_widget.dart';

class RadioButtonWithTitle<T> extends StatelessWidget {
  // [String, Widget] is supported
  final dynamic title;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final bool enable;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;

  const RadioButtonWithTitle({
    Key? key,
    required this.title,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.enable = true,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  })  : assert(
          title is String || title is Widget,
          '$title [String, Widget] is supported',
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleWidget = title is Widget
        ? title
        : Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              title,
              style: textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
          );
    return AvailabilityWidget(
      enable: enable,
      child: InkWell(
        onTap: () {
          onChanged?.call(value);
        },
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Radio<T>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      return Theme.of(context).colorScheme.primary;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 5),
              mainAxisSize == MainAxisSize.max
                  ? Expanded(
                      child: titleWidget,
                    )
                  : titleWidget,
            ],
          ),
        ),
      ),
    );
  }
}

class RadioGroup<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final void Function(T) onSelected;
  final String Function(T) getLabel;
  final Axis axis;

  const RadioGroup({
    Key? key,
    required this.items,
    required this.onSelected,
    required this.getLabel,
    this.selectedItem,
    this.axis = Axis.vertical,
  }) : super(key: key);

  @override
  _RadioGroupState createState() => _RadioGroupState<T>();
}

class _RadioGroupState<T> extends State<RadioGroup<T>> {
  T? seleted;

  @override
  void initState() {
    seleted = widget.selectedItem;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RadioGroup<T> oldWidget) {
    seleted = widget.selectedItem;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final radioButtons = widget.items
        .map(
          (e) => RadioButtonWithTitle<T>(
            title: widget.getLabel(e),
            value: e,
            groupValue: seleted,
            onChanged: (T? value) {
              setState(() {
                seleted = value;
                if (seleted != null) {
                  widget.onSelected(seleted!);
                }
              });
            },
          ),
        )
        .toList();
    if (widget.axis == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: radioButtons,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: radioButtons.map<Widget>((e) => Expanded(child: e)).toList(),
    );
  }
}
