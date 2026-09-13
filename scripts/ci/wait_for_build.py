"""업로드한 빌드가 App Store Connect 에 등록될 때까지 기다린다.

애플은 업로드 직후 바로 빌드를 보여주지 않는다. 관측된 지연은 2 분 안팎이다.
그동안은 next_build_number.py 가 이 빌드를 못 보므로, 뒤이어 도는 실행이
같은 번호를 다시 골라 업로드가 거부된다. 워크플로의 concurrency 가 실행을
직렬화하기 때문에, 이 단계에서 등록을 확인하고 끝내면 다음 실행은 항상
갱신된 상태를 본다.

처리 결과도 함께 본다. 업로드 성공과 애플의 처리 성공은 다른 이야기라
INVALID 로 끝나면 여기서 실패시킨다.

환경 변수
  ASC_KEY_ID / ASC_ISSUER_ID / ASC_PRIVATE_KEY / ASC_APP_ID
  BUILD_NUMBER  방금 올린 빌드 번호
"""

import os
import sys
import time

import asc

TIMEOUT_SECONDS = 15 * 60
POLL_SECONDS = 20


def main() -> None:
    key_id, issuer_id, private_key, app_id = asc.credentials()
    try:
        wanted = os.environ["BUILD_NUMBER"]
    except KeyError:
        sys.exit("환경 변수 BUILD_NUMBER 가 없습니다.")

    deadline = time.time() + TIMEOUT_SECONDS
    while True:
        # 토큰 수명이 20 분이라 매번 새로 만든다. 기다림이 길어져도 안전하다.
        bearer = asc.token(key_id, issuer_id, private_key)
        for build in asc.builds(app_id, bearer):
            attributes = build.get("attributes", {})
            if attributes.get("version") != wanted:
                continue
            state = attributes.get("processingState")
            print(f"build {wanted} 등록됨 (처리 상태 {state})")
            if state == "INVALID":
                sys.exit(f"build {wanted} 을 애플이 거부했습니다. App Store Connect 에서 사유를 확인하세요.")
            return

        if time.time() >= deadline:
            sys.exit(
                f"build {wanted} 이 {TIMEOUT_SECONDS // 60} 분 안에 등록되지 않았습니다.\n"
                "업로드 자체는 성공했을 수 있으니 App Store Connect 를 확인하세요.\n"
                "다음 실행이 같은 번호를 고를 수 있으므로 그대로 두지 말 것."
            )
        print(f"아직 안 보임. {POLL_SECONDS}초 뒤 다시 확인한다.", flush=True)
        time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    main()
