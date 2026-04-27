# Local Proxy Security

## 위험

`127.0.0.1:8318`에 응답하는 프로세스가 항상 VibeProxy/CLIProxyAPI라고 가정하면 port spoofing 위험이 있다.

## 요구 사항

- `/v1/models` 응답만으로 신뢰하지 않는다.
- expected protocol/version/header/shape를 확인한다.
- CORS/origin 정책을 확인한다.
- 악성 웹페이지가 localhost endpoint를 호출할 수 있는지 검토한다.
- provider request payload에 secret이 섞이는지 확인한다.

## 실패 시 UX

- "VibeProxy로 보이는 로컬 서비스가 확인되었지만 신뢰 검증에 실패했습니다."
- official API key fallback CTA 제공
