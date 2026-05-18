import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../l10n/localization_ext.dart';
import 'custom_picker_constrants.dart';
import 'flutter_datetime_picker/src/datetime_picker_theme.dart';

Future<dynamic> showCupertinoCustomTimePicker(
  BuildContext context, {
  Duration? initial,
  Function(Duration?)? onComfirmed,
}) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoTimePickerCustom(
        initialTimerDuration: initial,
        onComfirmed: onComfirmed,
        theme: CustomDatePickerTheme(
          theme: Theme.of(context),
        ),
      );
    },
  );
}

class CupertinoTimePickerCustom extends StatefulWidget {
  const CupertinoTimePickerCustom({
    Key? key,
    required this.initialTimerDuration,
    this.onCancelled,
    this.onComfirmed,
    required this.theme,
  }) : super(key: key);

  final Duration? initialTimerDuration;
  final void Function()? onCancelled;
  final void Function(Duration?)? onComfirmed;
  final CustomDatePickerTheme theme;

  @override
  _CupertinoTimePickerCustomState createState() =>
      _CupertinoTimePickerCustomState();
}

class _CupertinoTimePickerCustomState extends State<CupertinoTimePickerCustom> {
  Duration? selectedTime;

  @override
  void initState() {
    selectedTime = widget.initialTimerDuration;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: DefaultTextStyle(
        style: widget.theme.itemStyle!,
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: CustomPickerConstants.pickerSheetHeight +
                  widget.theme.titleHeight,
              child: Column(
                children: <Widget>[
                  _buildFunction(),
                  CupertinoTimerPicker(
                    backgroundColor:
                        CupertinoColors.systemBackground.resolveFrom(context),
                    initialTimerDuration: widget.initialTimerDuration!,
                    onTimerDurationChanged: (Duration newTimer) {
                      selectedTime = newTimer;
                    },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            height: widget.theme.titleHeight,
            child: CupertinoButton(
              pressedOpacity: 0.3,
              padding: const EdgeInsetsDirectional.only(start: 16, top: 0),
              onPressed: () {
                widget.onCancelled?.call();
                _close();
              },
              child: Text(
                coreL10n.cancel,
                style: widget.theme.cancelStyle,
              ),
            ),
          ),
          SizedBox(
            height: widget.theme.titleHeight,
            child: CupertinoButton(
              pressedOpacity: 0.3,
              padding: const EdgeInsetsDirectional.only(end: 16, top: 0),
              onPressed: () {
                widget.onComfirmed?.call(selectedTime);
                _close();
              },
              child: Text(
                coreL10n.confirm,
                style: widget.theme.doneStyle,
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
