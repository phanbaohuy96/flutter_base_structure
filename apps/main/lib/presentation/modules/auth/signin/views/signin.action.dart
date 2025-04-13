part of 'signin_screen.dart';

extension SignInAction on SignInScreenState {
  void loginSuccessCallback(
    AuthSuccessResponse response,
  ) {
    showSnackBar(message: 'Login Success');
  }
}
