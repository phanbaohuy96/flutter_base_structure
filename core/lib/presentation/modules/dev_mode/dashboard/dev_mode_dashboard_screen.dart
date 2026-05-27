import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/locale/app_locale.dart';
import '../../../common_bloc/app_bloc/app_bloc.dart';
import '../../../common_widget/forms/screen_form.dart';
import '../../../extentions/extention.dart';
import '../dev_mode_coordinator.dart';

class DevModeDashboardScreen extends StatefulWidget {
  static const String routeName = '/dev-mode-dashboard';

  const DevModeDashboardScreen({
    super.key,
    this.openFrom,
  });

  /// A human-readable note about where this screen was opened from, e.g.
  /// "Shaking the device". Shown to the QC team so they know they reached an
  /// intentional tool. Null when the origin is unknown.
  final String? openFrom;

  @override
  State<DevModeDashboardScreen> createState() => _DevModeDashboardScreenState();
}

class _DevModeDashboardScreenState extends State<DevModeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ScreenForm(
      title: 'Dev Mode',
      actions: [
        EnViSwitch(
          isVILanguage:
              context.read<AppGlobalBloc>().state.locale.languageCode ==
              AppLocale.vi.languageCode,
          onChanged: (isViLanguage) {
            context.read<AppGlobalBloc>().changeLocale(
              isViLanguage ? AppLocale.vi : AppLocale.en,
            );
          },
        ),
        IconButton(
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.nightlight
                : Icons.wb_sunny,
            color: context.theme.appBarTheme.foregroundColor,
          ),
          onPressed: () {
            if (Theme.of(context).brightness == Brightness.light) {
              context.read<AppGlobalBloc>().changeDarkTheme();
            } else {
              context.read<AppGlobalBloc>().changeLightTheme();
            }
          },
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DevModeIntro(openFrom: widget.openFrom),
          const SizedBox(height: 24),
          _DevModeTile(
            icon: Icons.article_outlined,
            title: 'Log Viewer',
            subtitle: 'Browse the app logs and console output.',
            onTap: context.openLogViewer,
          ),
          _DevModeTile(
            icon: Icons.lan_outlined,
            title: 'Network Log Viewer',
            subtitle: 'Inspect API requests, responses and timing.',
            onTap: context.openNetWorkLogViewer,
          ),
          _DevModeTile(
            icon: Icons.palette_outlined,
            title: 'Design System',
            subtitle: 'Preview UI components, typography and theme colors.',
            onTap: context.viewDesignSystem,
          ),
          _DevModeTile(
            icon: Icons.settings_outlined,
            title: 'App Config',
            subtitle: 'View and override the runtime app configuration.',
            onTap: context.openAppConfig,
          ),
        ],
      ),
    );
  }
}

/// An at-a-glance explanation of what this screen is, so QC and testers know
/// they reached an intentional tool — not a crash or a hidden bug.
class _DevModeIntro extends StatelessWidget {
  const _DevModeIntro({required this.openFrom});

  final String? openFrom;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.developer_mode,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Developer Mode',
                      style: context.theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A built-in tool for the dev & QC team. Nothing is '
                      'broken — this screen opens on purpose to help test the '
                      'app. From here you can inspect logs and network '
                      'traffic, review the app config, and switch theme or '
                      'language. Tap back to return to the app.',
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (openFrom?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _OpenFromChip(openFrom: openFrom!),
          ],
        ],
      ),
    );
  }
}

/// A small pill showing where the dashboard was opened from.
class _OpenFromChip extends StatelessWidget {
  const _OpenFromChip({required this.openFrom});

  final String openFrom;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 16,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 6),
          Text(
            'Opened from: $openFrom',
            style: context.theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// A single entry in the dev-mode tool list.
class _DevModeTile extends StatelessWidget {
  const _DevModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
