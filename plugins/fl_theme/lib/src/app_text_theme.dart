import 'package:flutter/material.dart';

import 'theme_color.dart';

/// Semantic text role names exposed by [AppTextTheme].
///
/// The first values mirror Flutter's Material 3 [TextTheme] slots. The extra
/// values at the end are app-specific roles for inputs, validation, helpers,
/// and buttons.
enum TextThemeStyle {
  /// Largest of the display styles.
  ///
  /// As the largest text on the screen, display styles are reserved for short,
  /// important text or numerals. They work best on large screens.
  displayLarge,

  /// Middle size of the display styles.
  ///
  /// As the largest text on the screen, display styles are reserved for short,
  /// important text or numerals. They work best on large screens.
  displayMedium,

  /// Smallest of the display styles.
  ///
  /// As the largest text on the screen, display styles are reserved for short,
  /// important text or numerals. They work best on large screens.
  displaySmall,

  /// Largest of the headline styles.
  ///
  /// Headline styles are smaller than display styles. They're best-suited for
  /// short, high-emphasis text on smaller screens.
  headlineLarge,

  /// Middle size of the headline styles.
  ///
  /// Headline styles are smaller than display styles. They're best-suited for
  /// short, high-emphasis text on smaller screens.
  headlineMedium,

  /// Smallest of the headline styles.
  ///
  /// Headline styles are smaller than display styles. They're best-suited for
  /// short, high-emphasis text on smaller screens.
  headlineSmall,

  /// Largest of the title styles.
  ///
  /// Titles are smaller than headline styles and should be used for shorter,
  /// medium-emphasis text.
  titleLarge,

  /// Middle size of the title styles.
  ///
  /// Titles are smaller than headline styles and should be used for shorter,
  /// medium-emphasis text.
  titleMedium,

  /// Smallest of the title styles.
  ///
  /// Titles are smaller than headline styles and should be used for shorter,
  /// medium-emphasis text.
  titleSmall,

  /// Extra-small title role used for dense labels and form metadata.
  titleTiny,

  /// Largest of the body styles.
  ///
  /// Body styles are used for longer passages of text.
  bodyLarge,

  /// Middle size of the body styles.
  ///
  /// Body styles are used for longer passages of text.
  ///
  /// The default text style for [Material].
  bodyMedium,

  /// Smallest of the body styles.
  ///
  /// Body styles are used for longer passages of text.
  bodySmall,

  /// Largest of the label styles.
  ///
  /// Label styles are smaller, utilitarian styles, used for areas of the UI
  /// such as text inside of components or very small supporting text in the
  /// content body, like captions.
  ///
  /// Used for text on [ElevatedButton], [TextButton] and [OutlinedButton].
  labelLarge,

  /// Middle size of the label styles.
  ///
  /// Label styles are smaller, utilitarian styles, used for areas of the UI
  /// such as text inside of components or very small supporting text in the
  /// content body, like captions.
  labelMedium,

  /// Smallest of the label styles.
  ///
  /// Label styles are smaller, utilitarian styles, used for areas of the UI
  /// such as text inside of components or very small supporting text in the
  /// content body, like captions.
  labelSmall,

  /// Text entered into input controls.
  textInput,

  /// Labels and titles for input controls.
  inputTitle,

  /// Required-field indicators and required helper text.
  inputRequired,

  /// Placeholder and hint text inside input controls.
  inputHint,

  /// Validation error text for input controls.
  inputError,

  /// Text used by app button themes.
  buttonText,
}

/// Theme extension that stores the app semantic text theme in [ThemeData].
///
/// It is attached by [AppTheme] and read through `context.textTheme` so widgets
/// can use app-specific roles without reaching into `Theme.of(context)`
/// directly.
class AppTextThemeExtension extends ThemeExtension<AppTextThemeExtension> {
  /// Semantic text theme for app widgets and generated Material themes.
  final AppTextTheme textTheme;

  /// Creates a text theme extension.
  AppTextThemeExtension({required this.textTheme});

  @override
  AppTextThemeExtension copyWith({AppTextTheme? textTheme}) {
    return AppTextThemeExtension(textTheme: textTheme ?? this.textTheme);
  }

  @override
  AppTextThemeExtension lerp(covariant AppTextThemeExtension? other, double t) {
    return AppTextThemeExtension(
      textTheme: textTheme.lerp(other?.textTheme, t),
    );
  }
}

