part of 'extention.dart';

TranslateCallback translate(BuildContext context) => S.of(context).translate;

String locale(BuildContext context) => S.of(context).localeName ?? '';

bool isVnLocale(BuildContext context) => locale(context).isVn;

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

Future<void> prePt(String path, BuildContext ctx) =>
    precachePicture(ExactAssetPicture(SvgPicture.svgStringDecoder, path), ctx);
