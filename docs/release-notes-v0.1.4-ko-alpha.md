# Release Notes — v0.1.4-ko-alpha

VoidLight CoDesign `v0.1.4-ko-alpha`는 한국어 사용자와 강의/시연 환경을 위한 developer preview입니다. 정식 v1.0이 아니며, 설치·첫 실행·provider 연결·한국어 핵심 흐름을 검증하기 위한 알파 릴리스입니다.

## 핵심 목표

- 핵심 UI 한국어화 검증
- VibeProxy experimental 연결 문서화
- official API key fallback 경로 유지
- unsigned/dev 배포 흐름 검증
- patch governance와 보안 체크리스트 고정
- v1.0 전 필수 backlog 분리

## Provider 연결

### 1. Official API key fallback

공식 API key 기반 연결은 v0.1.4-ko-alpha에서 계속 first-class 경로로 취급합니다. 조직/상업/장기 사용자는 이 경로를 우선 검토하세요.

### 2. VibeProxy experimental

VibeProxy는 로컬 proxy와 호환되는 experimental 연결입니다. 일부 provider 약관(ToS)과 충돌할 수 있으므로 개인 학습·교육·시연 범위에서만 신중히 사용하세요. 이 프로젝트는 VibeProxy를 공식 provider 지원 경로로 표현하지 않습니다.

## 보안/컴플라이언스 주의

- OAuth token/API key 평문 저장은 금지 원칙입니다.
- token, account email, prompt 전문이 log/crash report에 포함되지 않아야 합니다.
- 새 telemetry 서비스나 secret은 알파에서 도입하지 않습니다.
- provider 약관, 계정 정책, 상업 사용 가능 여부는 사용자가 직접 확인해야 합니다.

## 운영 정책

- upstream sync와 model-bumper는 PR 생성까지만 허용합니다.
- 자동 merge와 자동 release는 금지합니다.
- quilt-style patch queue를 유지합니다.
- release freeze 중에는 보안 P0/P1 외 기능 변경을 제한합니다.

## 검증 명령

릴리스 후보에는 다음 gate를 실행합니다.

```bash
bash scripts/verify-patches.sh
bash scripts/verify-security.sh
```

## v1.0 전 필수 작업

- signed/notarized macOS build 또는 명확한 대체 배포 정책
- official API key fallback UX 강화
- full i18n coverage와 stale translation detection
- local proxy origin/handshake/port spoofing 검증 강화
- telemetry/crash reporting privacy audit 완료
- LICENSE/NOTICE/About/brew formula 표기 정리
- upstream parity test 확대
- patch count budget과 patch diet 운영

## 대상 사용자

이 릴리스는 일반 최종 사용자용 안정판이 아닙니다. 한국어 알파 테스트, 강의 준비, provider 연결 검증, 운영 프로세스 검토에 참여할 개발자/파워유저를 대상으로 합니다.
