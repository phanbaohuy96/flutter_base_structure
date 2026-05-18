import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';

import '../../../../theme/export.dart';

class DesignSystemButtons extends StatelessWidget {
  const DesignSystemButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      children: [
        TextButton(
          onPressed: () {},
          child: const Text('TextButton'),
        ),
        const TextButton(
          onPressed: null,
          child: Text('TextButton Disabled'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('ElevatedButton'),
        ),
        const ElevatedButton(
          onPressed: null,
          child: Text('ElevatedButton Disabled'),
        ),
        OutlinedButton(
          onPressed: () {},
          child: const Text('OutlinedButton'),
        ),
        const OutlinedButton(
          onPressed: null,
          child: Text('OutlinedButton Disabled'),
        ),
        ThemeButton.text(
          onPressed: () {},
          title: 'ThemeButton.text',
        ),
        ThemeButton.text(
          title: 'ThemeButton.text Disabled',
        ),
        ThemeButton.outline(
          onPressed: () {},
          title: 'ThemeButton.outline',
        ),
        ThemeButton.outline(
          title: 'ThemeButton.outline Disabled',
        ),
        ThemeButton.primary(
          onPressed: () {},
          title: 'ThemeButton.primary',
        ),
        ThemeButton.primary(
          title: 'ThemeButton.primary Disabled',
        ),
        ThemeButton.secondary(
          onPressed: () {},
          title: 'ThemeButton.secondary',
        ),
        ThemeButton.secondary(
          title: 'ThemeButton.secondary Disabled',
        ),
      ].insertSeparator(
        (index) => const SizedBox(
          height: 16,
        ),
      ),
    );
  }
}
