part of 'input_container.dart';

class InputContainerProperties {
  TextEditingController tdController;
  String? validation;
  String? warning;
  bool isShowPassword;
  FocusNode focusNode;

  InputContainerProperties({
    TextEditingController? tdController,
    this.validation,
    this.isShowPassword = false,
    FocusNode? focusNode,
  })  : tdController = tdController ?? TextEditingController(),
        focusNode = focusNode ?? FocusNode();

  void withValue({
    TextEditingController? tdController,
    FocusNode? focusNode,
  }) {
    this.tdController = tdController ?? this.tdController;
    this.focusNode = focusNode ?? this.focusNode;
  }

  void dispose() {
    try {
      tdController.dispose();
    } catch (e) {
      // Ignore any errors during disposal
    }
    try {
      focusNode.dispose();
    } catch (e) {
      // Ignore any errors during disposal
    }
  }
}

class InputContainerController extends ValueNotifier<InputContainerProperties> {
  InputContainerController({InputContainerProperties? value})
      : super(value ?? InputContainerProperties());

  String get text => value.tdController.text;

  set text(String? v) {
    value.tdController.let((ctrl) {
      ctrl.value = ctrl.value.copyWith(
        text: v,
        selection: TextSelection.collapsed(offset: v?.length ?? 0),
        composing: TextRange.empty,
      );
    });
    resetValidation();
  }

  set textValue(TextEditingValue value) {
    this.value.tdController.let((ctrl) {
      ctrl.value = value;
    });
  }

  set selection(TextSelection selection) {
    textValue = value.tdController.value.copyWith(
      selection: selection,
    );
  }

  void resetValidation() {
    value
      ..validation = null
      ..warning = null;
    notifyListeners();
  }

  void setError(String message, {bool needFocus = false}) {
    if (needFocus) {
      requestFocus();
    }
    value.validation = message;
    notifyListeners();
  }

  void setWarning(String message, {bool needFocus = false}) {
    if (needFocus) {
      requestFocus();
    }
    value.warning = message;
    notifyListeners();
  }

  void clearError() {
    value.validation = null;
    notifyListeners();
  }

  void clearWarning() {
    value.warning = null;
    notifyListeners();
  }

  void requestFocus() {
    value.focusNode.requestFocus();
  }

  void unfocus() {
    value.focusNode.unfocus();
  }

  void reset() {
    value = InputContainerProperties(
      tdController: value.tdController,
      focusNode: value.focusNode,
    );
    notifyListeners();
  }

  bool get isShowPass => value.isShowPassword;

  void showOrHidePass() {
    value.isShowPassword = !value.isShowPassword;
    notifyListeners();
  }

  void clear() {
    value.tdController.clear();
    resetValidation();
  }

  @override
  void dispose() {
    value.dispose();
    super.dispose();
  }
}

typedef InputContainerBuilder = Widget Function(
  BuildContext context,
  InputContainerController controller,
);

class InputContainerProvider extends StatefulWidget {
  const InputContainerProvider({
    super.key,
    this.child,
    this.builder,
    this.controller,
  });

  final Widget? child;
  final InputContainerBuilder? builder;
  final InputContainerController? controller;

  static InputContainerController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_InputContainerInherited>()
        ?.controller;
  }

  static InputContainerController of(BuildContext context) {
    final result = maybeOf(context);
    assert(
      result != null,
      'No InputContainerProvider found in context',
    );
    return result!;
  }

  @override
  State<InputContainerProvider> createState() => _InputContainerProviderState();
}

class _InputContainerProviderState extends State<InputContainerProvider> {
  late InputContainerController _controller;
  bool _isControllerCreated = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = InputContainerController();
      _isControllerCreated = true;
    } else {
      _controller = widget.controller!;
      _isControllerCreated = false;
    }
  }

  @override
  void didUpdateWidget(InputContainerProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_isControllerCreated) {
        _controller.dispose();
      }
      if (widget.controller == null) {
        _controller = InputContainerController();
        _isControllerCreated = true;
      } else {
        _controller = widget.controller!;
        _isControllerCreated = false;
      }
    }
  }

  @override
  void dispose() {
    if (_isControllerCreated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _InputContainerInherited(
      controller: _controller,
      child: widget.builder != null
          ? widget.builder!(context, _controller)
          : widget.child!,
    );
  }
}

class _InputContainerInherited extends InheritedWidget {
  const _InputContainerInherited({
    required super.child,
    required this.controller,
  });

  final InputContainerController controller;

  @override
  bool updateShouldNotify(_InputContainerInherited oldWidget) =>
      controller != oldWidget.controller;
}
