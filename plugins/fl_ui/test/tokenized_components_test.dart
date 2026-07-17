import 'package:fl_theme/fl_theme.dart';
import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders tokenized fl_ui components', (tester) async {
    final appTheme = AppTheme.create(
      AppThemeConfig(
        designSystem: AppDesignSystem(
          colors: ThemeColor(
            primary: Colors.blue,
            secondary: Colors.lightBlue,
            brightness: Brightness.light,
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: appTheme.theme,
        home: const Scaffold(
          body: Column(
            children: [
              BadgeBox(count: 3, child: Icon(Icons.notifications)),
              ErrorBox(validation: 'Required', child: Text('Field')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
  });
}
