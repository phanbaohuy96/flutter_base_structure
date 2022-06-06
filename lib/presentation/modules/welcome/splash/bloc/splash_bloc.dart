import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../base/base.dart';
import '../../../../route/route_list.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends AppBlocBase<SplashEvent, SplashState> {
  // late final _configRepo = injector.get<ConfigRepository>();

  SplashBloc() : super(SplashInitialState()) {
    on<SplashInitialEvent>(initial);
  }

  Future<void> initial(
    SplashInitialEvent event,
    Emitter<SplashState> emitter,
  ) async {
    await _configServices();
    // await _configRepo.getAppSetting();
    emitter(SplashFinishState(RouteList.dashBoardRoute));
  }

  Future<void> _configServices() async {
    // final notificationService = injector.get<NotificationService>();
    // injector.get<NotificationManager>().registerService(notificationService);
    // await Future.wait([
    //   injector.get<LocalDataManager>().init(),
    //   injector.get<AuthService>().init(),
    //   notificationService.init(),
    // ]);
  }
}
