import 'dart:async';

import 'package:core/core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../domain/usecases/auth/auth_usecase.dart';

part 'signin_bloc.freezed.dart';
part 'signin_event.dart';
part 'signin_state.dart';

@Injectable()
class SigninBloc extends CoreBlocBase<SigninEvent, SigninState> {
  final AuthUsecase _authUsecase;

  SigninBloc(this._authUsecase)
    : super(SigninInitial(data: const _StateData())) {
    on<UpdatePhoneEvent>(_onUpdatePhone);
    on<UpdatePasswordEvent>(_onUpdatePassword);
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onUpdatePhone(
    UpdatePhoneEvent event,
    Emitter<SigninState> emit,
  ) async {
    emit(state.copyWith(data: state.data.copyWith(phone: event.phone.trim())));
  }

  Future<void> _onUpdatePassword(
    UpdatePasswordEvent event,
    Emitter<SigninState> emit,
  ) async {
    emit(state.copyWith(data: state.data.copyWith(password: event.password)));
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<SigninState> emit,
  ) async {
    if (state is LoginSuccess) {
      return;
    }
    if (state.phone.isEmpty || state.password.isEmpty) {
      return;
    }

    showLoading();
    try {
      final user = await _authUsecase.loginWithPhoneNumberPassword(
        phoneNumber: state.phone,
        password: state.password,
      );
      if (user == null) {
        emit(state.copyWith<LoginFailed>());
      } else {
        emit(state.copyWith<LoginSuccess>());
      }
    } finally {
      hideLoading();
    }
  }
}
