import 'package:flutter/material.dart';

import '../../common/utils.dart';
import '../extentions/extention.dart';
import 'input_container/input_container.dart';

class SelectionDialog<T> extends StatefulWidget {
  final List<T> items;
  final Function(T) onSelected;
  final Widget Function(BuildContext, T) itemBuilder;
  final bool Function(T item, String? filter) filterFn;

  const SelectionDialog({
    Key? key,
    required this.items,
    required this.onSelected,
    required this.itemBuilder,
    required this.filterFn,
  }) : super(key: key);

  @override
  _SelectionDialogState<T> createState() => _SelectionDialogState<T>();
}

class _SelectionDialogState<T> extends State<SelectionDialog<T>> {
  late ValueNotifier<List<T>> searchNotifier;
  late Debouncer _debouncer;

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

  @override
  Widget build(BuildContext context) {
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
                  InputContainer(
                    hint: translate(context).search,
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
                            return InkWell(
                              onTap: () {
                                widget.onSelected(items[idx]);
                              },
                              child: widget.itemBuilder(ctx, items[idx]),
                            );
                          },
                          itemCount: items.length,
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
