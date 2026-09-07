# 디어졸리 문의 시스템

## 구성 및 현재 상태

- 입력: 답변받을 메일, 닉네임, 문의 종류, 핸드폰 기종, 문의 내용 및 개인정보 수집·이용 동의
- 경로: 앱 설정 → Google 설문지 → 비공개 Google 시트 → Discord 비공개 문의-알림 채널.
- 공개 문의 폼: https://docs.google.com/forms/d/e/1FAIpQLSdUC1NE73S9btyxDPVxWKJshuSEps3j8_qDxNpsay9rtZfBCQ/viewform
- 비공개 관리 시트: https://docs.google.com/spreadsheets/d/1y9FvZudUc4HM7dF5a9Vx_5y9jTgyoqHT_K5aPVc6u1Q/edit
- 폼 편집: https://docs.google.com/forms/d/1lhSpJqZWyTtY87MU3DCHA7jqZYC8XPYo9OrS-cN_RIk/edit
- Discord 비공개 채널 생성 완료: https://discord.com/channels/1449981461292777584/1546341316919828630
- 채널 접근 대상: 이연진(소유자), 고명서, 은정
- 전용 웹훅 `디어졸리 문의 알림` 생성 및 Apps Script의 `DISCORD_WEBHOOK_URL` 속성 저장 완료. 주소는 앱이나 저장소에 넣지 않습니다.
- Google 자동화 프로젝트: https://script.google.com/home/projects/1uXEzxOSLewyvUSKQmRyrPaKLkcmte8SMSxZTodVPx-0GVqss3dp1l7k0/edit
- Google 계정: dearjolly.official@gmail.com (Chrome DearJolly 프로필)
- Google 계정 접근 승인 완료. 폼 응답을 위 시트에 직접 연결하고 응답 표를 데이터 범위로 되돌린 뒤, 기존 정상 저장본의 setup 실행이 2026-09-07 11:53에 완료됐습니다.
- 앱 설정의 문의하기 메뉴가 공개 폼을 엽니다. 작은 화면에서 설정 메뉴가 스크롤됩니다.
- 비로그인 브라우저에서 필수 여섯 항목과 접수 완료 화면을 확인했습니다. `test@example.com` / `문의연결테스트` / `기타`로 명확히 테스트라고 표시한 응답 한 건을 제출했습니다. 실제 고객 정보나 이메일 발송은 없습니다.
- 앱 정적 검사 및 약관 링크 테스트 4개, 문의 링크·작은 화면 테스트 1개 통과.
- 재설치 및 복구용 원본: `scripts/support/Code.gs`. 신규 폼의 응답 대상 조회와 Google Forms 표 필터 충돌을 처리합니다. 현재 구글에는 기존 정상 저장본이 실행 중이며, 이 개선 원본을 다시 업로드하지는 않았습니다.
- 다른 Apps Script 편집 탭에는 잘못 입력된 미저장 수정 내용이 남아 있을 수 있습니다. 해당 탭의 수정본을 저장하지 마세요. 정상 실행에 사용한 탭은 최초에 열었던 Apps Script 탭입니다. 중복 탭 닫기는 자동 승인 검토에서 미저장 내용 손실 우려로 차단되어 그대로 두었습니다. 운영 중인 저장본에는 영향이 없습니다.

## 연결 검증 완료 (2026-09-07, 한국 시간)

1. 제출 시 실행되는 `onInquirySubmit`과 시간 기반 `retryNotifications` 트리거 2개를 확인했습니다. 두 트리거 오류율은 0%였습니다.
2. 기존 테스트 문의 `DJ-20260907-5ab21c13`가 오후 1:01에 Discord 문의-알림 채널에 도착했습니다. 다섯 입력값과 관리 시트 A2:L2 링크가 모두 표시됩니다.
3. 관리 시트 J2의 `전송 완료`를 확인했습니다.
4. 오후 1:02 `retryNotifications` 수동 실행도 완료됐으며, 이미 전송된 테스트 알림은 중복 발송되지 않았습니다.

## 운영

문의 종류: 오류 및 버그 / 계정 및 로그인 / 편지 작성 및 교정 / 기능 제안 / 개인정보 및 탈퇴 / 기타.

관리 시트에는 접수시각과 입력값 외에 문의번호, 처리 상태, 디스코드 알림, 알림 전송시각, 운영 메모를 둡니다. 처리 상태는 접수 / 확인 중 / 답변 완료 / 보류 중 선택합니다. 답변은 입력된 이메일로 운영자가 보냅니다. 자동 이메일 발송은 포함하지 않습니다.

알림 실패 시 최대 10건씩 5분마다 재시도합니다. 시트가 문의 원본이며, Discord 알림 실패로 원본이 사라지지 않습니다. 사용자 입력으로 Discord 멘션이 발생하지 않도록 `allowed_mentions`를 비활성화합니다.

폼에 안내한 보관기간은 접수일부터 1년입니다. 기간이 지난 폼 응답, 시트 행, Discord 메시지는 운영자가 삭제해야 합니다.

폼 응답 링크만 일반 사용자에게 제공하고, 응답 시트·자동화 프로젝트·웹훅은 운영진이 관리합니다.
