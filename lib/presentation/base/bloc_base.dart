part of 'base.dart';

abstract class AppBlocBase<E, S> extends Bloc<E, S> {
  AppApiService appApiService = AppApiService()..create();

  LocalDataManager get localDataManager => injector.get();

  // TODO: implement `isLoggedIn`
  // bool get isLoggedIn => localDataManager.getToken()?.isNotEmpty == true;

  AppBlocBase(S s) : super(s);

  void updateHeader(Map<String, String> headers) {
    appApiService.updateHeaders(headers: headers);
  }

  // ignore: use_setters_to_change_properties
  void registerDelegate(ApiServiceDelegate delegate) =>
      appApiService.apiServiceDelegate = delegate;
}
