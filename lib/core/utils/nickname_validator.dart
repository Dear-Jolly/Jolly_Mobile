class NicknameValidator {
  static String? validate(String text) {
    if (text.isEmpty) return null;
    if (text.length < 2) return '2자 이상 입력해주세요';
    if (text.length > 10) return '10자 이하로 입력해주세요';
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(text)) {
      return '공백,특수기호,한글 없이 작성해주세요';
    }
    return null;
  }

  static bool isValid(String text) {
    return text.isNotEmpty && validate(text) == null;
  }
}
