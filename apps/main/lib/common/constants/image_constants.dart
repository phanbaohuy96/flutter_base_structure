import 'package:core/common/constants.dart' as core_const;
import 'package:injectable/injectable.dart';

import '../../di/di.dart';
import '../../generated/assets.dart';

ImageConstant get imageConstant =>
    injector.get<core_const.CoreImageConstant>() as ImageConstant;

@Singleton(as: core_const.CoreImageConstant)
class ImageConstant extends core_const.CoreImageConstant {
  @override
  String get icUserAvatar => Assets.images.svg.icUserAvatar;

  @override
  String get icGroupAvatar => Assets.images.svg.icUserAvatar;

  @override
  String get imgScreenFormHeader => '';

  @override
  String get imgMainPageFormHeader => '';

  @override
  String get logo => Assets.images.png.logo;

  @override
  String get icDefaultItem => Assets.images.png.logo;
}