/// Material text theme with app-specific semantic text roles.
///
/// `AppTextTheme` keeps Flutter's Material 3 text slots and adds roles used by
/// this template's inputs, helpers, validation messages, and button themes. It
/// is generated from [ThemeColor] by [AppTextTheme.create], optionally
/// adjusted by typography configuration, and attached to [ThemeData] with
/// [AppTextThemeExtension].
class AppTextTheme extends TextTheme {
  /// Default using [TextTheme.titleSmall] with 85% font size
  ///
  /// If specified
  /// it can apply for [AppTextTheme.inputTitle] & [AppTextTheme.inputError]
  final TextStyle? titleTiny;

  /// Default using [TextTheme.bodyMedium]
  final TextStyle? textInput;

  /// Default using [AppTextTheme.titleTiny] or [TextTheme.titleSmall]
  final TextStyle? inputTitle;

  /// Default using [TextTheme.bodySmall] with color is [Colors.red]
  final TextStyle? inputRequired;

  /// Default using [TextTheme.bodyMedium] with color is [Colors.grey]
  final TextStyle? inputHint;

  /// Default using [AppTextTheme.titleTiny] or [TextTheme.titleSmall]
  /// with color is [Colors.red]
  final TextStyle? inputError;

  /// Default using [TextTheme.labelLarge]
  final TextStyle? buttonText;

  /// Default using [AppTextTheme.titleTiny] or [TextTheme.titleSmall]
  /// with color is [Colors.red]
  final TextStyle? helper;

  /// Creates an app text theme with Material and custom semantic roles.
  ///
  /// Any omitted custom role is derived from the closest Material text slot.
  /// The generated defaults are useful when manually creating a theme, but most
  /// apps should use [AppTextTheme.create] or [AppTypographyTheme.create] so
  /// colors and role overrides stay consistent.
  AppTextTheme({
    super.displayLarge,
    super.displayMedium,
    super.displaySmall,
    super.headlineLarge,
    super.headlineMedium,
    super.headlineSmall,
    super.titleLarge,
    super.titleMedium,
    super.titleSmall,
    TextStyle? titleTiny,
    super.bodyLarge,
    super.bodyMedium,
    super.bodySmall,
    super.labelLarge,
    super.labelMedium,
    super.labelSmall,
    TextStyle? textInput,
    TextStyle? inputTitle,
    TextStyle? inputRequired,
    TextStyle? inputHint,
    TextStyle? inputError,
    TextStyle? helper,
    TextStyle? buttonText,
  }) : titleTiny =
           titleTiny ??
           titleSmall?.copyWith(fontSize: titleSmall.fontSize! * 0.85),
       inputTitle = inputTitle ?? titleTiny ?? titleSmall,
       inputRequired = inputRequired ?? bodySmall!.copyWith(color: Colors.red),
       textInput = textInput ?? bodyMedium,
       inputHint = inputHint ?? bodyMedium?.copyWith(color: Colors.grey),
       inputError =
           inputError ?? (titleTiny ?? titleSmall)?.copyWith(color: Colors.red),
       helper = helper ?? bodySmall,
       buttonText = buttonText ?? labelLarge;

