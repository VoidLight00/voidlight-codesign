# M07 — security-compliance

ToS, privacy, token storage, local proxy 보안, dependency/license audit를 release gate로 관리한다.

## 책임

- VibeProxy/CLIProxyAPI ToS risk register
- official API key fallback 정책
- OAuth/API token 저장 정책
- local proxy handshake/origin/port spoofing 검증
- telemetry/crash/log privacy audit
- dependency/font/license notice audit

## v0.1-ko-alpha 기준

- VibeProxy는 experimental 경로로 표기
- 상업/대규모 사용 전 provider ToS 확인 안내
- token 평문 저장 금지 원칙 명시
