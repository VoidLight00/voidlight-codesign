# VoidLight CoDesign

> **OpenCoworkAI/open-codesign**(MIT) 위에 ① VibeProxy 통합 ② 완전 한국어 UI ③ 신규 모델 자동 반영을 더한 fork.
> upstream 코드는 손대지 않고 4-레이어 모듈러 구조로 운영한다.

**현재 상태**: 기획 단계 (Day 0 · 2026-04-27)

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
| [`docs/ARCHITECTURE.md`](./docs/ARCHITECTURE.md) | 4-레이어 모듈러 구조 |
| [`docs/MODULES.md`](./docs/MODULES.md) | 5개 모듈 상세 명세 |
| [`docs/UPSTREAM_SYNC.md`](./docs/UPSTREAM_SYNC.md) | 주간 rebase 운영 매뉴얼 |
| [`docs/ROADMAP.md`](./docs/ROADMAP.md) | 35일 마일스톤 |

---

## 핵심 원칙

1. **upstream은 read-only submodule** — 직접 편집 금지
2. **모든 커스터마이즈는 modules/ + patches/ + overlays/** — 4레이어 구조
3. **각 patch는 단일 책임 100줄 미만** — upstream PR 후보
4. **모든 기능은 보존** — parity test로 회귀 차단
5. **변경 우선순위 사다리** — upstream PR > 사이드카 > overlay > patch > (hard fork 금지)

---

## 모듈

| ID | 이름 | 책임 |
|----|------|------|
| M01 | i18n-ko | 한국어 UI + 폰트 + 자동 번역 인프라 |
| M02 | vibeproxy-bridge | VibeProxy(=CLIProxyAPI) 자동감지/연결/문서 |
| M03 | model-bumper | 신규 모델 24h 내 반영 자동화 |
| M04 | branding-ko | (선택) 한국어 브랜딩 토글 |
| M05 | installer-ko | brew tap + xattr 자동 + 한국어 가이드 |

---

## 라이선스

MIT (upstream 라이선스 승계). 상세는 `LICENSE` 및 [`NOTICE`](./NOTICE) 참조.

상위 프로젝트인 OpenCoworkAI/open-codesign 의 라이선스, 상표, 기여자에 대한 모든 권리를 존중합니다. 본 fork는 한국어 사용자 편의 및 VibeProxy 통합을 목적으로 합니다.

---

## 기여

- Issue / PR 환영
- 한국어 번역 글로사리는 `modules/01-i18n-ko/src/locale/ko-glossary.md`
- upstream에 PR 가능한 변경은 patches/ 가 아닌 [upstream](https://github.com/OpenCoworkAI/open-codesign) 으로 직접 보내주세요

---

**Maintainer**: [@voidlight](https://github.com/voidlight) · 손상현 / VOIDLIGHT
