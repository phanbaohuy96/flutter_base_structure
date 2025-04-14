import '../../../di/core_micro.dart';
import '../../data.dart';

mixin DataRepository {
  late AppApiService appApiService = injector.get<AppApiService>();

  RestApiRepository get restApi => appApiService.restApi;
}
