import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';

import 'theme_presets.dart';
import 'theme_preview_options.dart';

class ThemeEditorPanel extends StatelessWidget {
  final ThemeJsonConfig config;
  final ThemePreviewOptions previewOptions;
  final ValueChanged<ThemeJsonConfig> onChanged;
  final ValueChanged<ThemePreviewOptions> onPreviewOptionsChanged;
  final ValueChanged<ThemeJsonConfig> onPresetSelected;

  const ThemeEditorPanel({
    super.key,
    required this.config,
    required this.previewOptions,
    required this.onChanged,
    required this.onPreviewOptionsChanged,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.decorationTheme.spaceMd;

    return ListView(
      key: const ValueKey('theme_controls_list'),
      children: [
        Text('Theme controls', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: spacing),
        _Section(
          title: 'Preset and mode',
          children: [
            _PresetDropdown(
              value: _presetLabel,
              onChanged: (value) {
                final preset =
                    themePresets.firstWhere((it) => it.label == value);
                onPresetSelected(preset.config);
              },
            ),
            _TextEditor(
              label: 'Theme name',
              value: config.name,
              onSubmitted: (value) => onChanged(config.copyWith(name: value)),
            ),
            _ChoiceEditor<Brightness>(
              label: 'Mode',
              value: config.mode,
              values: Brightness.values,
              labelBuilder: (value) => value.name,
              onChanged: (value) => onChanged(config.copyWith(mode: value)),
            ),
            SwitchListTile(
              value: config.useMaterial3,
              title: const Text('Use Material 3'),
              contentPadding: EdgeInsets.zero,
              onChanged: (value) =>
                  onChanged(config.copyWith(useMaterial3: value)),
            ),
            _TextEditor(
              label: 'Font family',
              value: config.fontFamily ?? '',
              helperText: 'Leave empty to use the platform default.',
              onSubmitted: (value) => onChanged(
                config.copyWith(
                  fontFamily: value.trim().isEmpty ? null : value.trim(),
                  includeFontFamily: true,
                ),
              ),
            ),
          ],
        ),
        _Section(
          title: 'Colors',
          children: [
            _ColorEditor(
              label: 'Primary',
              color: config.colors.primary,
              onChanged: (color) => onChanged(
                config.copyWith(colors: config.colors.copyWith(primary: color)),
              ),
            ),
            _ColorEditor(
              label: 'Secondary',
              color: config.colors.secondary,
              onChanged: (color) => onChanged(
                config.copyWith(
                    colors: config.colors.copyWith(secondary: color)),
              ),
            ),
            _ColorEditor(
              label: 'Surface',
              color: config.colors.surface,
              onChanged: (color) => onChanged(
                config.copyWith(colors: config.colors.copyWith(surface: color)),
              ),
            ),
            _ColorEditor(
              label: 'Background',
              color: config.colors.background,
              onChanged: (color) => onChanged(
                config.copyWith(
                    colors: config.colors.copyWith(background: color)),
              ),
            ),
            _ColorEditor(
              label: 'Error',
              color: config.colors.error,
              onChanged: (color) => onChanged(
                config.copyWith(colors: config.colors.copyWith(error: color)),
              ),
            ),
            _ColorEditor(
              label: 'App bar background',
              color: config.colors.appBarBackground,
              onChanged: (color) => onChanged(
                config.copyWith(
                  colors: config.colors.copyWith(appBarBackground: color),
                ),
              ),
            ),
            _ColorEditor(
              label: 'App bar foreground',
              color: config.colors.appBarForeground,
              onChanged: (color) => onChanged(
                config.copyWith(
                  colors: config.colors.copyWith(appBarForeground: color),
                ),
              ),
            ),
          ],
        ),
        _Section(
          title: 'Decoration',
          children: [
            _SliderEditor(
              label: 'Base radius',
              value: config.decoration.radius,
              min: 0,
              max: 32,
              onChanged: (value) => onChanged(
                config.copyWith(
                  decoration: config.decoration.copyWith(radius: value),
                ),
              ),
            ),
            _SliderEditor(
              label: 'Button radius',
              value: config.decoration.buttonRadius,
              min: 0,
              max: 32,
              onChanged: (value) => onChanged(
                config.copyWith(
                  decoration: config.decoration.copyWith(buttonRadius: value),
                ),
              ),
            ),
            _SliderEditor(
              label: 'Input radius',
              value: config.decoration.inputRadius,
              min: 0,
              max: 32,
              onChanged: (value) => onChanged(
                config.copyWith(
                  decoration: config.decoration.copyWith(inputRadius: value),
                ),
              ),
            ),
            _SliderEditor(
              label: 'Chip radius',
              value: config.decoration.chipRadius,
              min: 0,
              max: 40,
              onChanged: (value) => onChanged(
                config.copyWith(
                  decoration: config.decoration.copyWith(chipRadius: value),
                ),
              ),
            ),
            _SliderEditor(
              label: 'Screen padding',
              value: config.decoration.screenPadding,
              min: 8,
              max: 40,
              onChanged: (value) => onChanged(
                config.copyWith(
                  decoration: config.decoration.copyWith(screenPadding: value),
                ),
              ),
            ),
          ],
        ),
        _Section(
          title: 'Typography',
          children: [
            _SliderEditor(
              label: 'Button font size',
              value: config.typography.buttonFontSize,
              min: 12,
              max: 24,
              onChanged: (value) => onChanged(
                config.copyWith(
                  typography: config.typography.copyWith(buttonFontSize: value),
                ),
              ),
            ),
            _ChoiceEditor<int>(
              label: 'Button font weight',
              value: config.typography.buttonFontWeight,
              values: const [100, 200, 300, 400, 500, 600, 700, 800, 900],
              labelBuilder: (value) => value.toString(),
              onChanged: (value) => onChanged(
                config.copyWith(
                  typography:
                      config.typography.copyWith(buttonFontWeight: value),
                ),
              ),
            ),
            _SliderEditor(
              label: 'Body font size',
              value: config.typography.bodyFontSize,
              min: 12,
              max: 22,
              onChanged: (value) => onChanged(
                config.copyWith(
                  typography: config.typography.copyWith(bodyFontSize: value),
                ),
              ),
            ),
          ],
        ),
        _Section(
          title: 'Components',
          children: [
            _SwitchEditor(
              label: 'Filled inputs',
              value: config.components.inputFilled,
              onChanged: (value) => onChanged(
                config.copyWith(
                  components: config.components.copyWith(inputFilled: value),
                ),
              ),
            ),
            _SwitchEditor(
              label: 'Center app bar titles',
              value: config.components.appBarCenterTitle,
              onChanged: (value) => onChanged(
                config.copyWith(
                  components: config.components.copyWith(
                    appBarCenterTitle: value,
                  ),
                ),
              ),
            ),
            _SwitchEditor(
              label: 'Show chip checkmarks',
              value: config.components.chipShowCheckmark,
              onChanged: (value) => onChanged(
                config.copyWith(
                  components: config.components.copyWith(
                    chipShowCheckmark: value,
                  ),
                ),
              ),
            ),
          ],
        ),
        _Section(
          title: 'Screen chrome',
          children: [
            _SwitchEditor(
              label: 'Show header image',
              value: config.screen.showHeaderImage,
              onChanged: (value) => onChanged(
                config.copyWith(
                  screen: config.screen.copyWith(showHeaderImage: value),
                ),
              ),
            ),
            _SwitchEditor(
              label: 'Bottom border radius',
              value: config.screen.hasBottomBorderRadius,
              onChanged: (value) => onChanged(
                config.copyWith(
                  screen: config.screen.copyWith(hasBottomBorderRadius: value),
                ),
              ),
            ),
            _SwitchEditor(
              label: 'App bar divider',
              value: config.screen.showAppbarDivider,
              onChanged: (value) => onChanged(
                config.copyWith(
                  screen: config.screen.copyWith(showAppbarDivider: value),
                ),
              ),
            ),
            _SwitchEditor(
              label: 'Center screen titles',
              value: config.screen.centerTitle,
              onChanged: (value) => onChanged(
                config.copyWith(
                    screen: config.screen.copyWith(centerTitle: value)),
              ),
            ),
          ],
        ),
        _Section(
          title: 'Preview only',
          children: [
            _SwitchEditor(
              label: 'Show device frame',
              value: previewOptions.showDeviceFrame,
              onChanged: (value) => onPreviewOptionsChanged(
                previewOptions.copyWith(showDeviceFrame: value),
              ),
            ),
            _ChoiceEditor<ThemePreviewDevice>(
              label: 'Device',
              value: previewOptions.selectedDevice,
              values: themePreviewDevices,
              labelBuilder: (device) => device.label,
              onChanged: (device) => onPreviewOptionsChanged(
                previewOptions.copyWith(selectedDevice: device),
              ),
            ),
            _ChoiceEditor<Orientation>(
              label: 'Orientation',
              value: previewOptions.orientation,
              values: Orientation.values,
              labelBuilder: (value) => value.name,
              onChanged: (value) => onPreviewOptionsChanged(
                previewOptions.copyWith(orientation: value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String get _presetLabel {
    return themePresets
        .firstWhere(
          (preset) => preset.config.name == config.name,
          orElse: () => themePresets.first,
        )
        .label;
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final decoration = context.decorationTheme;
    return Padding(
      padding: EdgeInsets.only(top: decoration.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: decoration.spaceSm),
          ...children.insertSpacing(SizedBox(height: decoration.spaceSm)),
        ],
      ),
    );
  }
}

class _PresetDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PresetDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Preset',
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: themePresets
              .map(
                (preset) => DropdownMenuItem(
                  value: preset.label,
                  child: Text(preset.label),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

class _ChoiceEditor<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  const _ChoiceEditor({
    required this.label,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: values
              .map(
                (item) => DropdownMenuItem(
                    value: item, child: Text(labelBuilder(item))),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

class _SwitchEditor extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchEditor({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }
}

class _TextEditor extends StatefulWidget {
  final String label;
  final String value;
  final String? helperText;
  final ValueChanged<String> onSubmitted;

  const _TextEditor({
    required this.label,
    required this.value,
    required this.onSubmitted,
    this.helperText,
  });

  @override
  State<_TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<_TextEditor> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
    focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _TextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!focusNode.hasFocus && widget.value != controller.text) {
      controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helperText,
        border: const OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}

class _ColorEditor extends StatefulWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorEditor({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_ColorEditor> createState() => _ColorEditorState();
}

class _ColorEditorState extends State<_ColorEditor> {
  late final TextEditingController controller;
  late final FocusNode focusNode;
  String? error;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: themeColorToHex(widget.color));
    focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _ColorEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = themeColorToHex(widget.color);
    if (!focusNode.hasFocus && nextText != controller.text) {
      controller.text = nextText;
      error = null;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('color_${widget.label}'),
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: 'Use #RRGGBB or #AARRGGBB.',
        errorText: error,
        border: const OutlineInputBorder(),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: const SizedBox(width: 20, height: 20),
          ),
        ),
      ),
      textInputAction: TextInputAction.done,
      onFieldSubmitted: _submit,
    );
  }

  void _submit(String value) {
    try {
      final color = themeColorFromHex(value, path: widget.label);
      setState(() => error = null);
      widget.onChanged(color);
    } on FormatException catch (exception) {
      setState(() => error = exception.message);
    }
  }
}

class _SliderEditor extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderEditor({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(0)}'),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

extension on List<Widget> {
  List<Widget> insertSpacing(Widget separator) {
    if (isEmpty) {
      return this;
    }
    return [
      for (var index = 0; index < length; index++) ...[
        if (index != 0) separator,
        this[index],
      ],
    ];
  }
}
