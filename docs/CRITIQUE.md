# Plan Critique & Decisions

> **목적**: 본 PRD/Architecture/Modules 기획에 대한 자체 비판과, 그에 따른 결정·미정 항목 정리.
> **작성**: 2026-04-27 (Day 0, GPT-5.5 외부 검토 사용량 한도 도달로 self-critique 채택)
> **방법**: 강사·운영자·유지보수자 3개 관점에서 의도적으로 잘못될 수 있는 지점만 골라 비판.

---

## Q1. 누락된 critical 요소

### C1.1 — 라이선스/저작자 표기 정책 부재 🔴
**문제**: PRD §2 N1에서 "하드 포크 금지"만 적혀있고, **fork명, app명, NOTICE 파일, 라이선스 문구 표기 가이드라인이 없음**. MIT는 "include the original copyright notice"를 강제하는데, 이걸 빌드 산출물(About 화면, dmg 메타, brew formula description)마다 어떻게 적용할지 미정.

**결정**:
- `NOTICE` 파일 추가 (upstream MIT 원문 + 우리 추가 항목 표기)
- About 화면 스플래시: "VoidLight CoDesign — based on Open CoDesign by OpenCoworkAI (MIT)"
- 모든 PR/Issue에서 fork임을 명시
- M5 (브랜딩) 도입 시에도 "powered by Open CoDesign" 문구 의무

### C1.2 — VibeProxy 자체의 ToS 면책 표시 누락 🟠
**문제**: VibeProxy 가이드 README에 이미 *"This guide documents a technique that may violate the Terms of Service of AI model providers"* 명시되어 있음. 우리 fork가 VibeProxy를 권장하면서 면책 문구를 빠뜨리면 사용자 불만 + 잠재 분쟁 소지.

**결정**:
- M02 vibeproxy-bridge docs/ 모든 페이지 상단에 한국어 면책 문구 의무
- README.md 에도 "VibeProxy는 제공자 ToS를 위반할 수 있음, 교육·개인 용도 한정" 단락 추가

### C1.3 — 데이터 마이그레이션 시나리오 미정의 🟡
**문제**: 사용자가 영문 빌드 v0.1.x 사용 후 한국어 빌드로 전환 시 `~/.config/open-codesign/config.toml`, SQLite 디자인 히스토리는 그대로 인식되는가? 검증 안됨.

**결정**: M0 정찰에서 기존 사용자 데이터 호환성 명시적 검증.

### C1.4 — 기여자 협업 모델 미정의 🟡
**문제**: 한국어 사용자 피드백이 어떤 채널로 들어오고 누가 트리아지하는지 부재. 손상현 1인 운영 시 빠르게 병목.

**결정**:
- GitHub Issues 한국어 템플릿 (`bug-report-ko.yml`, `feature-ko.yml`)
- Discussions 한국어 카테고리
- (미래) 글로사리 기여자 모집 → MAINTAINERS.md

---

## Q2. 모듈 분해 적정성

### C2.1 — M02 vibeproxy-bridge와 M05 installer-ko의 중복 🟠
**문제**: M02는 "VibeProxy 안내 문서 + 자동 감지 검증" 90%가 docs. M05는 "한국어 설치 가이드 + 첫 실행 온보딩". 둘 다 **"사용자가 첫 사용까지의 마찰 제거"** 라는 동일 책임. 모듈 경계가 인공적.

**결정안 (B 채택)**:
- A. 합치기: `02-onboarding-ko` 단일 모듈 (설치 + VibeProxy + 첫 실행)
- B. **유지하되 의존 명시**: M05가 M02 docs를 참조하는 형태로 둠 (현행 유지)
- C. M02를 docs-only로 명확화 + M05가 실행 코드 담당

**채택 사유**: 모듈 단독 배포 가능성을 고려하면 분리가 유리. 단, MODULES.md에 "M05는 M02 docs를 deeplink"라는 의존을 명시.

### C2.2 — M03 model-bumper 책임 비대 🟡
**문제**: M03이 "폴링 + diff + PR 생성 + 알림 + 로컬 override" 5가지 일을 함. 단일 책임 원칙(SRP) 위반.

