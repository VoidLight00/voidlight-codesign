# PRD — VoidLight CoDesign

> **Project**: `voidlight-codesign`
> **Owner**: 손상현 / VOIDLIGHT
> **Status**: Draft v0.1 (planning)
> **Last updated**: 2026-04-27
> **Upstream**: [OpenCoworkAI/open-codesign](https://github.com/OpenCoworkAI/open-codesign) v0.1.4 (MIT)

---

## 1. Vision

> **"한국어 사용자가 Open CoDesign을 안전하게 이해하고, 본인이 선택한 AI 연결 방식으로 디자인 작업을 시연·학습·실험할 수 있게 한다."**

Open CoDesign(MIT, Electron 기반)을 베이스로 다음 3가지를 추가한다:

1. **Provider bridge** — VibeProxy(=CLIProxyAPI)는 고급/실험적 경로로 검증하고, official API key fallback을 동등한 P0 경로로 제공한다.
2. **한국어 핵심 UX** — 메뉴·설정·알림·문서의 핵심 플로우를 우선 한국어화하고, v1.0 전까지 전체 UI coverage 95% 이상을 달성한다.
3. **검증된 모델 카탈로그** — 신규 모델은 24시간 내 감지하되, schema·capability·사람 승인 게이트를 통과한 뒤 노출한다.

이 모든 것을 **upstream 코드 수정 최소화 + 모든 기능 보존 + 사용자 계정/토큰 안전성**의 제약 안에서 달성한다.

---

## 2. Non-Goals (이 프로젝트가 다루지 않는 것)

| # | 비목표 | 이유 |
|---|------|-----|
| N1 | upstream 하드 포크(영구 분기) | 유지 비용 폭증, 커뮤니티 분리 |
| N2 | Claude Design 자체 대체 | 우리는 fork이지 신규 제품이 아님 |
| N3 | Electron → 다른 프레임워크 마이그레이션 | upstream 호환성 깨짐 |
| N4 | 자체 백엔드/클라우드 | local-first 원칙 유지 |
| N5 | 비-OAuth 구독 우회(Cursor, Lovable 등) | ToS 리스크, 가치 대비 비용 낮음 |
| N6 | provider ToS 우회 보장 | VibeProxy는 실험적 호환 경로일 뿐, 공식 지원/약관 적합성을 보장하지 않음 |
| N7 | 코드사이닝 없는 정식 v1.0 | 알파는 unsigned 가능하지만 v1.0은 배포 신뢰 정책 필요 |

---

## 3. Personas & Use Cases

### Persona A1 — "한국어 디자인 강사: 구독 경로" (=손상현)
- 이미 Claude Pro / ChatGPT Plus 결제 중
- AI Beyond 멤버십 등에서 강의·시연
- 한국어 UI가 필요 (학생 시연, 자료 캡처)
- VibeProxy의 ToS/계정 리스크를 이해한 고급 사용자
- **Use case**: VibeProxy 실행 → experimental 연결 확인 → 한국어 UI에서 Claude Sonnet으로 슬라이드 덱 생성

### Persona A2 — "한국어 디자인 강사: API 키 경로"
- 강의·시연 안정성을 위해 provider 공식 API key를 준비
- 조직/학생 데이터 정책상 약관·감사 가능성이 중요
- VibeProxy보다 표준 경로와 예측 가능한 오류 처리를 선호
- **Use case**: API key 입력 → standard 연결 확인 → 한국어 UI에서 동일 데모 생성

### Persona B — "한국 일반 디자이너"
- 영어 UI 부담, AI 도구 입문
- 본인이 쓰는 ChatGPT 구독 그대로 활용 원함
- **Use case**: brew 한 줄 설치 → 한국어 온보딩 → ChatGPT Plus 로그인 → 첫 프로토타입 5분 내

### Persona C — "팀 도입 검토 엔지니어"
- 회사 보안 정책상 cloud 도구 못 씀
- LiteLLM 사내 게이트웨이 보유
- **Use case**: `--key-less` 모드 + 사내 relay → 엔터프라이즈 사용

---

## 4. Module Specification (5 modules)

각 모듈은 **독립적으로 개발·테스트·릴리스 가능**하도록 설계. 자세한 인터페이스는 [`MODULES.md`](./MODULES.md).

| # | Module | Goal | Owner | Priority |
|---|--------|------|-------|---------|
| 01 | `i18n-ko` | 한국어 로케일 + 폰트 + 번역 자동화 | core | 🔴 P0 |
| 02 | `provider-bridge` | VibeProxy + official API fallback 연결/문서화 | core | 🔴 P0 |
| 03 | `model-bumper` | 검증된 신규 모델 감지·PR·override | infra | 🟡 P1 |
| 04 | `distribution-ko` | 브랜딩·앱 메타·배포 채널·라이선스 표기 | infra | 🟡 P1 |
| 05 | `installer-ko` | brew tap + 한국어 설치 가이드 | infra | 🟡 P1 |
| 06 | `release-ops` | upstream sync·patch governance·rollback | infra | 🔴 P0 |
| 07 | `security-compliance` | ToS·token storage·local proxy·license audit | security | 🔴 P0 |

### 4.1 모듈 간 의존 관계
```
i18n-ko             ← independent
provider-bridge     ← security-compliance 정책을 따름
model-bumper        ← security-compliance schema/allowlist 정책을 따름
distribution-ko     ← security-compliance + release-ops와 강결합
installer-ko        ← depends on (i18n-ko, provider-bridge, distribution-ko)
release-ops         ← patch/CI/release glue
security-compliance ← 모든 외부 연결·배포·라이선스 게이트
```

### 4.2 모듈 단위 인수 기준 (요약)

#### M01 i18n-ko
- [ ] `apps/desktop` 모든 UI 문자열의 ≥ 95%가 ko.json에 존재
- [ ] 로케일 스위처에서 한국어 선택 시 즉시 반영(재시작 불필요)
- [ ] 한국어 전문 용어 사전(`ko-glossary.md`) 200개 이상
- [ ] IME 한글 입력 회귀 테스트 통과

#### M02 provider-bridge
- [ ] VibeProxy 실행 상태 → 앱이 자동 감지 → provider 자동 등록
- [ ] official API key fallback으로 동일 데모 E2E 통과
- [ ] VibeProxy가 미실행/만료/충돌 상태일 때 한국어 오류와 대안 경로 표시
- [ ] local proxy handshake와 port spoofing 위험 검증
- [ ] 한국어 트러블슈팅 문서 완비

#### M03 model-bumper
- [ ] cron으로 매일 provider 모델 목록 폴링
- [ ] 신규 모델 발견 시 PR 자동 생성
- [ ] 로컬 override 파일로 즉시 사용 가능 (PR 머지 전)
- [ ] GPT-5.5 출시 시 24시간 내 사용 가능 검증

#### M04 distribution-ko
- [ ] 앱명·bundle id·About·NOTICE·update channel 정책이 fork 혼동을 만들지 않음
- [ ] signed/notarized build 또는 알파용 unsigned 정책이 명확히 분리됨
- [ ] upstream 자산 미수정, overlay만 사용

#### M05 installer-ko
- [ ] `brew install --cask voidlight/tap/voidlight-codesign` 1줄 설치 PoC
- [ ] xattr 격리 해제는 알파용 안내로만 사용하고 v1.0 배포 신뢰 정책과 분리
- [ ] 한국어 설치 가이드 (스크린샷 포함)

#### M06 release-ops
- [ ] upstream sync는 PR 생성까지만 수행하고 자동 머지하지 않음
- [ ] patch manifest/series/metadata 검증
- [ ] stable freeze와 rollback runbook 존재

#### M07 security-compliance
- [ ] provider ToS/privacy warning이 README·docs·첫 실행 UI에 반영
- [ ] OAuth/API token 평문 저장 금지 정책 검증
- [ ] local proxy origin/handshake/port spoofing 체크리스트 존재
- [ ] dependency/font/license audit 통과

---

## 5. Architectural Constraints

자세한 구조는 [`ARCHITECTURE.md`](./ARCHITECTURE.md).

### 5.1 절대 규칙
1. **Upstream 코드는 git submodule로만 참조** — 직접 편집 금지.
2. **모든 커스터마이즈는 `modules/` 또는 `patches/` 또는 `overlays/`** 중 하나에 위치.
3. **각 patch는 단일 책임** — 100줄 미만 권장, upstream PR 가능한 단위.
4. **모든 모듈은 자체 README + 자체 tests**.
5. **patch는 항상 rebase 가능해야 함** — 충돌 시 CI 실패 + 수동 해결.

### 5.2 우선순위 사다리 (커스터마이즈 방식)
```
1. upstream PR             ← 가능하면 항상 첫 옵션 (i18n 인프라, 모델 카탈로그)
2. 사이드카 설정/스크립트    ← 코드 수정 0 (vibeproxy preset, 자동 감지)
3. overlays/               ← 빌드 시 파일 shadow (브랜딩, 정적 자산)
4. patches/ (rebase-able)  ← 코드 수정 필요할 때만
5. hard fork (금지)
```

---

## 6. Risks & Mitigations

| # | Risk | Severity | Mitigation |
|---|------|---------|-----------|
| R1 | upstream 0.x 변화로 patch 충돌 빈발 | 🔴 High | release tag 추종 우선, sync PR만 생성, patch manifest 운영 |
| R2 | i18n 인프라가 upstream에 없으면 도입 patch가 invasive | 🔴 High | upstream PR 우선, 단기 compile-time transform spike, DOM 치환은 시연용만 |
| R3 | VibeProxy ToS/계정 정지/호환성 리스크 | 🔴 High | VibeProxy를 experimental로 표기, official API key fallback P0 제공 |
| R4 | 코드사이닝/notarization 부재로 배포 신뢰 하락 | 🔴 High | M0에서 비용·키·채널 결정, v1.0 exit criteria로 격상 |
| R5 | local proxy port spoofing 또는 token leakage | 🔴 High | handshake/origin/token storage 보안 체크리스트 |
| R6 | 한국어 AI 번역 품질 일관성 부족 | 🟠 Med | 용어 사전 + 사람 QA + stale translation detection |
| R7 | 신규 모델 카탈로그 오염/잘못된 모델 노출 | 🟠 Med | schema validation + allowlist + 사람 승인 + rollback |
| R8 | 1인 운영 bus factor | 🟠 Med | release-ops runbook, patch budget, contributor-friendly docs |

---

## 7. Roadmap (Milestones)

자세한 일정은 [`ROADMAP.md`](./ROADMAP.md).

| Milestone | Goal | ETA | Modules |
|-----------|------|-----|---------|
| **M0 — Recon & Risk Audit** | 기술·거버넌스·보안·배포 가정 검증 | D+5 | 06, 07 |
| **M1 — Provider MVP** | VibeProxy + official API fallback 검증 | D+12 | 02, 07 |
| **M2 — Korean Alpha Core** | 핵심 화면 한국어 + IME/parity 최소 안전망 | D+24 | 01, parity |
| **M3 — Distribution Preview** | 설치·첫 실행·배포 문서 알파 품질 | D+31 | 04, 05, 07 |
| **M4 — Automation & Patch Governance** | model-bumper + upstream sync + patch manifest | D+37 | 03, 06 |
| **M5 — v0.1-ko-alpha** | developer preview 릴리스 | D+42 | all |

> D+42 목표는 v1.0 정식 릴리스가 아니라 `v0.1-ko-alpha`다. v1.0은 [`ROADMAP.md`](./ROADMAP.md)의 exit criteria를 충족할 때 별도 릴리스한다.

---

## 8. Maintenance Contract (지속성)

### 8.1 주간 루틴 (자동화)
- 매일 upstream fetch로 새 release/tag 감지
- release/tag 또는 변화량 임계치 도달 시 `sync-upstream.sh` dry-run 실행
- 충돌 발생 → Issue 자동 생성 + Telegram 알림 + stable channel freeze
- 충돌 없음 → upstream-sync PR 생성
- **자동 main push/자동 머지 금지**

### 8.2 모델 출시 대응
- model-bumper가 매일 03:00 폴링
- 신규 모델 발견 → PR 자동 생성 (1줄 카탈로그 추가)
- 사람 1명이 24시간 내 머지 + 릴리스 태깅

### 8.3 분기 1회 (수동)
- 한국어 사전 정리 (사용자 피드백 반영)
- 의존성 버전 업그레이드
- VibeProxy/CLIProxyAPI 호환성 매트릭스 갱신

### 8.4 책임 매트릭스
| 영역 | 1차 | 2차 |
|------|----|----|
| upstream sync | core | infra |
| 한국어 번역 | core (사람 QA) | AI 번역 자동화 |
| 모델 카탈로그 | model-bumper bot | core (PR 머지) |
| 릴리스 | infra (CI) | core (검증) |
| 사용자 지원 | core | community |

---

## 9. Success Metrics

| Metric | Target (3개월) |
|--------|-------------|
| 핵심 UI 한국어 coverage | ≥ 95% |
| parity test golden path | 8개 중 8개 통과 |
| provider 연결 성공률 | VibeProxy 또는 official API fallback 중 1개 이상 ≥ 95% |
| 신규 모델 감지 시간 | ≤ 24시간 (자동 노출 아님) |
| model catalog 검증 실패 rollback | ≤ 1시간 |
| 설치 문서 기반 첫 실행 성공률 | ≥ 90% |
| patch queue budget | 활성 patch ≤ 20개 |
| 활성 issue 응답 시간 (P50) | ≤ 48시간 |

---

## 10. Open Questions (사용자 결정 필요)

| # | Question | Default | Owner |
|---|----------|---------|------|
| Q1 | GitHub 저장소 이름: `voidlight-codesign` vs `open-codesign-ko` | `voidlight-codesign` | 사용자 |
| Q2 | upstream에 한국어 i18n PR 시도 여부 | 시도 | 사용자 |
| Q3 | 빌드 채널 분리 (한국어 전용 dmg) vs 통합 빌드 | 통합 + 로케일 스위처 | 사용자 |
| Q4 | Apple 코드사이닝($99/년) 도입 시점 | M0에서 v1.0 gate로 결정 | 사용자 |
| Q5 | model-bumper 알림 채널 (Slack/Telegram/Email) | Telegram | 사용자 |
| Q6 | VibeProxy 자동 기동 권한(launchd) 부여 여부 | 사용자 옵트인 | 사용자 |

---

## 11. Decisions & Trade-offs (Day 0 self-critique)

> 본 섹션은 [`CRITIQUE.md`](./CRITIQUE.md) 의 핵심 결정사항을 PRD에 고정한 것이다. 향후 변경은 critique 문서를 업데이트하고 본 섹션을 갱신한다.

### 11.1 확정 결정 (Day 0)
| # | 결정 | 영향 |
|---|------|-----|
| D1 | **NOTICE 파일** 추가 (MIT + 폰트 + ToS 면책) | 라이선스 안전 |
| D2 | **README/M02 docs 면책 문구** 의무 | ToS 리스크 명시 |
| D3 | **M01/M03 내부 sub-package 분리** — extractor/translator/glossary/locale-ko/fonts (M01), poller/differ/pr-bot/notifier/override (M03) | SRP 준수 |
| D4 | **parity test 시작 D+8** (기존 D+25 → 17일 앞당김) | 회귀 안전망 |
| D5 | **35일 v1.0 → 42일 v0.1-ko-alpha** 로 목표 재정의 | 현실성 |
| D6 | **patches 태그 시스템** — `PR_safe` / `Fork_only` | upstream PR 안전 |
| D7 | **catalog schema validation** (Zod) | model-bumper 신뢰성 |
| D8 | **IME 회귀 게이트** — upstream 메이저 sync 시 차단 | 한국어 사용자 보호 |
| D9 | **submodule SHA + GPG 체크** | supply chain |

### 11.2 미정 (사용자 결정 필요 — Q-A ~ Q-D)
| Q | 질문 | 후보 | 기본값 제안 |
|---|------|-----|-----------|
| Q-A | M02 + M05 통합 vs 유지 | 통합 / 유지 | **유지** (모듈 단독 배포 가능성) |
| Q-B | distribution-ko 토글 위치 | Settings UI / 빌드 환경변수 | Settings (사용자 제어) |
| Q-C | 학생용 lite 가이드 별도 모듈(M08)?  | 분리 / M01에 포함 | M01 docs/ 하위 |
| Q-D | NOTICE 한국어/영문 병기 | 분리 / 병기 | **병기** (이미 적용됨) |

### 11.3 우선순위 격상 (P0)
critique 결과 다음 5가지를 P0로 격상:
- **회귀 안전망 (parity test)** — 기존 P1 → **P0**
- **공급망 견고성 (model-bumper schema)** — 기존 P1 → **P0**
- **법무·라이선스 단정 (NOTICE/ToS 명시)** — 기존 P2 → **P0**
- **official API key fallback** — VibeProxy 단일 의존 제거
- **release/security 운영 게이트** — M06/M07로 분리

---

## 12. References

- Upstream: <https://github.com/OpenCoworkAI/open-codesign>
- VibeProxy guide: `~/projects/voidlight-vibeproxy-guide`
- CLIProxyAPI: 내장 (`/Applications/VibeProxy.app/Contents/Resources/cli-proxy-api-plus`)
- Open CoDesign config: `~/.config/open-codesign/config.toml`
- Official API key fallback: upstream provider 설정 방식 확인 필요 (M0)
- Korean glossary baseline: TBD (M2 시점)

---

## Appendix A — Initial Recon Findings (2026-04-27)

### A.1 VibeProxy 내부
- 실제 엔진: **CLIProxyAPI** (`cli-proxy-api-plus` 바이너리)
- 포트: `127.0.0.1:8318`
- OAuth 토큰 저장: `~/.cli-proxy-api/`
- 지원 provider: Claude, Codex/GPT, Gemini, GitHub Copilot, Qwen, Z.ai, Antigravity

### A.2 Open CoDesign v0.1.4 호환성
- 릴리스 노트: **"CLIProxyAPI 자동 감지 + 원클릭 임포트"** 명시
- 즉, **VibeProxy 통합은 코드 수정 0** 가능성이 매우 높음
- M01 정찰에서 실측 검증 필요

### A.3 i18n 인프라 (미확인 → Phase 0에서 검증)
- React 19 + Vite 6 기반 → i18next 표준 패턴
- upstream PR 가능성 추정: 중간 (영중 → 영중한 추가 PR)
