import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/locale/app_locale.dart';
import '../../../common_bloc/app_bloc/app_bloc.dart';
import '../../../common_widget/forms/screen_form.dart';
import '../../../extentions/extention.dart';
import '../devmode_coordinator.dart';

class DevModeDashboardScreen extends StatefulWidget {
  static String routeName = '/devmode_dashboard';
  const DevModeDashboardScreen({super.key});

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
                  AppLocale.th.languageCode,
          onChanged: (isViLanguage) {
            context
                .read<AppGlobalBloc>()
                .changeLocale(isViLanguage ? AppLocale.th : AppLocale.en);
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
          TextButton(
            onPressed: context.openLogViewer,
            child: const Text('Log Viewer'),
          ),
          TextButton(
            onPressed: context.openNetWorkLogViewer,
            child: const Text('Network Log Viewer'),
          ),
          TextButton(
            onPressed: context.viewDesignSystem,
            child: const Text('Design System'),
          ),
          TextButton(
            onPressed: context.openAppConfig,
            child: const Text('App Config'),
          ),
        ],
      ),
    );
  }
}
