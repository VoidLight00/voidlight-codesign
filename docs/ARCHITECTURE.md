# Architecture — VoidLight CoDesign

> **목적**: upstream(`OpenCoworkAI/open-codesign`)에 손을 대지 않으면서, 우리만의 확장(VibeProxy 통합 · 한국어 · 모델 자동 갱신 · 한국어 설치)을 4-레이어 모듈러 구조로 운영한다.

---

## 0. 한 장 요약

```
┌──────────────────────────────────────────────────────────────────┐
│                   voidlight-codesign (this repo)                │
│                                                                  │
│  Layer 4 ──  modules/         (자체 패키지·스크립트·자산)        │
│              ├─ 01-i18n-ko                                       │
│              ├─ 02-vibeproxy-bridge                              │
│              ├─ 03-model-bumper                                  │
│              ├─ 04-branding-ko                                   │
│              └─ 05-installer-ko                                  │
│                                                                  │
│  Layer 3 ──  overlays/        (빌드 시 upstream 위에 file copy)  │
│  Layer 2 ──  patches/         (rebase-able, single-responsibility)│
│  Layer 1 ──  upstream/        (git submodule, 절대 수정 금지)    │
│                                                                  │
│  Glue   ──  scripts/          (sync · apply · build · verify)    │
│         ──  .github/workflows (자동 rebase · 모델 폴링 · 릴리스)  │
│         ──  tests/parity/     (upstream 기능 회귀 검증)          │
└──────────────────────────────────────────────────────────────────┘
```

### 변경 우선순위 사다리

```
가장 먼저  →  ① upstream PR             (한국어 i18n 인프라, 신규 모델)
              ② Layer 4 사이드카         (preset, 자동 감지 스크립트)
              ③ Layer 3 overlay         (정적 파일 shadow)
가장 나중  →  ④ Layer 2 patch           (기존 코드 라인 수정)
              (Layer 1 직접 수정 = 금지)
```

---

## 1. Repository Layout

```
voidlight-codesign/
├── upstream/                          ← Layer 1: git submodule
│   └── (OpenCoworkAI/open-codesign 원본, read-only)
│
├── patches/                           ← Layer 2
│   ├── 0001-i18n-introduce-locale-loader.patch
│   ├── 0002-i18n-extract-renderer-strings.patch
│   ├── 0003-add-vibeproxy-preset-detection.patch
│   ├── 0004-model-registry-allow-override-file.patch
│   └── series                         ← 적용 순서 (quilt 형식)
│
├── overlays/                          ← Layer 3
│   ├── apps/desktop/src/renderer/
│   │   └── i18n/                      ← (i18n 인프라가 upstream에 없을 때만)
│   ├── apps/desktop/public/
│   │   └── fonts/                     ← Pretendard, Noto Sans KR
│   └── packaging/homebrew/
│       └── voidlight-codesign.rb
│
├── modules/                           ← Layer 4 (자체 패키지)
│   ├── 01-i18n-ko/
│   │   ├── package.json               ← 독립 npm 패키지
│   │   ├── src/locale/ko.json
│   │   ├── src/locale/ko-glossary.md
│   │   ├── src/fonts/Pretendard.css
│   │   ├── scripts/extract-strings.ts
│   │   ├── scripts/translate-batch.ts
│   │   ├── scripts/verify-coverage.ts
│   │   ├── tests/coverage.test.ts
│   │   └── README.md
│   │
│   ├── 02-vibeproxy-bridge/
│   │   ├── presets/vibeproxy-provider.json
│   │   ├── scripts/detect.sh
│   │   ├── scripts/bootstrap.sh
│   │   ├── docs/connect-claude-pro.md
│   │   ├── docs/connect-chatgpt-plus.md
│   │   ├── docs/troubleshooting.md
│   │   ├── tests/compat-matrix.md
│   │   └── README.md
│   │
│   ├── 03-model-bumper/
│   │   ├── catalog/voidlight-extras.json
│   │   ├── scripts/poll-providers.ts
│   │   ├── scripts/diff-and-pr.ts
│   │   ├── scripts/apply-locally.ts
│   │   ├── tests/catalog.test.ts
│   │   └── README.md
│   │
│   ├── 04-branding-ko/
│   │   ├── assets/icons-ko/
│   │   ├── assets/splash-ko.png
│   │   └── README.md
│   │
│   └── 05-installer-ko/
│       ├── homebrew/voidlight-codesign.rb
│       ├── scripts/install.sh
│       ├── scripts/post-install-quarantine.sh
│       ├── docs/한국어-설치가이드.md
│       └── README.md
│
├── scripts/                           ← 글루 자동화
│   ├── sync-upstream.sh               ← 주간 rebase
│   ├── apply-modules.sh               ← patches+overlays 적용
│   ├── build.sh                       ← 통합 빌드
│   ├── verify-parity.sh               ← upstream 기능 회귀 테스트
│   ├── release.sh                     ← tag + DMG/EXE/AppImage
│   └── lib/                           ← 공통 helper
│
├── tests/
│   ├── e2e/                           ← Playwright (앱 동작)
│   ├── parity/                        ← upstream demo 통과 검증
│   └── i18n/                          ← 로케일 회귀
│
├── .github/workflows/
│   ├── upstream-sync.yml              ← 주 1회 rebase
│   ├── model-bumper.yml               ← 매일 03:00 폴링
│   ├── ci.yml                         ← lint + typecheck + test
│   └── release.yml                    ← tag push 시 빌드
│
├── docs/
│   ├── PRD.md
│   ├── ARCHITECTURE.md   ← 본 문서
│   ├── MODULES.md
│   ├── UPSTREAM_SYNC.md
│   ├── ROADMAP.md
│   └── TRANSLATION_GUIDE.md
│
├── package.json          ← pnpm workspace root
├── pnpm-workspace.yaml
├── tsconfig.base.json
├── .gitignore
├── .gitmodules
└── README.md             ← 한국어 메인 README
```

