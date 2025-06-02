import 'package:dio/dio.dart' as dio_p;

import '../../../common/constants.dart';
import '../../../common/utils.dart';
import '../../data.dart';

part 'api_service_error.dart';

class AppApiService {
  final RestApiRepository restApi;
  final CoreLocalDataManager localDataManager;

  AppApiService(
    this.restApi,
    this.localDataManager,
  );
}
