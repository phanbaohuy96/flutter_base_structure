part of 'pick_file_helper.dart';

class FilePicked {
  FilePicked({
    this.path,
    required this.name,
    required this.size,
    this.bytes,
    this.identifier,
  });

  factory FilePicked.fromPlatFormFile(f_picker.PlatformFile file) {
    ///  On web `path` is always `null`,
    ///  You should access `bytes` property instead,
    ///  Read more about it [here](https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ)
    return FilePicked(
      path: kIsWeb ? null : file.path,
      name: file.name,
      size: file.size,
      bytes: file.bytes,
      identifier: file.identifier,
    );
  }

  factory FilePicked.fromXFile(XFile file) {
    ///  On web `path` is always `null`,
    ///  You should access `bytes` property instead,
    ///  Read more about it [here](https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ)
    final _file = File(file.path);
    return FilePicked(
      path: kIsWeb ? null : file.path,
      name: file.name,
      size: _file.lengthSync(),
      bytes: _file.readAsBytesSync(),
    );
  }

  /// The absolute path for a cached copy of this file.
  /// It can be used to create a file instance with a
  /// descriptor for the given path.
  /// ```
  /// final File myFile = File(FilePicked.path);
  /// ```
  /// On web this is always `null`. You should access `bytes` property instead.
  /// Read more about it [here](https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ)
  final String? path;

  /// File name including its extension.
  final String name;

  /// Byte data for this file.
  /// Particurlarly useful if you want to manipulate its data
  /// or easily upload to somewhere else.
  /// [Check here in the FAQ](https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ) an example on how to use it to upload on web.
  final Uint8List? bytes;

  /// The file size in bytes. Defaults to `0` if the file size could not be
  /// determined.
  final int size;

  /// The platform identifier for the original file, refers to an [Uri](https://developer.android.com/reference/android/net/Uri) on Android and
  /// to a [NSURL](https://developer.apple.com/documentation/foundation/nsurl) on iOS.
  /// Is set to `null` on all other platforms since those are all already
  /// referencing the original file content.
  ///
  /// Note: You can't use this to create a Dart `File` instance since
  /// this is a safe-reference for the original platform files, for
  /// that the [path] property should be used instead.
  final String? identifier;

  /// File extension for this file.
  String? get extension => name.split('.').last;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is FilePicked &&
        (kIsWeb || other.path == path) &&
        other.name == name &&
        other.bytes == bytes &&
        other.identifier == identifier &&
        other.size == size;
  }

  @override
  int get hashCode {
    return kIsWeb
        ? 0
        : path.hashCode ^
            name.hashCode ^
            bytes.hashCode ^
            identifier.hashCode ^
            size.hashCode;
  }

  @override
  String toString() {
    return '''FilePicked(${kIsWeb ? '' : 'path $path'}, name: $name, bytes: $bytes, size: $size)''';
  }
}
