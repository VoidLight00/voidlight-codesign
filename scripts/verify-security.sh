#!/usr/bin/env bash
# verify-security.sh — security/compliance gate stub
# STUB: 현재는 필수 보안 문서 존재만 검사한다. 실제 내용 검증은 M07 구현에서 추가한다.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

required=(
  "NOTICE"
  "modules/07-security-compliance/README.md"
  "modules/07-security-compliance/docs/tos-risk-register.md"
  "modules/07-security-compliance/docs/token-storage-policy.md"
  "modules/07-security-compliance/docs/local-proxy-security.md"
)

for path in "${required[@]}"; do
  if [ ! -f "$ROOT/$path" ]; then
    echo "missing security/compliance artifact: $path"
    exit 1
  fi
done

echo "OK — security/compliance stub gate 통과"