---

## 2. Layer 별 책임 정의

### Layer 1 — `upstream/` (read-only submodule)
- **Pin**: `git submodule update --remote` 으로 명시적 업그레이드
- **Branch**: 우리는 항상 upstream `main`의 특정 SHA를 가리킨다
- **수정 금지**: `.gitmodules`로 submodule 등록 후 어떤 파일도 직접 편집하지 않음
- **CI 검증**: `git diff --quiet HEAD upstream/main -- upstream/` 가 항상 빈 diff여야 함 (= 우리가 upstream을 안 건드렸음)

### Layer 2 — `patches/`
- **형식**: `git format-patch` 출력 (3-way merge 가능)
- **순서**: `patches/series` 파일이 적용 순서를 결정 (quilt convention)
- **단위**: 단일 책임, 100줄 미만 권장, 각각이 upstream PR 후보
- **재정렬 가능**: 각 patch는 다른 patch에 의존하지 않도록 작성 (가능한 한)
- **CI 검증**: `pnpm test:patch-apply` 가 모든 patch를 깨끗이 적용해야 함

#### Patch 예시
```
patches/
├── 0001-i18n-introduce-locale-loader.patch     ← upstream에 i18n 없을 때만
├── 0002-i18n-extract-renderer-strings.patch    ← 0001과 함께 PR
├── 0003-add-vibeproxy-preset-detection.patch   ← provider preset 추가
└── 0004-model-registry-allow-override-file.patch
```

### Layer 3 — `overlays/`
- **메커니즘**: `apply-modules.sh` 가 `overlays/` 의 모든 파일을 `upstream/` 위에 cp -R
- **용도**: patch로 표현하기 어려운 자산(폰트, 아이콘, 정적 리소스, 패키징 메타)
- **장점**: 충돌 시 빠르게 인지 (해당 파일이 upstream에 추가됐는지 확인)
- **단점**: 라인 단위 추적 안 됨 → 텍스트 코드 변경에는 부적합 (그건 Layer 2)

