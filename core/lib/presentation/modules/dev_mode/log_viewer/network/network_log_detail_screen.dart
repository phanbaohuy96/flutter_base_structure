import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../common/services/network_log/network_log_service.dart';

class NetworkLogDetailScreen extends StatefulWidget {
  final NetworkLog log;

  static String routeName = '/network-log-detail';

  const NetworkLogDetailScreen({super.key, required this.log});

  @override
  State<NetworkLogDetailScreen> createState() => _NetworkLogDetailScreenState();
}

class _NetworkLogDetailScreenState extends State<NetworkLogDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Log Details'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Headers'),
              Tab(text: 'Request'),
              Tab(text: 'Response'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(),
            _buildHeadersTab(),
            _buildJsonTab(widget.log.requestBody, 'No request body'),
            _buildJsonTab(widget.log.responseBody, 'No response body'),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoTile('Method', widget.log.method),
        _infoTile('URL', widget.log.url),
        _infoTile('Status', '${widget.log.statusCode}'),
        _infoTile('Time', _formatTime(widget.log.startTime)),
        _infoTile('Duration', '${widget.log.duration.inMilliseconds}ms'),
      ],
    );
  }

  Widget _buildHeadersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: widget.log.requestHeaders.entries.map((entry) {
        return _infoTile(entry.key, entry.value.toString());
      }).toList(),
    );
  }

  Widget _buildJsonTab(dynamic data, String emptyText) {
    if (data == null) {
      return Center(child: Text(emptyText));
    }

    String pretty;
    try {
      final jsonObject = data is String ? json.decode(data) : data;
      pretty = const JsonEncoder.withIndent('  ').convert(jsonObject);
    } catch (_) {
      pretty = data.toString();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(pretty),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '''${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}''';
  }
}
