import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../common/components/i18n/internationalization.dart';
import '../../common/utils.dart';
import '../../data/data_source/local/local_data_manager.dart';
import '../../domain/entities/app_data.dart';
import '../../presentation/theme/theme_data.dart';

class AppDataBloc extends Cubit<dynamic> {
  AppData? _appData;

  AppData? get appData => _appData;

  final PublishSubject<AppData> _appDataController;
  Stream<AppData> get appDataStream => _appDataController.stream;

  AppDataBloc()
      : _appDataController = PublishSubject<AppData>(),
        super(0);

  void initial() {
    if (!isInitialed) {
      _appData = AppData(
        LocalDataManager.getTheme(),
        Locale(LocalDataManager.getLocalization() ?? LocaleKey.vn),
      );
      notifyAppDataChanged();
    }
  }

  bool get isInitialed => _appData != null;

  /// --------------------- Theme ---------------------//
  void changeLightTheme() {
    appData!
      ..currentTheme = SupportedTheme.light
      ..themeData = buildLightTheme().data;
    notifyAppDataChanged();
  }

  void changeDarkTheme() {
    appData!
      ..currentTheme = SupportedTheme.dark
      ..themeData = buildDarkTheme().data;
    notifyAppDataChanged();
  }

  /// ------------------- End Theme -------------------//

  /// -------------------- Locale --------------------//
  Future<bool> changeLocale(String locale) async {
    if (!LocaleKey.isSupported(locale)) {
      LogUtils.w('locale $locale is not supported!');
      return false;
    }

    if (await LocalDataManager.saveLocalization(locale) == true) {
      appData?.locale = Locale(locale);
      notifyAppDataChanged();
      return true;
    } else {
      return false;
    }
  }

  /// ------------------- End Locale ------------------------//
  void notifyAppDataChanged() {
    _appDataController.sink.add(appData!);
  }

  void dispose() {
    _appDataController.close();
  }
}
