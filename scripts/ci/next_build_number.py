"""App Store Connect 에 올라간 가장 큰 빌드 번호 + 1 을 출력한다.

TestFlight 는 같은 버전에서 이미 쓴 빌드 번호를 거부한다. 그래서 올릴 번호를
추측하는 대신 실제 스토어 상태를 물어보고 그 다음 번호를 쓴다.

환경 변수
  ASC_KEY_ID       App Store Connect API 키 ID
  ASC_ISSUER_ID    Issuer ID
  ASC_PRIVATE_KEY  .p8 파일 내용
  ASC_APP_ID       앱의 App Store ID
"""

import base64
import json
import os
import sys
import time
import urllib.error
import urllib.request

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.hazmat.primitives.asymmetric import utils as asym_utils

BASE = "https://api.appstoreconnect.apple.com"
# 한 번에 다 못 받아올 만큼 빌드가 쌓였을 때를 대비한 안전장치.
MAX_PAGES = 20


def _b64(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode()


def _token(key_id: str, issuer_id: str, private_key: str) -> str:
    key = serialization.load_pem_private_key(private_key.encode(), password=None)
    header = {"alg": "ES256", "kid": key_id, "typ": "JWT"}
    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 20 * 60,
        "aud": "appstoreconnect-v1",
    }
    signing_input = f"{_b64(json.dumps(header).encode())}.{_b64(json.dumps(payload).encode())}"
    der = key.sign(signing_input.encode(), ec.ECDSA(hashes.SHA256()))
    r, s = asym_utils.decode_dss_signature(der)
    return f"{signing_input}.{_b64(r.to_bytes(32, 'big') + s.to_bytes(32, 'big'))}"


def _get(url: str, token: str) -> dict:
    request = urllib.request.Request(url)
    request.add_header("Authorization", "Bearer " + token)
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.loads(response.read())
    except urllib.error.HTTPError as error:
        sys.exit(f"App Store Connect 조회 실패: HTTP {error.code}\n{error.read().decode()}")
    except urllib.error.URLError as error:
        sys.exit(f"App Store Connect 에 연결하지 못했습니다: {error.reason}")


def main() -> None:
    try:
        key_id = os.environ["ASC_KEY_ID"]
        issuer_id = os.environ["ASC_ISSUER_ID"]
        private_key = os.environ["ASC_PRIVATE_KEY"]
        app_id = os.environ["ASC_APP_ID"]
    except KeyError as missing:
        sys.exit(f"환경 변수 {missing} 가 없습니다.")

    token = _token(key_id, issuer_id, private_key)
    # 처리 중인 빌드도 번호를 차지하므로 상태로 거르지 않고 전부 센다.
    url = f"{BASE}/v1/builds?filter[app]={app_id}&limit=200"
    highest = 0
    seen = 0

    for _ in range(MAX_PAGES):
        page = _get(url, token)
        for build in page.get("data", []):
            seen += 1
            raw = build.get("attributes", {}).get("version")
            # 빌드 번호가 늘 정수라는 보장은 없다. 숫자가 아니면 비교에서 뺀다.
            try:
                highest = max(highest, int(raw))
            except (TypeError, ValueError):
                print(f"빌드 번호를 숫자로 읽지 못해 건너뜁니다: {raw!r}", file=sys.stderr)
        url = page.get("links", {}).get("next")
        if not url:
            break
    else:
        sys.exit(f"빌드가 {MAX_PAGES} 페이지를 넘습니다. 조회 방식을 손봐야 합니다.")

    print(f"빌드 {seen}개 조회, 가장 큰 번호 {highest}", file=sys.stderr)
    print(highest + 1)


if __name__ == "__main__":
    main()
