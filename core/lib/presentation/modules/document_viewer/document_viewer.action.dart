part of 'document_viewer_screen.dart';

extension DocumentReaderAction on _DocumentViewerScreenState {
  Future<Uint8List?> getDataFrom({required String url}) async {
    if (url.contains('http')) {
      final request = await HttpClient().getUrl(Uri.parse(url));
      final response = await request.close();
      final data = await consolidateHttpClientResponseBytes(response);

      return data;
    } else if (url.isLocalUrl) {
      return File(url).readAsBytes();
    }

    final data = await rootBundle.load(url);
    return data.buffer.asUint8List();
  }
}
