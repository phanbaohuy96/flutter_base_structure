import 'package:flutter/material.dart';

import '../../../base/bloc_provider.dart';
import '../../../common/components/preferences_helper/preferences_helper.dart';
import '../../../common/utils/dimension.dart';
import '../../../common/utils/log_utils.dart';
import '../../../presentation/common_bloc/app_data_bloc.dart';
import '../../../presentation/route/route_list.dart';
import '../../theme/text_utils.dart';
import 'splash_view.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PreferencesHelper().init().then((_) {
      //init appdata based on local cache
      BlocProvider.of<AppDataBloc>(context).initial();

      final MediaQueryData data = MediaQuery.of(context);
      Dimension.setup(data);
      TextSize.textScaleFactor = data.textScaleFactor;

      Future.delayed(
        const Duration(seconds: 1),
      ).then((onValue) {
        _launchApp();
      });
    });
  }

  void _launchApp() {
    Navigator.of(context).pushReplacementNamed(RouteList.dashBoardRoute);
  }

  @override
  Widget build(BuildContext context) {
    LogUtils.i('[SplashScreen] build');

    return Scaffold(
      body: SplashView(),
    );
  }
}
