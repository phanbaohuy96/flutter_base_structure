import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme_color.dart';

part 'input_container.controller.dart';

class InputContainer extends StatelessWidget {
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
  }) : super(key: key);

  bool get hasSuffixIcon => isPassword || suffixIcon != null;
  double get suffixIconSize => hasSuffixIcon ? 16 : 0;
  bool get hasPrefixIcon => prefixIcon != null;
  double get prefixIconSize => hasPrefixIcon ? 16 : 0;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return ValueListenableBuilder<InputContainerProperties>(
      valueListenable: controller ?? InputContainerController(),
      builder: (ctx, value, w) {
        Widget body;
        final textField = TextField(
          textAlign: textAlign,
          focusNode: value.focusNode,
          readOnly: readOnly || !enable,
          controller: value.tdController,
          maxLength: maxLength,
          decoration: InputDecoration(
            filled: !enable || fillColor != null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            hintText: hint,
            hintStyle: hintStyle ?? themeData.textTheme.subtitle2,
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
                    child: prefixIcon,
                  )
                : null,
            prefixIconConstraints: hasPrefixIcon
                ? BoxConstraints(
                    minHeight: suffixIconSize,
                    minWidth: suffixIconSize,
                  )
                : null,
            fillColor: enable ? fillColor : null,
            counterStyle: themeData.textTheme.subtitle1,
          ),
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: textStyle ?? themeData.textTheme.bodyText2,
          obscureText: isPassword && controller?.isShowPass != true,
          onChanged: (text) {
            if (value.validation != null) {
              controller?.resetValidation();
            }
            onTextChanged?.call(text);
          },
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onTap: onTap,
          onSubmitted: onSubmitted,
        );
        if (title?.isNotEmpty == true) {
          body = Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    text: title!.toUpperCase(),
                    style: themeData.textTheme.headline6,
                    children: [
                      if (isRequired == true)
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
              border: OutlineInputBorder(
                borderSide: borderSide ??
                    const BorderSide(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(6.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: borderSide ??
                    const BorderSide(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
          ),
          child: body,
        );
      },
    );
  }

  Widget? _getSuffixIcon() {
    if (isPassword) {
      final icon = suffixIcon ?? _getPasswordIcon();
      return InkWell(
        onTap: controller!.showOrHidePass,
        child: icon,
      );
    }
    return suffixIcon;
  }

  Widget _getPasswordIcon() {
    return Icon(
      Icons.remove_red_eye,
      size: suffixIconSize,
      color:
          controller?.isShowPass == true ? AppColor.primaryColor : Colors.grey,
    );
  }
}
