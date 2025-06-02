import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../di/di.dart';
import '../l10n/generated/app_localizations.dart';
import 'modules/auth/signin/views/signin_screen.dart';
import 'route/route.dart';
import 'theme/theme.dart';

class MainApplication extends StatefulWidget {
  const MainApplication({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MainApplication>
    with WidgetsBindingObserver, AfterLayoutMixin {
  final themeSetting = MainAppTheme.normal();

  late final appBloc = injector<AppGlobalBloc>(
    param1: AppGlobalState(
      lightTheme: themeSetting.light,
      darkTheme: themeSetting.dark,
    ),
  );

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    _didChangeAppLifecycleState(state);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _updateStatusBarColor();
  }

  void _didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateStatusBarColor();
    }
  }

  void _updateStatusBarColor() {
    if (appBloc.state.themeMode == ThemeMode.dark) {
      globalNavigatorKey.currentContext?.themeColor.setDarkStatusBar();
    } else {
      globalNavigatorKey.currentContext?.themeColor.setLightStatusBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => appBloc),
        BlocProvider(create: (_) => injector<LocationCubit>()),
      ],
      child: BlocBuilder<AppGlobalBloc, AppGlobalState>(
        builder: (context, state) {
          return MaterialApp(
            theme: state.lightTheme?.theme,
            darkTheme: state.darkTheme?.theme,
            themeMode: state.themeMode,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              FlMediaLocalizations.delegate,
              CoreLocalizations.delegate,
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocale.supportedLocales,
            locale: state.locale,
            onGenerateRoute: (s) => injector<RouteGenerator>().generateRoute(
              s,
              supportUnknownRoute: false,
            ),
            navigatorObservers: [myNavigatorObserver],
            navigatorKey: globalNavigatorKey,
            initialRoute: SignInScreen.routeName,
            builder: EasyLoading.init(
              builder: (_, child) {
                return MobileSizeLayoutConstraints(
                  child: TextScaleFixed(
                    child: child ?? const SizedBox(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
