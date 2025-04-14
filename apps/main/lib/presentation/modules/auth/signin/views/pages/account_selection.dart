import 'dart:async';
import 'dart:math';

import 'package:core/core.dart';
import 'package:data_source/data_source.dart';
import 'package:flutter/material.dart';

import '../../../../../../domain/entities/auth/response.dart';
import '../../../../../../generated/assets.dart';
import '../../../../../../l10n/localization_ext.dart';
import '../../../../../base/base.dart';
import '../../../../../extentions/extention.dart';
import '../../bloc/signin_bloc.dart';
import '../signin_screen.dart';

class AccountSelection extends StatefulWidget {
  const AccountSelection({super.key});

  @override
  State<AccountSelection> createState() => _AccountSelectionState();
}

class _AccountSelectionState extends StateBase<AccountSelection> {
  @override
  SigninBloc get bloc => BlocProvider.of(context);

  @override
  bool get willHandleError => false;

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
                  child: _buildBody(context, state),
                ),
              ),
            ),
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(bottom: max(paddingBottom, 16)),
              child: Text(
                trans.poweredByVNS,
                style: textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SigninState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Assets.image.logo,
            height: 100,
            fit: BoxFit.fitHeight,
          ),
          const SizedBox(height: 20),
          Text(
            'Flutter Core'.hardcode,
            style: textTheme.titleMedium,
          ),
          const SizedBox(height: 30),
          DropdownWidget<UserModel>(
            title: trans.userRole,
            itemBuilder: (p0) => Text(p0.fullName),
            items: state.users,
            onChanged: state.users.isNotEmpty ? _onRoleChanged : null,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ThemeButton.primary(
              title: trans.login,
              onPressed: _handleLogin,
            ),
          ),
        ],
      ),
    );
  }
}

extension on _AccountSelectionState {
  void _blocListener(BuildContext context, SigninState state) {
    hideLoading();
  }

  void _onRoleChanged(UserModel? user) {
    bloc.add(UpdateSelectedUserModelEvent(user));
  }

  Future _handleLogin() async {
    final selectedUser = bloc.state.selectedUser;
    if (selectedUser == null) {
      showSnackBar(message: trans.pleaseSelectARoleBeforeLoginMsg);
      return;
    }
    showLoading();
    final completer = Completer<AuthResponse>();
    bloc.add(LoginEvent(completer));

    final result = await completer.future;

    switch (result.result) {
      case LoginResultType.failed:
        showSnackBar(message: trans.loginFailed);
        break;

      case LoginResultType.unsupportedRole:
        showSnackBar(message: trans.thisRoleIsNotSupportedYet);
        break;
      default:
    }

    if (result is AuthSuccessResponse) {
      SigninScreenInherited.maybeOf(context)
          ?.state
          .loginSuccessCallback(result);
    }
  }
}
