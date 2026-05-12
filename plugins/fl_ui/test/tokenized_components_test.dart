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
        home: Scaffold(
          body: Column(
            children: [
              const BadgeBox(count: 3, child: Icon(Icons.notifications)),
              const ErrorBox(validation: 'Required', child: Text('Field')),
              CheckboxWithTitle(
                title: 'Accept terms',
                value: true,
                onChanged: (_) {},
              ),
              RadioButtonWithTitle<int>(
                title: 'Option one',
                value: 1,
                groupValue: 1,
                onChanged: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Accept terms'), findsOneWidget);
    expect(find.text('Option one'), findsOneWidget);
  });
}
