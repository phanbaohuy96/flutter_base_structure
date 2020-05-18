import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Center(
        child: FlutterLogo(
          size: 60,
        ),
      ),
    );
  }
}
