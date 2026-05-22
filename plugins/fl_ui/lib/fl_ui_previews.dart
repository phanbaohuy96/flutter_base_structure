import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'fl_ui.dart';

final ThemeData _materialLightPreviewTheme = _buildPreviewTheme(
  Brightness.light,
);
final ThemeData _materialDarkPreviewTheme = _buildPreviewTheme(Brightness.dark);
final PreviewThemeData _previewTheme = PreviewThemeData(
  materialLight: _materialLightPreviewTheme,
  materialDark: _materialDarkPreviewTheme,
);

PreviewThemeData flUiPreviewTheme() => _previewTheme;

Widget flUiPreviewWrapper(Widget child) {
  return Material(
    color: Colors.transparent,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: child,
        ),
      ),
    ),
  );
}

final class FlUiPreview extends MultiPreview {
  const FlUiPreview({required this.group, required this.size});

  final String group;
  final Size size;

  @override
  List<Preview> get previews => const <Preview>[
    Preview(name: 'Light', brightness: Brightness.light),
    Preview(name: 'Dark', brightness: Brightness.dark),
  ];

  @override
  List<Preview> transform() {
    return super.transform().map((preview) {
      final builder = preview.toBuilder()
        ..group = group
        ..size = size
        ..theme = flUiPreviewTheme
        ..wrapper = flUiPreviewWrapper;
      return builder.build();
    }).toList();
  }
}

ThemeData _buildPreviewTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  return AppTheme.create(
    AppThemeConfig(
      designSystem: AppDesignSystem(
        name: 'fl_ui ${brightness.name}',
        colors: ThemeColor(
          primary: isLight ? const Color(0xFF2563EB) : const Color(0xFF60A5FA),
          secondary: isLight
              ? const Color(0xFF14B8A6)
              : const Color(0xFF2DD4BF),
          brightness: brightness,
          background: isLight
              ? const Color(0xFFF8FAFC)
              : const Color(0xFF0F172A),
          surface: isLight ? Colors.white : const Color(0xFF1E293B),
          scaffoldBackgroundColor: isLight
              ? const Color(0xFFF8FAFC)
              : const Color(0xFF0F172A),
          cardBackground: isLight ? Colors.white : const Color(0xFF1E293B),
          borderColor: isLight
              ? const Color(0xFFE2E8F0)
              : const Color(0xFF475569),
          dividerColor: isLight
              ? const Color(0xFFE2E8F0)
              : const Color(0xFF334155),
        ),
      ),
    ),
  ).theme;
}

void _ignoreTap() {}
void _ignoreBool(bool? _) {}
void _ignoreString(String _) {}
void _ignoreNullableString(String? _) {}
void _ignoreStringList(List<String> _) {}
void _ignoreChipSelection(bool _) {}
String _stringLabel(String item) => item;

@FlUiPreview(group: 'fl_ui / selection', size: Size(393, 720))
Widget flUiSelectionPreview() => const _SelectionPreview();

@FlUiPreview(group: 'fl_ui / feedback', size: Size(393, 620))
Widget flUiFeedbackPreview() => const _FeedbackPreview();

@FlUiPreview(group: 'fl_ui / information', size: Size(393, 680))
Widget flUiInformationPreview() => const _InformationPreview();

@FlUiPreview(group: 'fl_ui / containers', size: Size(393, 560))
Widget flUiContainersPreview() => const _ContainersPreview();

