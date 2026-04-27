# Modules — VoidLight CoDesign

> 7개 모듈의 contract / interface / 파일 구조 / 인수 기준 / 의존성을 정의한다. 각 모듈은 독립 빌드·테스트·검증 가능해야 하며, release/security gate는 M06/M07이 소유한다.

---

## 모듈 인덱스

| ID | Name | Status | Priority | Lines (target) |
|----|------|--------|---------|---------------|
| M01 | `i18n-ko` | planned | 🔴 P0 | ≤ 800 per sub-package + 1500 키(JSON) |
| M02 | `provider-bridge` | planned | 🔴 P0 | ≤ 500 |
| M03 | `model-bumper` | planned | 🟡 P1 | ≤ 600 |
| M04 | `distribution-ko` | planned | 🟡 P1 | ≤ 300 |
| M05 | `installer-ko` | planned | 🟡 P1 | ≤ 300 |
| M06 | `release-ops` | planned | 🔴 P0 | docs/runbooks + CI glue |
| M07 | `security-compliance` | planned | 🔴 P0 | docs/checklists + validators |

---

## M01 — `i18n-ko`

### Goal
Open CoDesign UI의 핵심 플로우를 먼저 한국어화하고, v1.0 전까지 전체 UI coverage 95% 이상과 stale translation 추적 인프라를 제공한다.

### Decision Tree (Phase 0 결과에 따라 분기)

```
Phase 0 정찰 → upstream에 i18n 프레임워크가 있는가?
   ├─ YES (i18next or similar)
   │   └─ Strategy A: ko.json 추가 → upstream PR
   └─ NO (하드코딩 문자열)
       ├─ Strategy B: i18n 인프라 patch + ko.json 추가
       │               → 영문/중문 추출 patch도 함께 PR
       └─ Strategy D: compile-time transform으로 알파 bridge
                       → v1.0 전 upstream i18n 또는 Strategy B로 이전
```

### Contract
- **입력**: upstream 소스(`upstream/apps/desktop/src/renderer/**/*.{ts,tsx}`)
- **출력**:
  - `dist/locales/ko.json` — 키-값 한국어 사전
  - `dist/fonts/Pretendard.css` — 폰트 등록 CSS
  - `dist/glossary/ko.md` — 전문 용어 사전 (인간 검수용)
- **부산물**: `extracted-strings.json` (어떤 파일·라인의 문자열인지 추적)

### File Structure
```
modules/01-i18n-ko/
├── package.json                         (@vc/i18n-ko)
├── README.md
├── extractor/                            ← AST → strings
├── translator/                           ← AI 번역 어댑터
├── glossary/                             ← 용어 사전 + lint
├── locale-ko/                            ← ko.json 빌드 결과
├── fonts/                                ← Pretendard/Noto CSS
├── src/
│   ├── locale/
│   │   ├── ko.json                      ← 메인 사전
│   │   ├── ko-glossary.md               ← 전문 용어 200+
│   │   └── ko-tone-guide.md             ← 톤 가이드 (존댓말 / 명령형)
│   └── fonts/
│       ├── Pretendard.css
│       └── NotoSansKR.css               ← 폴백
├── scripts/
│   ├── extract-strings.ts               ← AST 기반 문자열 추출
│   ├── translate-batch.ts               ← Anthropic API로 1차 번역
│   ├── apply-glossary.ts                ← 용어 사전 적용 (강제 일관성)
│   ├── verify-stale.ts                  ← 원문 hash 변경 감지
│   └── verify-coverage.ts               ← 미번역 누락 체크
├── tests/
│   ├── coverage.test.ts                 ← 95% 커버리지
│   ├── glossary-consistency.test.ts     ← 용어 사전 위반 검사
│   └── ime-composition.test.ts          ← 한글 IME 입력 회귀
└── tsconfig.json
```

### Acceptance Criteria
- [ ] AC-01: `extract-strings.ts` 실행 → upstream의 모든 UI 문자열을 키로 추출
- [ ] AC-02: `ko.json` 커버리지 ≥ 95% (자동 검증)
- [ ] AC-03: `ko-glossary.md` 200개 이상 (Settings, Provider, Model, Generate 등 핵심 용어)
- [ ] AC-04: 로케일 스위처에서 한국어 선택 시 즉시 반영(앱 재시작 불필요)
- [ ] AC-05: 한글 입력기(IME) composition event 회귀 0건
- [ ] AC-06: Pretendard 폰트가 모든 UI에서 우선 적용 + 영문은 Inter 폴백
- [ ] AC-07: CI에서 신규 문자열 추가 시 미번역 알림 자동 발생

