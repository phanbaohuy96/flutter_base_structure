import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/localization_ext.dart';
import '../extentions/context_extention.dart';

const double pickerSheetHeight = 216.0;

const double pickerButtonHeight = 20.0;

Future<dynamic> showCupertinoCustomDatePicker(
  BuildContext context,
  DateTime? initialDateTime,
  Function(DateTime?)? onConfirmed, {
  DateTime? maxDate,
  DateTime? minDate,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
}) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoDatePickerCustom(
        initialDateTime: initialDateTime,
        onConfirmed: onConfirmed,
        maxDate: maxDate,
        minDate: minDate,
        mode: mode,
      );
    },
  );
}

class CupertinoDatePickerCustom extends StatefulWidget {
  CupertinoDatePickerCustom({
    Key? key,
    required this.initialDateTime,
    this.maxDate,
    this.minDate,
    this.mode = CupertinoDatePickerMode.date,
    this.onCancelled,
    this.onConfirmed,
  }) : super(key: key);

  final DateTime? initialDateTime;
  final DateTime? maxDate;
  final DateTime? minDate;
  final void Function()? onCancelled;
  final void Function(DateTime?)? onConfirmed;
  final CupertinoDatePickerMode mode;

  @override
  _CupertinoDatePickerCustomState createState() =>
      _CupertinoDatePickerCustomState();
}

class _CupertinoDatePickerCustomState extends State<CupertinoDatePickerCustom> {
  DateTime? selectedTime;

  @override
  void initState() {
    selectedTime = DateTime.fromMillisecondsSinceEpoch(
      widget.initialDateTime!.millisecondsSinceEpoch,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: DefaultTextStyle(
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: Container(
              height: pickerSheetHeight + pickerButtonHeight,
              child: Column(
                children: <Widget>[
                  _buildFunction(),
                  Container(
                    height: pickerSheetHeight - 30,
                    child: CupertinoDatePicker(
                      backgroundColor:
                          CupertinoColors.systemBackground.resolveFrom(context),
                      mode: widget.mode,
                      initialDateTime: widget.initialDateTime,
                      maximumDate: widget.maxDate,
                      minimumDate: widget.minDate,
                      onDateTimeChanged: (DateTime newTimer) {
                        selectedTime = newTimer;
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

  Widget _buildFunction() {
    final actionTextStyle = context.textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextButton(
            onPressed: () {
              widget.onCancelled?.call();
              _close();
            },
            child: Text(
              context.coreL10n.cancel,
              style: actionTextStyle?.copyWith(
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.onConfirmed?.call(selectedTime);
              _close();
            },
            child: Text(
              context.coreL10n.confirm,
              style: actionTextStyle?.copyWith(
                color: context.themeColor.schemeAction,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _close() {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
