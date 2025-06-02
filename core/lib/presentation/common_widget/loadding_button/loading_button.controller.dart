import 'package:flutter/foundation.dart';

enum ButtonState { normal, loading }

class LoadingButtonController {
  final ValueNotifier<ButtonState> buttonState;

  LoadingButtonController({
    ButtonState state = ButtonState.normal,
  }) : buttonState = ValueNotifier(state);

  set changeState(ButtonState state) => buttonState.value = state;

  void setNormalState() {
    buttonState.value = ButtonState.normal;
  }

  void setLoadingState() {
    buttonState.value = ButtonState.loading;
  }

  bool get isLoading => buttonState.value == ButtonState.loading;
}
