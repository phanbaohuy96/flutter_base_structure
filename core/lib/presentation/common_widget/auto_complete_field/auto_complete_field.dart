import 'dart:async';

import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../common/utils.dart';
import '../../theme/export.dart';
import '../input_container/input_container.dart';
import '../shared/input_decoration_factory.dart';

typedef AutocompleteOptionBuilder<T> = Widget Function(T option);

class AutoCompleteField<T extends Object> extends StatefulWidget {
  final AutocompleteOptionToString<T> displayStringForOption;
  final AutocompleteOptionBuilder<T>? optionBuilder;
  final void Function(T?) onSelected;
  final T? initialValue;
  final Future<Iterable<T>> Function(String text) fetch;
  final String? title;
  final TitleMode titleMode;
  final String? hint;
  final Widget? suffixIcon;
  final double optionsMaxHeight;
  final InputContainerController? inputController;
  final Duration debounceDuration;
  final bool enable;
  final bool required;
  final bool allowFreeText;
  final bool isLocalSearch;
  final void Function(String)? onTextChanged;
  final void Function()? onFocused;
  final EdgeInsets scrollPadding;
  final bool withClearButton;
  final VoidCallback? onTap;
  final bool Function(InputContainerController ctr)? showOptionTitleWhen;
  final String? optionTitle;
  final OptionsViewOpenDirection optionsViewOpenDirection;
  final String? validation;
  final String? warning;
  final String? helperText;

  const AutoCompleteField({
    Key? key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.fetch,
    this.initialValue,
    this.optionBuilder,
    this.title,
    this.titleMode = TitleMode.above,
    this.hint,
    this.suffixIcon,
    this.optionsMaxHeight = 200.0,
    this.inputController,
    this.enable = true,
    this.debounceDuration = Duration.zero,
    this.required = false,
    this.allowFreeText = false,
    this.isLocalSearch = false,
    this.onTextChanged,
    this.onFocused,
    this.scrollPadding = const EdgeInsets.all(20),
    this.withClearButton = true,
    this.onTap,
    this.showOptionTitleWhen,
    this.optionTitle,
    this.optionsViewOpenDirection = OptionsViewOpenDirection.down,
    this.validation,
    this.warning,
    this.helperText,
  }) : super(key: key);

  @override
  State<AutoCompleteField<T>> createState() => _AutoCompleteFieldState<T>();
}

class _AutoCompleteFieldState<T extends Object>
    extends State<AutoCompleteField<T>>
    with AfterLayoutMixin {
  final _fetching = ValueNotifier(false);
  var _fecthingAt = DateTime.now();

  late InputContainerController _icText;

  T? _selected;

  @override
  void initState() {
    _icText = widget.inputController ?? InputContainerController();
    _selected = widget.initialValue;

    if (widget.warning != null) {
      _icText.setWarning(widget.warning!);
    }
    if (widget.validation != null) {
      _icText.setError(widget.validation!);
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _icText = widget.inputController ?? InputContainerController();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant AutoCompleteField<T> oldWidget) {
    if (oldWidget.initialValue != widget.initialValue) {
      _selected = widget.initialValue;
      final text = selectedToText;
      _icText.value.tdController.value = _icText.value.tdController.value
          .copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text?.length ?? 0),
          );
    }

    if (widget.warning != null) {
      _icText.setWarning(widget.warning!);
    }
    if (widget.validation != null) {
      _icText.setError(widget.validation!);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _fetching.dispose();
    super.dispose();
  }

  String? get selectedToText => _selected?.let(widget.displayStringForOption);

  @override
  void afterFirstLayout(BuildContext context) {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    _icText.value.tdController.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.optionTitle;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Focus(
          onFocusChange: (value) {
            if (!value && !widget.allowFreeText) {
              _icText.text = selectedToText ?? '';
            }
            if (value) {
              _icText.text = _icText.text;
              widget.onFocused?.call();
            }
          },
          child: IgnorePointer(
            ignoring: !widget.enable,
            child: Autocomplete<T>(
              displayStringForOption: widget.displayStringForOption,
              initialValue: widget.initialValue?.let(
                (it) =>
                    TextEditingValue(text: widget.displayStringForOption(it)),
              ),
              optionsViewOpenDirection: widget.optionsViewOpenDirection,
              optionsMaxHeight: widget.optionsMaxHeight,
              optionsBuilder: (TextEditingValue textEditingValue) async {
                final now = DateTime.now();
                _fecthingAt = now.copyWith();
                _fetching.value = true;

                await Future.delayed(
                  widget.isLocalSearch
                      ? const Duration(milliseconds: 50)
                      : widget.debounceDuration,
                );
                if (now.millisecondsSinceEpoch !=
                    _fecthingAt.millisecondsSinceEpoch) {
                  // break unnecessary fetch data request
                  return [];
                }

                return widget.fetch.call(textEditingValue.text).then((value) {
                  _fetching.value = false;
                  return value;
                });
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: _fetching,
                      builder: (context, fetching, _) {
                        return InputContainer(
                          controller: _icText
                            ..value.withValue(
                              tdController: textEditingController,
                              focusNode: focusNode,
                            ),
                          onTap: widget.onTap,
                          onSubmitted: (_) => onFieldSubmitted(),
                          title: widget.title,
                          titleMode: widget.titleMode,
                          hint: widget.hint,
                          required: widget.required,
                          validation: _icText.value.validation,
                          scrollPadding: widget.scrollPadding,
                          helperText: widget.helperText,
                          suffixIcon: Builder(
                            builder: (context) {
                              if (fetching && !widget.isLocalSearch) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Loading(
                                    brightness: Brightness.light,
                                    radius: 8,
                                  ),
                                );
                              }
                              return widget.suffixIcon ??
                                  const Icon(Icons.search, size: 18);
                            },
                          ),
                          enable: widget.enable,
                          withClearButton: !fetching && widget.withClearButton,
                          onClear: (hasFocus) {
                            widget.onSelected.call(null);
                          },
                          onTextChanged: widget.onTextChanged,
                          maxLines: null,
                        );
                      },
                    );
                  },
              optionsViewBuilder: (context, onSelected, options) {
                /// Move to option overlap over title when
                /// [widget.optionsViewOpenDirection] is
                /// [OptionsViewOpenDirection.up]
                /// and [widget.titleMode] is TitleMode.above
                final offset = switch (widget.optionsViewOpenDirection) {
                  OptionsViewOpenDirection.up => switch (widget.titleMode) {
                    TitleMode.above => const Offset(0, 18),
                    _ => const Offset(0, 0),
                  },
                  // mostSpace is resolved by Flutter at layout; fall through
                  // to the no-offset branch since we can't predict direction.
                  OptionsViewOpenDirection.down ||
                  OptionsViewOpenDirection.mostSpace => const Offset(0, 0),
                };
                return Transform.translate(
                  offset: offset,
                  child: _AutocompleteOptions<T>(
                    openDirection: widget.optionsViewOpenDirection,
                    displayStringForOption: widget.displayStringForOption,
                    optionBuilder: widget.optionBuilder,
                    onSelected: (option) {
                      _selected = option;
                      return onSelected(option);
                    },
                    options: options,
                    title: (widget.showOptionTitleWhen?.call(_icText) ?? true)
                        ? title
                        : null,
                    maxOptionsHeight: widget.optionsMaxHeight,
                    maxOptionsWidth: constraints.maxWidth,
                    selected: _selected,
                  ),
                );
              },
              onSelected: widget.onSelected,
            ),
          ),
        );
      },
    );
  }
}