### Dependencies
- 외부: Anthropic API (번역용, 빌드 시점만)
- 내부: 없음
- upstream에 영향: 분기 A는 0, 분기 B는 patch 2개 (i18n loader + 추출)

### Risks
| # | Risk | Mitigation |
|---|------|-----------|
| 01 | 한글 폰트와 영문 폰트 baseline 불일치 | line-height 조정 + visual regression test |
| 02 | i18n 인프라 도입 PR이 거부되면 invasive patch 필요 | compile-time transform bridge + upstream PR 재시도 |
| 03 | AI 번역의 일관성(같은 단어가 다르게 번역) | glossary 강제 적용 + CI 검증 |
| 04 | upstream 영문 카피 변경 후 한국어 번역 stale | source hash 기반 `verify-stale.ts` |

---

## M02 — `provider-bridge`

### Goal
VibeProxy(=CLIProxyAPI) 경로와 official API key fallback 경로를 모두 제공하여, 사용자가 약관·계정·비용 리스크를 이해한 상태에서 연결 방식을 선택하게 만든다.

### Reality Check (2026-04-27 정찰)
- Open CoDesign v0.1.4는 **CLIProxyAPI 자동 감지를 이미 내장**
- VibeProxy 내부 = CLIProxyAPI 8318 포트
- VibeProxy는 provider ToS와 충돌할 수 있으므로 experimental/guided path로 표기
- → 이 모듈은 자동 감지 검증뿐 아니라 **fallback UX와 실패 경로 안내**를 소유한다.

### Contract
- **입력**: 사용자가 VibeProxy 앱 실행 또는 official API key 제공
- **출력**:
  - 자동 감지 검증 결과 (`detect.sh` 출력)
  - official API fallback preset/guide
  - 한국어 가이드 문서 3종 이상
  - E2E 테스트 (VibeProxy와 official API key 중 최소 1개 경로 generation 통과)

### File Structure
```
modules/02-provider-bridge/
├── package.json                         (@vc/provider-bridge)
├── README.md
├── presets/
│   ├── vibeproxy-provider.json          ← 수동 등록 시 사용
│   ├── official-api-provider.json       ← API key fallback preset
│   └── compat-matrix.json               ← VibeProxy/API key × Open CoDesign 버전
├── scripts/
│   ├── detect.sh                        ← VibeProxy 실행 여부 + handshake 확인
│   ├── bootstrap.sh                     ← 사용자 옵트인 기동
│   └── verify-provider-flow.ts          ← E2E 검증 스크립트
├── docs/
│   ├── connect-vibeproxy.md             ← 한국어 가이드 + ToS warning
│   ├── connect-official-api.md          ← API key fallback 가이드
│   ├── troubleshooting.md
│   └── why-provider-modes.md            ← 연결 방식 비교
└── tests/
    ├── compat-matrix.test.ts
    └── local-proxy-security.test.ts
```

### Detect Script (참고용 시그니처)
```bash
#!/usr/bin/env bash
# detect.sh — exits 0 if VibeProxy/CLIProxyAPI is responsive
PORT="${VIBEPROXY_PORT:-8318}"
if curl -fsSL "http://127.0.0.1:${PORT}/v1/models" -o /dev/null; then
  echo "OK: CLIProxyAPI on :${PORT}"
  exit 0
fi
echo "FAIL: VibeProxy not running on :${PORT}"
exit 1
```

### Acceptance Criteria
- [ ] AC-01: VibeProxy 실행 상태 → Open CoDesign이 자동 감지 (재현 100%)
- [ ] AC-02: official API key fallback으로 동일 데모 1종 이상 생성 성공
- [ ] AC-03: VibeProxy와 API key 모드의 차이·비용·ToS 리스크가 UI/docs에 명확히 표시
- [ ] AC-04: ChatGPT/Gemini/Claude 중 최소 2종 provider가 documented path로 동작
- [ ] AC-05: VibeProxy 미실행 시 명확한 한국어 에러 메시지와 fallback CTA 표시
- [ ] AC-06: 한국어 트러블슈팅 문서 (포트 충돌 / OAuth 만료 / SSL / API key 오류 등 5+ 케이스)
- [ ] AC-07: 단순 8318 포트 응답이 아니라 expected protocol/handshake 확인
- [ ] AC-08: 자동 기동은 launchd가 아니라 사용자 명시 옵트인만 허용

