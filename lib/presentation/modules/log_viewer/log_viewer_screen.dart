import 'package:flutter/material.dart';

import '../../../common/utils.dart';
import '../../common_widget/forms/screen_form.dart';

class LogViewerScreen extends StatefulWidget {
  const LogViewerScreen({Key? key}) : super(key: key);

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  @override
  Widget build(BuildContext context) {
    final logs = LogUtils.logs.reversed.toList();
    return ScreenForm(
      title: 'Log Viewer',
      actions: [
        IconButton(
          onPressed: () {
            setState(() {});
          },
          icon: const Icon(
            Icons.refresh,
            size: 32,
          ),
        ),
      ],
      child: Container(
        color: Colors.white,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Colors.grey,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...logs[index]
                        .logStrings
                        .map((e) => Text(e.replaceFirst('[38;5;196m', ''))),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemCount: logs.length,
        ),
      ),
    );
  }
}
