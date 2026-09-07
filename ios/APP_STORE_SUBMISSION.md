# Dear Jolly — App Store 심사 제출 체크리스트

iOS 첫 심사 제출까지 필요한 작업과, 반려가 잦은 항목의 대응 상태를 정리한다.

## 2026-09-07 develop 통합 및 TestFlight 업데이트

- `ios` 브랜치의 커밋 `47ed7da`까지 develop에 통합했다.
- develop의 Riverpod 구성, 약관 열람과 동의 분리, 문의 폼 연결을 유지했다.
- iOS 시스템 인증 세션을 적용하고 Android는 기존 외부 브라우저 로그인 경로를 유지한다.
- 등록된 번들 ID `com.dearjolly.app`, App Store ID `6808617546`, iPhone 세로 화면 및 개인정보 매니페스트를 반영했다.
- TestFlight에서 기존 `1.0.0 (1)` 및 내부 그룹 `졸리`를 확인했다. 다음 빌드는 `1.0.0 (2)`이다.
- 로컬 Flutter 3.38.3 / Xcode 26.1.1에서 정적 검사와 전체 테스트 16개, 서명 없는 iOS 릴리즈 빌드가 통과했다.
- 이 Mac의 Xcode 계정은 `leeyeonjeen@icloud.com`이며 Eunjeong Heo 팀의 App Manager로 표시된다. `Certificates, Identifiers, & Profiles` 접근은 불가하며 유효한 코드 서명 인증서가 없다.
- 이번 빌드는 아직 TestFlight에 업로드되지 않았다. 서명 가능한 개발자 계정 또는 기존 배포 인증서와 프로필이 필요하다. 비밀번호나 개인 키를 저장소에 넣지 않는다.
- 아래 이전 작업 기록의 '배포 인증서 서명 완료'는 당시 작업 환경에 대한 설명이며 현재 Mac의 상태를 뜻하지 않는다.


---

## 1. 이번에 처리한 항목

| 항목 | 처리 내용 | 관련 가이드라인 |
| --- | --- | --- |
| 빌드 환경 | 로컬 Flutter 3.35.6 이 pubspec 요구치(3.38.1+)보다 낮아 빌드 자체가 불가능했다. 3.47.2 로 올림 | 빌드 불가 |
| 앱 표시 이름 | `Jolly Mobile` / `jolly_mobile` → `Dear Jolly` | 2.3.7 |
| 기본 언어 | `CFBundleDevelopmentRegion` 을 `ko` 로 지정 | 메타데이터 |
| 수출 규정 | `ITSAppUsesNonExemptEncryption = false`. 업로드마다 뜨던 암호화 설문이 사라진다 | 5.1.3 |
| 화면 방향 | 세로 고정. 모든 화면이 세로 Figma 프레임 좌표 기준이라 가로에서 깨진다 | 2.1 |
| 지원 기기 | iPhone 전용 (`TARGETED_DEVICE_FAMILY = 1`) | 2.1 |
| 개인정보 매니페스트 | `ios/Runner/PrivacyInfo.xcprivacy` 추가 후 Xcode 타겟 리소스로 등록 | ITMS-91053 |
| 설정 화면 죽은 버튼 | `공지사항` / `개인정보처리방침` 이 아무 동작도 하지 않던 문제 수정. `서비스 이용약관` 메뉴 추가 | 2.1 |
| 약관 열람 경로 | 약관 항목 자체에 원문 링크 연결 (별도 `보기` 버튼 없음) | 5.1.1 |
| 앱 버전 표기 | `현재 버전 1.0.0 (MVP)` 하드코딩 → 실제 번들 버전 표시 | 2.3.1 |
| 계정 삭제 | 설정 → 회원탈퇴 로 앱 안에서 완결 (기존 구현 유지) | 5.1.1(v) |
| Sign in with Apple | 카카오 로그인과 함께 제공 (기존 구현 유지) | 4.8 |

### 검증한 내용

