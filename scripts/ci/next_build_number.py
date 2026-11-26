"""App Store Connect 에 올라간 가장 큰 빌드 번호 + 1 을 출력한다.

TestFlight 는 같은 버전에서 이미 쓴 빌드 번호를 거부한다. 그래서 올릴 번호를
추측하는 대신 실제 스토어 상태를 물어보고 그 다음 번호를 쓴다.

애플이 업로드된 빌드를 등록하는 데 2 분쯤 걸린다. 그 사이에 이 스크립트가
돌면 방금 올린 빌드를 못 보고 같은 번호를 다시 내놓는다. 그래서 워크플로는
업로드 뒤 wait_for_build.py 로 등록을 확인한 다음에야 끝난다.

환경 변수
  ASC_KEY_ID       App Store Connect API 키 ID
  ASC_ISSUER_ID    Issuer ID
  ASC_PRIVATE_KEY  .p8 파일 내용
  ASC_APP_ID       앱의 App Store ID
"""

import sys

import asc


def main() -> None:
    key_id, issuer_id, private_key, app_id = asc.credentials()
    bearer = asc.token(key_id, issuer_id, private_key)
    found = asc.builds(app_id, bearer)

    highest = 0
    for build in found:
        raw = build.get("attributes", {}).get("version")
        # 빌드 번호가 늘 정수라는 보장은 없다. 숫자가 아니면 비교에서 뺀다.
        try:
            highest = max(highest, int(raw))
        except (TypeError, ValueError):
            print(f"빌드 번호를 숫자로 읽지 못해 건너뜁니다: {raw!r}", file=sys.stderr)

    print(f"빌드 {len(found)}개 조회, 가장 큰 번호 {highest}", file=sys.stderr)
    print(highest + 1)


if __name__ == "__main__":
    main()
