//@GeneratedMicroModule;DataSourcePackageModule;package:data_source/src/di/data_source_micro.module.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i687;

import 'package:data_source/src/data/data_source/rest_api_repository.dart'
    as _i975;
import 'package:data_source/src/di/data_source_micro.dart' as _i269;
import 'package:dio/dio.dart' as _i361;
import 'package:injectable/injectable.dart' as _i526;

class DataSourcePackageModule extends _i526.MicroPackageModule {
  // initializes the registration of main-scope dependencies inside of GetIt
  @override
  _i687.FutureOr<void> init(_i526.GetItHelper gh) {
    final dataSourceOverrideModule = _$DataSourceOverrideModule();
    gh.factory<_i975.DataSourceRestApiRepository>(
      () => dataSourceOverrideModule.restApiRepo(gh<_i361.Dio>()),
    );
  }
}

class _$DataSourceOverrideModule extends _i269.DataSourceOverrideModule {}
