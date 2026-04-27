# M04 — distribution-ko

한국어 빌드의 앱 메타데이터, 브랜딩, update channel, 코드사이닝/notarization, NOTICE/About 표기를 소유한다.

## 원칙

- 알파 unsigned build와 v1.0 signed/notarized build 정책을 분리한다.
- upstream fork임을 숨기지 않는다.
- bundle id, app name, channel metadata를 release gate에서 검증한다.
