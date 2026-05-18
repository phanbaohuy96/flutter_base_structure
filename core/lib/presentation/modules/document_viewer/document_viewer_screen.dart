import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core.dart';
import 'viewers/pdf_viewer.dart';

part 'document_viewer.action.dart';

class DocumentViewerArgs {
  final String title;
  final MimeType type;
  final String url;
  final void Function()? onDownload;

  DocumentViewerArgs({
    required this.title,
    required this.type,
    required this.url,
    this.onDownload,
  });
}

class DocumentViewerScreen extends StatefulWidget {
  static String routeName = '/document_viewer';
  const DocumentViewerScreen({
    Key? key,
    required this.args,
  }) : super(key: key);

  final DocumentViewerArgs args;

  @override
  _DocumentViewerScreenState createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  late String? downloadId;

  @override
  Widget build(BuildContext context) {
    return ScreenForm(
      title: widget.args.title,
      actions: [
        if (widget.args.onDownload != null)
          IconButton(
            iconSize: 20,
            padding: EdgeInsets.zero,
            splashRadius: 20,
            icon: Container(
              width: 40,
              height: 40,
              child: const Icon(
                Icons.download,
                size: 20,
                color: Color(0xFF767676),
              ),
            ),
            onPressed: widget.args.onDownload,
          ),
      ],
      child: Builder(
        builder: (context) {
          switch (widget.args.type) {
            case MimeType.pdf:
              return PDFViewer(url: widget.args.url, getDataFrom: getDataFrom);
            default:
          }
          return const Center(
            child: Text('Không hỗ trợ'),
          );
        },
      ),
    );
  }
}
