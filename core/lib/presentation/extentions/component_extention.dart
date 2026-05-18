part of 'extention.dart';

Future<void> preIm(String path, BuildContext ctx) =>
    precacheImage(AssetImage(path), ctx);

// Future<void> prePt(String path, BuildContext ctx) => precachePicture(
//       ExactAssetPicture(SvgPicture.svgStringDecoder, path),
//       ctx,
//     );
