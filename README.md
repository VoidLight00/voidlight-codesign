# VoidLight CoDesign

> **OpenCoworkAI/open-codesign**(MIT) 위에 ① 한국어 UX ② VibeProxy/API provider bridge ③ 검증된 모델 카탈로그 운영을 더한 fork.
> upstream 코드는 손대지 않고 `upstream/` → `generated-app/` → `patches/overlays/modules` 구조로 운영한다.

**현재 상태**: 기획 단계 (Day 0 · 2026-04-27)

**42일 목표**: 정식 v1.0이 아니라 `v0.1-ko-alpha` developer preview. v1.0은 코드사이닝·보안·fallback·parity exit criteria 충족 후 별도 릴리스한다.

---

## 빠른 시작 (예정)

```bash
# 설치 (M3 이후)
brew install --cask voidlight/tap/voidlight-codesign

# 또는 직접 빌드
git clone --recurse-submodules https://github.com/voidlight/voidlight-codesign.git
cd voidlight-codesign
pnpm bootstrap
pnpm build
```

---

## 문서

| 문서 | 내용 |
|------|------|
| [`docs/PRD.md`](./docs/PRD.md) | 비전·페르소나·인수기준·성공지표 |
| [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) | 4-레이어 + generated build target 구조 |
| [`docs/MODULES.md`](./docs/MODULES.md) | 7개 모듈 상세 명세 |
| [`docs/UPSTREAM_SYNC.md`](./docs/UPSTREAM_SYNC.md) | upstream sync·patch queue 운영 매뉴얼 |
| [`docs/ROADMAP.md`](./docs/ROADMAP.md) | 42일 알파 로드맵 + v1.0 exit criteria |

---

## 핵심 원칙

1. **upstream은 read-only submodule** — 직접 편집 금지
2. **실제 빌드 대상은 generated-app/** — upstream + patches + overlays 결과만 테스트
3. **모든 커스터마이즈는 modules/ + patches/ + overlays/** — 재생성 가능한 구조
4. **patch는 manifest로 관리** — owner/risk/drop condition/PR 가능성 기록
5. **모든 기능은 보존** — parity test로 회귀 차단
6. **VibeProxy 단일 의존 금지** — official API key fallback을 동등 경로로 유지
7. **변경 우선순위 사다리** — upstream PR > 사이드카 > overlay > patch > (hard fork 금지)

---

## 모듈

| ID | 이름 | 책임 |
|----|------|------|
| M01 | i18n-ko | 한국어 UI + 폰트 + 자동 번역 인프라 |
| M02 | provider-bridge | VibeProxy + official API fallback 연결/문서 |
| M03 | model-bumper | 신규 모델 감지·검증·PR·override |
| M04 | distribution-ko | 브랜딩·앱 메타·서명·update channel |
| M05 | installer-ko | brew tap + 한국어 설치/첫 실행 가이드 |
| M06 | release-ops | upstream sync·patch governance·rollback |
| M07 | security-compliance | ToS·token storage·local proxy·license audit |

---

## Provider / ToS 주의

VibeProxy/CLIProxyAPI 경로는 편리하지만 AI provider 약관(ToS)과 충돌할 수 있습니다. 이 프로젝트는 이를 공식 지원 경로로 보장하지 않으며, official API key fallback을 함께 제공하는 것을 원칙으로 합니다.

상업 배포·대규모 사용 전에는 각 provider 약관과 조직 보안 정책을 반드시 확인하세요.

---

## 라이선스

MIT (upstream 라이선스 승계). 상세는 `LICENSE` 및 [`NOTICE`](./NOTICE) 참조.

상위 프로젝트인 OpenCoworkAI/open-codesign 의 라이선스, 상표, 기여자에 대한 모든 권리를 존중합니다. 본 fork는 한국어 사용자 편의 및 VibeProxy 통합을 목적으로 합니다.

---

## 기여

- Issue / PR 환영
- 한국어 번역 글로사리는 `modules/01-i18n-ko/src/locale/ko-glossary.md`
- patch 추가 시 `patches/manifest.json`과 `patches/series`를 함께 갱신하세요
- upstream에 PR 가능한 변경은 fork-only patch가 아니라 [upstream](https://github.com/OpenCoworkAI/open-codesign) 으로 분리해 보내주세요

---

**Maintainer**: [@voidlight](https://github.com/voidlight) · 손상현 / VOIDLIGHT
