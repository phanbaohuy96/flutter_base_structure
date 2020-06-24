import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../base/bloc_provider.dart';
import '../../common/components/i18n/internationalization.dart';
import '../../domain/entities/app_data.dart';
import '../../envs.dart';
import '../common_bloc/app_data_bloc.dart';
import '../route/route.dart';
import '../route/route_list.dart';

class App extends StatefulWidget {
  const App({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  final AppDataBloc _appDataBloc = AppDataBloc();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppDataBloc>(
          create: (BuildContext context) => _appDataBloc,
        ),
      ],
      child: StreamBuilder<AppData>(
        initialData: _appDataBloc.appData,
        stream: _appDataBloc.appDataStream,
        builder: (BuildContext context, AsyncSnapshot<AppData> snapshotTheme) {
          return MaterialApp(
            theme: snapshotTheme.data?.themeData ?? ThemeData(),
            debugShowCheckedModeBanner: appConfig.cheat,
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
            locale: snapshotTheme.data?.locale ?? const Locale(LocaleKey.vn),
            onGenerateRoute: RouteGenerator.buildRoutes,
            initialRoute: RouteList.initial,
          );
        },
      ),
    );
  }
}