  /// Creates the default semantic text roles from [themeColor].
  ///
  /// The optional [wrapper] is applied to every base [TextStyle]. This is
  /// useful for global font adapters because it runs before custom roles such
  /// as [inputTitle] and [buttonText] are derived or overridden.
  factory AppTextTheme.create(
    ThemeColor themeColor, {
    TextStyle Function(TextStyle)? wrapper,
  }) {
    return AppTextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w600,
        color: themeColor.displayText,
      ).wrapper(wrapper),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        color: themeColor.displayText,
      ).wrapper(wrapper),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: themeColor.displayText,
      ).wrapper(wrapper),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: themeColor.headlineText,
      ).wrapper(wrapper),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: themeColor.headlineText,
      ).wrapper(wrapper),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: themeColor.headlineText,
      ).wrapper(wrapper),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: themeColor.titleText,
      ).wrapper(wrapper),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: themeColor.titleText,
      ).wrapper(wrapper),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: themeColor.titleText,
      ).wrapper(wrapper),
      titleTiny: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: themeColor.titleText,
      ).wrapper(wrapper),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: themeColor.bodyText,
      ).wrapper(wrapper),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: themeColor.bodyText,
      ).wrapper(wrapper),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: themeColor.bodyText,
      ).wrapper(wrapper),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: themeColor.labelText,
      ).wrapper(wrapper),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: themeColor.labelText,
      ).wrapper(wrapper),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: themeColor.labelText,
      ).wrapper(wrapper),
    );
  }

  /// Linearly interpolates every Material and custom text role.
  AppTextTheme lerp(AppTextTheme? other, double t) {
    return AppTextTheme(
      displayLarge: TextStyle.lerp(displayLarge, other?.displayLarge, t),
      displayMedium: TextStyle.lerp(displayMedium, other?.displayMedium, t),
      displaySmall: TextStyle.lerp(displaySmall, other?.displaySmall, t),
      headlineLarge: TextStyle.lerp(headlineLarge, other?.headlineLarge, t),
      headlineMedium: TextStyle.lerp(headlineMedium, other?.headlineMedium, t),
      headlineSmall: TextStyle.lerp(headlineSmall, other?.headlineSmall, t),
      titleLarge: TextStyle.lerp(titleLarge, other?.titleLarge, t),
      titleMedium: TextStyle.lerp(titleMedium, other?.titleMedium, t),
      titleSmall: TextStyle.lerp(titleSmall, other?.titleSmall, t),
      titleTiny: TextStyle.lerp(titleTiny, other?.titleTiny, t),
      bodyLarge: TextStyle.lerp(bodyLarge, other?.bodyLarge, t),
      bodyMedium: TextStyle.lerp(bodyMedium, other?.bodyMedium, t),
      bodySmall: TextStyle.lerp(bodySmall, other?.bodySmall, t),
      labelLarge: TextStyle.lerp(labelLarge, other?.labelLarge, t),
      labelMedium: TextStyle.lerp(labelMedium, other?.labelMedium, t),
      labelSmall: TextStyle.lerp(labelSmall, other?.labelSmall, t),
      textInput: TextStyle.lerp(textInput, other?.textInput, t),
      inputTitle: TextStyle.lerp(inputTitle, other?.inputTitle, t),
      inputRequired: TextStyle.lerp(inputRequired, other?.inputRequired, t),
      inputHint: TextStyle.lerp(inputHint, other?.inputHint, t),
      inputError: TextStyle.lerp(inputError, other?.inputError, t),
      buttonText: TextStyle.lerp(buttonText, other?.buttonText, t),
    );
  }

  /// Creates a copy with selected Material or custom text roles replaced.
  ///
  /// This method intentionally returns [AppTextTheme], unlike Flutter's base
  /// `TextTheme.copyWith`, so custom roles remain available after overrides.
  AppTextTheme copyWithTypography({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? displaySmall,
    TextStyle? headlineLarge,
    TextStyle? headlineMedium,
    TextStyle? headlineSmall,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? titleTiny,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? textInput,
    TextStyle? inputTitle,
    TextStyle? inputRequired,
    TextStyle? inputHint,
    TextStyle? inputError,
    TextStyle? buttonText,
  }) {
    return AppTextTheme(
      displayLarge: displayLarge ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      displaySmall: displaySmall ?? this.displaySmall,
      headlineLarge: headlineLarge ?? this.headlineLarge,
      headlineMedium: headlineMedium ?? this.headlineMedium,
      headlineSmall: headlineSmall ?? this.headlineSmall,
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      titleTiny: titleTiny ?? this.titleTiny,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      labelLarge: labelLarge ?? this.labelLarge,
      labelMedium: labelMedium ?? this.labelMedium,
      labelSmall: labelSmall ?? this.labelSmall,
      textInput: textInput ?? this.textInput,
      inputTitle: inputTitle ?? this.inputTitle,
      inputRequired: inputRequired ?? this.inputRequired,
      inputHint: inputHint ?? this.inputHint,
      inputError: inputError ?? this.inputError,
      buttonText: buttonText ?? this.buttonText,
    );
  }
}

extension on TextStyle {
  TextStyle wrapper(TextStyle Function(TextStyle p1)? wrapper) {
    if (wrapper != null) {
      return wrapper(this);
    }
    return this;
  }
}
