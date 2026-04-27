# M02 — provider-bridge

Standard path는 official API key이고, VibeProxy/CLIProxyAPI는 advanced experimental path다.

VibeProxy/CLIProxyAPI와 official API key fallback을 함께 다루는 provider 연결 모듈이다.

## 원칙

- VibeProxy는 experimental/guided path로 표기한다.
- official API key fallback을 first-class path로 유지한다.
- 단순 포트 감지가 아니라 expected protocol/handshake를 검증한다.
- 실패 시 한국어 오류와 대안 경로를 제공한다.
