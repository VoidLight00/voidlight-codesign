# Rollback Runbook

## 원칙

사용자에게 배포된 artifact나 model catalog가 잘못되면 새 자동화 실행으로 덮어쓰지 말고, 마지막 green 상태로 명시적으로 되돌린다.

## 절차

1. 문제 artifact 또는 catalog version 확인
2. 마지막 green commit/tag 확인
3. stable channel freeze 공지
4. rollback PR 생성
5. parity/security/distribution gate 재실행
6. release note에 영향 범위 기록

## 자동화 금지

- rollback 자동 merge 금지
- 실패한 model-bumper PR 자동 재시도 금지
