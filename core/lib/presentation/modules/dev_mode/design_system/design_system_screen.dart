import 'package:flutter/material.dart';

import '../../../../core.dart';
import 'pages/buttons_page.dart';
import 'pages/dialogs_and_picker_page.dart';
import 'pages/story_book.dart';
import 'pages/theme_color_page.dart';
import 'pages/typography_page.dart';

class DesignSystemScreen extends StatefulWidget {
  static String routeName = '/devmode-design-system';

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
      child: TabPageWidget(
        length: 5,
        pageController: _pageController,
        isTabScrollable: true,
        tabBuilder: (context, index) => [
          () => const Tab(text: 'Typography'),
          () => const Tab(text: 'Storybook'),
          () => const Tab(text: 'Dialog And Picker'),
          () => const Tab(text: 'Buttom Theme'),
          () => const Tab(text: 'Theme Color'),
        ][index](),
        pageBuilder: (context, index) => [
          const TypographyPage(),
          const WidgetStoryBook(),
          const DialogAndPickerPage(),
          const DesignSystemButtons(),
          const ThemeColorPage(),
        ][index],
      ),
    );
  }
}
