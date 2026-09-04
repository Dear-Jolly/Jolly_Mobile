import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/jolly_toast.dart';

/// 약관/개인정보처리방침 같은 외부 문서를 브라우저로 연다.
///
/// 열지 못한 경우에도 화면이 멈추지 않도록 토스트로만 알린다.
class ExternalLink {
  const ExternalLink._();

  static Future<void> open(
    BuildContext context,
    Uri? uri, {
    String failureMessage = '페이지를 열 수 없습니다.',
  }) async {
    if (uri == null) {
      JollyToast.show(context, message: failureMessage);
      return;
    }

    bool launched;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }

    if (!launched && context.mounted) {
      JollyToast.show(context, message: failureMessage);
    }
  }
}
