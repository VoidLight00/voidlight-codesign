#!/usr/bin/env bash
# release.sh — release gate stub
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  echo "usage: pnpm release <version>"
  echo "example: pnpm release v0.1.4-ko-alpha"
  exit 1
fi

echo "[release] $VERSION"
echo "[gate] patches"
bash scripts/verify-patches.sh

echo "[gate] parity"
bash scripts/verify-parity.sh

echo "[gate] security"
bash scripts/verify-security.sh

echo "Release artifact creation is stubbed until M3/M5."
echo "Do not tag/push automatically from this script."
