import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/client_info.dart';
import '../../common/constants/app_locale.dart';
import '../../common/utils.dart';
import '../../data/data_source/local/local_data_manager.dart';
import '../../di/di.dart';
import '../../domain/entities/app_data.dart';
import '../../presentation/theme/theme_data.dart';

class AppDataBloc extends Cubit<AppData?> {
  AppDataBloc() : super(null);

  LocalDataManager get localDataManager => injector.get();

  Future<void> initial() async {
    if (!isInitialed) {
      ClientInfo.languageCode =
          localDataManager.getLocalization() ?? AppLocale.vi.languageCode;
      emit(AppData(
        localDataManager.getTheme(),
        Locale(ClientInfo.languageCode),
      ));
    }
  }

  bool get isInitialed => state != null;

  /// --------------------- Theme ---------------------//
  void changeLightTheme() {
    emit(state?.copyWith(
      currentTheme: SupportedTheme.light,
    ));
  }

  void changeDarkTheme() {
    emit(state?.copyWith(
      currentTheme: SupportedTheme.dark,
    ));
  }

  /// ------------------- End Theme -------------------//

  /// -------------------- Locale --------------------//
  Future<bool> changeLocale(Locale locale) async {
    if (!AppLocale.isSupported(locale)) {
      LogUtils.w('locale $locale is not supported!');
      return false;
    }
    ClientInfo.languageCode = locale.languageCode;

    if (await localDataManager.saveLocalization(locale.languageCode) == true) {
      emit(state?.copyWith(locale: locale));
      return true;
    } else {
      return false;
    }
  }

  /// ------------------- End Locale ------------------------//
}
