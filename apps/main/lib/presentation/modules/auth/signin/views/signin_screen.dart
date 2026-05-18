import 'dart:math';

import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../generated/assets.dart';
import '../../../../../l10n/localization_ext.dart';
import '../../../../base/base.dart';
import '../../../../extentions/extention.dart';
import '../bloc/signin_bloc.dart';

part 'signin.action.dart';

class SigninRouteArgs {
  final String? redirectTo;

  const SigninRouteArgs({this.redirectTo});

  factory SigninRouteArgs.fromUrlParams(Map<String, dynamic> queryParameters) =>
      SigninRouteArgs(redirectTo: asOrNull(queryParameters['redirect']));

  dynamic get adaptiveArguments {
    if (kIsWeb) {
      if (redirectTo == null) {
        return null;
      }
      return <String, dynamic>{'redirect': redirectTo};
    }
    return this;
  }
}

class SignInScreen extends StatefulWidget {
  static const String routeName = '/signin';
  static const String usernameKey = 'username_text_input';
  static const String passwordKey = 'password_text_input';
  static const String loginBtnKey = 'login_button';

  const SignInScreen({super.key, this.redirectTo});

  /// Where to land after a successful login. Passed through by
  /// [AuthenticationCoordinator.openSignIn] via [SigninRouteArgs] (route
  /// arguments or `?redirect=` query). Falls back to the dev-mode dashboard.
  final String? redirectTo;

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
    return BlocConsumer<SigninBloc, SigninState>(
      listener: _blocListener,
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: _buildBody(state),
                ),
              ),
            ),
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(bottom: max(paddingBottom, 16)),
              child: Text(
                trans.poweredByApp,
                style: textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(SigninState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Assets.images.png.logo,
            height: 100,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(height: 20),
          Text('My Flutter Base'.hardcode, style: textTheme.titleMedium),
          const SizedBox(height: 30),
          InputContainer(
            key: const Key(SignInScreen.usernameKey),
            title: trans.phoneNumber,
            hint: trans.phoneNumberHint,
            keyboardType: TextInputType.phone,
            text: state.phone,
            onTextChanged: _onPhoneChanged,
          ),
          const SizedBox(height: 16),
          InputContainer(
            key: const Key(SignInScreen.passwordKey),
            title: trans.password,
            hint: trans.passwordHint,
            isPassword: true,
            text: state.password,
            onTextChanged: _onPasswordChanged,
          ),
          if (state is LoginFailed) ...[
            const SizedBox(height: 12),
            Text(
              trans.loginFailed,
              style: textTheme.bodyMedium?.copyWith(
                color: _themeData.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ThemeButton.primary(
              key: const Key(SignInScreen.loginBtnKey),
              title: trans.login,
              onPressed: _canSubmit(state) ? _handleLogin : null,
            ),
          ),
        ],
      ),
    );
  }

  bool _canSubmit(SigninState state) =>
      state.phone.isNotEmpty && state.password.isNotEmpty;
}

extension on SignInScreenState {
  void _blocListener(BuildContext context, SigninState state) {
    if (state is LoginSuccess) {
      loginSuccessCallback();
    }
  }

  void _onPhoneChanged(String value) {
    bloc.add(UpdatePhoneEvent(value));
  }

  void _onPasswordChanged(String value) {
    bloc.add(UpdatePasswordEvent(value));
  }

  void _handleLogin() {
    bloc.add(LoginEvent());
  }
}
