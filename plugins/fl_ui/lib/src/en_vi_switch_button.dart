import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fl_media/fl_media.dart';
import 'package:flutter/material.dart';

import '../generated/assets.dart';

class EnViSwitch extends StatelessWidget {
  const EnViSwitch({
    super.key,
    required this.isVILanguage,
    required this.onChanged,
    this.indicatorSize = const Size(26, 26),
    this.textStyle,
    this.border,
    this.enCode = 'EN',
    this.viCode = 'VI',
  });

  final bool isVILanguage;
  final void Function(bool isViLanguage) onChanged;
  final Size indicatorSize;
  final TextStyle? textStyle;
  final BorderSide? border;
  final String enCode;
  final String viCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final _border = border ??
        BorderSide(
          width: theme.dividerTheme.indent ?? 1,
          color: theme.dividerColor,
        );
    return AnimatedToggleSwitch<bool>.dual(
      current: isVILanguage,
      first: false,
      second: true,
      dif: 0,
      borderColor: _border.color,
      borderWidth: _border.width,
      indicatorSize: indicatorSize,
      height: indicatorSize.height + 2,
      onChanged: onChanged,
      colorBuilder: (b) => Colors.transparent,
      iconBuilder: (value) => ImageView(
        source: value ? Assets.svg.icVi : Assets.svg.icEn,
        package: 'fl_ui',
        width: indicatorSize.width * .8,
        height: indicatorSize.width * .8,
      ),
      textMargin: EdgeInsets.zero,
      textBuilder: (value) => Center(
        child: Text(
          value ? viCode : enCode,
          style: textStyle,
        ),
      ),
    );
  }
}