### Dependencies
- 외부: VibeProxy 1.8.x+ (사용자 별도 설치), provider official API key
- 내부: M07 security-compliance 정책
- upstream에 영향: 가능하면 0, fallback preset이 필요하면 PR_safe patch 1개

### Risks
| # | Risk | Mitigation |
|---|------|-----------|
| 01 | VibeProxy의 CLIProxyAPI 버전 업그레이드로 wire 변경 | compat-matrix 테스트 + 버전 핀 |
| 02 | provider ToS/계정 정지 리스크 | experimental 표기 + official API fallback 우선 노출 |
| 03 | 사용자가 VibeProxy 설치 경로 변경 | scripts/detect.sh가 대안 경로 5곳 fallback |
| 04 | OAuth 토큰 만료 시 무한 재시도 | 명확한 한국어 안내 + 1회 재인증 유도 |
| 05 | 악성 로컬 프로세스가 8318 포트 spoofing | protocol handshake + warning + M07 gate |

---

## M03 — `model-bumper`

### Goal
provider별 신규 모델(GPT-5.5, Claude 4.7, Gemini 3, Kimi K2, GLM-5 등) 출시 후 24시간 이내에 사용 가능 상태로 만든다.

### Strategy
- **로컬 override**: 사용자는 즉시 사용 가능 (PR 머지 전에도)
- **upstream PR**: 카탈로그가 upstream의 `pi-ai` 패키지에 있으면 PR
- **자동 폴링**: cron으로 매일 provider `/v1/models` 호출

### Contract
- **입력**: provider API 응답 (모델 목록)
- **출력**:
  - `dist/catalog.json` — Open CoDesign이 읽는 override
  - PR 자동 생성 본문 (변경된 모델 diff)
  - 변경 알림 (Telegram/Email)

### File Structure
```
modules/03-model-bumper/
├── package.json                         (@vc/model-bumper)
├── README.md
├── poller/                              ← provider /v1/models 호출
├── differ/                              ← upstream catalog diff
├── pr-bot/                              ← gh CLI 자동 PR 생성
├── notifier/                            ← Telegram/Email 알림 어댑터
├── override/                            ← 로컬 사용자용 override
├── catalog/
│   ├── voidlight-extras.json            ← 우리가 추가한 모델 사전
│   ├── known-providers.json             ← 폴링 대상 endpoint allowlist
│   └── schema.ts                        ← Zod schema
├── scripts/
│   ├── poll-providers.ts                ← /v1/models 폴링
│   ├── diff-and-pr.ts                   ← upstream과 비교 후 PR 생성
│   ├── validate-catalog.ts              ← schema/capability 검증
│   ├── apply-locally.ts                 ← 로컬 override 적용
│   └── notify.ts                        ← Telegram/Email 알림
├── tests/
│   ├── catalog.test.ts
│   └── diff.test.ts
└── .github/workflows-fragment.yml       ← 모듈이 제공하는 cron 설정
```

### Override File Format (`voidlight-extras.json`)
```json
{
  "version": 1,
  "models": [
    {
      "id": "gpt-5.5",
      "provider": "openai",
      "displayName": "GPT-5.5",
      "tier": "premium",
      "addedAt": "2026-04-27",
      "source": "openai/v1/models",
      "notes": "Successor to GPT-5"
    }
  ]
}
```

### Acceptance Criteria
- [ ] AC-01: cron 매일 03:00 KST 자동 실행
- [ ] AC-02: 신규 모델 발견 → PR 자동 생성 (diff + 자동 changelog), 자동 머지 금지
- [ ] AC-03: 사용자가 `apply-locally.ts` 1줄로 override 즉시 사용
- [ ] AC-04: PR 본문에 모델 metadata(가격·context·capability·endpoint 호환성) 포함
- [ ] AC-05: 폴링 실패 시(rate limit, network) 24시간 backoff
- [ ] AC-06: allowlist provider만 모니터링(OpenAI, Anthropic, Google, OpenRouter, Kimi 등)
- [ ] AC-07: Zod/JSON Schema 검증 실패 시 PR 생성 차단
- [ ] AC-08: 잘못된 모델 노출 시 rollback 파일/절차 제공

### Dependencies
- 외부: 각 provider API key (CI secret으로 보관, 매우 제한적 권한)
- upstream에 영향: override 파일 읽는 patch 1개 (`patches/0004-model-registry-allow-override-file.patch`)

### Risks
| # | Risk | Mitigation |
|---|------|-----------|
| 01 | provider별 모델 ID 명명 규칙 불일치 | per-provider normalizer |
| 02 | upstream PR이 늦어져 fork 카탈로그가 ahead | 로컬 override로 사용자 영향 차단 |
| 03 | API key 유출 | GitHub Secret + minimal scope |

