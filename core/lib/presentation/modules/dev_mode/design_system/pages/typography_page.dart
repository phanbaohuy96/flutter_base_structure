import 'package:fl_theme/fl_theme.dart';
import 'package:flutter/material.dart';

class TypographyPage extends StatelessWidget {
  const TypographyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return ListView(
      padding: const EdgeInsets.all(16).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      children: [
        ...TextThemeStyle.values.map((e) {
          final style = e.style(textTheme);

          return TextStyleItem(
            name: e.name,
            style: e.style(textTheme),
            text: '''family: ${style.fontFamily}
weight: ${style.fontWeightText}
size: ${style.fontSize}''',
          );
        }),
      ],
    );
  }
}

class TextStyleItem extends StatelessWidget {
  const TextStyleItem({
    Key? key,
    required this.name,
    required this.style,
    required this.text,
  }) : super(key: key);

  final String name;
  final TextStyle style;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8).copyWith(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(name, style: style),
          const SizedBox(height: 12),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 2,
                  color: Colors.grey,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const Divider(
            height: 16,
          ),
        ],
      ),
    );
  }
}

extension TextThemeStyleExt on TextThemeStyle {
  TextStyle style(AppTextTheme textTheme) {
    switch (this) {
      case TextThemeStyle.displayLarge:
        return textTheme.displayLarge!;
      case TextThemeStyle.displayMedium:
        return textTheme.displayMedium!;
      case TextThemeStyle.displaySmall:
        return textTheme.displaySmall!;
      case TextThemeStyle.headlineLarge:
        return textTheme.headlineLarge!;
      case TextThemeStyle.headlineMedium:
        return textTheme.headlineMedium!;
      case TextThemeStyle.headlineSmall:
        return textTheme.headlineSmall!;
      case TextThemeStyle.titleLarge:
        return textTheme.titleLarge!;
      case TextThemeStyle.titleMedium:
        return textTheme.titleMedium!;
      case TextThemeStyle.titleSmall:
        return textTheme.titleSmall!;
      case TextThemeStyle.titleTiny:
        return textTheme.titleTiny!;
      case TextThemeStyle.bodyLarge:
        return textTheme.bodyLarge!;
      case TextThemeStyle.bodyMedium:
        return textTheme.bodyMedium!;
      case TextThemeStyle.bodySmall:
        return textTheme.bodySmall!;
      case TextThemeStyle.labelLarge:
        return textTheme.labelLarge!;
      case TextThemeStyle.labelMedium:
        return textTheme.labelMedium!;
      case TextThemeStyle.labelSmall:
        return textTheme.labelSmall!;
      case TextThemeStyle.textInput:
        return textTheme.textInput!;
      case TextThemeStyle.inputTitle:
        return textTheme.inputTitle!;
      case TextThemeStyle.inputRequired:
        return textTheme.inputRequired!;
      case TextThemeStyle.inputHint:
        return textTheme.inputHint!;
      case TextThemeStyle.inputError:
        return textTheme.inputError!;
      case TextThemeStyle.buttonText:
        return textTheme.buttonText!;
    }
  }
}

extension FontWeightExtension on TextStyle {
  String get fontWeightText {
    switch (fontWeight) {
      case FontWeight.w100:
        return 'w${fontWeight!.value} | thin';
      case FontWeight.w200:
        return 'w${fontWeight!.value} | extra-light';
      case FontWeight.w300:
        return 'w${fontWeight!.value} | light';
      case FontWeight.w400:
        return 'w${fontWeight!.value} | regular';
      case FontWeight.w500:
        return 'w${fontWeight!.value} | medium';
      case FontWeight.w600:
        return 'w${fontWeight!.value} | semi-bold';
      case FontWeight.w700:
        return 'w${fontWeight!.value} | bold';
      case FontWeight.w800:
        return 'w${fontWeight!.value} | extra-bold';
      case FontWeight.w900:
        return 'w${fontWeight!.value} | black';
      default:
        return 'w${fontWeight?.value} | normal';
    }
  }
}
