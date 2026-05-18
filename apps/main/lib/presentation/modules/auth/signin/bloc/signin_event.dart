part of 'signin_bloc.dart';

abstract class SigninEvent {}

class UpdatePhoneEvent extends SigninEvent {
  UpdatePhoneEvent(this.phone);
  final String phone;
}

class UpdatePasswordEvent extends SigninEvent {
  UpdatePasswordEvent(this.password);
  final String password;
}

class LoginEvent extends SigninEvent {}
