import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../../domain/entities/auth/response.dart';
import '../../../../../l10n/localization_ext.dart';
import '../../../../base/base.dart';
import '../../../../extentions/extention.dart';
import '../bloc/signin_bloc.dart';
import 'pages/account_selection.dart';

part 'signin.action.dart';

class SignInScreen extends StatefulWidget {
  static String routeName = '/signin';
  static const String usernameKey = 'username_text_input';
  static const String passwordKey = 'password_text_input';
  static const String loginBtnKey = 'login_button';

  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => SignInScreenState();
}

class SignInScreenState extends StateBase<SignInScreen> {
  @override
  SigninBloc get bloc => BlocProvider.of(context);

  late ThemeData _themeData;

  TextTheme get textTheme => _themeData.textTheme;

  late AppLocalizations trans;

  @override
  Widget build(BuildContext context) {
    _themeData = context.theme;
    trans = translate(context);

    return SigninScreenInherited(state: this, child: const AccountSelection());
  }
}

class SigninScreenInherited extends InheritedWidget {
  const SigninScreenInherited({
    super.key,
    required this.state,
    required super.child,
  });

  final SignInScreenState state;

  static SigninScreenInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SigninScreenInherited>();
  }

  static SigninScreenInherited of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No SigninScreenInherited found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(SigninScreenInherited oldWidget) =>
      state != oldWidget.state;
}
