import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'rest_api_repository.g.dart';

///////////////////////////////////////////////////////////////////////
//                https://pub.dev/packages/retrofit                 //
// flutter pub run build_runner build --delete-conflicting-outputs //
////////////////////////////////////////////////////////////////////

@RestApi()
abstract class RestApiRepository {
  factory RestApiRepository(Dio dio, {String baseUrl}) = _RestApiRepository;
}
