import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info/package_info.dart';

import '../../../../common/client_info.dart';
import '../../../../common/constants.dart';
import '../../../base/base.dart';
import '../../../common_widget/after_layout.dart';
import '../../../extentions/extention.dart';
import '../../../theme/theme_color.dart';
import 'bloc/splash_bloc.dart';

part 'splash_action.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends StateBase<SplashScreen> with AfterLayoutMixin {
  @override
  void afterFirstLayout(BuildContext context) {
    getClientInfo();
  }

  @override
  SplashBloc get bloc => BlocProvider.of<SplashBloc>(context);

  late ThemeData _themeData;

  TextTheme get textTheme => _themeData.textTheme;

  @override
  Widget build(BuildContext context) {
    _themeData = Theme.of(context);
    return Scaffold(
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          final nextScreen = state.nextScreen;
          if (nextScreen == null) {
            return;
          }
          Navigator.pushNamedAndRemoveUntil(
            context,
            nextScreen,
            (route) => false,
          );
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(ImageConstant.logoImage),
                  const SizedBox(height: 12),
                  Text(
                    translate(context).appName.toUpperCase(),
                    style: textTheme.bodyText1!.copyWith(
                      color: AppColor.subText,
                      fontWeight: FontWeight.normal,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Text(
                'Powered By Flutter Base Tructure',
                style: textTheme.bodyText2!.copyWith(
                  color: AppColor.subText,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
