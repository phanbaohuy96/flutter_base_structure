import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'rest_client.g.dart';

////////////////////////////////////////////////////////////////////////
//                  https://pub.dev/packages/retrofit                //
// flutter pub run build_runner build --delete-conflicting-outputs  //
/////////////////////////////////////////////////////////////////////
@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio, {String baseUrl}) = _RestClient;
}