**결정**: M03 내부에서 sub-module 분리:
```
modules/03-model-bumper/
├── poller/      ← provider /v1/models 호출
├── differ/      ← upstream catalog diff
├── pr-bot/      ← gh CLI 자동 PR 생성
├── notifier/    ← Telegram 알림 어댑터
└── override/    ← 로컬 사용자용
```
모듈 단위가 아닌 **모듈 내부 sub-package** 로 처리. 외부 인터페이스는 동일.

### C2.3 — i18n-ko가 너무 큼 🟠
**문제**: AST 추출 + AI 번역 + 용어사전 + 폰트 + IME 테스트 → M01 단독 LOC 추정 1500+ (의도한 ≤800 초과).

**결정**: 다음을 sub-package 분리:
```
modules/01-i18n-ko/
├── extractor/        ← AST → strings (재사용 가능, 다른 언어도)
├── translator/       ← AI 번역 어댑터
├── glossary/         ← 한국어 전문용어 (단독 npm 배포 가능)
├── locale-ko/        ← ko.json 빌드 결과
└── fonts/            ← Pretendard CSS
```
**glossary** 는 다른 한국어 AI 도구(예: voidwiki)에서도 재사용 가능 → 사용자 자산.

---

## Q3. upstream sync 함정

### C3.1 — patches/ 의존이 양방향이 됨 🔴
**문제**: 우리가 `0001-i18n-loader.patch` 적용 후 그 위에 `0002-i18n-extract-strings.patch` 가 빌드되는 순서. 그런데 upstream이 0001과 같은 영역을 바꾸면 0002도 동시에 깨짐. **patch 간 hidden dependency**가 생김.

**결정**:
- patches 단위 의존성 명시 — 각 patch 헤더에 `Depends-On: 0001`
- `series` 파일에 의존 그래프 주석
- 주간 rebase 워크플로우는 의존 순서대로 적용 (이미 그렇게 설계됨)
- **그러나**: 두 patch가 함께 망가지면 동시에 재작성. 이를 위해 `patches/` 도 unit test (= patch가 적용 후 컴파일 통과) 필요.

### C3.2 — parity test가 stub인 채로 운영 시작 위험 🔴
**문제**: ROADMAP M5에서야 parity test 구현. 그 전까지(D+0~D+25) 우리는 **회귀를 감지할 수단이 없음**. patches 5개 누적 + upstream 변경 합쳐지면 어디가 망가졌는지 추적 불가.

**결정 (강한 변경)**:
- parity test 도입 시점 **D+8(M2 시작)로 앞당김**
- 최소 3개 데모(landing, slide deck, prototype)에 대해 산출물 hash 비교
- M3·M4 에서 점진 확장

### C3.3 — submodule 자동 update의 보안 이슈 🟡
**문제**: `git submodule update --remote` 가 upstream의 latest를 자동으로 가져옴. upstream에 supply chain 공격이 들어오면 우리 빌드도 자동 오염.

**결정**:
- 자동 sync는 **PR 생성까지만**, 머지는 사람이 한다 (이미 PRD에 명시됨)
- 추가: 매 sync에서 upstream의 새 커밋 SHA를 PR 본문에 명기 + GPG 서명 확인 (가능한 경우)

### C3.4 — fork 자체의 supply chain 🟡
**문제**: M03 model-bumper가 자동으로 `voidlight-extras.json` 에 모델 추가 → 누구든 PR 본문 변조하면 악성 카탈로그 진입.

**결정**:
- model-bumper PR은 봇 자동 생성, 머지는 사람만
- 카탈로그는 schema validation (Zod 또는 JSON Schema)
- 신뢰하는 provider endpoint 화이트리스트

---

## Q4. i18n Strategy A/B 외 옵션

### Strategy C — DOM 후처리 (런타임 치환) 🟡
- 영문 텍스트를 MutationObserver로 감지 → 한글 치환
- **장점**: upstream 0 수정, patches 0
- **단점**: 동적 텍스트 누락, 폰트 baseline 어색, 성능 저하, IME 충돌 가능

