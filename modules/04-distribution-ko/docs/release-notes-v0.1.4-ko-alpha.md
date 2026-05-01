# 릴리스 노트 — VoidLight CoDesign v0.1.4-ko-alpha

| 항목 | 값 |
|---|---|
| 버전 | 0.1.4-ko-alpha |
| 채널 | alpha-ko |
| 대상 | 내부·초기 한국어 테스터 |
| 빌드 상태 | unsigned, 미공증 |
| 최소 macOS | Ventura (13.0) 이상 |

---

## 이 릴리스에 포함된 사항

- Open CoDesign 업스트림 기반 한국어 alpha fork 메타데이터 정렬
- 한국어 locale core + hotspot 번역 patch queue 반영
- local proxy 실패 시 official API key 경로로 유도하는 diagnostics fallback CTA
- About 패널, diagnostics bundle 이름, GitHub report/update 링크의 fork 브랜딩 반영
- Homebrew Cask PoC, unsigned dev build 안내, NOTICE 및 라이선스 attribution 문서 정리

## 변경되지 않은 사항

- upstream Open CoDesign 원본 아키텍처와 기본 동작
- 업스트림 기여자 attribution (upstream/ 하위 보존)
- 자동 업데이트 — alpha-ko는 수동 업데이트만 지원
- Apple signing/notarization, Release asset 업로드, Homebrew tap 공개는 이번 범위 밖

## 알려진 제한 사항

알려진 문제는 `known-issues-v0.1.4-ko-alpha.md`를 참조하십시오.

---

## 라이선스 고지

이 릴리스는 Open CoDesign(MIT) 기반 fork입니다.
전체 내용은 배포 패키지의 NOTICE 파일을 참조하십시오.

VibeProxy / CLIProxyAPI 사용은 AI 제공자 ToS와 계정 정책 위험을 수반할 수 있습니다.
상업적·대규모 사용은 사용자 본인 책임 하에 진행하십시오.
