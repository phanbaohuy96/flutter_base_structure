import 'package:flutter/material.dart';

import '../../../../common/utils.dart';
import '../../../theme/export.dart';
import '../../shared/input_decoration_factory.dart';

part 'dropdown_controller.dart';

class DropdownWidget<T> extends StatefulWidget {
  final String? title;
  final TextStyle? titleStyle;
  final bool required;
  final T? selected;
  final List<T> items;
  final void Function(T?)? onChanged;
  final String? hint;
  final Widget Function(T) itemBuilder;
  final DropdownController<T, DropdownData<T>>? controller;
  final Widget? prefixIcon;
  final EdgeInsetsGeometry? prefixIconPadding;
  final EdgeInsetsGeometry? contentPadding;
  final Color? iconColor;
  final Widget? suffixIcon;
  final bool showBorder;
  final TextStyle? hintStyle;
  final BorderSide? borderSide;
  final BorderSide? focusedBorderSide;
  final double menuMaxHeight;
  final bool enable;
  final Color? fillColor;
  final bool isDense;
  final bool isExpanded;
  final Widget Function(T)? selectedItemBuilder;
  final BorderRadius? borderRadius;

  DropdownWidget({
    this.title,
    this.titleStyle,
    required this.itemBuilder,
    required this.items,
    this.selected,
    this.controller,
    this.onChanged,
    this.hint,
    this.required = false,
    this.prefixIcon,
    this.prefixIconPadding,
    this.iconColor,
    this.suffixIcon,
    this.contentPadding,
    this.showBorder = true,
    this.hintStyle,
    this.borderSide,
    this.focusedBorderSide,
    this.menuMaxHeight = 500,
    this.enable = true,
    this.fillColor,
    this.isDense = true,
    this.isExpanded = true,
    this.selectedItemBuilder,
    this.borderRadius,
  });

  @override
  State<DropdownWidget<T>> createState() => _DropdownWidgetState<T>();
}

class _DropdownWidgetState<T> extends State<DropdownWidget<T>> {
  bool get hasPrefixIcon => widget.prefixIcon != null;

  double get prefixIconSize => hasPrefixIcon ? 16 : 0;

  DropdownController<T, DropdownData<T>>? _controller;

  @override
  void initState() {
    _setupController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant DropdownWidget<T> oldWidget) {
    _setupController();
    super.didUpdateWidget(oldWidget);
  }

  void _setupController() {
    _controller = widget.controller ??
        _controller ??
        DropdownController<T, DropdownData<T>>(
          value: DropdownData<T>(),
        );
    if (_controller!.data != widget.selected &&
        (widget.selected == null ||
            widget.items.any((e) => e == widget.selected))) {
      _controller!.setData(widget.selected);
    }
    if (!widget.items.any((e) => e == _controller!.data)) {
      _controller!.setData(null);
    }
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
    final themeData = context.theme;
    return ValueListenableBuilder<DropdownData<T>>(
      valueListenable: _controller!,
      builder: (ctx, value, w) {
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
              alignLabelWithHint: false,
            ),
          ),
          child: DropdownButtonFormField<T>(
            menuMaxHeight: widget.menuMaxHeight,
            value: value.value,
            items: widget.items.map((e) {
              return DropdownMenuItem<T>(
                value: e,
                child: widget.itemBuilder(e),
              );
            }).toList(),
            selectedItemBuilder: widget.selectedItemBuilder != null
                ? (context) => widget.items
                    .map((e) => widget.selectedItemBuilder!(e))
                    .toList()
                : null,
            onChanged: !widget.enable
                ? null
                : (value) {
                    _controller!.setData(value);
                    widget.onChanged?.call(value);
                  },
            iconSize: 24,
            icon: !widget.enable
                ? const SizedBox()
                : widget.suffixIcon ??
                    Icon(
                      Icons.keyboard_arrow_down,
                      color:
                          widget.iconColor ?? context.themeColor.schemeAction,
                    ),
            style: context.textTheme.textInput,
            isExpanded: widget.isExpanded,
            isDense: widget.isDense,
            decoration: InputDecorationFactory.build(
              context: context,
              hint: widget.hint,
              hintStyle: widget.hintStyle,
              title: widget.title,
              required: widget.required,
              titleStyle: widget.titleStyle,
              errorText: value.validation,
              prefixIcon: _getPrefixIcon(),
              prefixIconSize: prefixIconSize,
              prefixIconPadding: widget.prefixIconPadding,
              enable: widget.enable,
              fillColor: widget.fillColor,
            ),
          ),
        );
      },
    );
  }

  Widget? _getPrefixIcon() {
    return widget.prefixIcon?.let(
      (icon) => Padding(
        padding: widget.prefixIconPadding ??
            EdgeInsets.symmetric(horizontal: prefixIconSize),
        child: icon,
      ),
    );
  }
}
