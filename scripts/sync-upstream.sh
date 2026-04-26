#!/usr/bin/env bash
# sync-upstream.sh — 주간 upstream 동기화 + patches 재적용
# Stub. 구현은 M4 (자동화 인프라) 단계에서 채운다.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "[1/4] submodule 동기화"
git submodule update --init --remote upstream

echo "[2/4] 우리 patches 재적용"
cd upstream
for p in "$ROOT"/patches/*.patch; do
  [ -f "$p" ] || continue
  echo "  applying $(basename "$p")"
  git am --3way "$p" || {
    echo "  CONFLICT at $(basename "$p")"
    echo "  see UPSTREAM_SYNC.md §4 (patch 재작성 가이드)"
    exit 1
  }
done

echo "[3/4] overlays 적용"
cd "$ROOT"
[ -d overlays ] && rsync -a overlays/ upstream/

echo "[4/4] verify parity"
bash "$ROOT/scripts/verify-parity.sh" || {
  echo "  parity test 실패 — modules/ 검토 필요"
  exit 2
}

echo "OK — upstream sync 완료"
