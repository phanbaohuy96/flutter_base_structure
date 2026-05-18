import 'dart:async';

import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../common/utils.dart';
import '../../theme/export.dart';
import '../input_container/input_container.dart';

class AutoCompleteField<T extends Object> extends StatefulWidget {
  final AutocompleteOptionToString<T> displayStringForOption;
  final void Function(T) onSelected;
  final T? initialValue;
  final Future<Iterable<T>> Function(String text) fetch;
  final String? title;
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

  const AutoCompleteField({
    Key? key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.fetch,
    this.initialValue,
    this.title,
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
  }) : super(key: key);

  @override
  State<AutoCompleteField<T>> createState() => _AutoCompleteFieldState<T>();
}

class _AutoCompleteFieldState<T extends Object>
    extends State<AutoCompleteField<T>> with AfterLayoutMixin {
  final _fetching = ValueNotifier(false);
  var _fecthingAt = DateTime.now();

  late InputContainerController _icText;

  T? _selected;

  @override
  void initState() {
    _icText = widget.inputController ?? InputContainerController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _icText = widget.inputController ?? InputContainerController();
    _updateInitialValue(widget.initialValue);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant AutoCompleteField<T> oldWidget) {
    if (oldWidget.initialValue != widget.initialValue) {
      _updateInitialValue(widget.initialValue);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _updateInitialValue(T? value) {
    _selected = value;
    final text = selectedToText;
    _icText.value.tdController.value =
        _icText.value.tdController.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    _fetching.dispose();
    super.dispose();
  }

  String get selectedToText =>
      _selected?.let(widget.displayStringForOption) ?? '';

  @override
  void afterFirstLayout(BuildContext context) {
    // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
    _icText.value.tdController.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Focus(
          onFocusChange: (value) {
            if (!value && !widget.allowFreeText) {
              _icText.text = selectedToText;
            }
            if (value) {
              widget.onFocused?.call();
            }
          },
          child: IgnorePointer(
            ignoring: !widget.enable,
            child: Autocomplete<T>(
              displayStringForOption: widget.displayStringForOption,
              initialValue: widget.initialValue?.let(
                (it) => TextEditingValue(
                  text: widget.displayStringForOption(it),
                ),
              ),
              optionsMaxHeight: widget.optionsMaxHeight,
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if ((!_icText.value.focusNode.hasFocus ||
                        textEditingValue.text == selectedToText) &&
                    !widget.isLocalSearch) {
                  // user leave focus
                  return [];
                }
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
                  // break unecessary fetch data request
                  return [];
                }
                return widget.fetch.call(textEditingValue.text).then((value) {
                  _fetching.value = false;
                  return value;
                });
              },
              fieldViewBuilder: (
                context,
                textEditingController,
                focusNode,
                onFieldSubmitted,
              ) {
                return InputContainer(
                  controller: _icText
                    ..value.withValue(
                      tdController: textEditingController,
                      focusNode: focusNode,
                    ),
                  onSubmitted: (_) => onFieldSubmitted(),
                  title: widget.title,
                  hint: widget.hint,
                  required: widget.required,
                  suffixIcon: ValueListenableBuilder<bool>(
                    valueListenable: _fetching,
                    builder: (context, fetching, widget) {
                      if (fetching && !this.widget.isLocalSearch) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Loading(
                            brightness: Brightness.light,
                            radius: 8,
                          ),
                        );
                      }
                      return widget!;
                    },
                    child: widget.suffixIcon,
                  ),
                  enable: widget.enable,
                  withClearButton: false,
                  onTextChanged: widget.onTextChanged,
                );
              },
              optionsViewBuilder: (context, onSelected, options) =>
                  _AutocompleteOptions<T>(
                displayStringForOption: widget.displayStringForOption,
                onSelected: (option) {
                  _selected = option;
                  return onSelected(option);
                },
                options: options,
                maxOptionsHeight: widget.optionsMaxHeight,
                maxOptionsWidth: constraints.maxWidth,
                selected: _selected,
              ),
              onSelected: widget.onSelected,
            ),
          ),
        );
      },
    );
  }
}

class _AutocompleteOptions<T extends Object> extends StatelessWidget {
  const _AutocompleteOptions({
    super.key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.maxOptionsHeight,
    required this.maxOptionsWidth,
    this.selected,
  });

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight;
  final double maxOptionsWidth;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxOptionsHeight,
            maxWidth: maxOptionsWidth,
          ),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (BuildContext context, int index) {
              final option = options.elementAt(index);
              return InkWell(
                onTap: () {
                  onSelected(option);
                },
                child: Builder(
                  builder: (BuildContext context) {
                    final highlight = selected == option;
                    if (highlight) {
                      SchedulerBinding.instance
                          .addPostFrameCallback((Duration timeStamp) {
                        Scrollable.ensureVisible(context, alignment: 0.5);
                      });
                    }
                    return Container(
                      color: highlight ? Theme.of(context).focusColor : null,
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        displayStringForOption(option),
                        style: textTheme.textInput,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
