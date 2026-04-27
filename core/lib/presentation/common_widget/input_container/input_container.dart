import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core.dart';

part 'input_container.controller.dart';

class InputContainer extends StatefulWidget {
  final InputContainerController? controller;
  final String? hint;
  final bool isPassword;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final void Function()? onTap;
  final void Function(String)? onTextChanged;
  final void Function(String)? onSubmitted;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final bool enable;
  final String? title;
  final TitleMode titleMode;
  final TextStyle? titleStyle;
  final String? validation;
  final String? warning;
  final String? helperText;
  final bool required;
  final Color? fillColor;
  final Widget? prefixIcon;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final BorderSide? borderSide;
  final BorderSide? focusedBorderSide;
  final TextAlign textAlign;
  final int? maxLength;
  final bool showBorder;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry prefixIconPadding;
  final EdgeInsetsGeometry suffixIconPadding;
  final TextInputAction? textInputAction;
  final void Function()? onEditingComplete;
  final double prefixIconSize;
  final double suffixIconSize;
  final BorderRadius? borderRadius;
  final bool justShowPrefixIconWhenEmpty;
  final bool withClearButton;
  final void Function(bool hasFocus)? onClear;
  final bool? isDense;
  final EdgeInsets scrollPadding;
  final String? text;
  final bool autofocus;
  final bool selectAllWhenFocus;
  final void Function(bool hasFocus)? onFocusChanged;
  final Widget? iconClear;

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
    this.onClear,
    this.enable = true,
    this.title,
    this.titleStyle,
    this.titleMode = TitleMode.above,
    this.required = false,
    this.fillColor,
    this.prefixIcon,
    this.hintStyle,
    this.textStyle,
    this.borderSide,
    this.focusedBorderSide,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.showBorder = true,
    this.contentPadding,
    this.suffixIconPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.prefixIconPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.onEditingComplete,
    this.textInputAction,
    this.prefixIconSize = 16.0,
    this.suffixIconSize = 16.0,
    this.borderRadius,
    this.justShowPrefixIconWhenEmpty = false,
    this.withClearButton = true,
    this.isDense,
    this.scrollPadding = const EdgeInsets.all(20),
    this.text,
    this.validation,
    this.warning,
    this.helperText,
    this.autofocus = false,
    this.onFocusChanged,
    this.iconClear,
    this.selectAllWhenFocus = false,
  }) : super(key: key);

  @override
  State<InputContainer> createState() => _InputContainerState();
}

class _InputContainerState extends State<InputContainer> {
  bool showPrefixIcon = true;

  InputContainerController? _controller;

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
    if (widget.text != null && _controller!.text != widget.text) {
      if (widget.keyboardType?.index == TextInputType.number.index) {
        /// In-case input type is number
        /// on editing allow user keep the decimal separate
        /// eg: if user input `12` then input decimal separate '.'
        /// the text changed maybe format it to 12 but the same value with `12.`
        final oldNumValue = _controller!.text.doubleNumber ?? 0;
        final newNumValue = widget.text.doubleNumber ?? 0;
        if (oldNumValue != newNumValue || _controller!.text.isEmpty) {
          _controller!.text = widget.text;
        }
      } else {
        _controller!.text = widget.text;
      }
    }
    if (widget.validation != null &&
        _controller!.value.validation != widget.validation) {
      if (widget.validation!.isEmpty) {
        _controller!.clearError();
      } else {
        _controller!.setError(widget.validation!);
      }
    }

