part of 'extention.dart';

AppLocalizations translate(BuildContext context) =>
    AppLocalizations.of(context)!;

extension DiacriticsAwareString on String {
  static const diacritics =
      'àáâãèéêếìíòóôõùúăđĩũơưăạảấầẩẫậắằẳẵặẹẻẽềềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ';
  static const nonDiacritics =
      'aaaaeeeeiioooouuadiuouaaaaaaaaaaaaaeeeeeeeeiioooooooooooouuuuuuuyyyy';

  String get removeDiacritics => splitMapJoin('',
      onNonMatch: (char) => char.isNotEmpty && diacritics.contains(char)
          ? nonDiacritics[diacritics.indexOf(char)]
          : char);
}

Future<void> preIm(String path, BuildContext ctx) =>
    precacheImage(AssetImage(path), ctx);

Future<void> prePt(String path, BuildContext ctx) => precachePicture(
      ExactAssetPicture(SvgPicture.svgStringDecoderBuilder, path),
      ctx,
    );
