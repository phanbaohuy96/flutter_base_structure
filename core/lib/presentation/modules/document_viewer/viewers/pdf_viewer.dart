import 'dart:typed_data';

import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class PDFViewer extends StatefulWidget {
  final String url;
  final Future<Uint8List?> Function({required String url}) getDataFrom;

  const PDFViewer({
    Key? key,
    required this.url,
    required this.getDataFrom,
  }) : super(key: key);

  @override
  _PDFViewerState createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  Uint8List? pdfData;

  void onViewCreated() {
    widget.getDataFrom(url: widget.url).then((value) {
      setState(() {
        pdfData = value;
      });
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      onViewCreated();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (pdfData == null) {
      return const Center(
        child: Loading(
          brightness: Brightness.light,
          radius: 16,
        ),
      );
    }
    return SizedBox(
      key: UniqueKey(),
      child: PdfViewer.openData(pdfData!),
    );
  }
}
