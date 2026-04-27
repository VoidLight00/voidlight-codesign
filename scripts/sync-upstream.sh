#!/usr/bin/env bash
# sync-upstream.sh — upstream dry-run 동기화 + patches 재적용
# Stub. 구현은 M4 (자동화 인프라) 단계에서 채운다.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "[1/5] submodule pin 동기화"
git submodule update --init upstream

echo "[2/5] generated-app 재생성"
rm -rf "$ROOT/generated-app"
rsync -a --delete --exclude='.git' "$ROOT/upstream/" "$ROOT/generated-app/"
if [ -e "$ROOT/upstream/.git" ]; then
  (cd "$ROOT/generated-app" && git init -q && git add -A && git commit -q -m "generated upstream base")
fi

echo "[3/5] patch manifest 검증 + patches 재적용"
bash "$ROOT/scripts/verify-patches.sh"
cd "$ROOT/generated-app"
for p in "$ROOT"/patches/*.patch; do
  [ -f "$p" ] || continue
  echo "  applying $(basename "$p")"
  git am --3way "$p" || {
    echo "  CONFLICT at $(basename "$p")"
    echo "  see UPSTREAM_SYNC.md §5 (patch 재작성 가이드)"
    exit 1
  }
done

echo "[4/5] overlays 적용"
cd "$ROOT"
bash "$ROOT/scripts/apply-modules.sh"

echo "[5/5] verify gates"
bash "$ROOT/scripts/verify-parity.sh" || {
  echo "  parity test 실패 — modules/ 검토 필요"
  exit 2
}
bash "$ROOT/scripts/verify-security.sh"

echo "OK — upstream sync dry-run 완료. 자동 머지는 금지."
