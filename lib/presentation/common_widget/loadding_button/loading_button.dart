import 'package:flutter/material.dart';

import 'loading_button.controller.dart';

class LoadingButton extends StatelessWidget {
  final LoadingButtonController controller;
  final Widget normalIcon;
  final Color bgColor;
  final Widget loadingIndicator;
  final String title;
  final TextStyle? textStyle;
  final Function()? onPressed;
  final EdgeInsetsGeometry padding;

  const LoadingButton({
    Key? key,
    required this.controller,
    this.normalIcon = const SizedBox(),
    this.bgColor = const Color(0xFF03a1e4),
    this.loadingIndicator = const SizedBox(),
    this.title = '',
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ButtonState>(
      valueListenable: controller.buttonState,
      builder: (context, state, w) {
        return InkWell(
          onTap: _getPressedFunction(state),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: bgColor,
            ),
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: textStyle,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                _getIcon(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getIcon(ButtonState state) {
    switch (state) {
      case ButtonState.loading:
        return loadingIndicator;
      default:
        return normalIcon;
    }
  }

  GestureTapCallback? _getPressedFunction(ButtonState state) {
    switch (state) {
      case ButtonState.loading:
        return null;
      default:
        return onPressed;
    }
  }
}
