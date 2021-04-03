part of 'input_container.dart';

class InputContainerProperties {
  TextEditingController tdController;
  String validation;
  bool isShowPassword;
  FocusNode focusNode;

  InputContainerProperties({
    this.tdController,
    this.validation,
    this.isShowPassword = false,
    this.focusNode,
  }) {
    focusNode ??= FocusNode();
    tdController ??= TextEditingController();
  }
}

class InputContainerController extends ValueNotifier<InputContainerProperties> {
  InputContainerController({InputContainerProperties value})
      : super(value ?? InputContainerProperties());

  String get text => value.tdController.text;

  void resetValidation() {
    value.validation = null;
    notifyListeners();
  }

  void setError(String message) {
    value.focusNode?.requestFocus();
    value.validation = message;
    notifyListeners();
  }

  void reset() {
    value = InputContainerProperties();
    notifyListeners();
  }

  bool get isShowPass => value.isShowPassword;

  void showOrHidePass() {
    value.isShowPassword = !value.isShowPassword;
    notifyListeners();
  }

  set setText(String v) {
    value.tdController.text = v;
    resetValidation();
  }
}