---

## M04 — `distribution-ko`

### Goal
한국어 빌드의 앱 메타데이터, 브랜딩, update channel, 코드사이닝/notarization, NOTICE/About 표기를 소유한다.

### Default Stance
- 알파: unsigned/dev build 가능하지만 위험과 실행 방법을 명확히 고지
- v1.0: signed/notarized build 또는 동등한 배포 신뢰 정책 필요
- 브랜딩은 선택 장식이 아니라 fork 혼동 방지와 update channel 분리의 일부로 취급
- 모든 화면/문서에서 "based on Open CoDesign by OpenCoworkAI (MIT)" credit 유지

### File Structure
```
modules/04-distribution-ko/
├── package.json
├── README.md
├── assets/
│   ├── icons-ko/
│   │   ├── app.icns
│   │   ├── app.ico
│   │   └── app.png (multi-resolution)
│   ├── splash-ko.png
│   └── logo-ko.svg
├── metadata/
│   ├── app-channel.json
│   └── about-notice.md
├── docs/
│   ├── signing-notarization.md
│   └── update-channel.md
└── overlays-fragment/
    └── apps/desktop/build/icon.* (overlay 적용 시 복사)
```

### Acceptance Criteria
- [ ] AC-01: 앱명·bundle id·update channel 정책이 문서화됨
- [ ] AC-02: 환경변수 `VC_BRAND=voidlight` 빌드 시 한국어 브랜딩 적용
- [ ] AC-03: 라이선스 표기(MIT, OpenCoworkAI credit) 모든 화면에 유지
- [ ] AC-04: 앱명 한국어 표기 옵션 ("VoidLight 코디자인")
- [ ] AC-05: macOS signing/notarization 준비 체크리스트 완료
- [ ] AC-06: unsigned alpha와 signed v1.0 배포 메시지가 분리됨

### Dependencies
- M01 (한국어 문구)
- M06 (release channel/runbook)
- M07 (license/privacy/security gate)

### Risks
| # | Risk | Mitigation |
|---|------|-----------|
| 01 | 브랜딩 분리가 upstream 커뮤니티에 혼란 | "powered by Open CoDesign" 명기, 라이선스 준수 |
| 02 | 아이콘 캐시로 변경 미반영 | 빌드 후 아이콘 캐시 무효화 스크립트 |
| 03 | unsigned build로 사용자 신뢰 하락 | alpha/dev build로만 표기, v1.0 gate에서 signing 해결 |
| 04 | update channel 혼선 | stable-ko/beta-ko/channel metadata 명시 |

---

## M05 — `installer-ko`

### Goal
한국 사용자가 마찰 없이 설치하고 첫 실행에 도달.

### File Structure
```
modules/05-installer-ko/
├── package.json
├── README.md
├── homebrew/
│   ├── voidlight-codesign.rb            ← Cask formula
│   └── tap.json                         ← voidlight/homebrew-tap 메타
├── scripts/
│   ├── install.sh                       ← 1줄 curl-bash 설치
│   ├── post-install-quarantine.sh       ← xattr 자동
│   └── uninstall.sh
├── docs/
│   ├── 한국어-설치가이드.md             ← 스크린샷 포함
│   ├── 첫-실행-체크리스트.md
│   └── 자주-묻는-질문.md
└── tests/
    └── install-matrix.md                ← macOS 13/14/15 + Sonoma/Sequoia
```

### Acceptance Criteria
- [ ] AC-01: `brew install --cask voidlight/tap/voidlight-codesign` 1줄 설치 PoC
- [ ] AC-02: xattr 격리 해제는 알파용 안내로만 제공하고 v1.0 신뢰 정책과 분리
- [ ] AC-03: 첫 실행 시 한국어 온보딩 화면 (M01 의존)
- [ ] AC-04: VibeProxy 미설치 사용자에 provider mode 선택 안내 (M02 docs로 deeplink)
- [ ] AC-05: Homebrew tap이 GitHub Action으로 자동 SHA 업데이트
- [ ] AC-06: signed/notarized 여부가 설치 문서 첫 화면에 명확히 표시

### Dependencies
- M01 (온보딩 한국어)
- M02 (provider 연결 안내)
- M04 (배포 채널·서명 정책)
- M07 (보안/라이선스 warning)

