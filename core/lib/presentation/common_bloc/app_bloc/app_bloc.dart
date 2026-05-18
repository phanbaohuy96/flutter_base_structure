import 'dart:async';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../core.dart';

part 'app_state.dart';

@Injectable()
class AppGlobalBloc extends Cubit<AppGlobalState> {
  @factoryMethod
  factory AppGlobalBloc.injectable({
    @factoryParam AppGlobalState appData = const AppGlobalState(),
    required CoreLocalDataManager ldm,
  }) {
    ClientInfo.languageCode =
        ldm.getLocalization() ?? AppLocale.defaultLocale.languageCode;
    final data = appData.copyWith(
      themeMode:
          ldm.getTheme()?.let((it) => ThemeMode.values[it]) ?? ThemeMode.light,
      locale: Locale(ClientInfo.languageCode),
    );
    return AppGlobalBloc._(ldm, data);
  }

  AppGlobalBloc._(this.localDataManager, AppGlobalState data) : super(data);

  final CoreLocalDataManager localDataManager;

  /// --------------------- Theme ---------------------//
  void changeLightTheme() {
    localDataManager.setTheme(ThemeMode.light.index);
    emit(
      state.copyWith(
        themeMode: ThemeMode.light,
      ),
    );
  }

  void changeDarkTheme() {
    localDataManager.setTheme(ThemeMode.dark.index);
    emit(
      state.copyWith(
        themeMode: ThemeMode.dark,
      ),
    );
  }

  void changeSystemTheme() {
    localDataManager.setTheme(ThemeMode.system.index);
    emit(
      state.copyWith(
        themeMode: ThemeMode.system,
      ),
    );
  }

  void updateTheme({
    AppTheme? lightTheme,
    AppTheme? darkTheme,
  }) {
    emit(
      state.copyWith(
        lightTheme: lightTheme,
        darkTheme: darkTheme,
      ),
    );
  }

  /// ------------------- End Theme -------------------//

  /// -------------------- Locale --------------------//
  Future<bool> changeLocale(Locale locale) async {
    if (!AppLocale.isSupported(locale)) {
      logUtils.w('locale $locale is not supported!');
      return false;
    }

    if (await localDataManager.saveLocalization(locale.languageCode) == true) {
      ClientInfo.languageCode = locale.languageCode;
      emit(state.copyWith(locale: locale));
      return true;
    } else {
      return false;
    }
  }

  /// ------------------- End Locale ------------------------//
}
