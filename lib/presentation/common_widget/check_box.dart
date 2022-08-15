import 'package:flutter/material.dart';
import 'availability_widget.dart';

class CheckboxWithTitle extends StatelessWidget {
  final String title;
  final bool? value;
  final void Function(bool?)? onChanged;
  final bool enable;

  const CheckboxWithTitle({
    Key? key,
    required this.title,
    this.value,
    this.onChanged,
    this.enable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AvailabilityWidget(
      enable: enable,
      child: InkWell(
        onTap: () {
          final bool v;
          if (value == null) {
            v = true;
          } else {
            v = !value!;
          }
          onChanged?.call(v);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: value,
                  onChanged: onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    title,
                    style: textTheme.bodyText1?.copyWith(height: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
