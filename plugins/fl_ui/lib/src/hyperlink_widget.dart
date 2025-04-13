import 'package:fl_theme/fl_theme.dart';
import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';

class HyperlinkWidget extends StatelessWidget {
  const HyperlinkWidget({
    super.key,
    required this.label,
    this.onTap,
    this.visibleIcon = true,
    this.style,
  });

  final String? label;
  final bool visibleIcon;
  final VoidCallback? onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final hasLabel = label.isNotNullOrEmpty;
    final textStyle = style ?? context.textTheme.bodyMedium;
    return InkWell(
      onTap: hasLabel ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              hasLabel ? label! : '--',
              style: textStyle?.copyWith(
                color: onTap != null ? context.themeColor.hyperLink : null,
              ),
            ),
            if (visibleIcon && hasLabel && onTap != null) ...[
              const SizedBox(width: 2),
              Icon(
                Icons.open_in_new,
                size: textStyle?.fontSize,
                color: context.themeColor.hyperLink,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
