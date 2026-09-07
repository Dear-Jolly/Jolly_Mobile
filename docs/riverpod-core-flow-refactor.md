# Riverpod Core Flow Refactor

## 대상 흐름

이번 리팩터링 대상은 `편지 작성 -> 전송 API 요청 -> 작성 완료 화면 이동` 흐름이다.

해당 흐름은 실제 사용자가 앱에서 가장 먼저 경험하는 쓰기 기능이고, `WriteLetterScreen`에서 입력 검증, 확인 다이얼로그, API 요청, 실패 표시, 성공 라우팅이 한 클래스에 섞여 있었다. 프로젝트 안에서 "작성 -> API 요청 -> 결과 확인" 성격을 가장 명확하게 갖는 흐름이라 우선 전환 대상으로 선택했다.

## 해결하려는 문제

- `lib/features/write/view/write_letter_screen.dart`가 화면 렌더링과 전송 비동기 상태를 함께 관리했다.
- `_isSubmitting`, `_submitPausedUntil`, `Timer`가 UI 클래스에 있어 중복 제출 방지와 429 backoff 정책을 화면 코드가 직접 알고 있었다.
- API 실패는 `Failure`를 받은 직후 토스트만 띄우고 끝나서, 실패 상태와 재시도 가능 여부를 테스트하기 어려웠다.
- 화면이 이탈한 뒤 API 응답이 늦게 도착하는 상황은 `mounted` 체크로 일부 방어했지만, 요청 상태 자체의 생명주기는 화면 클래스에 묶여 있었다.

## Before

- UI: `WriteLetterScreen`
  - 텍스트 입력, 500자 카운트, 영어 입력 제한
  - 확인 다이얼로그 표시
  - `CreateLetterUseCase` 직접 호출
  - `_isSubmitting`으로 중복 제출 방지
  - 429 응답이면 `Timer`로 1분 제출 pause
  - 성공 시 `/write/complete` 이동
  - 실패 시 `JollyToast.show`
- API 의존성: `createLetterUseCaseProvider`
  - `CreateLetterUseCase -> LetterRepository -> LetterRemoteDataSource`
  - `POST /letters` payload는 `content`, `writtenAt`, `timeZone`

## After

- Provider: `lib/features/write/state/write_letter_controller.dart`
  - `writeLetterControllerProvider`
  - `writeLetterRetryBackoffProvider`
- Controller: `WriteLetterController`
  - `AsyncNotifier<WriteLetterSubmissionState>` 기반 전송 상태 관리
  - 중복 submit 차단
  - `Failure`를 `WriteLetterSubmissionFailure`로 변환
  - 429 / `COMMON_004` backoff와 retry 가능 상태 관리
  - autoDispose provider가 dispose되면 Timer 취소 및 응답 무시
- UI: `WriteLetterScreen`
  - 텍스트 입력, 카운터, 영어 입력 제한, 확인 다이얼로그는 유지
  - `ref.watch(writeLetterControllerProvider)`는 하단 제출 영역에서만 사용
  - 사용자 액션은 `ref.read(writeLetterControllerProvider.notifier).submit(...)`
  - 성공 라우팅과 토스트는 UI side effect로 유지

## 상태 흐름

- 빈 입력: 로컬 입력 검증으로 CTA disabled, Controller 상태는 `idle`
- 전송 시작: `idle/error -> submitting`
- 성공: `submitting -> success`, UI가 반환된 `Letter`로 `/write/complete?letterId=...&submittedAt=...` 이동
- 일반 실패: `submitting -> error`, 실패 메시지와 `다시 시도` 액션 노출
- 429 실패: `submitting -> error`, 1분 동안 retry pause, 이후 동일 실패 상태에서 retry 가능

## 처리한 엣지 케이스

- 중복 전송: `submitting` 또는 retry pause 상태에서는 추가 `submit`이 `null`을 반환하고 Repository를 호출하지 않는다.
- 화면 이탈: provider dispose 시 `_retryResumeTimer`를 취소하고, 늦게 도착한 응답은 상태에 반영하지 않는다.
- 네트워크/API 실패: 기존 Repository가 만든 `Failure.message/statusCode/code/requestId`를 `WriteLetterSubmissionFailure`로 보존한다.
- 429 rate limit: `statusCode == 429` 또는 `code == COMMON_004`이면 backoff를 적용한다.
- rebuild 범위: 작성 화면 전체가 아니라 하단 제출 영역만 `ref.watch`로 구독한다.
- 기존 UX 보존: CTA 문구 `전달하기`, 확인 다이얼로그, 성공 이동 경로, 500자 카운터, 영문 입력 제한은 유지했다.

## 테스트

추가한 테스트:

- `test/write_letter_controller_test.dart`
  - 요청 성공 시 `idle -> submitting -> success`
  - API 실패 시 `error` 상태와 retry 가능 여부
  - 연속 전송 시 Repository 호출 1회 유지
  - provider dispose 후 늦은 응답 무시
  - 429 실패 시 backoff 동안 retry pause 후 재시도 가능
- `test/write_letter_screen_test.dart`
  - 전송 실패 시 화면에 실패 메시지와 `다시 시도` 액션 노출

실행 결과:

```text
flutter analyze
No issues found.

flutter test test/write_letter_controller_test.dart test/write_letter_screen_test.dart
All tests passed.

flutter test
All tests passed.
```

## 아직 전환하지 않은 범위

- 홈 화면의 편지 목록, pagination, feedback polling 상태
- 리뷰 상세 화면의 피드백 조회 상태
- 로그인/OAuth callback 상태
- 온보딩 약관/닉네임 등록 상태
- 앱 전체 라우팅 상태와 인증 세션 상태

## 다음 단계 후보

1. 홈 화면 목록 상태를 `AsyncNotifier`로 분리하고 pagination, silent refresh, feedback polling을 테스트 가능하게 만든다.
2. 리뷰 상세 조회를 provider family로 전환해 `letterId` 단위 캐시와 재시도를 명확히 한다.
3. 로그인 callback 흐름을 controller로 분리해 deep link, 실패, 세션 저장 상태를 테스트한다.
