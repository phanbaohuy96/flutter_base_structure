import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme_editor_panel.dart';
import 'theme_json_panel.dart';
import 'theme_presets.dart';
import 'theme_preview_options.dart';
import 'theme_preview_panel.dart';

class ThemePlaygroundScreen extends StatefulWidget {
  const ThemePlaygroundScreen({super.key});

  @override
  State<ThemePlaygroundScreen> createState() => _ThemePlaygroundScreenState();
}

class _ThemePlaygroundScreenState extends State<ThemePlaygroundScreen> {
  late ThemeJsonConfig config = themePresets.first.config;
  late AppTheme theme = _buildTheme(config);
  ThemePreviewOptions previewOptions = ThemePreviewOptions();
  late final TextEditingController jsonController;
  String? jsonError;

  @override
  void initState() {
    super.initState();
    jsonController = TextEditingController(text: config.encode());
  }

  @override
  void dispose() {
    jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('fl_theme JSON playground'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: Text(config.name)),
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            final decoration = context.decorationTheme;
            return LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1000;
                final panelHeight = constraints.maxHeight
                    .clamp(560.0, constraints.maxHeight)
                    .toDouble();
                final editor = _buildEditorCard(decoration, panelHeight);
                final preview = _buildPreviewCard(theme.theme, decoration);
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: 420, child: editor),
                      Expanded(child: preview),
                    ],
                  );
                }

                return ListView(
                  padding: EdgeInsets.all(decoration.spaceLg),
                  children: [
                    SizedBox(height: panelHeight, child: editor),
                    SizedBox(height: decoration.spaceLg),
                    SizedBox(height: panelHeight, child: preview),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditorCard(AppDecorationTheme decoration, double panelHeight) {
    return Card(
      margin: EdgeInsets.all(decoration.spaceLg),
      child: Padding(
        padding: EdgeInsets.all(decoration.spaceLg),
        child: DefaultTabController(
          length: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(tabs: [Tab(text: 'Controls'), Tab(text: 'JSON')]),
              SizedBox(height: decoration.spaceMd),
              Flexible(
                fit: FlexFit.loose,
                child: SizedBox(
                  height: panelHeight,
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ThemeEditorPanel(
                        config: config,
                        previewOptions: previewOptions,
                        onChanged: _setConfig,
                        onPreviewOptionsChanged: _setPreviewOptions,
                        onPresetSelected: _setConfig,
                      ),
                      ThemeJsonPanel(
                        controller: jsonController,
                        error: jsonError,
                        onApply: _applyJson,
                        onFormat: _formatJsonEditor,
                        onRestore: _restoreCurrentThemeJson,
                        onCopy: _copyJson,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme, AppDecorationTheme decoration) {
    return Card(
      margin: EdgeInsets.all(decoration.spaceLg),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: theme,
        child: ThemePreviewPanel(options: previewOptions),
      ),
    );
  }

  AppTheme _buildTheme(ThemeJsonConfig config) {
    return AppTheme.create(
      AppThemeConfig(
        designSystem: AppDesignSystem.fromJsonConfig(config),
      ),
    );
  }

  void _setConfig(ThemeJsonConfig nextConfig) {
    setState(() {
      config = nextConfig;
      theme = _buildTheme(config);
      jsonError = null;
      _syncJsonController();
    });
  }

  void _setPreviewOptions(ThemePreviewOptions nextOptions) {
    setState(() => previewOptions = nextOptions);
  }

  void _applyJson() {
    try {
      _setConfig(ThemeJsonConfig.decode(jsonController.text));
    } on FormatException catch (error) {
      setState(() => jsonError = error.message);
    }
  }

  void _formatJsonEditor() {
    try {
      final formatted = ThemeJsonConfig.decode(jsonController.text).encode();
      setState(() {
        jsonController.text = formatted;
        jsonError = null;
      });
    } on FormatException catch (error) {
      setState(() => jsonError = error.message);
    }
  }

  void _restoreCurrentThemeJson() {
    setState(() {
      _syncJsonController();
      jsonError = null;
    });
  }

  void _syncJsonController() {
    final encoded = config.encode();
    if (jsonController.text != encoded) {
      jsonController.text = encoded;
    }
  }

  Future<void> _copyJson() async {
    await Clipboard.setData(ClipboardData(text: config.encode()));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Current theme JSON copied')),
    );
  }
}
