import 'package:flutter/material.dart';

import '../../../../core.dart';

part 'multiple_choice_dropdown_controller.dart';

class MultipleChoiceDropdownWidget<T> extends StatefulWidget {
  final String? title;
  final TextStyle? titleStyle;
  final TitleMode titleMode;
  final bool required;
  final List<T> items;
  final List<T>? selected;
  final void Function(List<T>)? onChanged;
  final String? hint;
  final Widget Function(T, bool selected) itemBuilder;
  final Widget Function(List<T>) valueBuilder;
  final MultipleChoiceDropdownController<T, MultipleChoiceDropdownData<T>>?
  controller;
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
  final bool showClearButton;
  final VoidCallback? onClear;

  /// Default using [AppTextTheme.inputError]
  final TextStyle? errorStyle;
  final BorderRadius? borderRadius;

  MultipleChoiceDropdownWidget({
    this.titleStyle,
    this.title,
    this.titleMode = TitleMode.above,
    this.controller,
    required this.itemBuilder,
    required this.valueBuilder,
    required this.items,
    this.selected,
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
    this.showClearButton = true,
    this.onClear,
    this.errorStyle,
    this.borderRadius,
  });

  @override
  State<MultipleChoiceDropdownWidget<T>> createState() =>
      _MultipleChoiceDropdownWidgetState<T>();
}

class _MultipleChoiceDropdownWidgetState<T>
    extends State<MultipleChoiceDropdownWidget<T>> {
  bool get hasPrefixIcon => widget.prefixIcon != null;

  double get prefixIconSize => hasPrefixIcon ? 16 : 0;

  Size? childSize;

  MultipleChoiceDropdownController<T, MultipleChoiceDropdownData<T>>?
  _controller;

  @override
  void initState() {
    _setupController();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MultipleChoiceDropdownWidget<T> oldWidget) {
    _setupController();
    super.didUpdateWidget(oldWidget);
  }

  void _setupController() {
    _controller =
        widget.controller ??
        _controller ??
        MultipleChoiceDropdownController<T, MultipleChoiceDropdownData<T>>(
          value: MultipleChoiceDropdownData<T>(),
        );
    if (_controller!.data != widget.selected &&
        (widget.selected == null ||
            widget.items.any((e) => e == widget.selected))) {
      _controller!.setData([...?widget.selected]);
    }
    if (!widget.items.any((e) => e == _controller!.data)) {
      _controller!.setData([]);
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

  Widget _buildSuffixIcon(MultipleChoiceDropdownData<T> value) {
    if (!widget.enable) {
      return const SizedBox();
    }
    if (widget.showClearButton && value.value.isNotEmpty) {
      return IconButton(
        icon: Icon(
          Icons.clear,
          color: widget.iconColor ?? context.themeColor.schemeAction,
        ),
        onPressed: () {
          widget.controller?.setData([]);
          widget.onClear?.call();
          widget.onChanged?.call([]);
        },
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        iconSize: 20,
        splashRadius: 20,
      );
    }

    return widget.suffixIcon ??
        Icon(
          Icons.keyboard_arrow_down,
          color: widget.iconColor ?? context.themeColor.schemeAction,
        );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = context.theme;
    final textTheme = context.textTheme;
    final dropdown = ValueListenableBuilder<MultipleChoiceDropdownData<T>>(
      valueListenable: _controller!,
      builder: (ctx, value, w) {
        final body = DropdownButtonFormField<T>(
          menuMaxHeight: widget.menuMaxHeight,
          initialValue: value.value.firstOrNull,
          items: widget.items.map((e) {
            return DropdownMenuItem<T>(
              value: e,
              child: _DropDownMenuBox(
                item: e,
                itemBuilder: widget.itemBuilder,
                selected: value.value.any((i) => i == e),
                onChanged: (selected) {
                  if (!selected) {
                    _controller!.setData([
                      ..._controller!.data.where((i) => i != e),
                    ]);
                  } else {
                    _controller!.setData([..._controller!.data, e]);
                  }
                  widget.onChanged?.call(_controller!.data);
                },
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) => [
            ...widget.items.map((_) => const SizedBox()),
          ],
          isDense: value.value.isEmpty,
          isExpanded: true,
          onChanged: !widget.enable ? null : (_) {},
          iconSize: 24,
          hint: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.hint ?? '',
              style: widget.hintStyle ?? textTheme.inputHint,
            ),
          ),
          icon: _buildSuffixIcon(value),
          autovalidateMode: AutovalidateMode.disabled,
          decoration: InputDecorationFactory.build(
            context: context,
            titleMode: widget.titleMode,
            hint: widget.hint,
            hintStyle: widget.hintStyle,
            title: switch (widget.titleMode) {
              TitleMode.floating => widget.title,
              _ => null,
            },
            required: widget.required,
            titleStyle: widget.titleStyle,
            errorText: switch (widget.titleMode) {
              TitleMode.floating => value.validation,
              // set error text to empty to enable error decoration
              _ => value.validation != null ? '' : null,
            },
            prefixIcon: _getPrefixIcon(),
            prefixIconSize: prefixIconSize,
            prefixIconPadding: widget.prefixIconPadding,
            enable: widget.enable,
            fillColor: widget.fillColor,
          ),
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
              alignLabelWithHint: false,
            ),
          ),
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding:
                      widget.contentPadding ??
                      themeData.inputDecorationTheme.contentPadding ??
                      EdgeInsets.zero,
                  child: MeasureSize(
                    onChange: (size) {
                      if (childSize == null ||
                          childSize!.height != size.height) {
                        setState(() {
                          childSize = size;
                        });
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: hasPrefixIcon ? prefixIconSize : 0,
                        right: 24,
                      ),
                      child: widget.valueBuilder(value.value),
                    ),
                  ),
                ),
              ),
              Positioned.fill(child: body),
            ],
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
                dropdown,
                ValueListenableBuilder(
                  valueListenable: _controller!,
                  builder: (context, value, child) {
                    return InputHelperError(
                      validation: value.validation,
                      padding: const EdgeInsets.only(top: spacing),
                    );
                  },
                ),
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
        padding:
            widget.prefixIconPadding ??
            EdgeInsets.symmetric(horizontal: prefixIconSize),
        child: icon,
      ),
    );
  }
}

class _DropDownMenuBox<T> extends StatefulWidget {
  final T item;
  final bool selected;
  final Function(bool selected) onChanged;
  final Widget Function(T, bool selected) itemBuilder;

  const _DropDownMenuBox({
    super.key,
    required this.item,
    required this.selected,
    required this.onChanged,
    required this.itemBuilder,
  });

  @override
  State<_DropDownMenuBox<T>> createState() => _DropDownMenuBoxState<T>();
}

class _DropDownMenuBoxState<T> extends State<_DropDownMenuBox<T>> {
  bool selected = false;
  @override
  void initState() {
    selected = widget.selected;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _DropDownMenuBox<T> oldWidget) {
    selected = widget.selected;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          selected = !selected;
        });
        widget.onChanged.call(selected);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: widget.itemBuilder(widget.item, selected),
      ),
    );
  }
}
