import 'package:fl_theme_example/src/theme_playground_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders theme playground sections', (tester) async {
    await tester.pumpWidget(const ThemePlaygroundApp());

    expect(find.text('fl_theme JSON playground'), findsOneWidget);
    expect(find.text('Theme controls'), findsOneWidget);
    expect(find.text('Preset and mode'), findsOneWidget);
    expect(find.text('Colors'), findsOneWidget);
  });

  testWidgets('preset switch updates controls and title', (tester) async {
    await tester.pumpWidget(const ThemePlaygroundApp());

    await tester.tap(find.text('Ocean Blue').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rose Dark').last);
    await tester.pumpAndSettle();

    expect(find.text('Rose Dark'), findsWidgets);
    expect(find.text('Dark mode'), findsNothing);
    expect(find.text('Mode'), findsOneWidget);
  });

  testWidgets('applies JSON edits', (tester) async {
    await tester.pumpWidget(const ThemePlaygroundApp());

    await tester.tap(find.text('JSON'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('theme_json_field')),
      '''
{
  "name": "Test Theme",
  "mode": "light",
  "colors": {
    "primary": "#FF0000",
    "secondary": "#FFF1F2"
  }
}
''',
    );
    await tester.tap(find.text('Apply JSON'));
    await tester.pumpAndSettle();

    expect(find.text('Test Theme'), findsOneWidget);
  });

  testWidgets('invalid JSON shows an error and keeps typed text',
      (tester) async {
    await tester.pumpWidget(const ThemePlaygroundApp());

    await tester.tap(find.text('JSON'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('theme_json_field')),
      '{"colors":{"primary":"nope"}}',
    );
    await tester.tap(find.text('Apply JSON'));
    await tester.pumpAndSettle();

    expect(find.text('colors.primary must be #RRGGBB or #AARRGGBB'),
        findsOneWidget);
    expect(find.textContaining('nope'), findsOneWidget);
  });

  testWidgets('device frame toggle is preview-only', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ThemePlaygroundApp());

    await tester.dragUntilVisible(
      find.text('Show device frame'),
      find.byKey(const ValueKey('theme_controls_list')),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SwitchListTile, 'Show device frame'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('frame')), findsOneWidget);

    await tester.tap(find.text('JSON'));
    await tester.pumpAndSettle();
    expect(find.textContaining('showDeviceFrame'), findsNothing);
    expect(find.textContaining('deviceIndex'), findsNothing);
  });
}
