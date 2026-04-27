# ToS Risk Register

## VibeProxy / CLIProxyAPI

VibeProxy 경로는 사용자가 이미 로그인한 provider 구독 세션을 로컬 proxy로 사용하는 방식일 수 있으며, provider 약관(ToS)과 충돌할 수 있다.

## 정책

- VibeProxy를 공식 provider 지원 경로로 표현하지 않는다.
- README, provider guide, 첫 실행 UI에 warning을 둔다.
- official API key fallback을 동등한 선택지로 제공한다.
- 상업 배포·대규모 사용 전 각 provider 약관 확인을 요구한다.

## 금지 문구

- "Claude Pro를 API처럼 무료로 사용"
- "ChatGPT Plus로 무제한 자동화"
- "공식 지원"

## 허용 문구

- "로컬 VibeProxy와 호환되는 experimental 연결"
- "개인 학습·시연용으로 검증"
- "약관 및 계정 리스크는 사용자가 확인 필요"
