export 'platform/unsupported.dart'
    if (dart.library.io) 'platform/io.dart'
    if (dart.library.html) 'platform/web.dart'
    if (dart.library.js_interop) 'platform/web.dart';
