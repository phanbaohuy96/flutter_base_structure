import '../data/data_source/remote/app_api_service.dart';

abstract class BlocBase {
  AppApiService appApiService = AppApiService();

  BlocBase() {
    appApiService.create();
  }

  void dispose();
}
