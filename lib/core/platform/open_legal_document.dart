import 'package:flutter/material.dart';

import '../config/legal_documents.dart';
import 'open_web_page.dart';

Future<void> openLegalDocument(BuildContext context, LegalDocument document) =>
    openWebPage(
      context,
      document.url,
      failureMessage: '문서를 열 수 없어요. 잠시 후 다시 시도해주세요.',
    );
