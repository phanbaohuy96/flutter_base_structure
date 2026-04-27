import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core.dart';

class NetworkLogViewerScreen extends StatefulWidget {
  static String routeName = '/network-log-viewer';

  const NetworkLogViewerScreen({Key? key}) : super(key: key);

  @override
  State<NetworkLogViewerScreen> createState() => _NetworkLogViewerScreenState();
}

class _NetworkLogViewerScreenState extends State<NetworkLogViewerScreen> {
  bool? error;

  List<NetworkLog> get logsByFilter => [
    ...NetworkLoggerService().logs.where(
      (e) => error == null || e.error == error,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final logs = logsByFilter;
    return ScreenForm(
      title: 'Network Log Viewer',
      actions: [_rightButton()],
      hasBottomBorderRadius: true,
      bgColor: context.theme.primaryColor,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final log = logs[index];
          return InkWell(
            onTap: () => _viewLogDetail(log),
            onDoubleTap: () => _copyCURL(log),
            child: NetworkLogItem(log: log),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: logs.length,
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
                style: context.textTheme.bodyLarge?.copyWith(color: e['color']),
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
        'title': 'Error',
        'color': error == true ? Colors.red : null,
        'icon': Icon(
          Icons.error,
          size: 16,
          color: error == true ? Colors.red : null,
        ),
        'onTap': () async {
          setState(() {
            error = true;
          });
        },
      },
      {
        'title': 'Request',
        'color': error == false ? Colors.blue : null,
        'icon': Icon(
          Icons.info_outline,
          size: 16,
          color: error == false ? Colors.blue : null,
        ),
        'onTap': () async {
          setState(() {
            error = false;
          });
        },
      },
      {
        'title': 'Log All',
        'color': null,
        'icon': const Icon(Icons.notes_outlined, size: 16, color: Colors.black),
        'onTap': () async {
          setState(() {
            error = null;
          });
        },
      },
      {
        'title': 'Refresh',
        'icon': const Icon(Icons.refresh, size: 16),
        'onTap': () async {
          setState(() {});
        },
      },
    ];
  }

  void _viewLogDetail(NetworkLog log) {
    context.openNetworkLogDetail(log: log);
  }

  void _copyCURL(NetworkLog log) {
    Clipboard.setData(ClipboardData(text: log.buildCurlCommand()));
    showToast(context, 'Copied as cURL');
  }
}

class NetworkLogItem extends StatelessWidget {
  final NetworkLog log;

  const NetworkLogItem({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final url = log.url;
    final statusCode = log.statusCode;
    final requestTime = log.timestamp;
    final duration = log.duration;

    final textTheme = context.textTheme;
    final color = log.error ? Colors.red : null;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: context.theme.canvasColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'url: $url',
              style: textTheme.labelMedium?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              'status: $statusCode',
              style: textTheme.labelMedium?.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'requestTime: ${_formatTime(requestTime)}',
                  style: textTheme.labelMedium?.copyWith(color: color),
                ),
                Text(
                  'duration: ${duration.inMilliseconds}ms',
                  style: textTheme.labelMedium?.copyWith(color: color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
