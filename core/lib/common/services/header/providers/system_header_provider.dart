import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../common.dart';

@injectable
class SystemHeaderProvider extends HeaderProvider {
  SystemHeaderProvider();

  @override
  Map<String, String> build() {
    return {
      RequestHeaderKey.osplatform.key: Platform.operatingSystem,
    };
  }
}
