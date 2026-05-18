import 'package:flutter/material.dart';

import '../theme/export.dart';

class InputTitleWidget extends StatelessWidget {
  const InputTitleWidget({
    super.key,
    required this.title,
    this.required = true,
    this.style,
  });

  final String? title;
  final bool required;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return RichText(
      text: TextSpan(
        text: title,
        style: style ?? textTheme.inputTitle,
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style:
                  style?.copyWith(color: Colors.red) ?? textTheme.inputRequired,
            ),
        ],
      ),
    );
  }
}
