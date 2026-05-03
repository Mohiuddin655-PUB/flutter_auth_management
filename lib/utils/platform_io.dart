import 'dart:io';

String platformName() {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isFuchsia) return 'fuchsia';
  if (Platform.isLinux) return 'linux';
  if (Platform.isWindows) return 'windows';
  return 'unknown';
}
