// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import '../data/data_source/local/preferences_helper/preferences_helper.dart'
    as _i5;
import '../data/data_source/remote/app_api_service.dart' as _i3;
import '../presentation/common_bloc/app_data_bloc.dart'
    as _i4; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
_i1.GetIt $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  gh.factory<_i3.AppApiService>(() => _i3.AppApiService());
  gh.singletonAsync<_i4.AppDataBloc>(() => _i4.AppDataBloc.create());
  gh.factory<_i5.PreferencesHelper>(() => _i5.PreferencesHelperImpl());
  return get;
}
