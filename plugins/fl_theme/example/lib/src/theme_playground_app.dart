import 'package:flutter/material.dart';

import 'playground/theme_playground_screen.dart';

class ThemePlaygroundApp extends StatelessWidget {
  const ThemePlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'fl_theme playground',
      home: ThemePlaygroundScreen(),
    );
  }
}