- `flutter analyze` 무경고, `flutter test` 5건 전부 통과
- 릴리즈 빌드 성공 (`flutter build ios --release`)
- 빌드 산출물의 `Info.plist` 에서 표시 이름 / 암호화 / iPhone 전용 / 세로 고정 확인
- 앱과 모든 플러그인의 `PrivacyInfo.xcprivacy` 가 번들에 포함됨을 확인
- 시뮬레이터에서 `dearjolly://` 콜백을 받아 약관 화면으로 이동하는 것을 확인
- 약관 3종 Notion 페이지가 웹 공개 상태임을 확인
- `/auth/apple`, `/auth/kakao` 가 각 공급자 인증 페이지로 정상 302 리다이렉트하는 것을 확인
- 약관 동의 화면이 전부 해제 상태로 시작하는지 위젯 테스트로 고정 (`test/terms_screen_test.dart`)

### Flutter 업그레이드가 함께 바꾼 것

3.47.2 로 올리면서 Flutter 도구가 iOS 프로젝트를 자동 마이그레이션했다.

- 최소 배포 타겟 iOS 13.0 → **15.0**
- `AppDelegate` 가 UIScene 생명주기 방식으로 전환 (`FlutterImplicitEngineDelegate`)
- `Info.plist` 에 `UIApplicationSceneManifest` 추가
- Swift Package Manager 통합 활성화 (`flutter_secure_storage` 는 아직 미지원이라 CocoaPods 로 처리됨)

UIScene 전환은 딥링크 수신 경로를 바꾸기 때문에 로그인 콜백이 깨질 위험이 있었다. 시뮬레이터에서 실제 콜백을 넣어 정상 동작을 확인했다.

---

## 2. 확정된 결정

| 항목 | 결정 |
| --- | --- |
| 앱 이름 | Dear Jolly |
| 지원 기기 | iPhone 전용 |
| API 주소 | 현재 IP 기반 주소(`43-201-80-36.sslip.io`)로 제출 |
| 심사 계정 | 리뷰어의 Apple ID 로 `Apple로 로그인` 안내 |
| 번들 ID | `com.dearjolly.app` (등록된 App ID 에 맞춤) |
| 출시 지역 | 대한민국만 |
| 가격 | 무료 |

약관 링크는 아래 Notion 주소를 코드 기본값으로 넣었다. 별도 주입 없이도 동작한다.

- 서비스 이용약관: `https://yeonjeen-0821.notion.site/service-agree`
- 개인정보 처리방침: `https://yeonjeen-0821.notion.site/privacy`
- 마케팅 정보 수신 동의: `https://yeonjeen-0821.notion.site/marketing`

---

## 3. 제출 전 남은 작업

### 반드시 확인할 것

**Apple 비공개 이메일 릴레이 가입 확인.** 심사 계정을 리뷰어의 Apple ID 로 가기로 했으므로, 리뷰어는 십중팔구 이메일 가리기를 선택한다. 그러면 서버에 `xxxxx@privaterelay.appleid.com` 형태의 주소가 들어온다. 이 주소로 가입과 로그인이 끝까지 되는지 실제로 한 번 돌려봐야 한다. 여기서 막히면 리뷰어가 첫 화면조차 못 넘어가고 바로 반려된다.

`/auth/apple` 은 `scope=name email` 로 요청하는데, Apple 은 **최초 인증 때만** 이름과 이메일을 보낸다. 테스트하다가 같은 Apple ID로 재인증하면 이메일이 안 오므로, 서버가 그 경우도 처리하는지 함께 봐야 한다.

**빌드 업로드만 남았다.** IPA 는 배포용 인증서로 서명을 마쳤다.

    build/ios/ipa/Dear Jolly.ipa

업로드는 앱 암호를 키체인에 넣어 두고 altool 로 보낸다. 이 Xcode 버전은 `--item` 플래그를 요구한다.

    xcrun altool --store-password-in-keychain-item --item AC_PASSWORD -u <Apple ID> -p <앱 암호>
    xcrun altool --upload-app --type ios -f "build/ios/ipa/Dear Jolly.ipa" \
      -u <Apple ID> -p "@keychain:AC_PASSWORD"

