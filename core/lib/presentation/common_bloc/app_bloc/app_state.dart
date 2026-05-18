part of 'app_bloc.dart';

class AppGlobalState {
  final ThemeMode themeMode;
  final Locale locale;
  final AppTheme? lightTheme;
  final AppTheme? darkTheme;
  final double scaleFixedFactor;

  const AppGlobalState({
    this.themeMode = ThemeMode.light,
    this.locale = AppLocale.defaultLocale,
    this.lightTheme,
    this.darkTheme,
    this.scaleFixedFactor = 1,
  });

  AppGlobalState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    AppTheme? lightTheme,
    AppTheme? darkTheme,
    double? scaleFixedFactor,
  }) {
    return AppGlobalState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      scaleFixedFactor: scaleFixedFactor ?? this.scaleFixedFactor,
    );
  }
}