### Strategy D — electron preload 가로채기 🟠
- preload 스크립트에서 React `createElement` wrap → 자식 텍스트가 한글이면 폰트만 바꾸고, 영문이면 사전 lookup
- **장점**: upstream 0 수정
- **단점**: React 내부 구현 의존 → upstream React 버전 업 시 깨짐

### Strategy E — 별도 wrapper 앱 🟢
- Open CoDesign을 webview/iframe으로 임베드한 한국어 wrapper Electron 앱
- **장점**: upstream 완전 격리
- **단점**: 본 프로젝트의 "fork" 컨셉 이탈, 기능 90%가 외부 의존

### 결정
- **기본**: Strategy A (i18next 표준) > Strategy B (인프라 patch + i18next 도입)
- **분기 결정**: Phase 0 정찰에서 upstream 코드를 보고 결정. i18next 이미 있으면 A, 없으면 B.
- **C/D/E는 비상시 폴백**으로만 문서화.

추가:
- **Hybrid 가능성**: 핵심 화면은 B(정식 i18n), 마이너 화면은 C(런타임 치환)로 시간 단축 가능

---

## Q5. 한국어 디자인 강사 페르소나 — 빠진 사용성

### C5.1 — 시연 중 토큰 비용 폭증 🟠
**문제**: 강의 시연(2시간) 동안 학생 30명이 동시에 같은 데모를 따라하면 OAuth 한도 빨리 도달. VibeProxy도 quota 한정.

**결정**:
- "교육 모드" 토글 (선택): 미리 캐시된 데모 5개만 호출 가능, 새 generation 차단
- 또는 "학생용 가이드" 별도 — 학생은 자기 ChatGPT Plus로 따라함

### C5.2 — 학생 onboarding 장벽 🟡
**문제**: 강사가 "여러분도 이걸 따라하세요" → 학생들이 brew install + VibeProxy 설치 + OAuth → 30분 소요. 강의 진도 지연.

**결정**:
- 1줄 부트스트랩 스크립트 (`curl ... | bash`) 제공 (M05)
- 학생용 영상 가이드 (1분 미만, M3 종료 시점 제작)

### C5.3 — 발표 중 "한국어 폰트 글리프 누락" 사고 🟡
**문제**: Pretendard에 일부 한자/특수문자 누락 → 강의 중 □ 박스 표시.

**결정**:
- 폰트 fallback chain 명시: Pretendard → Noto Sans KR → Apple SD Gothic Neo → system
- M01/AC-06 에 "글리프 누락 회귀 테스트" 추가

### C5.4 — 발표 자료 export 시 한글 깨짐 🟡
**문제**: PDF/PPTX export 시 한글이 영문 폰트로 저장되면 깨짐.

**결정**:
- PPTX 내장 폰트 강제 옵션 (M01 의 폰트 모듈에서 지원)
- 검증: parity test 에 한글 PDF/PPTX export 케이스 포함

---

## Q6. 35일 일정 비현실성

### C6.1 — M2 한글 알파 7일 빡빡 🟠
**문제**: AI 번역 1차 → 글로사리 강제 → 사람 QA → IME 회귀 → 폰트 baseline 조정. 7일은 무리.

**결정**:
- M2를 **10일**로 늘림 (D+12 → D+15)
- 후속 마일스톤 4일씩 밀림 (M5 v1.0 = D+39)
- 또는: M2 알파를 "핵심 3화면만"으로 축소 → 베타에서 전체

### C6.2 — D+19 외부 테스터 5인 모집 🟡
**문제**: 5명 모집 자체에 시간. AI Beyond 멤버십 활용해도 의향 확인 + 일정 조율 = 3~5일.

**결정**:
- D+13 부터 모집 시작 (병렬)
- 테스트는 D+22~24 (3일 윈도우)

### C6.3 — buffer 0% 🔴
**문제**: 모든 마일스톤이 deadline-driven, slack 없음. 하나만 밀려도 전체 도미노.