### Layer 4 — `modules/`
- **독립 패키지**: 각 모듈은 자체 `package.json`과 `tests/`
- **타 모듈에 의존 금지**: 단, 공통 helper는 `scripts/lib/`로 추출
- **upstream 비의존**: 빌드 시 결과물만 overlays/patches로 흘러감
- **사용자 직접 호출 가능**: 예) `pnpm --filter @vc/i18n-ko verify-coverage`

---

## 3. Build Pipeline

```
   ┌─────────────────────────────────────────────────────────────┐
   │ 1. submodule 동기화                                          │
   │    git submodule update --init --remote upstream            │
   └────────────────────────┬────────────────────────────────────┘
                            ▼
   ┌─────────────────────────────────────────────────────────────┐
   │ 2. modules 빌드 (각 모듈 독립)                                │
   │    pnpm -r build                                            │
   │    → modules/01-i18n-ko/dist/ko.json                         │
   │    → modules/03-model-bumper/dist/catalog.json               │
   └────────────────────────┬────────────────────────────────────┘
                            ▼
   ┌─────────────────────────────────────────────────────────────┐
   │ 3. patches 적용                                              │
   │    cd upstream && git am ../patches/*.patch                  │
   └────────────────────────┬────────────────────────────────────┘
                            ▼
   ┌─────────────────────────────────────────────────────────────┐
   │ 4. overlays 적용 + module artifacts 복사                     │
   │    rsync -a overlays/ upstream/                              │
   │    cp modules/01-i18n-ko/dist/ko.json upstream/.../locales/  │
   └────────────────────────┬────────────────────────────────────┘
                            ▼
   ┌─────────────────────────────────────────────────────────────┐
   │ 5. upstream 빌드 (그대로 호출)                               │
   │    cd upstream && pnpm build && pnpm package                 │
   └────────────────────────┬────────────────────────────────────┘
                            ▼
   ┌─────────────────────────────────────────────────────────────┐
   │ 6. parity test                                              │
   │    pnpm test:parity   (upstream의 데모 시드 generation 동작)  │
   └────────────────────────┬────────────────────────────────────┘
                            ▼
   ┌─────────────────────────────────────────────────────────────┐
   │ 7. 산출물                                                   │
   │    dist/voidlight-codesign-{version}-arm64.dmg              │
   │    dist/voidlight-codesign-{version}-x64.dmg                │
   │    dist/voidlight-codesign-{version}-x64-setup.exe          │
   │    dist/voidlight-codesign-{version}-x64.AppImage           │
   └─────────────────────────────────────────────────────────────┘
```

### 핵심 명령어
```bash
# 처음 셋업
pnpm bootstrap          # = submodule init + pnpm install -r

# 일상 개발
pnpm dev                # = upstream의 dev + i18n watch + overlay live-reload

# 빌드
pnpm build              # = 위 7-step 파이프라인 전체

# upstream 동기화
pnpm sync:upstream      # = sync-upstream.sh

# 회귀 검증
pnpm test:parity        # = upstream demo 8개가 동일하게 generation 통과
```

---

## 4. Module Communication Patterns

### 4.1 한 모듈이 다른 모듈을 호출하지 않는다
- 모듈 간 코드 의존 금지
- 공통 로직은 `scripts/lib/` 에만 위치
- 결과물(json, png, ts)을 overlays/patches로 합쳐서 upstream에 흘림

### 4.2 모듈은 upstream을 import 하지 않는다
- 모듈 코드는 upstream의 어떤 심볼도 import 하지 않음
- 인터페이스는 **파일 출력**(json, css, ts)으로만 통신
- → 모듈을 단독 테스트 가능

### 4.3 모듈 → 빌드 시점 통합
- 빌드 시 `apply-modules.sh` 가 dist를 적절한 upstream 경로에 배치
- 예: `modules/01-i18n-ko/dist/ko.json` → `upstream/apps/desktop/src/renderer/locales/ko.json`

---

## 5. Refactoring 친화 설계

