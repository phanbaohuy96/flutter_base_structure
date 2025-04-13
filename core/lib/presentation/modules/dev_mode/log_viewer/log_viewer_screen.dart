import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../../common/utils.dart';
import '../../../common_widget/forms/screen_form.dart';
import '../../../extentions/context_extention.dart';

class LogViewerScreen extends StatefulWidget {
  static String routeName = '/log_viewer';

  const LogViewerScreen({Key? key}) : super(key: key);

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  Level? level;

  List<AppLog> get logsByFilter => [
        ...logUtils.logs.reversed
            .where((e) => level == null || e.level == level),
      ];

  @override
  Widget build(BuildContext context) {
    final logs = logsByFilter;
    return ScreenForm(
      title: 'Log Viewer',
      actions: [_rightButton()],
      child: Container(
        color: context.theme.primaryColor,
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final log = logs[index];
            final logStr = log.logStrings.join('\n');
            return InkWell(
              onTap: () => _viewLogDetail(log),
              child: Container(
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
                  child: Text(
                    logStr,
                    style: TextStyle(
                      fontSize: 14,
                      color: log.level.color,
                    ),
                  ),
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

  Widget _rightButton() => PopupMenuButton<Map<String, dynamic>>(
        icon: Icon(
          Icons.more_vert_outlined,
          color: context.themeColor.appbarForegroundColor,
        ),
        color: context.theme.primaryColor,
        onSelected: (item) => item['onTap'].call(),
        itemBuilder: (_) => [
          ..._dropdownItems.map(
            (e) => PopupMenuItem<Map<String, dynamic>>(
              value: e,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  e['icon'],
                  const SizedBox(width: 8),
                  Text(
                    e['title'],
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: e['color'],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  List<Map<String, dynamic>> get _dropdownItems {
    return [
      {
        'title': 'Log Error',
        'color': level == Level.error ? level.color : null,
        'icon': Icon(
          Icons.error,
          size: 16,
          color: level == Level.error ? level.color : null,
        ),
        'onTap': () async {
          setState(() {
            level = Level.error;
          });
        },
      },
      {
        'title': 'Log Debug',
        'color': level == Level.debug ? level.color : null,
        'icon': Icon(
          Icons.bug_report,
          size: 16,
          color: level == Level.debug ? level.color : null,
        ),
        'onTap': () async {
          setState(() {
            level = Level.debug;
          });
        },
      },
      {
        'title': 'Log Info',
        'color': level == Level.info ? level.color : null,
        'icon': Icon(
          Icons.info_outline,
          size: 16,
          color: level == Level.info ? level.color : null,
        ),
        'onTap': () async {
          setState(() {
            level = Level.info;
          });
        },
      },
      {
        'title': 'Log All',
        'color': level == null ? level.color : null,
        'icon': Icon(
          Icons.notes_outlined,
          size: 16,
          color: level == null ? level.color : null,
        ),
        'onTap': () async {
          setState(() {
            level = null;
          });
        },
      },
      {
        'title': 'Refresh',
        'icon': const Icon(
          Icons.refresh,
          size: 16,
        ),
        'onTap': () async {
          setState(() {});
        },
      },
      {
        'title': 'Clear Log',
        'icon': const Icon(
          Icons.delete_outline_rounded,
          size: 16,
        ),
        'onTap': () async {
          setState(logUtils.logs.clear);
        },
      },
    ];
  }

  void _viewLogDetail(AppLog log) {
    final logStr = log.logStrings.join('\n').replaceAll(
      '''┌───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────''',
      '''┌───────────────''',
    ).replaceAll(
      '''┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄''',
      '''┄┄┄┄┄┄┄┄┄┄┄┄┄┄''',
    ).replaceAll(
      '''└───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────''',
      '''└───────────────''',
    );
    showDialog(
      context: context,
      builder: (context) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: InkWell(
                      child: Text(
                        logStr,
                        style: TextStyle(
                          fontSize: 14,
                          color: log.level.color,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension LogLevelExt on Level? {
  Color get color {
    switch (this) {
      case Level.info:
        return Colors.blue;
      case Level.error:
        return Colors.red;
      case Level.debug:
        return Colors.purple;
      case null: //case all
        return Colors.green;
      default:
        return Colors.black;
    }
  }
}
