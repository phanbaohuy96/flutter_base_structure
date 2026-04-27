import 'package:flutter/material.dart';

class ChipsPage extends StatefulWidget {
  const ChipsPage({super.key});

  @override
  State<ChipsPage> createState() => _ChipsPageState();
}

class _ChipsPageState extends State<ChipsPage> {
  bool _isSelected1 = false;
  bool _isSelected2 = true;
  bool _isSelected3 = false;
  final Set<int> _selectedFilters = {1};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(
        16,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      children: [
        // Basic Chips
        Text('Basic Chips', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: const Text('Default Chip'), onDeleted: () {}),
            const Chip(label: Text('Simple Chip')),
            Chip(
              label: const Text('With Avatar'),
              avatar: CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: const Text('A'),
              ),
            ),
            Chip(
              label: const Text('With Icon'),
              avatar: Icon(Icons.star, size: 18, color: colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Action Chips
        Text('Action Chips', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ActionChip(label: const Text('Action Chip'), onPressed: () {}),
            ActionChip(
              label: const Text('With Icon'),
              avatar: const Icon(Icons.add, size: 18),
              onPressed: () {},
            ),
            const ActionChip(label: Text('Disabled'), onPressed: null),
          ],
        ),
        const SizedBox(height: 24),

        // Filter Chips
        Text('Filter Chips', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('Filter 1'),
              selected: _selectedFilters.contains(1),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFilters.add(1);
                  } else {
                    _selectedFilters.remove(1);
                  }
                });
              },
            ),
            FilterChip(
              label: const Text('Filter 2'),
              selected: _selectedFilters.contains(2),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFilters.add(2);
                  } else {
                    _selectedFilters.remove(2);
                  }
                });
              },
            ),
            FilterChip(
              label: const Text('Filter 3'),
              selected: _selectedFilters.contains(3),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFilters.add(3);
                  } else {
                    _selectedFilters.remove(3);
                  }
                });
              },
            ),
            const FilterChip(
              label: Text('Disabled'),
              selected: false,
              onSelected: null,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Choice Chips
        Text('Choice Chips', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Choice 1'),
              selected: _isSelected1,
              onSelected: (selected) {
                setState(() => _isSelected1 = selected);
              },
            ),
            ChoiceChip(
              label: const Text('Choice 2'),
              selected: _isSelected2,
              onSelected: (selected) {
                setState(() => _isSelected2 = selected);
              },
            ),
            ChoiceChip(
              label: const Text('Choice 3'),
              selected: _isSelected3,
              onSelected: (selected) {
                setState(() => _isSelected3 = selected);
              },
            ),
            ChoiceChip(
              label: const Text('With Avatar'),
              selected: false,
              avatar: const Icon(Icons.check_circle, size: 18),
              onSelected: (selected) {},
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Input Chips
        Text('Input Chips', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            InputChip(
              label: const Text('Input Chip'),
              onPressed: () {},
              onDeleted: () {},
            ),
            InputChip(
              label: const Text('With Avatar'),
              avatar: CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: const Text('B'),
              ),
              onPressed: () {},
              onDeleted: () {},
            ),
            InputChip(
              label: const Text('Selected'),
              selected: true,
              onPressed: () {},
              onDeleted: () {},
            ),
            InputChip(
              label: const Text('Disabled'),
              isEnabled: false,
              onPressed: () {},
              onDeleted: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chip Sizes
        Text('Chip Sizes', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(
              label: Text('Small'),
              labelPadding: EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),
            Chip(label: Text('Default')),
            Chip(
              label: Text('Large'),
              labelPadding: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Custom Styled Chips
        Text('Custom Styled Chips', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: const Text('Primary'),
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: colorScheme.primary),
              side: BorderSide(color: colorScheme.primary),
            ),
            Chip(
              label: const Text('Secondary'),
              backgroundColor: colorScheme.secondary.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: colorScheme.secondary),
              side: BorderSide(color: colorScheme.secondary),
            ),
            Chip(
              label: const Text('Error'),
              backgroundColor: colorScheme.error.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: colorScheme.error),
              side: BorderSide(color: colorScheme.error),
            ),
            Chip(
              label: const Text('Surface'),
              backgroundColor: colorScheme.surface,
              elevation: 2,
            ),
          ],
        ),
      ],
    );
  }
}
