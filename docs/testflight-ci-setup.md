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

`pubspec.yaml` 의 `+2` 는 그대로 두고, CI 가 `100 + 실행 번호` 를 빌드 번호로 넣는다.
첫 실행이 101, 다음이 102 식으로 올라간다.

같은 실행을 **재실행(re-run)** 하면 실행 번호가 그대로라 빌드 번호가 겹치고
업로드가 거부된다. 이럴 땐 재실행 대신 빈 커밋을 하나 올려 새로 돌린다.

```bash
git commit --allow-empty -m "chore: trigger TestFlight build"
git push origin develop
```

## 업로드가 실패했을 때

빌드까지 성공했다면 IPA 가 Actions 실행 페이지의 Artifacts 에 14일간 남는다.
내려받아 Transporter 앱으로 직접 올리면 된다.

## 인증서·프로파일 만료

배포 인증서는 1년, 프로비저닝 프로파일도 1년이면 만료된다.
만료되면 서명 단계에서 실패하므로 새로 발급받아 해당 시크릿만 다시 등록한다.
