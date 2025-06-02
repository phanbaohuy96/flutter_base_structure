import 'package:core/core.dart';

import '../../../di/di.dart';
import 'signin/bloc/signin_bloc.dart';
import 'signin/views/signin_screen.dart';

class AuthenticationRoute extends IRoute {
  @override
  List<CustomRouter> routers() {
    return [
      CustomRouter(
        path: SignInScreen.routeName,
        builder: (context, uri, extra) {
          return BlocProvider<SigninBloc>(
            create: (context) => injector.get(),
            child: const SignInScreen(),
          );
        },
        verifier: (uri, extra) {
          return uri.path.startsWith(
            SignInScreen.routeName,
          );
        },
      ),
    ];
  }
}
