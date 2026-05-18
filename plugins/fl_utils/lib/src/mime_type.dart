enum MimeType { image, svgImage, pdf, xlsx, docx, unknow }

extension MimeTypeExt on String? {
  MimeType get mimeType {
    if (this?.contains('image') == true) {
      if (this!.contains('svg')) {
        return MimeType.svgImage;
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
    return MimeType.unknow;
  }
}
