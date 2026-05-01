# macOS 서명 및 공증 준비 체크리스트

VoidLight CoDesign 한국어 배포는 **알파 unsigned/dev build**와 **v1.0 signed/notarized build**를 명확히 분리한다. 알파 사용자는 위험을 이해한 테스터를 대상으로 하며, v1.0 전에는 서명·공증 또는 동등한 신뢰 정책을 반드시 확정한다.

## 현재 배포 원칙

| 구분 | 정책 |
|---|---|
| v0.1.4-ko-alpha | unsigned/dev build 허용, Gatekeeper 경고 명시 |
| v1.0 | signed/notarized build 또는 동등한 배포 신뢰 정책 필요 |
| VibeProxy | experimental 연결 경로로 표기 |
| official API key | first-class fallback 및 기본 권장 경로 |
| 라이선스 | Open CoDesign by OpenCoworkAI, MIT credit 유지 |

## 알파 배포 문구

알파 빌드는 다음 내용을 릴리스 노트와 설치 문서 첫 화면에 표시한다.

> 이 빌드는 개발자 프리뷰이며 macOS 서명 및 공증이 완료되지 않았을 수 있습니다. 신뢰할 수 있는 테스트 환경에서만 실행하세요. provider 연결은 official API key 방식을 우선 권장하며, VibeProxy/CLIProxyAPI는 약관 및 계정 정책 리스크가 있는 experimental 경로입니다.

## v1.0 전 필수 체크리스트

- [ ] Apple Developer Program 계정 소유자와 책임자 확정
- [ ] bundle id 확정: `ai.voidlight.codesign` 계열 사용 여부 검토
- [ ] 앱 표시명 확정: `VoidLight CoDesign` / `VoidLight 코디자인`
- [ ] hardened runtime 활성화 여부 확인
- [ ] entitlement 목록 최소화
- [ ] notarization 제출 및 stapling 절차 문서화
- [ ] DMG 또는 ZIP 배포 포맷 결정
- [ ] Homebrew Cask에서 signed/notarized 상태 표기
- [ ] NOTICE/About에 fork·MIT·폰트·VibeProxy 비번들 고지 유지
- [ ] crash/log/telemetry에 prompt, token, account email이 포함되지 않는지 확인

## 금지 사항

- 인증서, API key, app-specific password를 저장소에 커밋하지 않는다.
- 자동화가 main 브랜치에 직접 push하거나 릴리스를 자동 승격하지 않는다.
- VibeProxy를 공식 provider 인증 방식처럼 표현하지 않는다.
- unsigned alpha용 격리 해제 안내를 v1.0 신뢰 정책으로 포장하지 않는다.

## 릴리스 게이트

v1.0 릴리스 후보는 다음 조건을 만족해야 한다.

1. macOS 서명 및 공증 검증 로그 확보
2. official API key fallback 경로 재현
3. VibeProxy experimental 및 ToS warning 노출 확인
4. update channel metadata와 앱 bundle metadata 일치
5. `NOTICE`와 About 표기 검토 완료
6. patch queue 검증 및 security 검증 통과

## 알파 산출물 준비 메모

실제 공개 배포 전에는 다음 순서를 별도로 수행한다.

1. `generated-app` 기준 빌드 산출물 생성
2. DMG 또는 ZIP 중 실제 배포 포맷 확정
3. `shasum -a 256 <artifact>` 로 SHA256 산출
4. GitHub Release asset 업로드
5. Homebrew Cask `url`/`sha256` 고정
6. 설치 가이드와 release notes의 artifact 이름 일치 확인

## 적용 후 검증

```bash
bash scripts/verify-patches.sh
bash scripts/verify-security.sh
```
