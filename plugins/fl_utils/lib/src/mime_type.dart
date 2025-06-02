enum MimeType { image, jpg, jpeg, png, svg, pdf, xlsx, docx, unknown }

extension MimeTypeExt on String? {
  MimeType get mimeType {
    if (this?.contains('image') == true) {
      if (this!.contains('svg')) {
        return MimeType.svg;
      }
      if (this!.contains('jpg')) {
        return MimeType.jpg;
      }
      if (this!.contains('jpeg')) {
        return MimeType.jpeg;
      }
      if (this!.contains('png')) {
        return MimeType.png;
      }
      return MimeType.image;
    } else if (this?.contains('sheet') == true) {
      return MimeType.xlsx;
    } else if (this?.contains('pdf') == true) {
      return MimeType.pdf;
    } else if (this?.contains('docx') == true ||
        this?.contains('document') == true) {
      return MimeType.docx;
    }
    return MimeType.unknown;
  }
}
