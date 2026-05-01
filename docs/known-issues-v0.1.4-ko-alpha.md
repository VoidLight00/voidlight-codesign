# Known Issues — v0.1.4-ko-alpha

`v0.1.4-ko-alpha`는 developer preview입니다. 아래 제약을 이해한 뒤 사용하세요.

## 배포/설치

- macOS signed/notarized build가 아닐 수 있습니다.
- OS 보안 경고가 표시될 수 있습니다.
- 자동 업데이트 정책은 아직 고정되지 않았습니다.
- Homebrew cask/installer metadata의 license/fork 표기는 v1.0 전 보강 대상입니다.

## Provider 연결

- VibeProxy는 experimental 경로입니다.
- VibeProxy 사용 방식은 provider 약관(ToS)과 충돌할 수 있습니다.
- VibeProxy 미실행, 포트 충돌, OAuth 만료 시 연결 실패가 발생할 수 있습니다.
- 상업/대규모 사용에는 official API key fallback을 우선 검토해야 합니다.
- provider별 quota/rate limit/error message는 upstream 또는 provider 정책에 따라 달라질 수 있습니다.

## 보안/개인정보

- 새 telemetry 서비스는 도입하지 않는 것을 원칙으로 하지만, upstream 기본 crash/log 동작은 계속 확인이 필요합니다.
- prompt, token, account email이 log에 남지 않는지 release마다 점검해야 합니다.
- token storage는 평문 저장 금지 원칙을 따르며, 플랫폼별 secure storage 검증은 v1.0 전 계속 강화합니다.

## 한국어/i18n

- 핵심 화면 중심의 한국어 알파이며 전체 UI 100% 번역은 아닙니다.
- 일부 upstream 문자열은 영문으로 남아 있을 수 있습니다.
- 긴 한국어 문구에서 레이아웃 줄바꿈 문제가 발생할 수 있습니다.
- Electron/OS 버전에 따라 한글 IME composition 회귀가 발생할 수 있습니다.
- PDF/PPTX export의 한글 폰트 포함은 추가 검증이 필요합니다.

## Upstream/patch 운영

- patch queue는 quilt-style로 관리되며, upstream 변경과 충돌할 수 있습니다.
- sync 자동화는 PR 생성까지만 허용하고 자동 merge하지 않습니다.
- release freeze 중 upstream 기능 추가는 기본적으로 다음 릴리스로 미룹니다.
- patch count가 증가하면 v1.0 전 patch diet가 필요할 수 있습니다.

## 권장 피드백

이슈를 남길 때 다음 정보를 포함해 주세요.

- OS와 버전
- 설치 방식
- provider 연결 방식: VibeProxy 또는 official API key
- 재현 단계
- 로그가 있다면 token/API key/account email/prompt를 제거한 뒤 첨부