### 선택 사항

`JOLLY_NOTICE_URL` 은 비워두면 설정 화면에서 공지사항 메뉴 자체가 숨겨진다. 지금은 숨김 상태다.

### 릴리즈 빌드 명령

기본값이 들어 있어 그냥 빌드해도 된다. 앱 ID를 받은 뒤에는 아래처럼 스토어 주소를 넣는다.

```
flutter build ipa --release \
  --dart-define=JOLLY_IOS_STORE_URL=https://apps.apple.com/app/id0000000000
```

---

## 4. API 서버 관련 경고

현재 API 주소는 `https://43-201-80-36.sslip.io/api/v1` 이다. 이번 심사는 이대로 가기로 했으나, 아래 위험은 남아 있다.

- TLS 는 Let's Encrypt 정식 인증서라 App Transport Security 는 통과한다. 인증서 만료일은 2026-11-20 이며 자동 갱신 여부를 확인해 두는 편이 좋다.
- 도메인에 EC2 공인 IP가 그대로 박혀 있다. **인스턴스를 재시작해 IP가 바뀌면 이미 배포된 앱이 전부 서버에 붙지 못한다.** 심사 중에 그렇게 되면 Guideline 2.1 로 반려되고, 출시 후라면 앱이 그대로 죽는다.
- 같은 주소가 Apple Developer 포털의 Services ID 반환 URL(`.../auth/apple/callback`)과 카카오 개발자 콘솔의 Redirect URI 에도 등록되어 있다. IP가 바뀌면 그 두 곳도 함께 고쳐야 한다.

다음 버전에서는 고정 도메인으로 옮기고 `JOLLY_API_BASE_URL` 로 주입하는 것을 권한다.

---

## 5. App Store Connect 입력값

### 입력을 마친 항목

- 스크린샷 6장 (6.5인치, 1242 x 2688, 알파 제거). 원본이 3780 x 8208 이라 규격에 맞춰 변환했다.
  여러 장을 한 번에 올리면 순서가 섞이므로 한 장씩 순서대로 올려야 한다.
- 프로모션 텍스트: 영어 일기를 쓰고 피드백을 편지로 받는 영어 학습 서비스
- 설명 첫 줄: Write Jolly, Feel jolly!
- 지원 URL: https://yeonjeen-0821.notion.site/support
- 마케팅 URL: https://www.instagram.com/dearjolly.official
- 개인정보 처리방침 URL, 데이터 수집 4종 답변 게시 완료
- 연령 등급 4+, 가격 무료, 대한민국 단독 출시
- 심사 메모 작성, 데모 계정 칸은 비우고 리뷰어 Apple ID 안내로 대체

### TestFlight

- 내부 그룹 `졸리` 생성, 자동 배포 켬
- 계정 소유자 추가 완료
- leeyeonjeen@icloud.com 은 App Store Connect 사용자로 초대함 (Dear Jolly 앱 한정,
  앱 관리 · 사용자 지원 역할). 초대를 수락해야 내부 테스터 목록에 나타난다.
- 베타 앱 설명, 피드백 이메일, 개인정보 URL, 베타 심사 메모 입력 완료

### 앱 정보 (입력 완료)
- Apple ID: `6808617546`
- 이름: Dear Jolly
- 부제: 영어 편지를 쓰면 첨삭이 도착해요
- 기본 언어: 한국어
- 번들 ID: `com.dearjolly.app`
- SKU: `dearjolly-ios-1000`
- 카테고리: 교육 / 라이프스타일
- 연령 등급: 4+
- 콘텐츠 권한: 타사 콘텐츠 없음
- 가격: 무료, 대한민국만

### 출시 지역을 대한민국으로 제한한 이유

EU 에 배포하려면 디지털 서비스법(DSA) 거래자 자격 정보를 제출해야 하고,
미제출 시 EU App Store 에서 앱이 삭제된다. 여기에 GDPR 대응까지 얹으면
한국어 전용 약관만 가진 지금 상태로는 감당하기 어렵다.
해외 출시는 약관 영문화와 DSA · GDPR 대응을 마친 뒤 지역을 추가하는 편이 낫다.
지역 추가는 App Store Connect 에서 언제든 가능하다.

