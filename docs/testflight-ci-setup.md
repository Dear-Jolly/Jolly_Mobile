# TestFlight 자동 배포 설정

`develop` 에 push 하면 `.github/workflows/testflight.yml` 이 iOS 빌드를 만들어
TestFlight 에 올린다. 동작하려면 아래 7개 시크릿이 먼저 등록되어 있어야 한다.

## 등록할 시크릿

| 이름 | 값 | 얻는 곳 |
|---|---|---|
| `APP_STORE_CONNECT_KEY_ID` | 10자리 키 ID | App Store Connect → 사용자 및 액세스 → 통합 → App Store Connect API |
| `APP_STORE_CONNECT_ISSUER_ID` | UUID 형태 | 같은 화면, 표 위 `Issuer ID` |
| `APP_STORE_CONNECT_PRIVATE_KEY` | `.p8` 파일 **내용 전체** | 키 생성 시 1회만 다운로드 |
| `IOS_TEAM_ID` | 10자리 팀 ID | developer.apple.com → Membership details |
| `IOS_DIST_CERT_P12` | `.p12` 를 base64 인코딩한 문자열 | 키체인 접근에서 Apple Distribution 인증서 내보내기 |
| `IOS_DIST_CERT_PASSWORD` | `.p12` 내보낼 때 정한 비밀번호 | 본인이 정한 값 |
| `IOS_PROVISIONING_PROFILE` | `.mobileprovision` 을 base64 인코딩한 문자열 | developer.apple.com → Profiles → App Store 배포용 |

API 키 역할은 **App Manager** 이상이어야 업로드가 된다.
프로비저닝 프로파일은 App ID 가 `com.dearjolly.app` 인 **App Store Connect** 배포용이어야 한다.

## 등록 명령

경로만 실제 파일 위치로 바꿔서 그대로 실행한다.

```bash
cd ~/Documents/source_files/dear-jolly/mobile

gh secret set APP_STORE_CONNECT_KEY_ID      --body "ABCD123456"
gh secret set APP_STORE_CONNECT_ISSUER_ID   --body "69a6de00-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
gh secret set IOS_TEAM_ID                   --body "ABCDE12345"
gh secret set IOS_DIST_CERT_PASSWORD        --body "내가-정한-비밀번호"

# 파일은 내용을 그대로 넣는다
gh secret set APP_STORE_CONNECT_PRIVATE_KEY < ~/Downloads/AuthKey_ABCD123456.p8

# 바이너리는 base64 로 바꿔서 넣는다
base64 -i ~/Downloads/dist.p12            | gh secret set IOS_DIST_CERT_P12
base64 -i ~/Downloads/DearJolly.mobileprovision | gh secret set IOS_PROVISIONING_PROFILE
```

등록 확인:

```bash
gh secret list
```

## 첫 실행

시크릿을 다 넣은 뒤 워크플로를 `develop` 에 올리면 곧바로 한 번 돈다.

```bash
git checkout develop
git merge ios
git push origin develop
gh run watch
```

푸시 없이 시험만 해보려면 Actions 탭에서 `TestFlight` → `Run workflow` 를 누른다.

## 빌드 번호

`pubspec.yaml` 의 `+2` 는 그대로 두고, CI 가 매번 App Store Connect 에
올라간 가장 큰 빌드 번호를 조회해 거기에 1 을 더한다
(`scripts/ci/next_build_number.py`).

TestFlight 는 같은 버전에서 이미 쓴 번호를 거부하므로 번호를 추측하지 않고
실제 스토어 상태를 물어본다. 처리 중인 빌드도 번호를 차지하기 때문에
상태로 거르지 않고 전부 센다.

번호 값 자체는 의미가 없다. 사용자에게 보이는 것은 버전 `1.0.0` 이고
빌드 번호는 같은 버전 안에서 업로드를 구분하는 일련번호일 뿐이다.
지켜야 할 것은 **이전보다 크기만 하면 된다**는 것 하나다.

재실행(re-run) 해도 그 시점의 스토어 상태를 다시 조회하므로 번호가 겹치지 않는다.

### 등록 지연 때문에 대기 단계가 하나 더 있다

애플은 업로드된 빌드를 바로 보여주지 않는다. 실측으로 **2 분** 걸렸다.
그 사이에 다음 실행이 번호를 조회하면 방금 올린 빌드를 못 보고 같은 번호를 고른다.
워크플로가 실행을 직렬화(`concurrency`)하기 때문에 PR 을 연달아 머지하면
실제로 걸린다 — 두 번째 실행은 시작 76 초 뒤에 번호를 조회했다.

그래서 업로드 뒤 `scripts/ci/wait_for_build.py` 로 등록을 확인하고 나서야 실행이 끝난다.
다음 실행은 항상 갱신된 상태를 본다.

이 단계는 애플의 처리 결과도 본다. 업로드 성공과 처리 성공은 다른 이야기라
`INVALID` 로 끝나면 워크플로를 실패시킨다.

## 업로드가 실패했을 때

빌드까지 성공했다면 IPA 가 Actions 실행 페이지의 Artifacts 에 14일간 남는다.
내려받아 Transporter 앱으로 직접 올리면 된다.

## 인증서·프로파일 만료

배포 인증서는 1년, 프로비저닝 프로파일도 1년이면 만료된다.
만료되면 서명 단계에서 실패하므로 새로 발급받아 해당 시크릿만 다시 등록한다.
