import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../di/di.dart';
import '../l10n/generated/app_localizations.dart';
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
  GoRouter? _router;

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
    _router?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    _didChangeAppLifecycleState(state);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (appBloc.state.themeMode == ThemeMode.system) {
      _updateStatusBarColor();
    }
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

  void _scheduleStatusBarUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateStatusBarColor();
      }
    });
  }

  void _updateStatusBarColor() {
    final currentContext = globalNavigatorKey.currentContext;
    if (currentContext == null) {
      return;
    }

    final themeColor = currentContext.themeColor;
    if (_effectiveBrightness(currentContext) == Brightness.dark) {
      themeColor.setDarkStatusBar();
    } else {
      themeColor.setLightStatusBar();
    }
  }

  Brightness _effectiveBrightness(BuildContext context) {
    switch (appBloc.state.themeMode) {
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.system:
        return MediaQuery.platformBrightnessOf(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => appBloc),
        BlocProvider(create: (_) => injector<LocationCubit>()),
      ],
      child: BlocConsumer<AppGlobalBloc, AppGlobalState>(
        listenWhen: (previous, current) {
          return previous.themeMode != current.themeMode ||
              previous.lightTheme != current.lightTheme ||
              previous.darkTheme != current.darkTheme;
        },
        listener: (_, _) => _scheduleStatusBarUpdate(),
        builder: (context, state) => _buildApplication(state, context),
      ),
    );
  }

  Widget _buildApplication(AppGlobalState state, BuildContext context) {
    return MaterialApp.router(
      title: 'My Flutter Base',
      scrollBehavior: const MobileLikeScrollBehavior(),
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
      routerConfig: _router ??= buildAppRouter(appBloc),
      builder: EasyLoading.init(
        builder: (_, child) {
          return MobileSizeLayoutConstraints(
            child: FlashyFlushbarProvider(
              child: TextScaleFixed(child: child ?? const SizedBox()),
            ),
          );
        },
      ),
    );
  }
}
