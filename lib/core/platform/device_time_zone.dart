import 'package:flutter_timezone/flutter_timezone.dart';

import '../config/api_config.dart';

class DeviceTimeZone {
  const DeviceTimeZone();

  Future<String> get currentIdentifier async {
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      final identifier = timeZone.identifier.trim();
      if (identifier.isNotEmpty) {
        return identifier;
      }
    } catch (_) {
      // Native timezone lookup is unavailable in widget tests and some previews.
    }

    return ApiConfig.defaultTimeZone;
  }
}
