import 'dart:async';

import 'package:core/core.dart';
import 'package:data_source/data_source.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../../../domain/entities/auth/response.dart';
import '../../../../../domain/usecases/auth/auth_usecase.dart';
import '../../../../base/base.dart';

part 'signin_bloc.freezed.dart';
part 'signin_event.dart';
part 'signin_state.dart';

@Injectable()
class SigninBloc extends AppBlocBase<SigninEvent, SigninState> {
  final AuthUsecase _authUsecase;

  SigninBloc(
    this._authUsecase,
  ) : super(
          SigninInitial(
            data: const _StateData(),
          ),
        ) {
    on<UpdateSelectedUserModelEvent>(_onUpdateSelectedUserRoleEvent);
    on<GetUserRoleEvent>(_onGetUserRoleEvent);
    on<LoginEvent>(_onLoginEvent);

    add(GetUserRoleEvent());
  }

  Future<void> _onUpdateSelectedUserRoleEvent(
    UpdateSelectedUserModelEvent event,
    Emitter<SigninState> emit,
  ) async {
    emit(
      state.copyWith(
        data: state.data.copyWith(
          selectedUser: event.user,
        ),
      ),
    );
  }

  Future<void> _onGetUserRoleEvent(
    GetUserRoleEvent event,
    Emitter<SigninState> emit,
  ) async {
    final users = await _authUsecase.getUsers();
    emit(
      state.copyWith(
        data: state.data.copyWith(
          users: users,
        ),
      ),
    );
  }

  Future<void> _onLoginEvent(
    LoginEvent event,
    Emitter<SigninState> emit,
  ) async {
    final user = state.selectedUser;
    if (user == null) {
      // Do nothing when role is not selected
      return;
    }
    final result = await _authUsecase.loginWithUser(user: user);

    emit(state.copyWith<LoginSuccess>());

    event.completer.complete(result);
  }
}
