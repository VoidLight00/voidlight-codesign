#!/usr/bin/env bash
# build.sh — generated-app 기반 통합 빌드 stub
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
UPSTREAM="$ROOT/upstream"
GENERATED="$ROOT/generated-app"

if [ ! -d "$UPSTREAM" ] || [ -z "$(ls -A "$UPSTREAM" 2>/dev/null | grep -v '^.gitkeep$' || true)" ]; then
  echo "upstream/ 가 비어있다. 먼저 'pnpm bootstrap' 또는 M0 upstream setup을 실행."
  exit 1
fi

echo "[1/5] generated-app 재생성"
rm -rf "$GENERATED"
rsync -a --delete --exclude='.git' "$UPSTREAM/" "$GENERATED/"
if [ -e "$UPSTREAM/.git" ]; then
  (cd "$GENERATED" && git init -q && git add -A && git commit -q -m "generated upstream base")
fi

echo "[2/5] patch manifest 검증"
bash "$ROOT/scripts/verify-patches.sh"

echo "[3/5] modules/overlays 적용"
bash "$ROOT/scripts/apply-modules.sh"

echo "[4/5] parity/security gate"
bash "$ROOT/scripts/verify-parity.sh"
bash "$ROOT/scripts/verify-security.sh"

echo "[5/5] upstream build 위임"
if [ -f "$GENERATED/package.json" ]; then
  (cd "$GENERATED" && pnpm install && pnpm build)
else
  echo "generated-app/package.json 없음 — 현재는 planning stub 단계라 실제 빌드는 생략."
fi

echo "OK — build pipeline completed/stubbed"
