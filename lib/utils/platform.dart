import 'package:flutter/foundation.dart';

import 'platform_io.dart' if (dart.library.html) 'platform_web.dart' as impl;

String get currentPlatform {
  if (kIsWeb) return 'web';
  return impl.platformName();
}