class _SelectionPreview extends StatelessWidget {
  const _SelectionPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewSection(
          title: 'Checkboxes',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CheckboxWithTitle(
                title: 'Selected option',
                value: true,
                onChanged: _ignoreBool,
              ),
              CheckboxWithTitle(
                title: 'Unselected option',
                value: false,
                onChanged: _ignoreBool,
              ),
              CheckboxWithTitle(
                title: 'Disabled option',
                value: true,
                enable: false,
                onChanged: _ignoreBool,
              ),
              CheckBoxGroup<String>(
                items: ['Email', 'Push', 'SMS'],
                selectedItems: ['Email'],
                disableItems: ['SMS'],
                getLabel: _stringLabel,
                onSelectedChanged: _ignoreStringList,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        _PreviewSection(
          title: 'Radio buttons',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RadioButtonWithTitle<String>(
                title: 'Monthly billing',
                value: 'monthly',
                groupValue: 'monthly',
                onChanged: _ignoreNullableString,
              ),
              RadioButtonWithTitle<String>(
                title: 'Annual billing',
                value: 'annual',
                groupValue: 'monthly',
                onChanged: _ignoreNullableString,
              ),
              RadioButtonWithTitle<String>(
                title: 'Unavailable plan',
                value: 'legacy',
                groupValue: 'monthly',
                enable: false,
              ),
              FlRadioGroup<String>(
                items: ['Small', 'Medium', 'Large'],
                selectedItem: 'Medium',
                getLabel: _stringLabel,
                onSelected: _ignoreString,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedbackPreview extends StatelessWidget {
  const _FeedbackPreview();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewSection(
          title: 'Badges',
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              BadgeBox(count: 3, child: Icon(Icons.notifications_outlined)),
              BadgeBox(
                count: 127,
                maxCount: 99,
                child: Icon(Icons.shopping_bag_outlined),
              ),
              BadgeBox(count: 0, child: Icon(Icons.mail_outline)),
            ],
          ),
        ),
        SizedBox(height: 16),
        _PreviewSection(
          title: 'Validation',
          child: ErrorBox(
            validation: 'Please select a value',
            child: _FieldShell(label: 'Project role'),
          ),
        ),
        SizedBox(height: 16),
        _PreviewSection(
          title: 'Loading and availability',
          child: Row(
            children: [
              Loading(radius: 12),
              SizedBox(width: 24),
              AvailabilityWidget(
                enable: false,
                child: _StatusSample(label: 'Disabled action'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InformationPreview extends StatelessWidget {
  const _InformationPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final divider = theme.dividerColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewSection(
          title: 'Info items',
          child: Column(
            children: [
              InfoItem(
                title: 'Customer',
                value: 'Alex Nguyen',
                color: surface,
                divider: ItemDivider.line,
                dividerColor: divider,
                required: true,
              ),
              InfoItem(
                title: 'Status',
                value: StatusBox(
                  status: 'Active',
                  color: theme.colorScheme.primary,
                  textColor: theme.colorScheme.onPrimaryContainer,
                  bgColor: theme.colorScheme.primaryContainer,
                ),
                color: surface,
                divider: ItemDivider.none,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Menu rows',
          child: Column(
            children: [
              MenuItemWidget(
                title: 'Account settings',
                icon: const Icon(Icons.person_outline),
                description: const Text('Updated'),
                color: surface,
                divider: ItemDivider.line,
                onTap: _ignoreTap,
              ),
              MenuItemWidget(
                title: 'Disabled row',
                icon: const Icon(Icons.lock_outline),
                color: surface,
                divider: ItemDivider.none,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Indicators',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Separator(color: divider),
              const SizedBox(height: 16),
              Center(
                child: PageIndicatorWidget(
                  countItem: 4,
                  initialPage: 1,
                  color: divider,
                  colorActive: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContainersPreview extends StatelessWidget {
  const _ContainersPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PreviewSection(
          title: 'Boxes',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              BoxColor(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.all(16),
                child: Text(
                  'BoxColor',
                  style: textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              HighlightBoxColor(
                bgColor: theme.colorScheme.surface,
                borderColor: theme.colorScheme.primary,
                child: const Text('HighlightBoxColor'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _PreviewSection(
          title: 'Chips',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ChipItem(
                selected: true,
                text: 'Selected',
                textTheme: textTheme,
                onTap: _ignoreChipSelection,
              ),
              ChipItem(
                selected: false,
                text: 'Default',
                textTheme: textTheme,
                onTap: _ignoreChipSelection,
              ),
              StatusBox(
                status: 'Pending',
                color: theme.colorScheme.secondary,
                textColor: theme.colorScheme.onSecondaryContainer,
                bgColor: theme.colorScheme.secondaryContainer,
                hasBorder: true,
              ),
              StatusBox(
                status: 'Done',
                color: theme.colorScheme.primary,
                textColor: theme.colorScheme.onPrimaryContainer,
                bgColor: theme.colorScheme.primaryContainer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StoryWidgetBox<Object?>(
      title: title,
      builder: (context, _, _) => child,
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return BoxColor(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: Text(label),
    );
  }
}

class _StatusSample extends StatelessWidget {
  const _StatusSample({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(onPressed: _ignoreTap, child: Text(label));
  }
}