### 개인정보 보호 (App Privacy)

`PrivacyInfo.xcprivacy` 와 답변이 일치해야 한다. 현재 매니페스트 기준:

| 수집 항목 | 계정 연결 | 트래킹 | 목적 |
| --- | --- | --- | --- |
| 이메일 주소 | 예 | 아니오 | 앱 기능 |
| 사용자 ID | 예 | 아니오 | 앱 기능 |
| 이름(닉네임) | 예 | 아니오 | 앱 기능 |
| 기타 사용자 콘텐츠(편지 본문) | 예 | 아니오 | 앱 기능 |

- 트래킹: 사용 안 함
- 서드파티 광고 SDK: 없음

### 심사 정보 (App Review Information)

로그인 없이는 어떤 화면도 볼 수 없으므로 심사 메모에 진입 방법을 반드시 적는다. 데모 계정 칸은 비우고, 아래 메모로 대신한다.

```
Dear Jolly는 사용자가 영어로 짧은 편지를 쓰면 첨삭 피드백을 받는 앱입니다.

[로그인]
별도의 데모 계정은 없습니다.
로그인 화면의 'Apple로 로그인' 버튼을 눌러 리뷰어님의 Apple ID로 바로
가입 및 로그인하실 수 있습니다. 이메일 가리기를 선택하셔도 정상 동작합니다.

[사용 흐름]
1. Apple로 로그인 → 약관 동의 → 닉네임 입력
2. 홈에서 '편지 쓰기'를 눌러 영어로 편지를 작성하고 제출
3. 첨삭 피드백은 즉시 제공되지 않고 일정 시간 뒤에 도착합니다.
   홈 화면의 편지 카드에 남은 시간이 표시되며, 도착하면 카드를 눌러
   첨삭 결과를 확인할 수 있습니다.

[계정 삭제]
설정 → 회원탈퇴 에서 앱 안에서 계정과 모든 편지를 삭제할 수 있습니다.

[참고]
편지는 작성자 본인만 볼 수 있으며 사용자 간 공유나 공개 기능은 없습니다.
로그인은 앱에서 Safari로 이동했다가 앱으로 돌아오는 방식입니다.
```

> 피드백 대기 시간을 **분 단위로 정확히** 적어야 한다. 리뷰어가 결과 화면을 못 보고 "기능이 동작하지 않는다"고 판단하는 것이 이 앱에서 반려 확률이 가장 높은 지점이다. 가능하면 심사 기간에만 대기 시간을 짧게 두는 편이 안전하다.

---

## 6. 스크린샷

필수는 6.9인치(1320 x 2868 또는 1290 x 2796) 한 세트다. 6.5인치는 더 이상 필수가 아니며 6.9인치 세트가 하위 크기에 자동 적용된다.

권장 5장:
1. 로그인 / 인트로
2. 홈 (편지 목록)
3. 편지 작성
4. 작성 완료
5. 첨삭 결과

---

## 7. 남은 위험 요소

### 소셜 로그인이 외부 Safari로 나간다

`lib/features/login/view/login_screen.dart` 에서 `LaunchMode.externalApplication` 으로 로그인 페이지를 연다. 앱을 벗어났다가 `dearjolly://` 커스텀 스킴으로 돌아오는 구조다.

- 시뮬레이터에서 콜백 수신과 화면 전환은 확인했다.
- 다만 실제 기기에서 Apple ID 로그인 왕복 전체를 한 번은 돌려봐야 한다. 리뷰어가 Safari에서 앱으로 못 돌아오면 곧바로 2.1 반려다.
- 여유가 있다면 `ASWebAuthenticationSession` 으로 바꾸는 편이 이탈 없이 안전하다.

### 첨삭 결과가 지연 도착한다

위 심사 메모 항목 참고. 이 앱에서 가장 반려 확률이 높은 지점이다.

### API 주소가 IP 기반이다

4번 항목 참고.
