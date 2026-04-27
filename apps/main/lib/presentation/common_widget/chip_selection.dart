import 'package:core/core.dart';
import 'package:flutter/material.dart';

typedef ChipSelectionCallback<T> = void Function(T? item);

typedef MultipleChipSelectionCallback<T> = void Function(List<T> items);

typedef ChipLabelGetter<T> = String Function(T item);

enum SelectionMode { single, multiple }

class ChipSelection<T> extends StatelessWidget {
  const ChipSelection._({
    super.key,
    required this.items,
    this.selected,
    this.onSelectionChange,
    this.getChipLabel,
    this.decoration,
    this.selectedDecoration,
    this.constraints = const BoxConstraints(minHeight: 42, minWidth: 118),
    this.selectedLabelStyle,
    this.labelStyle,
    this.spacing = 8,
    this.runSpacing = 8,
    this.minimumItemsPerRow,
    required this.selectionMode,
  });

  factory ChipSelection.single({
    Key? key,
    required List<T> items,
    T? selected,
    ChipSelectionCallback<T>? onSelectionChange,
    ChipLabelGetter<T>? getChipLabel,
    BoxDecoration? decoration,
    BoxDecoration? selectedDecoration,
    BoxConstraints constraints = const BoxConstraints(
      minHeight: 42,
      minWidth: 118,
    ),
    TextStyle? selectedLabelStyle,
    TextStyle? labelStyle,
    double spacing = 8,
    double runSpacing = 8,
    int? minimumItemsPerRow,
  }) => ChipSelection._(
    items: items,
    selected: [if (selected != null) selected],
    onSelectionChange: (items) => onSelectionChange?.call(items.firstOrNull),
    getChipLabel: getChipLabel,
    decoration: decoration,
    selectedDecoration: selectedDecoration,
    constraints: constraints,
    selectedLabelStyle: selectedLabelStyle,
    labelStyle: labelStyle,
    spacing: spacing,
    runSpacing: runSpacing,
    minimumItemsPerRow: minimumItemsPerRow,
    selectionMode: SelectionMode.single,
  );

  factory ChipSelection.miltiple({
    Key? key,
    required List<T> items,
    List<T>? selectedItems,
    MultipleChipSelectionCallback<T>? onSelectionChange,
    ChipLabelGetter<T>? getChipLabel,
    BoxDecoration? decoration,
    BoxDecoration? selectedDecoration,
    BoxConstraints constraints = const BoxConstraints(
      minHeight: 42,
      minWidth: 118,
    ),
    TextStyle? selectedLabelStyle,
    TextStyle? labelStyle,
    double spacing = 8,
    double runSpacing = 8,
    int? minimumItemsPerRow,
  }) => ChipSelection._(
    items: items,
    selected: selectedItems,
    onSelectionChange: onSelectionChange,
    getChipLabel: getChipLabel,
    decoration: decoration,
    selectedDecoration: selectedDecoration,
    constraints: constraints,
    selectedLabelStyle: selectedLabelStyle,
    labelStyle: labelStyle,
    spacing: spacing,
    runSpacing: runSpacing,
    minimumItemsPerRow: minimumItemsPerRow,
    selectionMode: SelectionMode.multiple,
  );

  final List<T> items;
  final List<T>? selected;
  final MultipleChipSelectionCallback<T>? onSelectionChange;
  final ChipLabelGetter<T>? getChipLabel;
  final BoxDecoration? decoration;
  final BoxDecoration? selectedDecoration;
  final BoxConstraints constraints;
  final TextStyle? selectedLabelStyle;
  final TextStyle? labelStyle;
  final double spacing;
  final double runSpacing;
  final int? minimumItemsPerRow;
  final SelectionMode selectionMode;

  @override
  Widget build(BuildContext context) {
    if (minimumItemsPerRow != null) {
      final minItems = minimumItemsPerRow!;
      return LayoutBuilder(
        builder: (context, layout) {
          return _buildWrapChipWithConstraints(
            context,
            constraints.copyWith(
              minWidth:
                  (layout.maxWidth - ((minItems - 1) * spacing)) / minItems,
            ),
          );
        },
      );
    }
    return _buildWrapChipWithConstraints(context, constraints);
  }

  Widget _buildWrapChipWithConstraints(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: WrapAlignment.start,
      children: [
        ...items.map((e) {
          final isSelected = selected?.contains(e) == true;
          return _buildChipItem(
            context: context,
            item: e,
            isSelected: isSelected,
            onTap: onSelectionChange?.let(
              (callback) => () {
                if (selectionMode == SelectionMode.single) {
                  callback([e]);
                } else {
                  final selectedItems = [...?selected];
                  if (isSelected) {
                    selectedItems.remove(e);
                  } else {
                    selectedItems.add(e);
                  }
                  callback(selectedItems);
                }
              },
            ),
            constraints: constraints,
          );
        }),
      ],
    );
  }

  Widget _buildChipItem({
    required BuildContext context,
    required T item,
    required bool isSelected,
    VoidCallback? onTap,
    BoxConstraints? constraints,
  }) {
    return InkWell(
      onTap: onTap,
      child: FittedBox(
        child: Container(
          constraints: constraints,
          decoration: isSelected
              ? defaultSelectedChipDecoration(context)
              : defaultChipDecoration(context),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          child: Text(
            getChipLabel?.call(item) ?? item.toString(),
            style: isSelected ? selectedLabelStyle : labelStyle,
          ),
        ),
      ),
    );
  }
}

BoxDecoration defaultChipDecoration(BuildContext context) => BoxDecoration(
  border: Border.all(width: 1, color: context.themeColor.borderColor),
  borderRadius: BorderRadius.circular(4),
);

BoxDecoration defaultSelectedChipDecoration(BuildContext context) =>
    BoxDecoration(
      border: Border(
        left: BorderSide(width: 8, color: context.themeColor.primary),
        top: BorderSide(width: 1, color: context.themeColor.primary),
        right: BorderSide(width: 1, color: context.themeColor.primary),
        bottom: BorderSide(width: 1, color: context.themeColor.primary),
      ),
      borderRadius: BorderRadius.circular(4),
    );
