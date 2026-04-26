# PRD — VoidLight CoDesign

> **Project**: `voidlight-codesign`
> **Owner**: 손상현 / VOIDLIGHT
> **Status**: Draft v0.1 (planning)
> **Last updated**: 2026-04-27
> **Upstream**: [OpenCoworkAI/open-codesign](https://github.com/OpenCoworkAI/open-codesign) v0.1.4 (MIT)

---

## 1. Vision

> **"내가 이미 결제하고 있는 AI 구독으로, 한국어 UI 안에서, Claude Design 수준의 AI 디자인 작업을 한다."**

Open CoDesign(MIT, Electron 기반)을 베이스로 다음 3가지를 추가한다:

1. **VibeProxy(=CLIProxyAPI) 통합** — Claude Pro/Max·ChatGPT Plus·Gemini Advanced·Codex 구독을 추가 토큰비 0원으로 사용.
2. **완전 한국어 UI** — 메뉴·설정·알림·문서 100% 한글화. 폰트도 Pretendard/Noto Sans KR 기본 적용.
3. **신규 모델 24시간 반영** — GPT-5.5, Claude 4.7+, Gemini 3 등 출시 즉시 카탈로그 자동 업데이트.

이 모든 것을 **upstream 코드 수정 최소화 + 모든 기능 보존**의 제약 안에서 달성한다.

---

## 2. Non-Goals (이 프로젝트가 다루지 않는 것)

| # | 비목표 | 이유 |
|---|------|-----|
| N1 | upstream 하드 포크(영구 분기) | 유지 비용 폭증, 커뮤니티 분리 |
| N2 | Claude Design 자체 대체 | 우리는 fork이지 신규 제품이 아님 |
| N3 | Electron → 다른 프레임워크 마이그레이션 | upstream 호환성 깨짐 |
| N4 | 자체 백엔드/클라우드 | local-first 원칙 유지 |
| N5 | 비-OAuth 구독 우회(Cursor, Lovable 등) | ToS 리스크, 가치 대비 비용 낮음 |
| N6 | Apple 코드사이닝 즉시 도입 | $99/년 비용, v0.5 이후 검토 |

---

## 3. Personas & Use Cases

### Persona A — "한국어 디자인 강사" (=손상현)
- 이미 Claude Pro / ChatGPT Plus 결제 중
- AI Beyond 멤버십 등에서 강의·시연
- 한국어 UI가 필요 (학생 시연, 자료 캡처)
- **Use case**: VibeProxy 1번 클릭 → Open CoDesign 실행 → 한국어 UI에서 Claude Sonnet으로 슬라이드 덱 생성

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
| 02 | `vibeproxy-bridge` | VibeProxy 자동 감지/연결/문서화 | core | 🔴 P0 |
| 03 | `model-bumper` | 신규 모델 24시간 반영 자동화 | infra | 🟡 P1 |
| 04 | `branding-ko` | (선택) 한국어 빌드 브랜딩 | optional | 🟢 P2 |
| 05 | `installer-ko` | brew tap + 한국어 설치 가이드 | infra | 🟡 P1 |

### 4.1 모듈 간 의존 관계
```
i18n-ko        ← independent
vibeproxy-bridge ← independent
model-bumper   ← independent
branding-ko    ← depends on i18n-ko (한국어 문구 사용)
installer-ko   ← depends on (i18n-ko, vibeproxy-bridge)
```

### 4.2 모듈 단위 인수 기준 (요약)

#### M01 i18n-ko
- [ ] `apps/desktop` 모든 UI 문자열의 ≥ 95%가 ko.json에 존재
- [ ] 로케일 스위처에서 한국어 선택 시 즉시 반영(재시작 불필요)
- [ ] 한국어 전문 용어 사전(`ko-glossary.md`) 200개 이상
- [ ] IME 한글 입력 회귀 테스트 통과

#### M02 vibeproxy-bridge
- [ ] VibeProxy 실행 상태 → 앱이 자동 감지 → provider 자동 등록
- [ ] Claude Pro 구독으로 슬라이드 덱 생성 E2E 통과
- [ ] ChatGPT Plus·Gemini·Codex 모두 동일 흐름 동작
- [ ] 한국어 트러블슈팅 문서 완비

#### M03 model-bumper
- [ ] cron으로 매일 provider 모델 목록 폴링
- [ ] 신규 모델 발견 시 PR 자동 생성
- [ ] 로컬 override 파일로 즉시 사용 가능 (PR 머지 전)
- [ ] GPT-5.5 출시 시 24시간 내 사용 가능 검증

#### M04 branding-ko
- [ ] Settings에서 브랜드 토글(VoidLight/Open CoDesign)
- [ ] upstream 자산 미수정, overlay만 사용

#### M05 installer-ko
- [ ] `brew install --cask voidlight/tap/voidlight-codesign` 1줄 설치
- [ ] xattr 격리 자동 해제
- [ ] 한국어 설치 가이드 (스크린샷 포함)

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
| R1 | upstream의 빠른 릴리스(주 단위)로 patch 충돌 빈발 | 🔴 High | 주 1회 자동 rebase CI + 충돌 알림 |
| R2 | i18n 인프라가 upstream에 없으면 도입 patch가 invasive | 🟠 Med | upstream PR 우선 시도, 거부 시 overlay 방식 |
| R3 | VibeProxy 자체 업데이트로 wire format 변경 | 🟡 Low | 호환성 매트릭스 테스트, 버전 핀 |
| R4 | 한국어 AI 번역 품질 일관성 부족 | 🟠 Med | 용어 사전 + 사람 QA 패스 + glossary 강제 |
| R5 | ToS 리스크 (구독 우회) | 🟠 Med | "교육·개인용" 면책 명시, 상업 배포 자제 |
| R6 | Apple Gatekeeper 강화로 unsigned 앱 실행 어려움 | 🟡 Low | xattr 자동화 + 향후 코드사이닝 |
| R7 | 신규 모델 카탈로그 격차로 사용자 혼란 | 🟡 Low | model-bumper 자동화 + 로컬 override |

---

## 7. Roadmap (Milestones)

자세한 일정은 [`ROADMAP.md`](./ROADMAP.md).

| Milestone | Goal | ETA | Modules |
|-----------|------|-----|---------|
| **M0 — Recon** | Phase 0 정찰 완료, RECON.md 산출 | D+3 | (research only) |
| **M1 — VibeProxy MVP** | Claude Pro 구독으로 동작 검증 | D+7 | 02 |
| **M2 — 한글 알파** | 핵심 화면 한국어 적용 + parity test 가동 | D+17 | 01, parity |
| **M3 — 한글 베타** | 전체 UI 한국어 + brew 설치 | D+27 | 01, 05 |
| **M4 — 자동화 인프라** | model-bumper + upstream sync CI | D+33 | 03 |
| **M5 — 1.0** | 안정화 + 한국어 발표/홍보 | D+42 | 04, all |

> 일정은 [`CRITIQUE.md`](./CRITIQUE.md) §Q6 결정 반영하여 35일 → 42일로 조정 (20% buffer).

---

## 8. Maintenance Contract (지속성)

### 8.1 주간 루틴 (자동화)
- 월요일 09:00: `sync-upstream.sh` 자동 실행 → rebase 시도
- 충돌 발생 → Issue 자동 생성 + Slack/Telegram 알림
- 충돌 없음 → main 자동 푸시

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
| 한국어 UI coverage | ≥ 95% |
| upstream rebase 성공률 | ≥ 90% (자동 통과) |
| 신규 모델 반영 시간 | ≤ 24시간 |
| brew 설치 성공률 | ≥ 95% |
| VibeProxy 자동 감지 성공률 | ≥ 90% |
| GitHub stars | ≥ 100 (한국어 유저층) |
| 활성 issue 응답 시간 (P50) | ≤ 48시간 |

---

## 10. Open Questions (사용자 결정 필요)

| # | Question | Default | Owner |
|---|----------|---------|------|
| Q1 | GitHub 저장소 이름: `voidlight-codesign` vs `open-codesign-ko` | `voidlight-codesign` | 사용자 |
| Q2 | upstream에 한국어 i18n PR 시도 여부 | 시도 | 사용자 |
| Q3 | 빌드 채널 분리 (한국어 전용 dmg) vs 통합 빌드 | 통합 + 로케일 스위처 | 사용자 |
| Q4 | Apple 코드사이닝($99/년) 도입 시점 | v0.5 이후 | 사용자 |
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
| D5 | **35일 → 42일 일정** (20% buffer) | 현실성 |
| D6 | **patches 태그 시스템** — `PR_safe` / `Fork_only` | upstream PR 안전 |
| D7 | **catalog schema validation** (Zod) | model-bumper 신뢰성 |
| D8 | **IME 회귀 게이트** — upstream 메이저 sync 시 차단 | 한국어 사용자 보호 |
| D9 | **submodule SHA + GPG 체크** | supply chain |

### 11.2 미정 (사용자 결정 필요 — Q-A ~ Q-D)
| Q | 질문 | 후보 | 기본값 제안 |
|---|------|-----|-----------|
| Q-A | M02 + M05 통합 vs 유지 | 통합 / 유지 | **유지** (모듈 단독 배포 가능성) |
| Q-B | branding-ko 토글 위치 | Settings UI / 빌드 환경변수 | Settings (사용자 제어) |
| Q-C | 학생용 lite 가이드 별도 모듈(M06)? | 분리 / M01에 포함 | M01 docs/ 하위 |
| Q-D | NOTICE 한국어/영문 병기 | 분리 / 병기 | **병기** (이미 적용됨) |

### 11.3 우선순위 격상 (P0)
critique 결과 다음 3가지를 P0로 격상:
- **회귀 안전망 (parity test)** — 기존 P1 → **P0**
- **공급망 견고성 (model-bumper schema)** — 기존 P1 → **P0**
- **법무·라이선스 단정 (NOTICE/ToS 명시)** — 기존 P2 → **P0**

---

## 12. References

- Upstream: <https://github.com/OpenCoworkAI/open-codesign>
- VibeProxy guide: `~/projects/voidlight-vibeproxy-guide`
- CLIProxyAPI: 내장 (`/Applications/VibeProxy.app/Contents/Resources/cli-proxy-api-plus`)
- Open CoDesign config: `~/.config/open-codesign/config.toml`
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
