import 'package:flutter/material.dart';

import '../../../common/constants.dart';

part 'input_container.controller.dart';

class InputContainer extends StatelessWidget {
  final InputContainerController controller;
  final String hint;
  final bool isPassword;
  final bool readOnly;
  final Widget suffixIcon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final Function() onTap;
  final Function(String) onTextChanged;
  final int maxLines;

  const InputContainer({
    Key key,
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
  }) : super(key: key);

  bool get hasSuffixIcon => isPassword || suffixIcon != null;
  double get suffixIconSize => hasSuffixIcon ? 16 : 0;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return ValueListenableBuilder<InputContainerProperties>(
      valueListenable: controller ?? InputContainerController(),
      builder: (ctx, value, w) {
        return Theme(
          data: themeData.copyWith(
            primaryColor: themeData.primaryColorLight,
            primaryColorDark: themeData.primaryColorLight,
          ),
          child: TextField(
            focusNode: value.focusNode,
            readOnly: readOnly,
            controller: value.tdController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              hintText: hint,
              hintStyle: themeData.textTheme.subtitle2,
              errorText: value.validation,
              errorStyle: themeData.textTheme.subtitle1.copyWith(
                color: Colors.red,
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.all(suffixIconSize),
                child: _getSuffixIcon(),
              ),
              suffixIconConstraints: BoxConstraints(
                minHeight: suffixIconSize,
                minWidth: suffixIconSize,
              ),
            ),
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: themeData.textTheme.bodyText2,
            obscureText: isPassword && !controller.isShowPass,
            onChanged: (text) {
              if (value.validation != null) {
                controller.resetValidation();
              }
              onTextChanged?.call(text);
            },
            maxLines: maxLines,
            onTap: onTap,
          ),
        );
      },
    );
  }

  Widget _getSuffixIcon() {
    if (isPassword) {
      final icon = suffixIcon ?? _getPasswordIcon();
      return InkWell(
        onTap: controller.showOrHidePass,
        child: icon,
      );
    }
    return suffixIcon;
  }

  Widget _getPasswordIcon() {
    var imagePath = ImageConstant.iconEyeSlash;
    if (controller.isShowPass) {
      imagePath = ImageConstant.iconEye;
    }

    return Image.asset(
      imagePath,
      width: suffixIconSize,
      height: suffixIconSize,
    );
  }
}
