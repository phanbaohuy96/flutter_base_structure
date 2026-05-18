import 'package:core/core.dart';

import '../../../di/di.dart';
import 'signin/bloc/signin_bloc.dart';
import 'signin/views/signin_screen.dart';

@FlRouteProvider()
class AuthenticationRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter<SigninRouteArgs>(
        path: SignInScreen.routeName,
        name: SignInScreen.routeName,
        builder: (context, uri, extra) {
          final args = extra as SigninRouteArgs?;
          return BlocProvider<SigninBloc>(
            create: (context) => injector.get(),
            child: SignInScreen(redirectTo: args?.redirectTo),
          );
        },
        extraFromUrlQueries: SigninRouteArgs.fromUrlParams,
      ),
    ];
  }
}