**결정 (강함)**: **20% buffer** 추가
- 35일 → **42일** 으로 조정
- 각 마일스톤 끝에 1~2일 polish 시간 확보

### 일정 재구성 (제안)
| Milestone | 기존 | 수정 |
|-----------|------|------|
| M0 Recon | D+2 | **D+3** |
| M1 VibeProxy MVP | D+5 | **D+7** |
| M2 한글 알파 | D+12 | **D+17** |
| M3 한글 베타 + brew | D+20 | **D+27** |
| M4 자동화 | D+25 | **D+33** |
| M5 v1.0 | D+35 | **D+42** |

---

## Q7. 보안/ToS/라이선스 함정

### C7.1 — Claude OAuth 토큰 우회 사용의 회색지대 🟠
**문제**: VibeProxy가 Claude Code의 OAuth 세션을 가로채서 다른 클라이언트(Open CoDesign)로 사용. Anthropic ToS의 "API access via authorized clients only" 조항 위반 가능성.

**결정**:
- README/M02 docs에 명시: "공식 지원 아님. 개인 학습·교육 용도 권장. 상업 배포 자제"
- Claude Pro/Max 약관 변경 모니터링 (분기 1회)
- 향후 Anthropic이 공식 OAuth 공개 시 즉시 마이그레이션

### C7.2 — fork branding 후 upstream 혼동 🟡
**문제**: M04 branding-ko 가 적용된 빌드를 본 사용자가 "이게 Anthropic 공식인가? Open CoDesign인가? VoidLight 거인가?" 혼동.

**결정**:
- About 화면에 3-tier 표기: "VoidLight CoDesign | Open CoDesign fork | based on Anthropic Claude" 같은 계층
- 첫 실행 한 번 modal: "이 앱은 OpenCoworkAI/open-codesign 의 한국어 fork입니다"

### C7.3 — 한국어 PR 에 fork 코드 섞이지 않게 🟡
**문제**: i18n PR을 upstream에 보낼 때 우리 fork 전용 코드(VibeProxy preset, branding)가 섞여서 머지 거부 위험.

**결정**:
- PR 시 cherry-pick 으로 i18n 관련 commit만 분리
- patches/ 도 "PR_safe" 태그 (PR 가능) vs "Fork_only" 태그 (fork 전용) 분류

### C7.4 — 폰트 라이선스 명시 🟡
**문제**: Pretendard MIT, Noto Sans KR OFL — 모두 OK이지만 NOTICE에 빠뜨리면 문제.

**결정**: NOTICE 파일에 폰트 라이선스 섹션 명시.

---

## Q8. 1년 후 sustainability — 부채 포인트

### D8.1 — Electron 메이저 업그레이드 시 IME 회귀 🔴
**위험**: Electron 버전 업그레이드는 한글 IME composition event 깨지기로 유명. upstream이 Electron 33 → 34 가면 우리 한글 입력 망가질 수 있음.

**대응**:
- IME 회귀 테스트 자동화 (M01/AC-05)
- 매 upstream 메이저 sync 시 IME 테스트 강제
- 폴백: IME 깨지면 hotfix patch 즉시 작성 (1일 내)

### D8.2 — VibeProxy 자체의 지속성 🟠
**위험**: VibeProxy는 우리 통제 밖 도구. CLIProxyAPI 라이브러리 자체가 deprecated 되거나, 작자가 손 떼면 우리 M02 무용지물.

**대응**:
- M02 docs에 "VibeProxy 외 대안" 섹션 (LiteLLM, OpenRouter 등)
- 실제로 VibeProxy 비의존 경로(API 키 직접) 도 항상 동작 보장
- 1년 단위로 호환성 검증

### D8.3 — model-bumper bot이 stale 카탈로그 누적 🟡
**위험**: 1년간 매일 polling → catalog가 100+ 모델로 비대. UI에서 선택지 너무 많음.

**대응**:
- 카탈로그에 `deprecated`, `recommended` 플래그
- 분기 1회 정리 작업 (사람이 결정)

