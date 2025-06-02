import 'package:fl_media/fl_media.dart';
import 'package:flutter/widgets.dart';

import '../../common/constants.dart';
import '../../common/services/storage/storage_service.dart';
import '../../di/core_micro.dart';

class ImageViewWrapper extends ImageView {
  ImageViewWrapper.avatar(
    String source, {
    super.width,
    super.height,
    super.fit,
    super.color,
    super.alignment = Alignment.center,
    super.package,
    super.loadingRadius,
    super.cacheWidth = 480,
  }) : super(
          source: injector<StorageAssetProvider>().url(source),
          placeHolder: coreImageConstant.icUserAvatar,
        );

  ImageViewWrapper.item(
    String source, {
    super.width,
    super.height,
    super.fit,
    super.color,
    super.alignment = Alignment.center,
    super.package,
    super.loadingRadius,
    super.cacheWidth = 480,
  }) : super(
          source: injector<StorageAssetProvider>().url(source),
          placeHolder: coreImageConstant.icDefaultItem,
        );

  ImageViewWrapper.banner(
    String source, {
    super.width,
    super.height,
    super.fit,
    super.color,
    super.alignment = Alignment.center,
    super.package,
    super.loadingRadius,
    super.cacheWidth = 480,
  }) : super(
          source: injector<StorageAssetProvider>().url(source),
          placeHolder: coreImageConstant.icDefaultItem,
        );

  static ImageViewProviderFactory provider(String source) =>
      ImageViewProviderFactory(injector<StorageAssetProvider>().url(source));
}
