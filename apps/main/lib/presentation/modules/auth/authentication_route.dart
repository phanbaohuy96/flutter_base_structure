import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../di/di.dart';
import 'signin/bloc/signin_bloc.dart';
import 'signin/views/signin_screen.dart';

class AuthenticationRoute {
  Map<String, WidgetBuilder> getAll(RouteSettings settings) => {
        SignInScreen.routeName: (context) => BlocProvider<SigninBloc>(
              create: (context) => injector.get(),
              child: const SignInScreen(),
            ),
      };
}
