#!/usr/bin/env bash
# apply-modules.sh — modules/*/dist 를 upstream/ 적절한 경로에 배치
# Stub. 각 모듈의 dist 매핑은 모듈이 자체 manifest로 선언 (modules/*/manifest.json)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM="$ROOT/upstream"

if [ ! -d "$UPSTREAM" ] || [ -z "$(ls -A "$UPSTREAM" 2>/dev/null | grep -v '^.gitkeep$')" ]; then
  echo "upstream/ 가 비어있다. 먼저 'pnpm bootstrap' 실행."
  exit 1
fi

echo "[modules] 빌드"
pnpm -r --if-present build

echo "[modules] artifacts 배치"
for mod in "$ROOT"/modules/*/; do
  manifest="$mod/manifest.json"
  if [ -f "$manifest" ]; then
    echo "  $(basename "$mod"): manifest 읽음"
    # manifest 형식 (예시):
    # { "copies": [ { "from": "dist/ko.json", "to": "apps/desktop/src/renderer/locales/ko.json" } ] }
    # 실제 구현은 jq 또는 node 스크립트로 처리
  fi
done

echo "[overlays] static files"
[ -d "$ROOT/overlays" ] && rsync -a "$ROOT/overlays/" "$UPSTREAM/"

echo "OK — modules 적용 완료"
