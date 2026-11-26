"""App Store Connect API 호출에 필요한 최소한의 것들.

JWT 를 직접 만든다. 러너에 넣을 의존성을 cryptography 하나로 줄이기 위해서다.
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


def _b64(raw: bytes) -> str:
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode()


def credentials() -> tuple[str, str, str, str]:
    """환경 변수에서 자격 증명을 읽는다. 없으면 바로 세운다."""
    try:
        return (
            os.environ["ASC_KEY_ID"],
            os.environ["ASC_ISSUER_ID"],
            os.environ["ASC_PRIVATE_KEY"],
            os.environ["ASC_APP_ID"],
        )
    except KeyError as missing:
        sys.exit(f"환경 변수 {missing} 가 없습니다.")


def token(key_id: str, issuer_id: str, private_key: str) -> str:
    key = serialization.load_pem_private_key(private_key.encode(), password=None)
    header = {"alg": "ES256", "kid": key_id, "typ": "JWT"}
    now = int(time.time())
    payload = {"iss": issuer_id, "iat": now, "exp": now + 20 * 60, "aud": "appstoreconnect-v1"}
    signing_input = f"{_b64(json.dumps(header).encode())}.{_b64(json.dumps(payload).encode())}"
    der = key.sign(signing_input.encode(), ec.ECDSA(hashes.SHA256()))
    r, s = asym_utils.decode_dss_signature(der)
    return f"{signing_input}.{_b64(r.to_bytes(32, 'big') + s.to_bytes(32, 'big'))}"


def get(url: str, bearer: str) -> dict:
    request = urllib.request.Request(url)
    request.add_header("Authorization", "Bearer " + bearer)
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.loads(response.read())
    except urllib.error.HTTPError as error:
        sys.exit(f"App Store Connect 조회 실패: HTTP {error.code}\n{error.read().decode()}")
    except urllib.error.URLError as error:
        sys.exit(f"App Store Connect 에 연결하지 못했습니다: {error.reason}")


def builds(app_id: str, bearer: str, max_pages: int = 20) -> list[dict]:
    """앱의 빌드를 전부 모아 돌려준다. 처리 중인 것도 포함한다."""
    url = f"{BASE}/v1/builds?filter[app]={app_id}&limit=200"
    collected: list[dict] = []
    for _ in range(max_pages):
        page = get(url, bearer)
        collected.extend(page.get("data", []))
        url = page.get("links", {}).get("next")
        if not url:
            return collected
    sys.exit(f"빌드가 {max_pages} 페이지를 넘습니다. 조회 방식을 손봐야 합니다.")