    if (widget.warning != null &&
        _controller!.value.warning != widget.warning) {
      if (widget.warning!.isEmpty) {
        _controller!.clearWarning();
      } else {
        _controller!.setWarning(widget.warning!);
      }
    }
    _controller!.value.focusNode
      ..removeListener(onFocusChanged)
      ..addListener(onFocusChanged);
  }

  void onFocusChanged() {
    final hasFocus = _controller!.value.focusNode.hasFocus == true;
    if (hasFocus && widget.selectAllWhenFocus) {
      _controller!.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller!.text.length,
      );
    }
    widget.onFocusChanged?.call(hasFocus);

    /// On web platform we have an issue that when keyboard appears sometime
    /// that make the whole page move up.
    /// So the [Scaffold.resizeToAvoidBottomInset] need to be set to false
    /// then we do make sure the input field is visible
    if (hasFocus && isAndroidBrowser) {
      // Delay 300ms for keyboard to appear
      Future.delayed(const Duration(milliseconds: 300), _ensureVisible);
    }
  }

  void _ensureVisible() {
    if (!mounted) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      alignment: 0.5,
    );
  }

  @override
  void dispose() {
    _controller?.value.focusNode.removeListener(onFocusChanged);
    if (widget.controller == null) {
      _controller?.dispose();
      _controller = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = context.theme;
    if (widget.justShowPrefixIconWhenEmpty) {
      showPrefixIcon = _controller!.text.isEmpty;
    }
    return ValueListenableBuilder<InputContainerProperties>(
      valueListenable: _controller!,
      builder: (ctx, value, w) {
        final appTextTheme = context.textTheme;
        final textField = TextField(
          textAlign: widget.textAlign,
          focusNode: value.focusNode,
          scrollPadding: widget.scrollPadding,
          readOnly: widget.readOnly || !widget.enable,
          controller: value.tdController,
          enabled: widget.enable,
          maxLength: widget.maxLength,
          autofocus: widget.autofocus,
          decoration: InputDecorationFactory.build(
            context: context,
            titleMode: widget.titleMode,
            title: switch (widget.titleMode) {
              TitleMode.floating => widget.title,
              _ => null,
            },
            enable: widget.enable,
            required: widget.required,
            prefixIconPadding: widget.prefixIconPadding,
            suffixIconPadding: widget.suffixIconPadding,
            prefixIconSize: widget.prefixIconSize,
            suffixIconSize: widget.suffixIconSize,
            hintStyle: widget.hintStyle ?? appTextTheme.inputHint,
            hint: widget.hint,
            errorText: switch (widget.titleMode) {
              TitleMode.floating => value.validation ?? value.warning,
              // set error text to empty to enable error decoration
              _ => (value.validation ?? value.warning) != null ? '' : null,
            },
            errorStyle: appTextTheme.inputError?.copyWith(
              color: value.validation != null ? null : Colors.orange,
            ),
            helperText: switch (widget.titleMode) {
              TitleMode.floating => widget.helperText,
              // set error text to empty to enable error decoration
              _ => null,
            },
            suffixIcon: _getSuffixIcon(),
            prefixIcon: _getPrefixIcon(),
            isDense: widget.isDense,
            fillColor: widget.fillColor,
          ),
          textAlignVertical: widget.maxLines != null
              ? TextAlignVertical.top
              : null,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          style:
              widget.textStyle ??
              (widget.enable ? appTextTheme.textInput : appTextTheme.inputHint),
          obscureText:
              widget.isPassword && widget.controller?.isShowPass != true,
          onChanged: (text) {
            _showPrefixFilterFn(text);

            if (value.validation != null || value.warning != null) {
              widget.controller?.resetValidation();
            }
            widget.onTextChanged?.call(text);
          },
          onEditingComplete: widget.onEditingComplete,
          maxLines: widget.maxLines,
          inputFormatters: widget.inputFormatters,
          onTap: widget.enable ? widget.onTap : null,
          onSubmitted: widget.onSubmitted,
          textInputAction: widget.textInputAction,
        );
        return Theme(
          data: themeData.copyWith(
            primaryColor: themeData.colorScheme.secondary,
            primaryColorDark: themeData.colorScheme.secondary,
            inputDecorationTheme: InputDecorationFactory.overrideTheme(
              context: context,
              borderSide: widget.borderSide,
              borderRadius: widget.borderRadius,
              showBorder: widget.showBorder,
              contentPadding: widget.contentPadding,
              alignLabelWithHint: widget.maxLines != null,
            ),
          ),
          child: switch (widget.titleMode) {
            TitleMode.floating => textField,
            _ => Builder(
              builder: (context) {
                if (widget.title.isNullOrEmpty) {
                  return textField;
                }

                const spacing = 8.0;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InputTitleWidget(
                      title: widget.title,
                      required: widget.required,
                    ),
                    const SizedBox(height: spacing),
                    textField,
                    ValueListenableBuilder(
                      valueListenable: _controller!,
                      builder: (context, value, child) {
                        return InputHelperError(
                          padding: const EdgeInsets.only(top: spacing),
                          validation: value.validation ?? value.warning,
                          style: appTextTheme.inputError?.copyWith(
                            color: value.validation != null
                                ? null
                                : Colors.orange,
                          ),
                          helper: widget.helperText,
                          helperStyle: appTextTheme.helper,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          },
        );
      },
    );
  }

  Widget? _getSuffixIcon() {
    final padding = widget.suffixIconPadding;
    if (widget.isPassword) {
      final icon = _getPasswordIcon();
      return InkWell(
        onTap: widget.controller!.showOrHidePass,
        child: Padding(padding: padding, child: icon),
      );
    }
    if (widget.withClearButton &&
        (widget.maxLines == 1 || widget.maxLength == null)) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controller!.value.tdController,
        builder: (context, value, child) {
          if (!widget.enable || widget.readOnly) {
            return widget.suffixIcon?.let((it) {
                  return Padding(padding: padding, child: it);
                }) ??
                const SizedBox();
          }
          if (value.text.isNotEmpty != true) {
            if (widget.suffixIcon != null) {
              return Padding(padding: padding, child: widget.suffixIcon);
            }
            return const SizedBox();
          }
          return InkWell(
            onTap: () {
              _controller!.clear();
              _showPrefixFilterFn(_controller!.text);
              widget.onTextChanged?.call(_controller!.text);
              widget.onClear?.call(_controller!.value.focusNode.hasFocus);
            },
            child: Padding(
              padding: padding.add(const EdgeInsets.only(right: 8)),
              child:
                  widget.iconClear ??
                  Icon(Icons.close_rounded, size: widget.suffixIconSize),
            ),
          );
        },
      );
    }
    if (widget.suffixIcon != null) {
      return Padding(padding: padding, child: widget.suffixIcon);
    }
    return null;
  }

  Widget _getPasswordIcon() {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(
        widget.controller?.isShowPass == true
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
        size: widget.suffixIconSize,
        color: Colors.grey,
      ),
    );
  }

  Widget? _getPrefixIcon() {
    final padding = widget.prefixIconPadding;
    if (!showPrefixIcon || widget.prefixIcon == null) {
      return null;
    }
    return AvailabilityWidget(
      enable: widget.enable,
      child: Padding(padding: padding, child: widget.prefixIcon),
    );
  }

  void _showPrefixFilterFn(String text) {
    final isEmpty = text.isEmpty;
    if (widget.justShowPrefixIconWhenEmpty &&
        showPrefixIcon != isEmpty &&
        mounted) {
      setState(() {
        showPrefixIcon = isEmpty;
      });
    }
  }
}

class FakeInputField extends StatelessWidget {
  const FakeInputField({
    super.key,
    this.text,
    this.title,
    this.required = true,
    this.enable = true,
    this.prefixIcon,
    this.surfixIcon,
    this.hint,
    this.onTap,
    this.constraints = const BoxConstraints(minHeight: 46),
  });

  final String? text;
  final String? title;
  final bool required;
  final bool enable;
  final Widget? prefixIcon;
  final Widget? surfixIcon;
  final String? hint;
  final void Function()? onTap;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final inputDecor = context.theme.inputDecorationTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotNullOrEmpty) ...[
          InputTitleWidget(title: title!, required: required),
          const SizedBox(height: 8),
        ],
        AvailabilityWidget(
          enable: enable,
          child: InkWell(
            borderRadius: asOrNull<OutlineInputBorder>(
              inputDecor.border,
            )?.borderRadius,
            onTap: onTap,
            child: HighlightBoxColor(
              constraints: constraints,
              padding: inputDecor.contentPadding!,
              borderColor: asOrNull<OutlineInputBorder>(
                inputDecor.border,
              )?.borderSide.color,
              borderRadius: asOrNull<OutlineInputBorder>(
                inputDecor.border,
              )?.borderRadius,
              alignment: Alignment.centerLeft,
              bgColor: enable
                  ? Colors.transparent
                  : (inputDecor.fillColor ?? Colors.grey[100]!),
              child: Row(
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      text.isNotNullOrEmpty ? text! : (hint ?? '--'),
                      style: enable && text.isNotNullOrEmpty
                          ? textTheme.textInput
                          : textTheme.inputHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (surfixIcon != null) ...[
                    const SizedBox(width: 8),
                    surfixIcon!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
