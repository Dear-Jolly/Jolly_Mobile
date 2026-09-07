enum LegalDocument {
  serviceTerms(
    '서비스 이용약관',
    'https://yeonjeen-0821.notion.site/service-agree',
  ),
  privacyPolicy(
    '개인정보 수집·이용 동의 및 처리방침',
    'https://yeonjeen-0821.notion.site/privacy',
  ),
  marketingConsent(
    '마케팅 정보 수신 동의',
    'https://yeonjeen-0821.notion.site/marketing',
  );

  const LegalDocument(this.title, this.url);

  final String title;
  final String url;
}
