part of 'base.dart';

abstract class AppBlocBase<E, S> extends Bloc<E, S> {
  AppApiService appApiService = AppApiService()..create();

  AppBlocBase(S s) : super(s);

  void updateHeader(Map<String, String> headers) {
    appApiService.updateHeaders(headers: headers);
  }

  // ignore: use_setters_to_change_properties
  void listenApiError(ApiServiceHandler listener) =>
      appApiService.handlerEror = listener;
}
