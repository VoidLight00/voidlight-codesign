# Roadmap — VoidLight CoDesign

> **현재**: Day 0 (2026-04-27 기획 완료)
> **목표 v1.0**: D+42 (2026-06-08 전후)
> **수정 이력**: 2026-04-27 self-critique([CRITIQUE.md](./CRITIQUE.md)) 반영하여 35일 → 42일 조정 (20% buffer 반영)

---

## Milestones

### M0 — Recon (D+0 → D+3)
**Goal**: 기획의 가정을 사실로 바꾼다.

| Day | Task | Output |
|-----|------|--------|
| D+0 | 기획 문서 작성 (PRD/ARCHITECTURE/MODULES) | ✅ 본 커밋 |
| D+1 | upstream 클론 + 코드베이스 정찰 | `docs/RECON.md` |
| D+1 | i18n 인프라 존재 여부 확인 | RECON.md §1 |
| D+1 | provider 카탈로그 위치 확인 | RECON.md §2 |
| D+2 | VibeProxy 자동 감지 동작 확인 (실측) | RECON.md §3 |
| D+2 | upstream Discussions에서 한국어 PR 의향 탐지 | RECON.md §4 |

**Exit criteria**: RECON.md 작성 완료, M01/M02 분기 결정.

---

### M1 — VibeProxy MVP (D+4 → D+7)
**Goal**: Claude Pro 구독으로 동작 검증.

| Day | Task | Output |
|-----|------|--------|
| D+3 | M02 모듈 골격 + detect.sh | `modules/02/scripts/detect.sh` |
| D+3 | bootstrap.sh (VibeProxy + Open CoDesign 동시 기동) | `modules/02/scripts/bootstrap.sh` |
| D+4 | 한국어 가이드 3종 초안 | `modules/02/docs/*.md` |
| D+4 | E2E 테스트 (Claude Sonnet 슬라이드 덱) | `modules/02/tests/` |
| D+5 | compat-matrix 문서화 | `modules/02/presets/compat-matrix.json` |

**Exit criteria**: AC-01 ~ AC-04 통과, 사용자 수용 시연.

---

### M2 — 한국어 알파 (D+8 → D+17)
> **NOTE**: D+8 부터 `tests/parity/` 가동 시작 (CRITIQUE.md D4 결정 — 기존 D+25에서 17일 앞당김)
**Goal**: 핵심 화면(Settings, Generate, Export)의 한국어 적용.

| Day | Task | Output |
|-----|------|--------|
| D+6 | M01 모듈 골격 + extract-strings.ts | `modules/01/scripts/` |
| D+7 | upstream 문자열 1차 추출 | `extracted-strings.json` |
| D+8 | translate-batch.ts + ko-glossary.md 초안 100개 | `modules/01/src/locale/` |
| D+9 | 핵심 화면 한국어 적용 + 폰트(Pretendard) | `modules/01/dist/ko.json` 부분 |
| D+10 | i18n 인프라 patch (분기 B인 경우만) | `patches/0001*` |
| D+11 | 한글 IME 회귀 테스트 | `tests/i18n/ime.test.ts` |
| D+12 | 알파 빌드 (DMG) 시연 | `dist/voidlight-codesign-0.1.4-alpha-arm64.dmg` |

**Exit criteria**: 핵심 3화면 ≥ 95% 한국어, IME 회귀 0건.

---

### M3 — 한국어 베타 + brew (D+18 → D+27)
**Goal**: 전체 UI 한국어 + 1줄 설치.

| Day | Task | Output |
|-----|------|--------|
| D+13 | 전체 UI 문자열 추출 + 번역 | `ko.json` 전체 |
| D+14 | ko-glossary.md 200개 완성 | M01/AC-03 통과 |
| D+15 | 톤 가이드 + 사람 QA 패스 | `ko-tone-guide.md` |
| D+16 | M05 brew tap 셋업 | `voidlight/homebrew-tap` 저장소 |
| D+17 | Cask formula + post-install xattr | `modules/05/homebrew/` |
| D+18 | 한국어 설치 가이드 + 스크린샷 | `modules/05/docs/` |
| D+19 | 베타 빌드 + 외부 테스터 5인 | feedback loop |
| D+20 | 피드백 반영 + 한국어 README | `README.md` (한국어) |

**Exit criteria**: AC-95% 커버리지 + brew install 성공률 ≥ 95%.

---

