import 'package:flutter/material.dart';

import '../../l10n/localization_ext.dart';
import '../theme/export.dart';

class InformationPopup extends StatelessWidget {
  final String content;
  final String title;

  const InformationPopup({
    Key? key,
    required this.content,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final localization = context.coreL10n;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            content,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 32,
          ),
          ThemeButton.primary(
            title: localization.close,
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }
}
