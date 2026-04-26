# Modules — VoidLight CoDesign

> 5개 모듈의 contract / interface / 파일 구조 / 인수 기준 / 의존성을 정의한다. 각 모듈은 독립 빌드·테스트·릴리스 가능해야 한다.

---

## 모듈 인덱스

| ID | Name | Status | Priority | Lines (target) |
|----|------|--------|---------|---------------|
| M01 | `i18n-ko` | planned | 🔴 P0 | ≤ 800 (코드) + 1500 키(JSON) |
| M02 | `vibeproxy-bridge` | planned | 🔴 P0 | ≤ 400 (대부분 docs) |
| M03 | `model-bumper` | planned | 🟡 P1 | ≤ 600 |
| M04 | `branding-ko` | planned | 🟢 P2 | ≤ 200 |
| M05 | `installer-ko` | planned | 🟡 P1 | ≤ 300 |

---

## M01 — `i18n-ko`

### Goal
Open CoDesign UI를 한국어로 100% 변환하고, 향후 신규 문자열을 자동 추적·번역하는 인프라를 제공한다.

### Decision Tree (Phase 0 결과에 따라 분기)

```
Phase 0 정찰 → upstream에 i18n 프레임워크가 있는가?
   ├─ YES (i18next or similar)
   │   └─ Strategy A: ko.json 추가 → upstream PR
   └─ NO (하드코딩 문자열)
       └─ Strategy B: i18n 인프라 patch + ko.json 추가
                       → 영문/중문 추출 patch도 함께 PR
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
| 02 | i18n 인프라 도입 PR이 거부되면 invasive patch 필요 | overlay 폴백 준비 |
| 03 | AI 번역의 일관성(같은 단어가 다르게 번역) | glossary 강제 적용 + CI 검증 |

---

## M02 — `vibeproxy-bridge`

### Goal
사용자가 VibeProxy(=CLIProxyAPI)를 띄워두면 Open CoDesign이 자동으로 인식하여 Claude Pro/Max·ChatGPT Plus·Gemini Advanced·Codex 구독으로 동작하게 만든다.

### Reality Check (2026-04-27 정찰)
- Open CoDesign v0.1.4는 **CLIProxyAPI 자동 감지를 이미 내장**
- VibeProxy 내부 = CLIProxyAPI 8318 포트
- → **이 모듈의 작업은 90%가 검증·문서화·UX**

### Contract
- **입력**: 사용자가 VibeProxy 앱 실행
- **출력**:
  - 자동 감지 검증 결과 (`detect.sh` 출력)
  - 한국어 가이드 문서 3종
  - E2E 테스트 (Claude Pro 구독으로 generation 통과)

### File Structure
```
modules/02-vibeproxy-bridge/
├── package.json                         (@vc/vibeproxy-bridge)
├── README.md
├── presets/
│   ├── vibeproxy-provider.json          ← 수동 등록 시 사용
│   └── compat-matrix.json               ← VibeProxy 버전 × Open CoDesign 버전
├── scripts/
│   ├── detect.sh                        ← VibeProxy 실행 여부 확인
│   ├── bootstrap.sh                     ← VibeProxy + Open CoDesign 동시 기동
│   └── verify-claude-flow.ts            ← E2E 검증 스크립트
├── docs/
│   ├── connect-claude-pro.md            ← 한국어 가이드
│   ├── connect-chatgpt-plus.md
│   ├── connect-gemini.md
│   ├── troubleshooting.md
│   └── why-vibeproxy.md                 ← 배경 설명
└── tests/
    └── compat-matrix.test.ts
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
- [ ] AC-02: Claude Sonnet으로 5종 데모(landing, dashboard, slide, mobile, chat) 생성 성공
- [ ] AC-03: ChatGPT Plus 구독 인증 후 GPT-5 동작
- [ ] AC-04: Gemini 인증 후 Gemini 2.5 Pro 동작
- [ ] AC-05: VibeProxy 미실행 시 명확한 한국어 에러 메시지 (자동 감지 실패 사유 포함)
- [ ] AC-06: 한국어 트러블슈팅 문서 (포트 충돌 / OAuth 만료 / SSL 등 5+ 케이스)
- [ ] AC-07: bootstrap 스크립트가 launchd 또는 사용자 옵트인으로 자동 기동

### Dependencies
- 외부: VibeProxy 1.8.x+ (사용자 별도 설치)
- upstream에 영향: 0 (preset 추가는 하되 patch 불필요)

### Risks
| # | Risk | Mitigation |
|---|------|-----------|
| 01 | VibeProxy의 CLIProxyAPI 버전 업그레이드로 wire 변경 | compat-matrix 테스트 + 버전 핀 |
| 02 | 사용자가 VibeProxy 설치 경로 변경 | scripts/detect.sh가 대안 경로 5곳 fallback |
| 03 | OAuth 토큰 만료 시 무한 재시도 | 명확한 한국어 안내 + 1회 재인증 유도 |

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
├── catalog/
│   ├── voidlight-extras.json            ← 우리가 추가한 모델 사전
│   └── known-providers.json             ← 폴링 대상 endpoint
├── scripts/
│   ├── poll-providers.ts                ← /v1/models 폴링
│   ├── diff-and-pr.ts                   ← upstream과 비교 후 PR 생성
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
- [ ] AC-02: 신규 모델 발견 → PR 자동 생성 (diff + 자동 changelog)
- [ ] AC-03: 사용자가 `apply-locally.ts` 1줄로 override 즉시 사용
- [ ] AC-04: PR 본문에 모델 metadata(가격·context·capability) 포함
- [ ] AC-05: 폴링 실패 시(rate limit, network) 24시간 backoff
- [ ] AC-06: 5종 provider 동시 모니터링(OpenAI, Anthropic, Google, OpenRouter, Kimi)

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

