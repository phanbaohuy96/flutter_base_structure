import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../common.dart';

@injectable
class SystemHeaderProvider extends HeaderProvider {
  SystemHeaderProvider();

  @override
  Map<String, String> build() {
    return {
      RequestHeaderKey.osplatform.key:
          kIsWeb ? 'web-app' : Platform.operatingSystem,
    };
  }
}
