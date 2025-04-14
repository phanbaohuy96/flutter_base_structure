import 'package:fl_utils/fl_utils.dart';
import 'package:flutter/material.dart';

import 'box_color.dart';
import 'custom_stepper.dart';

class ErrorBox extends StatelessWidget {
  final ErrorBoxController controller;
  final Widget child;
  final EdgeInsetsGeometry errorPadding;
  final TextStyle? errorStyle;
  final BorderRadius borderRadius;
  final Color normalBorderColor;

  const ErrorBox({
    Key? key,
    required this.child,
    required this.controller,
    this.errorStyle,
    this.borderRadius = BorderRadius.zero,
    this.normalBorderColor = Colors.transparent,
    this.errorPadding = const EdgeInsets.only(top: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: controller.focusNode,
      child: ValueListenableBuilder<String?>(
        valueListenable: controller,
        builder: (context, value, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              HighlightBoxColor(
                padding: EdgeInsets.zero,
                borderRadius: borderRadius,
                bgColor: Colors.transparent,
                borderColor:
                    value.isNullOrEmpty ? normalBorderColor : Colors.red,
                child: child,
              ),
              Builder(
                builder: (context) {
                  if (value.isNullOrEmpty) {
                    return const SizedBox();
                  }
                  return AnimatedSlideBox(
                    begin: const Offset(0.0, -1),
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: errorPadding,
                      child: Text(
                        value!,
                        style: errorStyle ??
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Colors.red,
                                ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
        child: child,
      ),
    );
  }
}

class ErrorBoxController extends ValueNotifier<String?> {
  ErrorBoxController({String? value}) : super(null);

  final _focusNode = FocusNode();

  FocusNode get focusNode => _focusNode;

  void setError(String message) {
    value = message;
    notifyListeners();
    _focusNode.requestFocus();
  }

  void clear() {
    value = null;
    notifyListeners();
  }
}
