import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../common/client_info.dart';
import '../../common/constants/app_locale.dart';
import '../../common/utils.dart';
import '../../data/data_source/local/local_data_manager.dart';
import '../../di/di.dart';
import '../../domain/entities/app_data.dart';
import '../../presentation/theme/theme_data.dart';

@Singleton()
class AppDataBloc extends Cubit<AppData> {
  AppDataBloc._(AppData data) : super(data);

  LocalDataManager get localDataManager => injector.get();

  @factoryMethod
  static Future<AppDataBloc> create() async {
    final localDataManager = injector.get<LocalDataManager>();
    ClientInfo.languageCode = localDataManager.getLocalization() ??
        AppLocale.defaultLocale.languageCode;
    final data = AppData(
      localDataManager.getTheme(),
      Locale(ClientInfo.languageCode),
    );
    return AppDataBloc._(data);
  }

  /// --------------------- Theme ---------------------//
  void changeLightTheme() {
    emit(state.copyWith(
      currentTheme: SupportedTheme.light,
    ));
  }

  void changeDarkTheme() {
    emit(state.copyWith(
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
