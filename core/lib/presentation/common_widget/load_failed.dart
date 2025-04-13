import 'package:flutter/material.dart';

import '../extentions/extention.dart';

class LoadFailed extends StatelessWidget {
  final void Function()? onTap;

  const LoadFailed({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Center(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Failed to load. Tap to retry!',
            style: textTheme.bodySmall?.copyWith(
              color: context.themeColor.primary,
            ),
          ),
        ),
      ),
    );
  }
}
