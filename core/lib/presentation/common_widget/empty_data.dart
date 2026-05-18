import 'package:fl_media/fl_media.dart';
import 'package:flutter/material.dart';

import '../extentions/context_extention.dart';

class EmptyData extends StatelessWidget {
  final String message;
  final String? icon;
  final double? iconWidth;
  final double? iconHeight;

  const EmptyData({
    Key? key,
    required this.message,
    this.icon,
    this.iconWidth = 200,
    this.iconHeight = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _themeData = context.theme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon,
          const SizedBox(height: 12),
          Text(
            message,
            style: _themeData.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget get _buildIcon {
    if (icon?.isNotEmpty != true) {
      return const SizedBox();
    }

    return ImageView(
      source: icon!,
      width: iconWidth,
      height: iconHeight,
      fit: BoxFit.cover,
    );
  }
}
