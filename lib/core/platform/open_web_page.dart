import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/jolly_toast.dart';

Future<void> openWebPage(
  BuildContext context,
  String url, {
  required String failureMessage,
}) async {
  final uri = Uri.parse(url);
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  } catch (_) {
    // Some platforms only support the system browser.
  }
  if (!opened) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Present the same message for both launch failure modes.
    }
  }
  if (!opened && context.mounted) {
    JollyToast.show(context, message: failureMessage);
  }
}
