part of 'signin_bloc.dart';

abstract class SigninEvent {}

class GetUserRoleEvent extends SigninEvent {}

class UpdateSelectedUserModelEvent extends SigninEvent {
  final UserModel? user;

  UpdateSelectedUserModelEvent(this.user);
}

class LoginEvent extends SigninEvent {
  final Completer<AuthResponse> completer;

  LoginEvent(this.completer);
}
