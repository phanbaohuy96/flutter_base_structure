import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutterbasestructure/envs.dart';

import '../../base/bloc_provider.dart';
import '../../common/components/i18n/internationalization.dart';
import '../../common/components/preferences_helper/preferences_helper.dart';
import '../../domain/entities/app_data.dart';
import '../common_bloc/app_data_bloc.dart';
import '../route/route.dart';
import '../route/route_list.dart';
import 'welcome/splash_view.dart';

class App extends StatefulWidget {
  final Config config;

  const App({Key key, this.config}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  bool isConfigLoaded = false;
  AppDataBloc _appDataBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PreferencesHelper().init().then((_) {
      setState(() {
        _appDataBloc = AppDataBloc(widget.config);
        isConfigLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isConfigLoaded) {
      return MaterialApp(
        debugShowCheckedModeBanner: widget.config.cheat,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SplashView(),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider<AppDataBloc>(
          create: (BuildContext context) => _appDataBloc,
        ),
      ],
      child: StreamBuilder<AppData>(
        initialData: _appDataBloc.getAppData,
        stream: _appDataBloc.appDataStream,
        builder: (BuildContext context, AsyncSnapshot<AppData> snapshotTheme) {
          return MaterialApp(
            theme: snapshotTheme.data.themeData,
            debugShowCheckedModeBanner: _appDataBloc.getAppData.config.cheat,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale(LocaleKey.en),
              Locale(LocaleKey.vn),
            ],
            locale: snapshotTheme.data.locale,
            onGenerateRoute: RouteGenerator.buildRoutes,
            initialRoute: RouteList.initial,
          );
        },
      ),
    );
  }
}
