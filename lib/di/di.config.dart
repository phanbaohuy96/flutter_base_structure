// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i6;

import '../data/data_source/local/local_data_manager.dart' as _i4;
import '../data/data_source/local/preferences_helper/preferences_helper.dart'
    as _i5;
import '../data/data_source/remote/app_api_service.dart' as _i3;
import 'di.dart' as _i7; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
Future<_i1.GetIt> $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) async {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final appModule = _$AppModule();
  gh.factory<_i3.AppApiService>(() => _i3.AppApiService());
  gh.singleton<_i4.LocalDataManager>(_i4.LocalDataManager());
  gh.factory<_i5.PreferencesHelper>(() => _i5.PreferencesHelperImpl());
  await gh.factoryAsync<_i6.SharedPreferences>(
      () => appModule.sharedPreferences,
      preResolve: true);
  return get;
}

class _$AppModule extends _i7.AppModule {}
