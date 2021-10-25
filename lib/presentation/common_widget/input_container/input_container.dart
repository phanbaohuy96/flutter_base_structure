import 'package:flutter/material.dart';

import '../../theme/theme_color.dart';

part 'input_container.controller.dart';

class InputContainer extends StatelessWidget {
  final InputContainerController? controller;
  final String? hint;
  final bool isPassword;
  final bool readOnly;
  final bool enable;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final void Function()? onTap;
  final Function(String)? onTextChanged;
  final int maxLines;
  final String? title;

  const InputContainer({
    Key? key,
    this.controller,
    this.hint,
    this.isPassword = false,
    this.readOnly = false,
    this.enable = true,
    this.suffixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
    this.onTextChanged,
    this.maxLines = 1,
    this.title,
  }) : super(key: key);

  bool get hasSuffixIcon => isPassword || suffixIcon != null;

  double get suffixIconSize => hasSuffixIcon ? 16 : 0;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return ValueListenableBuilder<InputContainerProperties>(
      valueListenable: controller ?? InputContainerController(),
      builder: (ctx, value, w) {
        late Widget body;
        final textField = TextField(
          focusNode: value.focusNode,
          readOnly: readOnly || !enable,
          controller: value.tdController,
          decoration: InputDecoration(
            filled: !enable,
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(6.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
            hintText: hint,
            hintStyle: themeData.textTheme.subtitle2,
            errorText: value.validation,
            errorStyle: themeData.textTheme.subtitle1?.copyWith(
              color: Colors.red,
              fontSize: value.validation?.isNotEmpty == true ? null : 1,
            ),
            suffixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: suffixIconSize),
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
          obscureText: isPassword && controller?.isShowPass != true,
          onChanged: (text) {
            if (value.validation != null) {
              controller?.resetValidation();
            }
            onTextChanged?.call(text);
          },
          maxLines: maxLines,
          onTap: onTap,
        );
        if (title?.isNotEmpty == true) {
          body = Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title!,
                  style: themeData.textTheme.subtitle2?.copyWith(
                    fontWeight: FontWeight.w700,
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
            primaryColor: themeData.accentColor,
            primaryColorDark: themeData.accentColor,
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
        onTap: controller?.showOrHidePass,
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
