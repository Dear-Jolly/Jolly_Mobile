import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';

import '../config/api_config.dart';

class AppInfo {
  const AppInfo();

  String get apiPlatform => Platform.isIOS ? 'IOS' : 'AOS';

  Future<String> get appVersion async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version.trim();
      if (_isSemanticVersion(version)) {
        return version;
      }
    } catch (_) {
      // Platform package info is unavailable in widget tests and some previews.
    }

    return ApiConfig.appVersion;
  }

  Uri? get storeUri {
    final url = Platform.isIOS
        ? ApiConfig.iosStoreUrl
        : ApiConfig.androidStoreUrl;
    if (url.isEmpty) {
      return null;
    }
    return Uri.tryParse(url);
  }

  bool _isSemanticVersion(String value) {
    return RegExp(r'^\d{1,5}\.\d{1,5}\.\d{1,5}$').hasMatch(value);
  }
}
