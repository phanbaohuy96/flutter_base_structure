import 'package:dartx/dartx.dart';
import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';

import '../theme/export.dart';

class InputTitleWidget extends StatelessWidget {
  const InputTitleWidget({
    super.key,
    required this.title,
    this.required = true,
    this.style,
  });

  final String? title;
  final bool required;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return RichText(
      text: TextSpan(
        text: title,
        style: style ?? textTheme.inputTitle,
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style:
                  style?.copyWith(color: Colors.red) ?? textTheme.inputRequired,
            ),
        ],
      ),
    );
  }
}

class InputHelperError extends StatefulWidget {
  const InputHelperError({
    super.key,
    required this.validation,
    this.style,
    this.padding = const EdgeInsets.only(top: 8.0),
    this.helper,
    this.helperStyle,
  });

  final String? validation;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;
  final String? helper;
  final TextStyle? helperStyle;

  @override
  State<InputHelperError> createState() => _InputHelperErrorState();
}

class _InputHelperErrorState extends State<InputHelperError>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 167),
      vsync: this,
    );
    _controller.addListener(_handleChange);

    if (widget.validation != null) {
      _controller.forward();
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChange() {
    setState(() {
      // The _controller's value has changed.
    });
  }

  @override
  void didUpdateWidget(InputHelperError old) {
    super.didUpdateWidget(old);

    final newErrorText = widget.validation;
    final oldErrorText = old.validation;

    final errorStateChanged = (newErrorText != null) != (oldErrorText != null);

    if (errorStateChanged) {
      if (newErrorText != null) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    if (widget.helper.isNotNullOrBlank) {
      return ClipRRect(
        child: LayoutSwitching(
          isFirstLayout: widget.validation.isNullOrBlank,
          direction: SwitchingAnimation.swipeTTB,
          first: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: RichText(
                text: TextSpan(
                  text: widget.helper,
                  style: widget.helperStyle ?? textTheme.helper,
                ),
              ),
            ),
          ),
          second: Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                text: widget.validation,
                style: widget.style ?? textTheme.inputError,
              ),
            ),
          ),
        ),
      );
    }

    if (widget.validation.isNullOrBlank) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      child: FadeTransition(
        opacity: _controller,
        child: FractionalTranslation(
          translation: Tween<Offset>(
            begin: const Offset(0.0, -0.25),
            end: Offset.zero,
          ).evaluate(_controller.view),
          child: RichText(
            text: TextSpan(
              text: widget.validation,
              style: widget.style ?? textTheme.inputError,
            ),
          ),
        ),
      ),
    );
  }
}
