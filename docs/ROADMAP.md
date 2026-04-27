# Roadmap — VoidLight CoDesign

> **현재**: Day 0 (2026-04-27 기획 완료)
> **42일 목표**: `v0.1-ko-alpha` / developer preview
> **v1.0 원칙**: 날짜가 아니라 exit criteria 충족 시 릴리스

---

## 방향 수정

초기 기획의 `D+42 v1.0`은 보안·배포·i18n·upstream sync 리스크를 과소평가한다. 42일 목표는 정식 1.0이 아니라 **한국어 알파 + VibeProxy/API 연결 검증 + 운영 골격**으로 낮춘다.

`v1.0`은 다음 조건을 만족한 뒤 별도 태그로 낸다.

1. macOS signed/notarized build 또는 그에 준하는 명확한 배포 신뢰 정책
2. VibeProxy 외 official API key fallback 경로 제공
3. upstream 주요 기능 parity test 통과
4. 핵심 UI 한국어 coverage 95% 이상
5. OAuth/API token 평문 저장 없음
6. local proxy 연결 보안 검증(origin/handshake/port spoofing)
7. LICENSE/NOTICE/About/brew formula에 fork·상표·폰트 표기 완료
8. beta tester 5명 이상이 90분 사용하고 OAuth 만료/재인증 또는 fallback 전환 1회를 통과하며 crash 0건
9. model catalog rollback 가능
10. upstream sync 실패 시 stable channel freeze 가능

---

## Milestones

### M0 — Recon & Risk Audit (D+0 → D+5)

**Goal**: 기획의 가정을 사실로 바꾸고, 진행/중단 조건을 정한다.

| Day | Task | Output |
|-----|------|--------|
| D+0 | 기획 문서 작성 | PRD/ARCHITECTURE/MODULES/ROADMAP |
| D+1 | upstream 코드베이스 정찰 | `docs/RECON.md` |
| D+1 | i18n 인프라 존재 여부 확인 | RECON §i18n |
| D+1 | provider/model catalog 위치 확인 | RECON §model-catalog |
| D+2 | VibeProxy 자동 감지 실측 | RECON §vibeproxy |
| D+2 | official API key fallback 가능성 확인 | RECON §provider-fallback |
| D+3 | upstream CLA/DCO/리뷰 SLA/릴리즈 cadence 확인 | RECON §governance |
| D+3 | 코드사이닝/notarization/update channel 비용·키 정책 결정 | RECON §distribution |
| D+4 | ToS/privacy/license risk register 작성 | RECON §security-compliance |
| D+5 | M1/M2 진행 여부와 i18n Strategy A/B/D 결정 | RECON conclusion |

**Exit criteria**: `docs/RECON.md` 작성, go/no-go 결정, i18n·provider·distribution 분기 확정.

---

### M1 — Provider MVP (D+6 → D+12)

**Goal**: VibeProxy와 official API key fallback을 모두 검증한다.

| Day | Task | Output |
|-----|------|--------|
| D+6 | M02 detection script | `modules/02-provider-bridge/scripts/detect.sh` |
| D+6 | local proxy handshake/port spoofing 체크 설계 | M07 risk note |
| D+7 | official API key provider preset 검증 | fallback guide |
| D+8 | parity stub gate 가동 시작 | `tests/parity/` stub |
| D+8 | VibeProxy 한국어 가이드 초안 | `modules/02-provider-bridge/docs/` |
| D+9 | Claude/VibeProxy golden path E2E | compat result |
| D+10 | API key fallback golden path E2E | compat result |
| D+11 | OAuth 만료·포트 충돌·미실행 에러 UX 문서화 | troubleshooting |
| D+12 | provider MVP 시연 | demo note |

**Exit criteria**: VibeProxy와 official API key 경로 중 최소 하나가 안정 동작하고, 실패 경로가 한국어로 설명된다.

---

### M2 — Korean Alpha Core (D+13 → D+24)

**Goal**: 핵심 화면 한국어화와 IME/parity 최소 안전망을 동시에 만든다.

| Day | Task | Output |
|-----|------|--------|
| D+13 | M01 extractor/locale/glossary 골격 | `modules/01-i18n-ko/` |
| D+14 | 문자열 추출 1차 | `extracted-strings.json` |
| D+15 | i18n Strategy A/B/D 적용 spike | patch or transform |
| D+16 0시 | i18n stop-loss 결정: A/B/D 중 하나로 고정 | strategy decision |
| D+16 | Settings/Generate/Export 한국어 적용 | partial `ko.json` |
| D+17 | Pretendard/Noto fallback 적용 | font artifact |
| D+18 | IME composition smoke test | `tests/i18n/` |
| D+19 | parity test 최소 3개 시나리오 | `tests/parity/` |
| D+20 | glossary 100개 + tone guide 초안 | glossary/tone guide |
| D+21-D+23 | 핵심 UI QA 및 레이아웃 보정 | alpha fixes |
| D+24 | Korean alpha build | unsigned/dev build |

**Exit criteria**: 핵심 3화면 95% 한국어, IME smoke 통과, parity 3개 통과.

---

### M3 — Distribution Preview (D+25 → D+31)

