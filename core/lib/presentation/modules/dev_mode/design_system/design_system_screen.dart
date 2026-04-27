import 'package:flutter/material.dart';

import '../../../../core.dart';
import 'pages/buttons_page.dart';
import 'pages/chips_page.dart';
import 'pages/dialogs_and_picker_page.dart';
import 'pages/inputs_page.dart';
import 'pages/story_book.dart';
import 'pages/theme_color_page.dart';
import 'pages/typography_page.dart';

class DesignSystemScreen extends StatefulWidget {
  static String routeName = '/dev-mode-design-system';

  const DesignSystemScreen({Key? key}) : super(key: key);

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return ScreenForm(
      title: 'Design System',
      hasBottomBorderRadius: true,
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
      child: TabPageWidget(
        length: 7,
        pageController: _pageController,
        isTabScrollable: true,
        tabBuilder: (context, index) => [
          () => const Tab(text: 'Typography'),
          () => const Tab(text: 'Inputs'),
          () => const Tab(text: 'Chips'),
          () => const Tab(text: 'Buttons'),
          () => const Tab(text: 'Storybook'),
          () => const Tab(text: 'Dialog And Picker'),
          () => const Tab(text: 'Theme Color'),
        ][index](),
        pageBuilder: (context, index) => [
          const TypographyPage(),
          const InputsPage(),
          const ChipsPage(),
          const DesignSystemButtons(),
          const WidgetStoryBook(),
          const DialogAndPickerPage(),
          const ThemeColorPage(),
        ][index],
      ),
    );
  }
}
