import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

export 'package:dropdown_button2/dropdown_button2.dart';

typedef DropdownItemBuilder<T> = Widget Function(T item);

class DropdownMenuButton<T> extends StatelessWidget {
  const DropdownMenuButton({
    super.key,
    required this.customButton,
    required this.items,
    this.value,
    required this.itemBuilder,
    this.onChanged,
    this.onTap,
    this.dropdownHeight = kMinInteractiveDimension * 6,
    this.dropdownStyleData,
    this.menuItemStyleData = const MenuItemStyleData(),
  });

  final Widget customButton;
  final List<T> items;
  final T? value;
  final DropdownItemBuilder<T> itemBuilder;
  final ValueChanged<T?>? onChanged;
  final void Function()? onTap;
  final double dropdownHeight;
  final DropdownStyleData? dropdownStyleData;
  final MenuItemStyleData menuItemStyleData;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        customButton: customButton,
        items: [
          ...items.map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: itemBuilder(e),
            ),
          ),
        ],
        value: value,
        onChanged: (value) {
          onChanged?.call(value);
        },
        onMenuStateChange: (isOpen) {
          if (isOpen) {
            onTap?.call();
          }
        },
        dropdownStyleData: dropdownStyleData ??
            DropdownStyleData(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              padding: EdgeInsets.zero,
              scrollPadding: EdgeInsets.zero,
              elevation: 2,
              maxHeight: dropdownHeight,
              offset: const Offset(0, -5),
            ),
        menuItemStyleData: menuItemStyleData,
      ),
    );
  }
}