### 5.1 모듈 추가/제거 비용 = O(1)
- 모듈 디렉토리 생성/삭제만으로 추가/제거 완료
- `pnpm-workspace.yaml`에 자동 등록
- `apply-modules.sh` 가 modules/* 를 자동 발견

### 5.2 patch 재정렬 비용 = O(N)
- `patches/series` 파일에서 순서 변경
- 충돌 발생 시 단일 patch만 재작성

### 5.3 upstream 메이저 변경 시 비용
- 영향: 주로 patches/ (코드 라인 의존)
- modules/ 와 overlays/ 는 대부분 무영향
- → 평균 복구 시간(MTTR) 목표: **30분 이하**

---

## 6. Branching Model

```
main                           ← 항상 upstream + 우리 patch 가 적용 가능한 상태
├── develop                    ← 통합 브랜치, PR 머지 대상
├── feature/i18n-ko-init       ← 모듈 단위 작업 브랜치
├── feature/vibeproxy-detect
├── feature/model-bumper-cron
└── upstream-sync/2026-04-29   ← 주간 rebase PR (자동)
```

### 보호 규칙
- `main` 직접 push 금지 (자동 rebase 봇 제외)
- PR 머지 시 squash → 의미 단위 commit 1개
- patch 추가 시 PR 본문에 "이 patch는 upstream PR 가능한가?" 체크박스

---

## 7. CI/CD

### 7.1 트리거 매트릭스
| Event | Workflow | Action |
|-------|---------|--------|
| Push to PR | `ci.yml` | lint + typecheck + unit + parity |
| Merge to main | `ci.yml` + `release.yml` (태그면) | DMG/EXE/AppImage 빌드 |
| Cron 매주 월 09:00 | `upstream-sync.yml` | submodule update + rebase 시도 |
| Cron 매일 03:00 | `model-bumper.yml` | 모델 카탈로그 폴링 + PR |
| Tag push (v*) | `release.yml` | GitHub Release + brew bump |

### 7.2 환경 변수
```
UPSTREAM_REPO=OpenCoworkAI/open-codesign
UPSTREAM_BRANCH=main
ANTHROPIC_API_KEY=<for parity test>
TELEGRAM_BOT_TOKEN=<rebase 충돌 알림용, 옵션>
```

---

## 8. Security & Privacy

- 사용자 API 키/OAuth 토큰: 우리 빌드는 절대 수집하지 않음 (upstream 정책 그대로)
- VibeProxy 토큰 위치: `~/.cli-proxy-api/` (우리 코드는 read-only로만 참조)
- 텔레메트리: upstream 기본값(off) 유지
- 한국어 번역 자동화에 사용자 데이터 흐름 없음 — UI 문자열만 처리

---

## 9. Why this architecture (Trade-offs)

| 결정 | 대안 | 채택 이유 |
|------|-----|----------|
| submodule for upstream | vendor copy | 명시적 SHA 추적, diff 깔끔 |
| pnpm workspaces | npm/yarn | 모듈 격리 + 디스크 효율 |
| git format-patch | merge commits | rebase-friendly, upstream PR 변환 용이 |
| overlays + patches 병행 | patches만 | 정적 자산은 patches로 표현 비효율 |
| 모듈 간 의존 금지 | 공유 라이브러리 | 모듈 단독 리팩토링 가능, 테스트 격리 |
| 한 monorepo | 5개 polyrepo | /pcs 한 번으로 전체 커밋, CI 단순화 |

---

## 10. Glossary

- **Upstream**: `OpenCoworkAI/open-codesign` 본가
- **Patch**: 단일 책임 코드 변경의 git format-patch 산출
- **Overlay**: 빌드 시 upstream 위에 덮어쓰는 정적 파일
- **Module**: 독립 빌드 가능한 패키지 (modules/ 하위)
- **Parity test**: upstream의 기본 데모가 우리 빌드에서 동일하게 동작하는지 검증
- **Rebase 충돌**: upstream 변경이 우리 patch와 동일 라인 수정 → 자동 rebase 실패
- **MTTR**: Mean Time To Recover — 회귀 발생 후 복구까지 평균 시간
