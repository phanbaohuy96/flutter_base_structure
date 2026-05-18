import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../data/data_source/rest_api_repository.dart';

export 'data_source_micro.module.dart';

@InjectableInit.microPackage(
  externalPackageModulesBefore: [],
)
void initDataSourceMicroPackage() {}

@module
abstract class DataSourceOverrideModule {
  @injectable
  DataSourceRestApiRepository restApiRepo(Dio dio) =>
      DataSourceRestApiRepository(
        dio,
      );
}
