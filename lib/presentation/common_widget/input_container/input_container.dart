import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme_color.dart';

part 'input_container.controller.dart';

class InputContainer extends StatefulWidget {
  final InputContainerController? controller;
  final String? hint;
  final bool isPassword;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Function()? onTap;
  final Function(String)? onTextChanged;
  final Function(String)? onSubmitted;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool enable;
  final String? title;
  final bool isRequired;
  final Color? fillColor;
  final Widget? prefixIcon;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final BorderSide? borderSide;
  final TextAlign textAlign;
  final int? maxLength;
  final bool showBorder;

  const InputContainer({
    Key? key,
    this.controller,
    this.hint,
    this.isPassword = false,
    this.readOnly = false,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
    this.onTextChanged,
    this.maxLines = 1,
    this.inputFormatters,
    this.onSubmitted,
    this.enable = true,
    this.title,
    this.isRequired = false,
    this.fillColor,
    this.prefixIcon,
    this.hintStyle,
    this.textStyle,
    this.borderSide,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.showBorder = true,
  }) : super(key: key);

  @override
  State<InputContainer> createState() => _InputContainerState();
}

class _InputContainerState extends State<InputContainer> {
  InputContainerController? _controller;

  bool get hasSuffixIcon => widget.isPassword || widget.suffixIcon != null;

  double get suffixIconSize => hasSuffixIcon ? 16 : 0;

  bool get hasPrefixIcon => widget.prefixIcon != null;

  double get prefixIconSize => hasPrefixIcon ? 16 : 0;

  @override
  void initState() {
    _setupController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant InputContainer oldWidget) {
    _setupController();
    super.didUpdateWidget(oldWidget);
  }

  void _setupController() {
    _controller =
        widget.controller ?? _controller ?? InputContainerController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller?.dispose();
      _controller = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return ValueListenableBuilder<InputContainerProperties>(
      valueListenable: _controller!,
      builder: (ctx, value, w) {
        Widget body;
        final textField = TextField(
          textAlign: widget.textAlign,
          focusNode: value.focusNode,
          readOnly: widget.readOnly || !widget.enable,
          controller: value.tdController,
          maxLength: widget.maxLength,
          decoration: InputDecoration(
            filled: !widget.enable || widget.fillColor != null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            hintText: widget.hint,
            hintStyle: widget.hintStyle ?? themeData.textTheme.subtitle2,
            errorText: value.validation,
            errorStyle: themeData.textTheme.subtitle1?.copyWith(
              color: Colors.red,
              fontSize: value.validation?.isNotEmpty == true ? null : 1,
            ),
            errorMaxLines: 2,
            suffixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: suffixIconSize),
              child: _getSuffixIcon(),
            ),
            suffixIconConstraints: BoxConstraints(
              minHeight: suffixIconSize,
              minWidth: suffixIconSize,
            ),
            prefixIcon: hasPrefixIcon
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: prefixIconSize),
                    child: widget.prefixIcon,
                  )
                : null,
            prefixIconConstraints: hasPrefixIcon
                ? BoxConstraints(
                    minHeight: suffixIconSize,
                    minWidth: suffixIconSize,
                  )
                : null,
            fillColor: widget.enable ? widget.fillColor : null,
            counterStyle: themeData.textTheme.subtitle1,
          ),
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          style: widget.textStyle ?? themeData.textTheme.bodyText2,
          obscureText:
              widget.isPassword && widget.controller?.isShowPass != true,
          onChanged: (text) {
            if (value.validation != null) {
              widget.controller?.resetValidation();
            }
            widget.onTextChanged?.call(text);
          },
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          onTap: widget.onTap,
          onSubmitted: widget.onSubmitted,
        );
        if (widget.title?.isNotEmpty == true) {
          body = Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    text: widget.title!.toUpperCase(),
                    style: themeData.textTheme.headline6,
                    children: [
                      if (widget.isRequired == true)
                        TextSpan(
                          text: ' *',
                          style: themeData.textTheme.headline6,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              textField,
            ],
          );
        } else {
          body = textField;
        }
        return Theme(
          data: themeData.copyWith(
            primaryColor: themeData.colorScheme.secondary,
            primaryColorDark: themeData.colorScheme.secondary,
            inputDecorationTheme: InputDecorationTheme(
              border: widget.showBorder
                  ? OutlineInputBorder(
                      borderSide: widget.borderSide ??
                          const BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(6.0),
                    )
                  : InputBorder.none,
              enabledBorder: widget.showBorder
                  ? OutlineInputBorder(
                      borderSide: widget.borderSide ??
                          const BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.circular(6.0),
                    )
                  : InputBorder.none,
            ),
          ),
          child: body,
        );
      },
    );
  }

  Widget? _getSuffixIcon() {
    if (widget.isPassword) {
      final icon = widget.suffixIcon ?? _getPasswordIcon();
      return InkWell(
        onTap: widget.controller!.showOrHidePass,
        child: icon,
      );
    }
    return widget.suffixIcon;
  }

  Widget _getPasswordIcon() {
    return Icon(
      Icons.remove_red_eye,
      size: suffixIconSize,
      color:
          _controller?.isShowPass == true ? AppColor.primaryColor : Colors.grey,
    );
  }
}
