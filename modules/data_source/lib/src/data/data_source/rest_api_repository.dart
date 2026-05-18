import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'rest_api_repository.g.dart';

@RestApi()
abstract class DataSourceRestApiRepository {
  factory DataSourceRestApiRepository(Dio dio) = _DataSourceRestApiRepository;
}
