import 'package:flutter/material.dart';

import '../../../../core.dart';

part 'dropdown_controller.dart';

class DropdownWidget<T> extends StatefulWidget {
  final String? title;
  final TextStyle? titleStyle;
  final TitleMode titleMode;
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
  final VoidCallback? onTap;

  DropdownWidget({
    this.title,
    this.titleStyle,
    this.titleMode = TitleMode.above,
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
    this.onTap,
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
    _setupController(oldSelected: oldWidget.selected);
    super.didUpdateWidget(oldWidget);
  }

  void _setupController({T? oldSelected}) {
    _controller = widget.controller ??
        _controller ??
        DropdownController<T, DropdownData<T>>(
          value: DropdownData<T>(),
        );
    final initial = widget.selected != oldSelected
        ? widget.selected
        : widget.controller?.data ?? widget.selected;

    if (initial != _controller!.data || initial != oldSelected) {
      _controller!.setData(initial);
    }

    if (initial != null && !widget.items.any((e) => e == initial)) {
      _controller!.setData(null);
      return;
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
    final dropdown = ValueListenableBuilder<DropdownData<T>>(
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
            onTap: widget.onTap,
            decoration: InputDecorationFactory.build(
              context: context,
              hint: widget.hint,
              hintStyle: widget.hintStyle,
              title: switch (widget.titleMode) {
                TitleMode.floating => widget.title,
                _ => null,
              },
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

    return AvailabilityWidget(
      enable: widget.enable,
      child: switch (widget.titleMode) {
        TitleMode.floating => dropdown,
        _ => Builder(
            builder: (context) {
              if (widget.title.isNullOrEmpty) {
                return dropdown;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InputTitleWidget(
                    title: widget.title,
                    required: widget.required,
                  ),
                  const SizedBox(height: 8),
                  dropdown,
                ],
              );
            },
          ),
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