### M4 — 자동화 인프라 (D+28 → D+33)
**Goal**: 운영이 사람 1명 주 30분으로 가능하게.

| Day | Task | Output |
|-----|------|--------|
| D+21 | M03 model-bumper 골격 | `modules/03/` |
| D+22 | poll-providers.ts + diff-and-pr.ts | `modules/03/scripts/` |
| D+23 | GitHub Actions: cron 매일 03:00 | `.github/workflows/model-bumper.yml` |
| D+24 | upstream-sync.yml 자동 rebase | `.github/workflows/upstream-sync.yml` |
| D+25 | Telegram 알림 + 충돌 시 Issue 자동 생성 | infra 완성 |

**Exit criteria**: 자동 rebase 1회 성공, 모델 폴링 1회 성공.

---

### M5 — 1.0 (D+34 → D+42)
**Goal**: 안정화 + 한국어 발표/홍보.

| Day | Task | Output |
|-----|------|--------|
| D+26 | M04 branding-ko (선택, 토글식) | `modules/04/` |
| D+27 | 모든 모듈의 AC 회귀 테스트 | green CI |
| D+28 | parity test 보강 (upstream 데모 8개) | `tests/parity/` |
| D+29 | 한국어 발표 자료 (AI Beyond 등 활용) | `docs/공식발표.md` |
| D+30 | 1.0-rc1 릴리스 + 외부 사용자 테스트 | GitHub Release |
| D+32 | 피드백 반영 | rc2 |
| D+34 | rc3 + 마지막 검증 | green |
| D+35 | **v1.0 정식 릴리스** | brew · DMG · EXE · AppImage |

**Exit criteria**: PRD §9 Success Metrics 7개 항목 모두 통과.

---

## 1.0 이후 백로그

### v1.1 — 한국어 사용자 피드백 반영
- 용어 사전 v2 (피드백 기반)
- 한국어 음성 스타일 가이드 (예: 존댓말 vs 친근함 옵션)
- 한국어 키보드 단축키 가이드

### v1.2 — Apple 코드사이닝
- Developer ID 등록 ($99/년)
- 정식 서명 빌드
- "오른쪽 클릭 → 열기" 단계 제거

### v1.3 — VibeProxy 1-step 통합
- "Claude Pro 사용하기" 클릭 → VibeProxy 자동 설치(brew) + 로그인 → Open CoDesign 자동 등록

### v2.0 — 한국 디자인 시스템 라이브러리
- "한국 브랜드 시스템" 카탈로그 (네이버, 카카오, 토스, 우아한형제들 스타일)
- M01의 글로사리를 영어 사용자에게도 노출

### 보류 (조건부)
- Claude Pro/Max 직접 OAuth (VibeProxy 의존 제거) — Anthropic이 SDK OAuth 공개 시
- Figma → Open CoDesign import — upstream 로드맵 v1.0 이후
- Mobile companion app — 우선순위 낮음

---

## 마일스톤별 의존성

```
M0 (Recon) ───────────────┬────────────┐
                          │            │
                          ▼            ▼
                       M1 (Vibe)   M2 (Korean Alpha)
                          │            │
                          └─────┬──────┘
                                ▼
                          M3 (Korean Beta + brew)
                                │
                                ▼
                          M4 (Automation)
                                │
                                ▼
                          M5 (1.0)
```

M1과 M2는 병렬 가능. core 1명, infra 1명이면 압축 가능.

---

## 리스크별 일정 영향

| Risk | 만약 발생 시 | 일정 영향 |
|------|------------|---------|
| upstream에 i18n 인프라 없음 (분기 B) | i18n 인프라 patch 작성 | M2에 +3일 |
| upstream PR 거부 | overlay 폴백 | M2에 +1일 |
| VibeProxy 자동 감지 실측 실패 | 수동 등록 preset 보강 | M1에 +1일 |
| upstream rebase 충돌 빈발 | patches 재작성 빈도 ↑ | 운영 비용 ↑ (일정 영향 없음) |
| Apple Gatekeeper 더 강화 | 코드사이닝 우선순위 ↑ | M5에 +5일 또는 v1.2로 이연 |

---

## 작업 추적

- 일일 진행: `/pcs` 사용 (PRD Chat Save 자동 커밋)
- 주간 회고: 월요일에 ROADMAP.md 업데이트
- 마일스톤 완료: 본 문서 + tag 부여 (`v0.1-recon`, `v0.2-vibe-mvp` 등)