## M04 — `branding-ko` (선택 모듈)

### Goal
한국어 빌드의 시각적 정체성을 약간 분리(앱명, 아이콘, 스플래시) — **선택적**.

### Default Stance
- 기본: upstream 브랜딩 그대로 사용 (혼란 최소화)
- Settings → "VoidLight 브랜딩 사용" 옵션으로 토글
- 토글 ON 시에만 overlays 적용

### File Structure
```
modules/04-branding-ko/
├── package.json
├── README.md
├── assets/
│   ├── icons-ko/
│   │   ├── app.icns
│   │   ├── app.ico
│   │   └── app.png (multi-resolution)
│   ├── splash-ko.png
│   └── logo-ko.svg
└── overlays-fragment/
    └── apps/desktop/build/icon.* (overlay 적용 시 복사)
```

### Acceptance Criteria
- [ ] AC-01: 기본 빌드는 upstream 브랜딩 사용
- [ ] AC-02: 환경변수 `VC_BRAND=voidlight` 빌드 시 한국어 브랜딩 적용
- [ ] AC-03: 라이선스 표기(MIT, OpenCoworkAI credit) 모든 화면에 유지
- [ ] AC-04: 앱명 한국어 표기 옵션 ("VoidLight 코디자인")

### Dependencies
- M01 (한국어 문구)

### Risks
| # | Risk | Mitigation |
|---|------|-----------|
| 01 | 브랜딩 분리가 upstream 커뮤니티에 혼란 | "powered by Open CoDesign" 명기, 라이선스 준수 |
| 02 | 아이콘 캐시로 변경 미반영 | 빌드 후 아이콘 캐시 무효화 스크립트 |

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
- [ ] AC-01: `brew install --cask voidlight/tap/voidlight-codesign` 1줄로 설치
- [ ] AC-02: post-install hook이 xattr 격리 자동 해제
- [ ] AC-03: 첫 실행 시 한국어 온보딩 화면 (M01 의존)
- [ ] AC-04: VibeProxy 미설치 사용자에 자동 안내 (M02 docs로 deeplink)
- [ ] AC-05: Homebrew tap이 GitHub Action으로 자동 SHA 업데이트

### Dependencies
- M01 (온보딩 한국어)
- M02 (VibeProxy 안내)

### Risks
| # | Risk | Mitigation |
|---|------|-----------|
| 01 | macOS Sequoia 15+ Gatekeeper 강화 | xattr 자동 + Apple 코드사이닝 로드맵(v0.5) |
| 02 | brew tap 메타 동기화 실패 | 릴리스 워크플로우에서 자동 업데이트 |

---

## 모듈 간 통합 시나리오

### 시나리오 A — 신규 사용자
```
1. brew install --cask voidlight/tap/voidlight-codesign        [M05]
2. 첫 실행 → 한국어 온보딩                                       [M01, M05]
3. "Claude Pro 구독 사용하기" 카드 클릭 → VibeProxy 안내         [M02]
4. VibeProxy 설치 + 로그인
5. 자동 감지 → Provider 등록 완료                                [M02]
6. 첫 데모 생성 (한국어 UI)                                      [M01, M02]
```

### 시나리오 B — 신규 모델 출시
```
[03:00 KST] model-bumper cron 실행                              [M03]
[03:01]    OpenAI /v1/models 폴링 → "gpt-5.5" 발견              [M03]
[03:02]    PR 자동 생성 + Telegram 알림                         [M03]
[09:00]    사용자가 PR 검토 + 머지
[09:05]    `apply-locally.ts` 로 즉시 override (또는 다음 빌드 대기) [M03]
```

### 시나리오 C — upstream 메이저 업데이트
```
[월 09:00] sync-upstream.sh 자동 실행                           [scripts]
[09:05]    submodule update + git rebase upstream/main          [scripts]
[09:10]    충돌 발생 → Issue 자동 생성 + Telegram 알림          [.github]
[당일]      core가 patch 재작성 (보통 30분~1시간)
[익일]      재실행 → 통과 → main 자동 머지
```

---

## 모듈 신규 추가 가이드

새 모듈 `06-foo` 추가 시:
1. `mkdir -p modules/06-foo/{src,scripts,tests,docs}`
2. `cp templates/module-package.json modules/06-foo/package.json`
3. `pnpm install` (자동으로 workspace에 등록됨)
4. `MODULES.md` 에 본 양식대로 기술
5. `apply-modules.sh` 가 자동 발견 (별도 등록 불필요)
6. PR 생성 시 ARCHITECTURE.md 의 Layer 4 다이어그램 업데이트

> **모듈 추가는 30분 이내 완료되도록 설계되어 있다.** 그 이상 걸린다면 아키텍처 문제이며 ARCHITECTURE.md 검토 대상.
