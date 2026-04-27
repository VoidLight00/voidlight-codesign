#!/usr/bin/env bash
# apply-modules.sh — modules/*/dist 를 generated-app/ 적절한 경로에 배치
# Stub. 각 모듈의 dist 매핑은 모듈이 자체 manifest로 선언 (modules/*/manifest.json)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$ROOT/generated-app"
UPSTREAM="$ROOT/upstream"

if [ ! -d "$TARGET" ]; then
  if [ ! -d "$UPSTREAM" ] || [ -z "$(ls -A "$UPSTREAM" 2>/dev/null | grep -v '^.gitkeep$' || true)" ]; then
    echo "generated-app/ 와 upstream/ 가 비어있다. 먼저 'pnpm bootstrap' 또는 M0 upstream setup을 실행."
    exit 1
  fi
  echo "generated-app/ 없음 — upstream/에서 임시 생성"
  rm -rf "$TARGET"
  rsync -a --delete --exclude='.git' "$UPSTREAM/" "$TARGET/"
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
[ -d "$ROOT/overlays" ] && rsync -a "$ROOT/overlays/" "$TARGET/"

echo "OK — modules 적용 stub 완료 (manifest copy 구현 전까지 실제 dist 복사는 제한적)"
