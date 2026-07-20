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
            dividerColor: const Color(0xFF123456),
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
              SizedBox(
                width: 12,
                child: Separator(key: ValueKey('default-separator')),
              ),
              SizedBox(
                width: 12,
                child: Separator(
                  key: ValueKey('override-separator'),
                  color: Color(0xFF654321),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('3'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);

    BoxDecoration separatorDecoration(String key) {
      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byKey(ValueKey(key)),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return decoratedBox.decoration as BoxDecoration;
    }

    expect(
      separatorDecoration('default-separator').color,
      const Color(0xFF123456),
    );
    expect(
      separatorDecoration('override-separator').color,
      const Color(0xFF654321),
    );
  });
}
