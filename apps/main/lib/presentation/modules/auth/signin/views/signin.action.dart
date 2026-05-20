part of 'signin_screen.dart';

extension SignInAction on SignInScreenState {
  void loginSuccessCallback() {
    final destination = widget.redirectTo ?? DevModeDashboardScreen.routeName;
    const PushReplacementNamedBehavior().push(context, destination);
  }
}
