part of '../constants.dart';

CoreImageConstant get coreImageConstant => injector.get<CoreImageConstant>();

abstract class CoreImageConstant {
  String get logo;

  String get icUserAvatar;

  String? get imgScreenFormHeader;

  String? get imgMainPageFormHeader;

  String? get icDefaultItem;
}