### Risks
| # | Risk | Mitigation |
|---|------|-----------|
| 01 | macOS Sequoia 15+ Gatekeeper 강화 | alpha는 명시적 unsigned 안내, v1.0은 signing/notarization gate |
| 02 | brew tap 메타 동기화 실패 | 릴리스 워크플로우에서 자동 업데이트 |
| 03 | 설치 과정에서 ToS/security warning 누락 | M07 checklist를 release gate에 포함 |

---

## M06 — `release-ops`

### Goal
upstream sync, patch queue, CI, rollback, release freeze를 운영 가능하게 만든다.

### File Structure
```
modules/06-release-ops/
├── README.md
├── docs/
│   ├── rollback-runbook.md
│   ├── patch-budget.md
│   ├── upstream-sync-sla.md
│   └── release-freeze.md
└── tests/
    └── patch-manifest.test.ts
```

### Acceptance Criteria
- [ ] AC-01: upstream sync는 자동 PR까지만 수행하고 main 자동 push 금지
- [ ] AC-02: `patches/manifest.json`과 `patches/series` 불일치 시 CI 실패
- [ ] AC-03: 활성 patch 20개 초과 시 경고, 30개 초과 시 신규 기능 차단
- [ ] AC-04: sync 실패 시 stable channel freeze runbook 존재
- [ ] AC-05: model-bumper rollback 절차 존재

---

## M07 — `security-compliance`

### Goal
ToS, privacy, token storage, local proxy 보안, dependency/license audit를 release gate로 만든다.

### File Structure
```
modules/07-security-compliance/
├── README.md
├── docs/
│   ├── tos-risk-register.md
│   ├── token-storage-policy.md
│   ├── local-proxy-security.md
│   ├── telemetry-audit.md
│   └── license-audit.md
└── tests/
    └── compliance-checklist.test.ts
```

### Acceptance Criteria
- [ ] AC-01: VibeProxy/CLIProxyAPI ToS warning이 README, docs, 첫 실행 UI에 존재
- [ ] AC-02: OAuth/API token 평문 저장 금지 검증
- [ ] AC-03: local proxy detection이 handshake/origin/port spoofing 체크를 포함
- [ ] AC-04: dependency/font/license audit 결과 기록
- [ ] AC-05: crash/log/telemetry에 prompt, token, account email이 포함되지 않음

---

## 모듈 간 통합 시나리오

### 시나리오 A — 신규 사용자
```
1. brew install --cask voidlight/tap/voidlight-codesign        [M05]
2. 첫 실행 → 한국어 온보딩                                       [M01, M05]
3. provider mode 선택: official API key 또는 VibeProxy             [M02, M07]
4. 선택한 방식의 연결 가이드 진행
5. 자동 감지 또는 API key 검증 → Provider 등록 완료                 [M02]
6. 첫 데모 생성 (한국어 UI)                                      [M01, M02]
```

### 시나리오 B — 신규 모델 출시
```
[03:00 KST] model-bumper cron 실행                              [M03]
[03:01]    OpenAI /v1/models 폴링 → "gpt-5.5" 발견              [M03]
[03:02]    schema/capability 검증                                [M03, M07]
[03:03]    PR 자동 생성 + Telegram 알림 (자동 머지 금지)            [M03]
[09:00]    사용자가 PR 검토 + 머지
[09:05]    `apply-locally.ts` 로 즉시 override 또는 rollback 가능    [M03, M06]
```

### 시나리오 C — upstream 메이저 업데이트
```
[매일]      upstream release/tag 또는 변화량 감지                  [M06]
[감지 시]   generated-app dry-run + patch 적용                    [scripts]
[실패]      Issue 자동 생성 + Telegram 알림 + stable freeze        [M06]
[성공]      upstream-sync PR 생성 (자동 머지 금지)                 [.github]
[검토 후]   core가 patch 재작성 또는 PR 머지
```

---

## 모듈 신규 추가 가이드

새 모듈 `08-foo` 추가 시:
1. `mkdir -p modules/08-foo/{src,scripts,tests,docs}`
2. `cp templates/module-package.json modules/08-foo/package.json`
3. `pnpm install` (자동으로 workspace에 등록됨)
4. `MODULES.md` 에 본 양식대로 기술
5. `apply-modules.sh` 가 자동 발견 (별도 등록 불필요)
6. PR 생성 시 ARCHITECTURE.md 의 Layer 4 다이어그램 업데이트

> **모듈 추가는 30분 이내 완료되도록 설계되어 있다.** 그 이상 걸린다면 아키텍처 문제이며 ARCHITECTURE.md 검토 대상.
