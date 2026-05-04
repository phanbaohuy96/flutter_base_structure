import 'package:device_frame/device_frame.dart';
import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';

import 'theme_preview_options.dart';

class ThemePreviewPanel extends StatelessWidget {
  final ThemePreviewOptions options;

  const ThemePreviewPanel({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    const preview = _PreviewScaffold();
    if (!options.showDeviceFrame) {
      return preview;
    }

    return DeviceFrameTheme(
      style: DeviceFrameStyle.dark(),
      child: ColoredBox(
        color: context.themeColor.background,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(context.decorationTheme.spaceLg),
            child: DeviceFrame(
              device: options.selectedDevice.device,
              orientation: options.orientation,
              screen: Theme(data: Theme.of(context), child: preview),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewScaffold extends StatefulWidget {
  const _PreviewScaffold();

  @override
  State<_PreviewScaffold> createState() => _PreviewScaffoldState();
}

class _PreviewScaffoldState extends State<_PreviewScaffold>
    with SingleTickerProviderStateMixin {
  bool checked = true;
  int selectedIndex = 0;
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decoration = context.decorationTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live preview'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Tokens'),
            Tab(text: 'Inputs'),
            Tab(text: 'Chrome'),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(decoration.screenPadding),
        children: [
          const _TypographySection(),
          const _Gap.large(),
          const _ButtonSection(),
          const _Gap.large(),
          _InputSection(),
          const _Gap.large(),
          _SelectionSection(
            checked: checked,
            selectedIndex: selectedIndex,
            onCheckedChanged: (value) {
              setState(() => checked = value ?? false);
            },
            onSelectedIndexChanged: (value) {
              setState(() => selectedIndex = value);
            },
          ),
          const _Gap.large(),
          _NavigationSection(
            selectedIndex: selectedIndex,
            onDestinationSelected: (value) {
              setState(() => selectedIndex = value.clamp(0, 1));
            },
          ),
          const _Gap.large(),
          const _MenuSection(),
          const _Gap.large(),
          const _SurfaceSection(),
          const _Gap.large(),
          const _ScreenChromeSection(),
        ],
      ),
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final decoration = context.decorationTheme;

    return _PreviewSection(
      title: 'Typography roles',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Display role', style: textTheme.displaySmall),
          Text('Headline role', style: textTheme.headlineSmall),
          Text('Title role', style: textTheme.titleLarge),
          Text('Body role from JSON typography', style: textTheme.bodyMedium),
          Text('Input title role', style: textTheme.inputTitle),
          Text('Input error role', style: textTheme.inputError),
          SizedBox(height: decoration.spaceSm),
          FilledButton(onPressed: () {}, child: const Text('Button text role')),
        ],
      ),
    );
  }
}

class _ButtonSection extends StatelessWidget {
  const _ButtonSection();

