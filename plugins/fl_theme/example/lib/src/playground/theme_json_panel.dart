import 'package:flutter/material.dart';

class ThemeJsonPanel extends StatelessWidget {
  final TextEditingController controller;
  final String? error;
  final VoidCallback onApply;
  final VoidCallback onFormat;
  final VoidCallback onRestore;
  final VoidCallback onCopy;

  const ThemeJsonPanel({
    super.key,
    required this.controller,
    required this.error,
    required this.onApply,
    required this.onFormat,
    required this.onRestore,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('JSON config', style: Theme.of(context).textTheme.titleMedium),
            TextButton(
                onPressed: onRestore, child: const Text('Restore current')),
            TextButton(onPressed: onFormat, child: const Text('Format editor')),
            TextButton(onPressed: onCopy, child: const Text('Copy current')),
            FilledButton(onPressed: onApply, child: const Text('Apply JSON')),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Portable theme JSON only. Colors accept #RRGGBB or #AARRGGBB; '
          'device-frame preview settings are not exported.',
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TextField(
            key: const ValueKey('theme_json_field'),
            controller: controller,
            expands: false,
            maxLines: null,
            minLines: null,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              errorText: error,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
