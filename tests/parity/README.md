# Parity Test

> **목적**: upstream(`OpenCoworkAI/open-codesign`)의 기본 동작이 우리 빌드에서 동일하게 보존되는지 검증.
> **시작**: D+8 (M2 한글 알파 시작과 동시) — 자체 critique D4 결정.
> **현재**: stub 단계.

---

## 검증 항목 (목표)

### 1. Demo generation 등가성
upstream의 빌트인 demo 8종 — landing, dashboard, slide deck, mobile, chat UI, pricing, invoice, calendar — 을 동일 시드로 generation했을 때 산출물의 핵심 메타데이터가 일치하는가.

비교 대상:
- HTML 구조 유사도 (DOM 노드 수 ±5%)
- 사용된 디자인 토큰 (color, font, spacing) 일치
- generation 메타(skills selected, token count) 동등성

### 2. i18n 모드 비대칭 검증
같은 프롬프트를 영문 모드와 한국어 모드에서 실행했을 때, 코드 산출물의 의미 동등성. (UI 라벨만 다르고 코드는 동일해야 함.)

### 3. VibeProxy 경유 vs 직접 API 호출
VibeProxy(:8318) 경유와 Anthropic 직접 호출의 응답이 의미 동등한가.

---

## 실행 (계획)

```bash
pnpm test:parity                  # 전체 (CI에서 호출)
pnpm test:parity --demo landing   # 단일 demo
pnpm test:parity --update-snapshot # 스냅샷 갱신 (사람 검토 후)
```

---

## 현 stub 동작

`scripts/verify-parity.sh` 가 호출되면:
1. 입력 시드 디렉토리(`tests/parity/seeds/`) 존재 확인
2. (구현 예정) demo 1개 generation
3. (구현 예정) 산출물 hash → snapshot 비교

> 본격 구현은 D+8 시작.

---

## 회귀 정책

- snapshot 변경 시 PR 본문에 사유 명시 필수
- upstream 의도된 동작 변화 → snapshot 갱신
- 우리 patches 잘못으로 변경 → patch 재작성
