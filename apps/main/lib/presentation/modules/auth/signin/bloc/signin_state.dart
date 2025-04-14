// ignore_for_file: unused_element

part of 'signin_bloc.dart';

@freezed
class _StateData with _$StateData {
  const factory _StateData({
    @Default([]) final List<UserModel> users,
    final UserModel? selectedUser,
  }) = __StateData;
}

abstract class SigninState {
  final _StateData data;

  SigninState(this.data);

  T copyWith<T extends SigninState>({
    _StateData? data,
  }) {
    return _factories[T == SigninState ? runtimeType : T]!(
      data ?? this.data,
    );
  }

  List<UserModel> get users => data.users;

  UserModel? get selectedUser => data.selectedUser;
}

class SigninInitial extends SigninState {
  SigninInitial({
    _StateData data = const _StateData(),
  }) : super(data);
}

class LoginSuccess extends SigninState {
  LoginSuccess({
    _StateData data = const _StateData(),
  }) : super(data);
}

final _factories = <Type,
    Function(
  _StateData data,
)>{
  SigninInitial: (data) => SigninInitial(
        data: data,
      ),
  LoginSuccess: (data) => LoginSuccess(
        data: data,
      ),
};
