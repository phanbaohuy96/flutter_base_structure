import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../common.dart';

@injectable
class SystemHeaderProvider extends HeaderProvider {
  SystemHeaderProvider();

  @override
  Future<Map<String, String>> build() async {
    return {
      // Check if web platform then we don't include to os-platform in request
      // header to prevent CORS error
      if (!kIsWeb) RequestHeaderKey.osplatform.key: Platform.operatingSystem,
    };
  }
}