  @override
  Widget build(BuildContext context) {
    final decoration = context.decorationTheme;
    return _PreviewSection(
      title: 'Buttons',
      child: Wrap(
        spacing: decoration.spaceSm,
        runSpacing: decoration.spaceSm,
        children: [
          ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
          const ElevatedButton(onPressed: null, child: Text('Disabled')),
          OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
          const OutlinedButton(onPressed: null, child: Text('Disabled')),
          TextButton(onPressed: () {}, child: const Text('Text')),
          const TextButton(onPressed: null, child: Text('Disabled')),
        ],
      ),
    );
  }
}

class _InputSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final decoration = context.decorationTheme;
    return _PreviewSection(
      title: 'Inputs',
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Normal input',
              hintText: 'Configured by JSON tokens',
              helperText:
                  'Input radius ${decoration.inputRadius.toStringAsFixed(0)}',
            ),
          ),
          SizedBox(height: decoration.spaceMd),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Error input',
              errorText: 'Error color and text role',
              hintText: 'Validation preview',
            ),
          ),
          SizedBox(height: decoration.spaceMd),
          const TextField(
            enabled: false,
            decoration: InputDecoration(
              labelText: 'Disabled input',
              hintText: 'Disabled border/color preview',
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionSection extends StatelessWidget {
  final bool checked;
  final int selectedIndex;
  final ValueChanged<bool?> onCheckedChanged;
  final ValueChanged<int> onSelectedIndexChanged;

  const _SelectionSection({
    required this.checked,
    required this.selectedIndex,
    required this.onCheckedChanged,
    required this.onSelectedIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = context.decorationTheme;
    return _PreviewSection(
      title: 'Selection components',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            value: checked,
            onChanged: onCheckedChanged,
            title: const Text('Checkbox theme'),
            contentPadding: EdgeInsets.zero,
          ),
          Wrap(
            spacing: decoration.spaceSm,
            runSpacing: decoration.spaceSm,
            children: [
              ChoiceChip(
                label: const Text('Selected chip'),
                selected: selectedIndex == 0,
                onSelected: (_) => onSelectedIndexChanged(0),
              ),
              ChoiceChip(
                label: const Text('Choice chip'),
                selected: selectedIndex == 1,
                onSelected: (_) => onSelectedIndexChanged(1),
              ),
              const Chip(label: Text('Static chip')),
              const InputChip(
                label: Text('Disabled chip'),
                isEnabled: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavigationSection extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _NavigationSection({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return _PreviewSection(
      title: 'Navigation',
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.palette), label: 'Theme'),
          NavigationDestination(icon: Icon(Icons.widgets), label: 'UI'),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    final decoration = context.decorationTheme;
    return _PreviewSection(
      title: 'Menus',
      child: Wrap(
        spacing: decoration.spaceSm,
        runSpacing: decoration.spaceSm,
        children: [
          PopupMenuButton<String>(
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'copy', child: Text('Copy theme')),
              PopupMenuItem(value: 'export', child: Text('Export JSON')),
            ],
            child: const InputChip(label: Text('Popup menu')),
          ),
          MenuAnchor(
            menuChildren: const [
              MenuItemButton(child: Text('Preset action')),
              MenuItemButton(child: Text('Preview action')),
            ],
            builder: (context, controller, child) {
              return FilledButton.tonal(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: const Text('Menu anchor'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SurfaceSection extends StatelessWidget {
  const _SurfaceSection();

  @override
  Widget build(BuildContext context) {
    final decoration = context.decorationTheme;
    final colors = context.themeColor;
    return _PreviewSection(
      title: 'Surfaces and tokens',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(decoration.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Card surface', style: context.textTheme.titleMedium),
                  SizedBox(height: decoration.spaceSm),
                  Text('Primary ${themeColorToHex(colors.primary)}'),
                  Text('Surface ${themeColorToHex(colors.surface)}'),
                  Text('Background ${themeColorToHex(colors.background)}'),
                  Text('Error ${themeColorToHex(colors.error)}'),
                ],
              ),
            ),
          ),
          SizedBox(height: decoration.spaceMd),
          Container(
            padding: EdgeInsets.all(decoration.spaceLg),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: decoration.radiusLgBorder,
              border: Border.all(color: colors.borderColor),
              boxShadow: colors.boxShadowLightest,
            ),
            child: Text(
              'Dialog-like surface with decoration tokens',
              style: context.textTheme.bodyMedium,
            ),
          ),
          SizedBox(height: decoration.spaceMd),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.layers),
            title: Text('Divider and list tile'),
            subtitle: Text('Material surface and text roles'),
          ),
        ],
      ),
    );
  }
}

class _ScreenChromeSection extends StatelessWidget {
  const _ScreenChromeSection();

  @override
  Widget build(BuildContext context) {
    final screen = context.screenTheme;
    final form = screen.screenFormTheme;
    final main = screen.mainPageFormTheme;
    return _PreviewSection(
      title: 'Screen chrome extension',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TokenRow('Form header image', form.showHeaderImage.toString()),
          _TokenRow(
              'Form bottom radius', form.hasBottomBorderRadius.toString()),
          _TokenRow('Form title centered', form.centerTitle.toString()),
          _TokenRow('Form app bar divider', form.showAppbarDivider.toString()),
          _TokenRow('Main header image', main.showHeaderImage.toString()),
          _TokenRow(
              'Main bottom radius', main.hasBottomBorderRadius.toString()),
          _TokenRow('Main app bar divider', main.showAppbarDivider.toString()),
        ],
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  final String label;
  final String value;

  const _TokenRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.decorationTheme.spaceXxs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: context.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _PreviewSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final decoration = context.decorationTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: context.textTheme.titleLarge),
        SizedBox(height: decoration.spaceSm),
        child,
      ],
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap.large();

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: context.decorationTheme.spaceLg);
  }
}
