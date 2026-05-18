import 'package:flutter/material.dart';

import '../../../../../core.dart';

class DialogAndPickerPage extends StatelessWidget {
  const DialogAndPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16).copyWith(
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      children: <Widget>[
        OutlinedButton(
          child: const Text('Notice Confirm Dialog'),
          onPressed: () {
            showNoticeConfirmDialog(
              context: context,
              message: 'message',
              title: 'title',
            );
          },
        ),
        OutlinedButton(
          child: const Text('Notice Confirm With Reason Dialog'),
          onPressed: () {
            showNoticeConfirmWithReasonDialog(
              context: context,
              message: 'message',
              title: 'title',
            );
          },
        ),
        OutlinedButton(
          child: const Text('Notice Dialog'),
          onPressed: () {
            showNoticeDialog(
              context: context,
              message: 'message',
              title: 'title',
            );
          },
        ),
        OutlinedButton(
          child: const Text('Notice Error Dialog'),
          onPressed: () {
            showNoticeErrorDialog(
              context: context,
              message: 'message',
            );
          },
        ),
        OutlinedButton(
          child: const Text('Notice Warning Dialog'),
          onPressed: () {
            showNoticeWarningDialog(
              context: context,
              message: 'message',
            );
          },
        ),
        OutlinedButton(
          child: const Text('Show Action Dialog'),
          onPressed: () {
            showActionDialog(
              context,
              title: 'Action dialog',
              subTitle: 'sub title',
              actions: {
                'Action 1': () => debugPrint('action1'),
                'Action 2': () => debugPrint('action2'),
                'Action 3': () => debugPrint('action3'),
              },
            );
          },
        ),
        OutlinedButton(
          child: const Text('Show Modal'),
          onPressed: () {
            showModal(
              context,
              Container(
                constraints: const BoxConstraints(
                  maxHeight: 300,
                ),
                alignment: Alignment.center,
                child: const Text('showModal'),
              ),
            );
          },
        ),
        OutlinedButton(
          child: const Text('Notice Confirm With Validate Dialog'),
          onPressed: () {
            showNoticeConfirmWithValidateDialog(
              context: context,
              title: 'delete Account',
              message: 'deleteAccountConfirmMsg',
              validateString: 'YES',
              hint: 'input `Yes` To Confirm',
              onConfirmed: () async {},
            );
          },
        ),
        OutlinedButton(
          child: const Text('Show My Custom Date Picker'),
          onPressed: () {
            showMyCustomDatePicker(
              context,
              initialDateTime: DateTime.now(),
            );
          },
        ),
        OutlinedButton(
          child: const Text('Show Cupertino Custom Time Picker'),
          onPressed: () {
            showCupertinoCustomTimePicker(
              context,
              initial: const Duration(hours: 9),
            );
          },
        ),
        OutlinedButton(
          child: const Text('Show My Custom Month Picker'),
          onPressed: () {
            showMyCustomMonthPicker(
              context,
              initialDateTime: DateTime.now(),
            );
          },
        ),
        OutlinedButton(
          child: const Text('Show My Custom Time Picker'),
          onPressed: () {
            showMyTimePicker(
              context,
              initialDateTime: DateTime.now(),
            );
          },
        ),
      ].insertSeparator(
        (index) => const SizedBox(
          height: 16,
        ),
      ),
    );
  }
}
