#!/usr/bin/env bash
# verify-parity.sh — upstream의 기본 demo 8종이 우리 빌드에서 동일하게 동작하는지 검증
# Stub. 실제 구현은 M5 (1.0) 안정화 단계에서 채운다.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "parity test (stub):"
echo "  TODO: upstream의 examples/ 데모 8종 실행 → JSON 산출물 비교"
echo "  TODO: i18n 모드 ko/en 양쪽에서 동일한 generation 결과 검증"
echo "  TODO: VibeProxy 경유와 직접 API 호출 결과 동등성 검증"

# 현 시점: 구조만 통과
exit 0
