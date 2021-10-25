import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterbasestructure/common/utils.dart';

import '../../../presentation/common_bloc/app_data_bloc.dart';
import '../../../presentation/route/route_list.dart';
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
    Future.delayed(
      const Duration(seconds: 1),
    ).then((onValue) {
      _launchApp();
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
