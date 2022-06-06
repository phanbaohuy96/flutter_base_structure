import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Center(
        child: Image.asset(
          'assets/images/launcher_image.png',
          width: MediaQuery.of(context).size.width * 0.45,
        ),
      ),
    );
  }
}
