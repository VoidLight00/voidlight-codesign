# M06 — release-ops

upstream sync, patch queue, release freeze, rollback runbook을 소유한다.

## 책임

- `patches/manifest.json`과 `patches/series` 일관성 검증
- upstream sync dry-run과 PR 생성 정책 관리
- stable channel freeze와 rollback 절차 문서화
- patch budget 관리

## v0.1.4-ko-alpha 기준

- 자동 main push 금지
- 자동 merge 금지
- 실패 시 Issue + Telegram 알림 + stable freeze
