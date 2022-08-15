import 'package:flutter/material.dart';

import 'radio_button.dart';

class YesNoWidget extends StatefulWidget {
  final String yesLabel;
  final String noLabel;
  final void Function(bool?)? onChanged;
  final ValueNotifier<bool?>? controller;
  final bool enable;

  const YesNoWidget({
    Key? key,
    required this.yesLabel,
    required this.noLabel,
    required this.controller,
    this.onChanged,
    this.enable = true,
  }) : super(key: key);

  @override
  _YesNoWidgetState createState() => _YesNoWidgetState();
}

class _YesNoWidgetState extends State<YesNoWidget> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: widget.controller ?? ValueNotifier<bool?>(null),
      builder: (context, value, snapshot) {
        return Row(
          children: [
            Expanded(
              child: RadioButtonWithTitle<bool?>(
                title: widget.yesLabel,
                value: true,
                groupValue: value,
                enable: widget.enable,
                onChanged: (bool? value) {
                  widget.controller?.value = value;
                  widget.onChanged?.call(value);
                },
              ),
            ),
            Expanded(
              child: RadioButtonWithTitle<bool?>(
                title: widget.noLabel,
                value: false,
                groupValue: value,
                enable: widget.enable,
                onChanged: (bool? value) {
                  widget.controller?.value = value;
                  widget.onChanged?.call(value);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
