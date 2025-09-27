import 'package:web/web.dart';

bool get isIosBrowser {
  final userAgent = window.navigator.userAgent.toLowerCase();
  return userAgent.contains('iphone') || userAgent.contains('ipad');
}

bool get isAndroidBrowser {
  final userAgent = window.navigator.userAgent.toLowerCase();
  return userAgent.contains('android');
}
