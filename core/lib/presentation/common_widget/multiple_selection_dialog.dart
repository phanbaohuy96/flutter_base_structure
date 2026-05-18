import 'package:flutter/material.dart';

import '../../common/utils.dart';
import '../../l10n/localization_ext.dart';
import '../theme/export.dart';
import 'input_container/input_container.dart';

class MultipleSelectionDialog<T> extends StatefulWidget {
  final List<T> items;
  final List<T>? initialItems;
  final void Function(List<T>) onSelected;
  final void Function() onCancel;
  final Widget Function(BuildContext, T, bool) itemBuilder;
  final bool Function(T item, String? filter) filterFn;
  final bool Function(T, T)? compareFunction;

  const MultipleSelectionDialog({
    Key? key,
    required this.items,
    this.initialItems,
    this.compareFunction,
    required this.onSelected,
    required this.onCancel,
    required this.itemBuilder,
    required this.filterFn,
  }) : super(key: key);

  @override
  _MultipleSelectionDialog<T> createState() => _MultipleSelectionDialog<T>();
}

class _MultipleSelectionDialog<T> extends State<MultipleSelectionDialog<T>> {
  late ValueNotifier<List<T>> searchNotifier;
  late Debouncer _debouncer;

  late final List<T> multipleSelected = widget.initialItems ?? [];

  @override
  void initState() {
    searchNotifier = ValueNotifier(widget.items);
    _debouncer = Debouncer<String>(const Duration(milliseconds: 500), search);
    super.initState();
  }

  @override
  void dispose() {
    searchNotifier.dispose();
    super.dispose();
  }

  void search(String? filter) {
    final result = widget.items.where((element) {
      return widget.filterFn(element, filter);
    }).toList();

    searchNotifier.value = result;
  }

  late CoreLocalizations localization;

  @override
  Widget build(BuildContext context) {
    localization = context.coreL10n;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _toolbar(context),
                  InputContainer(
                    hint: localization.search,
                    onTextChanged: (text) {
                      _debouncer.value = text;
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ValueListenableBuilder<List<T>>(
                      valueListenable: searchNotifier,
                      builder: (ctx, items, w) {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          addAutomaticKeepAlives: false,
                          itemBuilder: (ctx, idx) {
                            final item = items[idx];
                            final index = _indexOfSelected(item);
                            final selected = index != -1;
                            return InkWell(
                              onTap: () {
                                if (selected) {
                                  setState(() {
                                    multipleSelected.removeAt(index);
                                  });
                                  return;
                                }

                                setState(() {
                                  multipleSelected.add(items[idx]);
                                });
                              },
                              child:
                                  widget.itemBuilder(ctx, items[idx], selected),
                            );
                          },
                          itemCount: items.length,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context) => Container(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            ThemeButton.secondary(
              title: localization.cancel,
              minimumSize: const Size(0, 36.0),
              onPressed: () {
                widget.onCancel();
              },
            ),
            Expanded(child: Container()),
            ThemeButton.primary(
              title: localization.confirm,
              minimumSize: const Size(0, 36.0),
              onPressed: () {
                widget.onSelected.call(multipleSelected);
              },
            ),
          ],
        ),
      );

  // bool _isItemSelected(T item) {
  //   return _indexOfSelected(item) != -1;
  // }

  int _indexOfSelected(T item) {
    return multipleSelected.indexWhere((element) => _isEqual(element, item));
  }

  bool _isEqual(T first, T second) {
    if (widget.compareFunction != null) {
      return widget.compareFunction!.call(first, second);
    }
    return first == second;
  }
}