class _AutocompleteOptions<T extends Object> extends StatefulWidget {
  const _AutocompleteOptions({
    super.key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
    required this.maxOptionsWidth,
    this.selected,
    this.optionBuilder,
    this.title,
    required this.openDirection,
  });

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight;
  final double maxOptionsWidth;
  final T? selected;
  final String? title;
  final AutocompleteOptionBuilder<T>? optionBuilder;
  final OptionsViewOpenDirection openDirection;

  @override
  State<_AutocompleteOptions<T>> createState() =>
      _AutocompleteOptionsState<T>();
}

class _AutocompleteOptionsState<T extends Object>
    extends State<_AutocompleteOptions<T>> {
  final _scrollCtr = ScrollController();

  @override
  void dispose() {
    super.dispose();
    _scrollCtr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final optionsAlignment = switch (widget.openDirection) {
      OptionsViewOpenDirection.up => AlignmentDirectional.bottomStart,
      OptionsViewOpenDirection.down ||
      OptionsViewOpenDirection.mostSpace => AlignmentDirectional.topStart,
    };
    return Align(
      alignment: optionsAlignment,
      child: Material(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: widget.maxOptionsHeight,
            maxWidth: widget.maxOptionsWidth,
          ),
          child: _buildOptions(context),
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    final textTheme = context.textTheme;
    final showTitle = widget.title.isNotNullOrEmpty;
    return PrimaryScrollController(
      controller: _scrollCtr,
      child: RawScrollbar(
        thumbVisibility: true,
        trackVisibility: true,
        radius: const Radius.circular(4),
        trackColor: Colors.grey.shade100,
        mainAxisMargin: 0,
        crossAxisMargin: 0,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        trackRadius: const Radius.circular(4),
        thickness: 4,
        minThumbLength: 32,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: widget.options.length + (showTitle ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            if (showTitle && index == 0) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Text(widget.title!, style: textTheme.bodyMedium),
              );
            }
            final option = widget.options.elementAt(
              index - (widget.title.isNotNullOrEmpty ? 1 : 0),
            );
            return InkWell(
              onTap: () {
                widget.onSelected(option);
              },
              child: Builder(
                builder: (BuildContext context) {
                  final highlight = widget.selected == option;
                  if (highlight) {
                    SchedulerBinding.instance.addPostFrameCallback((
                      Duration timeStamp,
                    ) {
                      Scrollable.ensureVisible(context, alignment: 0.5);
                    });
                  }
                  return Container(
                    color: highlight ? Theme.of(context).focusColor : null,
                    padding: const EdgeInsets.all(12.0),
                    child:
                        widget.optionBuilder?.call(option) ??
                        Text(
                          widget.displayStringForOption(option),
                          style: textTheme.textInput,
                        ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
