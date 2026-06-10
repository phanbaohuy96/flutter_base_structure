// ignore_for_file: unused_element, unused_element_parameter

part of 'signin_bloc.dart';

@freezed
abstract class _StateData with _$StateData {
  const factory _StateData({
    @Default('') final String phone,
    @Default('') final String password,
  }) = __StateData;
}

abstract class SigninState {
  final _StateData data;

  SigninState(this.data);

  T copyWith<T extends SigninState>({_StateData? data}) =>
      resolveState<SigninState, _StateData>(
            _factories,
            requested: T == SigninState ? runtimeType : T,
            data: data ?? this.data,
          )
          as T;

  String get phone => data.phone;
  String get password => data.password;
}

class SigninInitial extends SigninState {
  SigninInitial({_StateData data = const _StateData()}) : super(data);
}

class LoginSuccess extends SigninState {
  LoginSuccess({_StateData data = const _StateData()}) : super(data);
}

class LoginFailed extends SigninState {
  LoginFailed({_StateData data = const _StateData()}) : super(data);
}

final _factories = <Type, SigninState Function(_StateData)>{
  SigninInitial: (data) => SigninInitial(data: data),
  LoginSuccess: (data) => LoginSuccess(data: data),
  LoginFailed: (data) => LoginFailed(data: data),
};
