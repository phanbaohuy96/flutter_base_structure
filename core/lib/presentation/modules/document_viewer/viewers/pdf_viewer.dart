import 'dart:typed_data';

import 'package:fl_ui/fl_ui.dart';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

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

  late PdfController _pdfController;

  void onViewCreated() {
    widget.getDataFrom(url: widget.url).then((value) {
      pdfData = value;

      _pdfController.loadDocument(PdfDocument.openData(pdfData!));
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
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfView(
      builders: PdfViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) => loading,
        pageLoaderBuilder: (_) => loading,
        pageBuilder: _pageBuilder,
      ),
      controller: _pdfController,
    );
  }

  Widget get loading => const Center(
        child: Loading(
          brightness: Brightness.light,
          radius: 16,
        ),
      );

  PhotoViewGalleryPageOptions _pageBuilder(
    BuildContext context,
    Future<PdfPageImage> pageImage,
    int index,
    PdfDocument document,
  ) {
    return PhotoViewGalleryPageOptions(
      imageProvider: PdfPageImageProvider(
        pageImage,
        index,
        document.id,
      ),
      minScale: PhotoViewComputedScale.contained * 1,
      maxScale: PhotoViewComputedScale.contained * 2,
      initialScale: PhotoViewComputedScale.contained * 1.0,
      heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
    );
  }
}
