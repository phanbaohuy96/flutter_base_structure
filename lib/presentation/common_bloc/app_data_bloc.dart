import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

import '../../base/bloc_base.dart';
import '../../common/components/i18n/internationalization.dart';
import '../../common/components/preferences_helper/preferences_helper.dart';
import '../../domain/entities/app_data.dart';
import '../../presentation/theme/theme_data.dart';

class AppDataBloc extends BlocBase {
  static AppData appData;
  AppData get getAppData => appData;

  final PublishSubject<AppData> _appDataController;
  Stream<AppData> get appDataStream => _appDataController.stream;
  PreferencesHelper preferencesHelper;

  AppDataBloc() : _appDataController = PublishSubject<AppData>();

  void initial() {
    preferencesHelper = PreferencesHelper();
    appData = AppData(
      preferencesHelper.getTheme(),
      Locale(preferencesHelper.getLocalization() ?? LocaleKey.en),
    );
    notifyAppDataChanged();
  }

  /// --------------------- Theme ---------------------//
  void changeLightTheme() {
    appData.currentTheme = SupportedTheme.light;
    appData.themeData = buildLightTheme().data;
    notifyAppDataChanged();
  }

  void changeDarkTheme() {
    appData.currentTheme = SupportedTheme.dark;
    appData.themeData = buildDarkTheme().data;
    notifyAppDataChanged();
  }

  /// ------------------- End Theme -------------------//

  /// -------------------- Locale --------------------//
  Future<bool> changeLocale(String locale) async {
    if (await preferencesHelper.saveLocalization(locale)) {
      appData.locale = Locale(locale);
      notifyAppDataChanged();
      return true;
    } else {
      return false;
    }
  }

  /// ------------------- End Route ------------------------//
  void notifyAppDataChanged() {
    _appDataController.sink.add(appData);
  }

  @override
  void dispose() {
    _appDataController?.close();
  }
}
