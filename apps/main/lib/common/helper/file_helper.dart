import 'dart:io';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<File> saveTempImageFile(
    Uint8List data, [
    String extension = 'jpg',
  ]) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/${const Uuid().v4()}.$extension';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    return file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
  }
}
