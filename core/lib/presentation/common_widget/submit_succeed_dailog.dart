import 'package:fl_media/fl_media.dart';
import 'package:flutter/material.dart';

import '../extentions/context_extention.dart';

class SubmitSucceedDailog extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final String message;
  final dynamic icon;
  final String btnTitle;
  final void Function() onConfirm;

  const SubmitSucceedDailog({
    Key? key,
    required this.title,
    this.titleColor,
    required this.message,
    required this.btnTitle,
    required this.onConfirm,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = context.textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: size.width * 0.38 * 0.76,
                  child: _buildIcon(size.width * 0.38),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(color: titleColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.black,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 48.0,
                  minWidth: 140,
                ),
                child: ElevatedButton(
                  onPressed: onConfirm,
                  child: Text(btnTitle),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(double iconSize) {
    if (icon is Widget) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: iconSize,
          minHeight: iconSize,
        ),
        child: icon,
      );
    }
    if (icon is IconData) {
      return Icon(
        icon,
        size: iconSize,
      );
    }
    if (icon is! String) {
      return const SizedBox();
    }
    return ImageView(
      source: icon,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.cover,
    );
  }
}
