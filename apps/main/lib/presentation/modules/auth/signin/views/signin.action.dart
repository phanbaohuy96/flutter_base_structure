part of 'signin_screen.dart';

extension SignInAction on SignInScreenState {
  void loginSuccessCallback() {
    context.openDevMode(pushBehavior: const PushReplacementNamedBehavior());
  }
}