**Goal**: 설치·첫 실행·문서 흐름을 알파 사용자에게 배포 가능한 수준으로 만든다.

| Day | Task | Output |
|-----|------|--------|
| D+25 | M05 설치 가이드와 첫 실행 체크리스트 | installer docs |
| D+26 | macOS unsigned/dev build 절차 고정 | release note |
| D+27 | code signing/notarization 준비 체크리스트 | distribution decision |
| D+28 | Homebrew cask PoC | tap draft |
| D+29 | license/NOTICE/About 표기 점검 | compliance checklist |
| D+30 | 외부 테스터 5명 모집 및 배포 | tester loop |
| D+31 | 설치 피드백 반영 | preview fixes |

**Exit criteria**: tester가 문서만 보고 설치·첫 실행·provider 연결까지 도달한다.

---

### M4 — Automation & Patch Governance (D+32 → D+37)

**Goal**: 운영 비용을 낮추되 자동 머지는 금지한다.

| Day | Task | Output |
|-----|------|--------|
| D+32 | M03 model catalog schema | Zod/JSON schema |
| D+33 | model-bumper poll/diff PoC | generated PR draft |
| D+34 | patch metadata/manifest validation | patch governance |
| D+35 | upstream sync dry-run workflow | sync PR only |
| D+36 | Telegram/Issue 알림 PoC | alert route |
| D+37 | stable freeze/rollback runbook | ops note |

**Exit criteria**: upstream sync와 model-bumper가 PR만 만들고, 사람 승인 전에는 사용자 배포에 영향을 주지 않는다.

---

### M5 — v0.1-ko-alpha Hardening (D+38 → D+42)

**Goal**: 알파 릴리스를 고정하고 v1.0 backlog를 명확히 분리한다.

M06/M07은 이 시점에 문서·체크리스트 골격만 고정하고, alpha 이후 v1.0 전 구간에서 실제 CI gate와 validator를 본격 구현한다.

| Day | Task | Output |
|-----|------|--------|
| D+38 | M06 release-ops/M07 security-compliance 문서와 체크리스트 정리 | module docs |
| D+39 | alpha regression pass | green checks |
| D+40 | known issues와 ToS/privacy warning 정리 | release notes |
| D+41 | `v0.1-ko-alpha` release candidate | GitHub Release draft |
| D+42 | `v0.1-ko-alpha` 릴리스 | developer preview |

**Exit criteria**: 알파 사용자가 위험·제약·설치·연결 방식을 이해하고 핵심 플로우를 재현할 수 있다.

---

## 1.0 이후 백로그가 아니라 1.0 전 필수 작업

다음 항목은 `v1.0` 전에 해결해야 한다.

- signed/notarized macOS build 또는 명시적 대체 배포 정책
- Windows 배포 여부와 Authenticode 전략
- official API key fallback의 first-class UX
- auto-update channel 또는 수동 업데이트 정책
- telemetry/crash reporting privacy audit
- full i18n coverage와 stale translation detection
- visual regression 또는 screenshot QA
- VibeProxy ToS warning의 UI 노출
- M06/M07 CI gate와 validator 본격 구현
- patch count budget과 quarterly patch diet

---

## v1.x 후보

### v1.1 — 한국어 사용자 피드백 반영
- 용어 사전 v2
- 한국어 키보드/IME 가이드
- 강의용 화면 공유 안전 모드

### v1.2 — 모델 카탈로그 운영 고도화
- `recommended`, `deprecated`, `capabilities` metadata
- provider별 contract test
- rollback UI

### v2.0 — 한국 디자인 시스템 라이브러리
- 한국 브랜드 시스템 예제 카탈로그
- 강사용 demo pack

---

## 마일스톤별 의존성

```text
M0 Recon/Risk ───────┬──────────────┐
                     ▼              ▼
              M1 Provider MVP   M2 Korean Alpha
                     │              │
                     └──────┬───────┘
                            ▼
                 M3 Distribution Preview
                            │
                            ▼
              M4 Automation/Patch Governance
                            │
                            ▼
                  M5 v0.1-ko-alpha
                            │
                            ▼
                    v1.0 exit criteria
```

---

## 리스크별 일정 영향

| Risk | 만약 발생 시 | 일정 영향 |
|------|------------|---------|
| upstream에 i18n 인프라 없음 | compile-time transform 또는 invasive patch 필요 | M2 +7~14일 |
| upstream PR/CLA 병목 | fork-only patch 유지 | 운영 비용 증가 |
| VibeProxy 자동 감지 실패 | official API fallback 우선 | M1 범위 조정 |
| code signing 준비 지연 | v1.0 지연, alpha는 unsigned/dev로 명시 | v1.0 gate |
| ToS 리스크가 높음 | VibeProxy를 experimental로 격하 | 제품 메시지 변경 |
| patch 충돌 빈발 | patch diet sprint 필요 | M4 +3일 |

---

## 작업 추적

- 일일 진행: PR/Issue 또는 `/pcs` 사용
- 주간 회고: `ROADMAP.md` 업데이트
- 알파 완료: `v0.1-ko-alpha` 태그
- v1.0 진행: exit criteria 체크리스트 기준으로 별도 milestone 생성
