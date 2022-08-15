import 'package:flutter/material.dart';
import 'radio_button.dart';

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
