import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../common/components/i18n/internationalization.dart';
import '../../common/config.dart';
import '../../domain/entities/app_data.dart';
import '../common_bloc/app_data_bloc.dart';
import '../common_widget/text_scale_fixed.dart';
import '../modules/welcome/splash_screen.dart';
import '../route/route.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<App> {
  final AppDataBloc _appDataBloc = AppDataBloc();

  @override
  void initState() {
    //init appdata based on local cache
    _appDataBloc.initial();
    super.initState();
  }

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
            debugShowCheckedModeBanner:
                Config.instance.appConfig.developmentMode == true,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.supportedLocales,
            locale: snapshotTheme.data?.locale ?? S.supportedLocales.first,
            onGenerateRoute: RouteGenerator.buildRoutes,
            home: SplashScreen(),
            builder: EasyLoading.init(
              builder: (_, child) {
                return TextScaleFixed(
                  child: child ?? const SizedBox(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