### D8.4 — 한국어 글로사리 표류 🟡
**위험**: 1년 후 영문 신규 용어 200개 추가 → 한국어 번역 적시성 떨어짐.

**대응**:
- 글로사리에 `ai_translated`, `human_verified` 플래그
- 사용자 피드백으로 자연 수렴
- 분기 1회 글로사리 청소

### D8.5 — upstream maintainer가 사라지면 🟡
**위험**: OpenCoworkAI 가 1년 후 활동 정지하면 우리는 stale upstream에 묶임.

**대응**:
- 마지막 안정 SHA에 pin 후 long-term fork 모드 진입 (PRD §9 비상 절차)
- 다른 활성 fork 합류 가능성 모니터링

### D8.6 — 손상현 1인 운영의 bus factor 🔴
**위험**: 핵심 운영자 1명에 의존. 1주만 부재해도 자동화로 운영되지만 충돌 시 정체.

**대응**:
- 모든 운영을 문서화 (UPSTREAM_SYNC.md 이미 시작)
- 외부 컨트리뷰터 모집 시 글로사리부터 (낮은 진입장벽)
- 문서가 곧 후계자 — 본 PRD 수정 이력으로 학습 가능

---

## 변경 적용 (PRD/Architecture/Modules에 반영할 것)

### Decisions taken (이번 자체 critique로 확정)

1. **NOTICE 파일 추가** — 다음 commit에 포함
2. **README/docs 면책 문구** — VibeProxy ToS 위험 경고
3. **모듈 내 sub-package 도입** — M01, M03 만 적용 (M01: extractor/translator/glossary/locale-ko/fonts. M03: poller/differ/pr-bot/notifier/override)
4. **parity test 시작 시점 D+8로 앞당김** — ROADMAP 갱신
5. **35일 → 42일로 조정** — 20% buffer
6. **patches 태그 시스템** — `PR_safe` / `Fork_only` 구분 도입
7. **카탈로그 schema validation** — model-bumper에 zod schema 의무
8. **submodule SHA 명시 + 변경 알림** — sync workflow 보강
9. **IME 회귀 테스트 강제** — 모든 upstream 메이저 sync 시 차단 게이트

### 미정 (사용자 확정 필요)

- **Q-A**: M02/M05 합치기 vs 유지? → 본 critique에서 "유지" 권장했으나 사용자 의견 수렴
- **Q-B**: branding-ko 토글 위치? — Settings 또는 빌드 환경변수
- **Q-C**: 학생용 lite 가이드 별도 모듈로 분리 여부? — M06 후보
- **Q-D**: NOTICE 파일 한국어/영문 병기 여부

---

## 최종 의견

> 이 기획은 **운영 가능한 골격**으로는 합리적이지만, 다음 3가지가 강화되어야 1년 운영 가능합니다.

1. **회귀 안전망** — parity test를 D+0부터 stub이 아니라 실측으로 작성. 이게 부재하면 patches 5개 쌓일 즈음 사일로 모르게 깨짐.
2. **폴링 인프라의 supply-chain 견고성** — model-bumper 의 자동 PR이 카탈로그를 오염시키지 않도록 schema + 사람 게이트.
3. **법무·라이선스 단정** — VibeProxy 면책, MIT NOTICE, fork 표기. 1년 후 분쟁 0건을 위한 사전 작업.

위 3가지를 우선순위 P0로 격상하고 시작하면, 35일이 42일이 되더라도 **해체 가능한 / 인계 가능한 / 분쟁 가능성 낮은** 프로젝트가 됩니다.

---

## 다음 액션 후보

이번 critique 반영을 위한 후속 PR/문서 변경:
1. `NOTICE` 파일 추가
2. `docs/PRD.md` 에 §12 "Decisions & Trade-offs" 섹션 추가
3. `docs/ROADMAP.md` 일정 +7일 조정
4. `docs/MODULES.md` M01/M03 sub-package 구조 반영
5. `docs/UPSTREAM_SYNC.md` 에 schema validation + IME gate 추가
6. `tests/parity/README.md` (D+8 시작 stub) 작성

위 변경은 다음 commit에서 일괄 처리.
